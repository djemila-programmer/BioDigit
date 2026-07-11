"""
BioDigit — Intelligent Anomaly Detection Service
=================================================
Cloud-based ML service for biodigester monitoring.
Uses Z-score, Isolation Forest, and Linear Regression Trend Analysis
to detect anomalies in real-time sensor data.

Deploy: Railway / Render / any Python host
Schedule: runs every 5 minutes
"""

import os
import time
import logging
import numpy as np
from datetime import datetime, timedelta, timezone
from dotenv import load_dotenv
from supabase import create_client, Client
from sklearn.ensemble import IsolationForest
from sklearn.preprocessing import StandardScaler

# ─────────────────────────────────────────────
# Configuration
# ─────────────────────────────────────────────

from pathlib import Path
dotenv_path = Path(__file__).parent / ".env"
load_dotenv(dotenv_path)

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_SERVICE_KEY = os.getenv("SUPABASE_SERVICE_KEY")

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger("biodigit_ml")

# Detection parameters
ZSCORE_THRESHOLD = 2.5          # values beyond 2.5 std deviations = anomaly
ISOLATION_FOREST_CONTAMINATION = 0.10  # expected 10% anomaly rate
TREND_WINDOW_HOURS = 24         # window for trend analysis
MIN_SAMPLES_FOR_ML = 30         # minimum data points before ML runs
CHECK_INTERVAL_SECONDS = 300    # 5 minutes

SENSOR_FIELDS = ["temperature", "pressure", "methane", "slurry_level"]

SEVERITY_RULES = {
    "temperature": {"low": 25.0, "high": 40.0, "unit": "°C"},
    "pressure":    {"low": 0.8,  "high": 1.5,  "unit": "bar"},
    "methane":     {"low": 150.0, "high": 500.0, "unit": "ppm"},
    "slurry_level":{"low": 20.0,  "high": 90.0,  "unit": "%"},
}


# ─────────────────────────────────────────────
# Supabase connection
# ─────────────────────────────────────────────

def get_supabase() -> Client:
    if not SUPABASE_URL or not SUPABASE_SERVICE_KEY:
        raise RuntimeError(
            "Missing SUPABASE_URL or SUPABASE_SERVICE_KEY in environment. "
            "Create a .env file with your Supabase service role key."
        )
    return create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)


# ─────────────────────────────────────────────
# Data loading
# ─────────────────────────────────────────────

def fetch_recent_readings(supabase: Client, hours: int = 24) -> list[dict]:
    """Fetch sensor readings from the last N hours."""
    cutoff = (datetime.now(timezone.utc) - timedelta(hours=hours)).isoformat()
    response = (
        supabase.table("sensor_readings")
        .select("id, user_id, temperature, pressure, methane, slurry_level, created_at")
        .gte("created_at", cutoff)
        .order("created_at", desc=False)
        .execute()
    )
    return response.data


# ─────────────────────────────────────────────
# 1. Z-SCORE ANOMALY DETECTION
# ─────────────────────────────────────────────

def detect_zscore_anomalies(readings: list[dict]) -> list[dict]:
    """
    Detect point anomalies using the Z-score method.
    A reading is flagged when its value deviates more than
    ZSCORE_THRESHOLD standard deviations from the mean.
    """
    if len(readings) < MIN_SAMPLES_FOR_ML:
        logger.info(f"Z-score: only {len(readings)} samples, need {MIN_SAMPLES_FOR_ML}. Skipping.")
        return []

    anomalies = []
    scaler = StandardScaler()

    for field in SENSOR_FIELDS:
        values = np.array([r[field] for r in readings if r[field] is not None]).reshape(-1, 1)
        if len(values) < MIN_SAMPLES_FOR_ML:
            continue

        scaler.fit(values)
        z_scores = scaler.transform(values).flatten()

        for i, z in enumerate(z_scores):
            if abs(z) > ZSCORE_THRESHOLD:
                reading = readings[i]
                anomalies.append({
                    "anomaly_type": f"zscore_{field}",
                    "severity": _severity_from_z(abs(z)),
                    "confidence": round(min(abs(z) / 4.0, 1.0), 3),
                    "description": (
                        f"Z-score anomaly on {field}: value={reading[field]}, "
                        f"z={z:.2f} (threshold=±{ZSCORE_THRESHOLD})"
                    ),
                    "sensor_data": {
                        field: reading[field],
                        "z_score": round(z, 3),
                        "timestamp": reading["created_at"],
                    },
                    "user_id": reading.get("user_id"),
                    "reading_id": reading["id"],
                })

    logger.info(f"Z-score detection: {len(anomalies)} anomalies found.")
    return anomalies


def _severity_from_z(z_abs: float) -> str:
    if z_abs > 3.5:
        return "critical"
    elif z_abs > 3.0:
        return "high"
    elif z_abs > ZSCORE_THRESHOLD:
        return "medium"
    return "low"


# ─────────────────────────────────────────────
# 2. ISOLATION FOREST ANOMALY DETECTION
# ─────────────────────────────────────────────

def detect_isolation_forest_anomalies(readings: list[dict]) -> list[dict]:
    """
    Detect multivariate pattern anomalies using Isolation Forest.
    This model learns the normal correlation structure between
    temperature, pressure, methane, and slurry_level, and flags
    readings that deviate from this learned pattern.
    """
    if len(readings) < MIN_SAMPLES_FOR_ML:
        logger.info(f"Isolation Forest: only {len(readings)} samples. Skipping.")
        return []

    # Build feature matrix
    valid_readings = [
        r for r in readings
        if all(r.get(f) is not None for f in SENSOR_FIELDS)
    ]
    if len(valid_readings) < MIN_SAMPLES_FOR_ML:
        return []

    X = np.array([[r[f] for f in SENSOR_FIELDS] for r in valid_readings])

    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)

    model = IsolationForest(
        n_estimators=100,
        contamination=ISOLATION_FOREST_CONTAMINATION,
        random_state=42,
    )
    predictions = model.fit_predict(X_scaled)
    scores = model.score_samples(X_scaled)

    anomalies = []
    for i, (pred, score) in enumerate(zip(predictions, scores)):
        if pred == -1:  # anomaly
            reading = valid_readings[i]
            anomalies.append({
                "anomaly_type": "isolation_forest_multivariate",
                "severity": _severity_from_if_score(score),
                "confidence": round(min(abs(score) / 0.5, 1.0), 3),
                "description": (
                    f"Isolation Forest anomaly (multivariate pattern): "
                    f"score={score:.4f}. "
                    f"Values: temp={reading['temperature']}, "
                    f"pressure={reading['pressure']}, "
                    f"methane={reading['methane']}, "
                    f"level={reading['slurry_level']}"
                ),
                "sensor_data": {f: reading[f] for f in SENSOR_FIELDS} | {
                    "if_score": round(score, 4),
                    "timestamp": reading["created_at"],
                },
                "user_id": reading.get("user_id"),
                "reading_id": reading["id"],
            })

    logger.info(f"Isolation Forest detection: {len(anomalies)} anomalies found.")
    return anomalies


def _severity_from_if_score(score: float) -> str:
    # score is negative; more negative = more anomalous
    if score < -0.3:
        return "critical"
    elif score < -0.2:
        return "high"
    elif score < -0.1:
        return "medium"
    return "low"


# ─────────────────────────────────────────────
# 3. LINEAR REGRESSION TREND ANALYSIS
# ─────────────────────────────────────────────

def detect_trend_anomalies(readings: list[dict]) -> list[dict]:
    """
    Detect gradual degradation using linear regression on a
    sliding window. If the trend slope indicates a parameter
    is heading toward a threshold breach within 6 hours,
    a predictive alert is raised.
    """
    if len(readings) < MIN_SAMPLES_FOR_ML:
        logger.info(f"Trend analysis: only {len(readings)} samples. Skipping.")
        return []

    anomalies = []

    for field in SENSOR_FIELDS:
        values = [r[field] for r in readings if r[field] is not None]
        if len(values) < MIN_SAMPLES_FOR_ML:
            continue

        y = np.array(values)
        x = np.arange(len(y)).reshape(-1, 1)

        # Simple linear regression: y = slope * x + intercept
        slope = np.polyfit(x.flatten(), y, 1)[0]

        # Current value and projected value in 6h (72 intervals of 5min)
        current = y[-1]
        projected_6h = current + slope * 72

        threshold_high = SEVERITY_RULES[field]["high"]
        threshold_low = SEVERITY_RULES[field]["low"]

        # Check if trend will breach thresholds
        will_breach_high = projected_6h > threshold_high and current <= threshold_high
        will_breach_low = projected_6h < threshold_low and current >= threshold_low

        if will_breach_high or will_breach_low:
            direction = "upward" if will_breach_high else "downward"
            breach_val = threshold_high if will_breach_high else threshold_low
            anomalies.append({
                "anomaly_type": f"trend_{field}",
                "severity": "high" if abs(slope) > 0.5 else "medium",
                "confidence": round(min(abs(slope) * 10, 1.0), 3),
                "description": (
                    f"Predictive trend anomaly on {field}: "
                    f"current={current}, slope={slope:.4f}/interval, "
                    f"projected in 6h={projected_6h:.2f}, "
                    f"threshold={breach_val} ({direction} trend)"
                ),
                "sensor_data": {
                    field: current,
                    "slope": round(slope, 6),
                    "projected_6h": round(projected_6h, 2),
                    "threshold": breach_val,
                },
                "user_id": readings[-1].get("user_id"),
                "reading_id": readings[-1]["id"],
            })

    logger.info(f"Trend analysis: {len(anomalies)} predictive anomalies found.")
    return anomalies


# ─────────────────────────────────────────────
# Alert insertion
# ─────────────────────────────────────────────

def insert_anomalies(supabase: Client, anomalies: list[dict]) -> None:
    """Insert detected anomalies into anomaly_history and alerts tables."""
    for anomaly in anomalies:
        # Insert into anomaly_history
        supabase.table("anomaly_history").insert({
            "user_id": anomaly["user_id"],
            "anomaly_type": anomaly["anomaly_type"],
            "severity": anomaly["severity"],
            "description": anomaly["description"],
            "confidence": anomaly["confidence"],
            "sensor_data": anomaly["sensor_data"],
        }).execute()

        # Insert corresponding alert
        title = _alert_title(anomaly["anomaly_type"])
        supabase.table("alerts").insert({
            "user_id": anomaly["user_id"],
            "title": title,
            "description": anomaly["description"],
            "severity": anomaly["severity"],
            "sensor_id": anomaly["anomaly_type"].replace("zscore_", "").replace("trend_", ""),
        }).execute()

    if anomalies:
        logger.info(f"Inserted {len(anomalies)} anomalies into Supabase.")


def _alert_title(anomaly_type: str) -> str:
    titles = {
        "zscore_temperature":       "Abnormal Temperature Detected",
        "zscore_pressure":          "Abnormal Pressure Detected",
        "zscore_methane":           "Abnormal Methane Level Detected",
        "zscore_slurry_level":      "Abnormal Slurry Level Detected",
        "isolation_forest_multivariate": "Multivariate Pattern Anomaly Detected",
        "trend_temperature":        "Temperature Trend: Threshold Breach Imminent",
        "trend_pressure":           "Pressure Trend: Threshold Breach Imminent",
        "trend_methane":            "Methane Trend: Threshold Breach Imminent",
        "trend_slurry_level":       "Slurry Level Trend: Threshold Breach Imminent",
    }
    return titles.get(anomaly_type, "Anomaly Detected")


# ─────────────────────────────────────────────
# Main loop
# ─────────────────────────────────────────────

def run_detection_cycle(supabase: Client) -> None:
    """Run one full detection cycle."""
    logger.info("Starting detection cycle...")

    readings = fetch_recent_readings(supabase, hours=TREND_WINDOW_HOURS)
    logger.info(f"Fetched {len(readings)} readings from last {TREND_WINDOW_HOURS}h.")

    if len(readings) < MIN_SAMPLES_FOR_ML:
        logger.warning(
            f"Not enough data ({len(readings)}/{MIN_SAMPLES_FOR_ML}). "
            f"ML models need more historical data. Waiting..."
        )
        return

    # Run all three detection algorithms
    zscore_anomalies = detect_zscore_anomalies(readings)
    iforest_anomalies = detect_isolation_forest_anomalies(readings)
    trend_anomalies = detect_trend_anomalies(readings)

    # Merge and deduplicate (by reading_id + anomaly_type)
    all_anomalies = zscore_anomalies + iforest_anomalies + trend_anomalies
    seen = set()
    unique_anomalies = []
    for a in all_anomalies:
        key = (a.get("reading_id"), a["anomaly_type"])
        if key not in seen:
            seen.add(key)
            unique_anomalies.append(a)

    logger.info(
        f"Total unique anomalies: {len(unique_anomalies)} "
        f"(Z-score: {len(zscore_anomalies)}, "
        f"IF: {len(iforest_anomalies)}, "
        f"Trend: {len(trend_anomalies)})"
    )

    if unique_anomalies:
        insert_anomalies(supabase, unique_anomalies)
    else:
        logger.info("No anomalies detected this cycle.")

    logger.info("Detection cycle complete.")


def main():
    logger.info("BioDigit ML Service starting...")
    logger.info(f"Algorithms: Z-score (threshold={ZSCORE_THRESHOLD}), "
                f"Isolation Forest (contamination={ISOLATION_FOREST_CONTAMINATION}), "
                f"Linear Regression Trend (window={TREND_WINDOW_HOURS}h)")

    supabase = get_supabase()

    while True:
        try:
            run_detection_cycle(supabase)
        except Exception as e:
            logger.error(f"Detection cycle failed: {e}", exc_info=True)

        logger.info(f"Sleeping {CHECK_INTERVAL_SECONDS}s until next cycle...")
        time.sleep(CHECK_INTERVAL_SECONDS)


if __name__ == "__main__":
    main()
