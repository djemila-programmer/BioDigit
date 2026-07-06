/*
 * BioDigit - ESP32 Sensor Firmware
 * ==================================
 * Envoie les données capteurs à Supabase en temps réel.
 * 
 * Capteurs connectés :
 * - DS18B20  → Température (GPIO 4)
 * - BMP280   → Pression (I2C: SDA=21, SCL=22)
 * - MQ-4     → Méthane CH4 (GPIO 34 - ADC)
 * - HC-SR04  → Niveau bouillie (Trig=5, Echo=18)
 * 
 * Flux : ESP32 → WiFi → HTTP POST → Supabase → App Flutter (Realtime)
 */

#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <Wire.h>
#include <Adafruit_BMP280.h>

// ═══════════════════════════════════════════════════════════════
// CONFIGURATION - MODIFIER CES VALEURS
// ═══════════════════════════════════════════════════════════════

// WiFi
const char* WIFI_SSID     = "VOTRE_WIFI";        // Nom du réseau WiFi
const char* WIFI_PASSWORD  = "VOTRE_MOT_DE_PASSE"; // Mot de passe WiFi

// Supabase
const char* SUPABASE_URL   = "https://VOTRE-PROJET.supabase.co";
const char* SUPABASE_ANON_KEY = "VOTRE_CLE_ANON_SUPABASE";
const char* USER_ID        = "UUID_UTILISATEUR";  // UUID du profil dans Supabase

// Intervalle d'envoi (secondes)
const int SEND_INTERVAL = 5;

// ═══════════════════════════════════════════════════════════════
// BROCHES (PINS)
// ═══════════════════════════════════════════════════════════════

// DS18B20 - Température
#define ONE_WIRE_BUS 4
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature tempSensor(&oneWire);

// BMP280 - Pression (I2C)
#define SDA_PIN 21
#define SCL_PIN 22
Adafruit_BMP280 bmpSensor;

// MQ-4 - Méthane (analogique)
#define MQ4_PIN 34

// HC-SR04 - Ultrason (niveau)
#define TRIG_PIN 5
#define ECHO_PIN 18

// ═══════════════════════════════════════════════════════════════
// VARIABLES GLOBALES
// ═══════════════════════════════════════════════════════════════

unsigned long lastSendTime = 0;
int wifiRetryCount = 0;

// Tendances (calculées par comparaison avec la lecture précédente)
double prevTemp = 0, prevPressure = 0, prevMethane = 0, prevLevel = 0;

// ═══════════════════════════════════════════════════════════════
// SETUP
// ═══════════════════════════════════════════════════════════════

void setup() {
  Serial.begin(115200);
  Serial.println("\n=== BioDigit ESP32 ===");
  
  // Configuration des broches
  pinMode(MQ4_PIN, INPUT);
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  
  // Initialisation DS18B20
  tempSensor.begin();
  Serial.println("[OK] DS18B20 initialise");
  
  // Initialisation BMP280
  Wire.begin(SDA_PIN, SCL_PIN);
  if (bmpSensor.begin(0x76)) {
    Serial.println("[OK] BMP280 initialise");
  } else {
    Serial.println("[ERREUR] BMP280 non trouve - verifier le cablage");
  }
  
  // Connexion WiFi
  connectWiFi();
}

// ═══════════════════════════════════════════════════════════════
// LOOP PRINCIPALE
// ═══════════════════════════════════════════════════════════════

void loop() {
  // Vérifier WiFi
  if (WiFi.status() != WL_CONNECTED) {
    connectWiFi();
  }
  
  // Envoyer les données à l'intervalle défini
  if (millis() - lastSendTime >= SEND_INTERVAL * 1000) {
    lastSendTime = millis();
    
    // Lire tous les capteurs
    double temperature = readTemperature();
    double pressure = readPressure();
    double methane = readMethane();
    double slurryLevel = readSlurryLevel();
    
    // Calculer les tendances
    String tempTrend = calculateTrend(temperature, prevTemp, 0.5);
    String pressTrend = calculateTrend(pressure, prevPressure, 0.03);
    String methaneTrend = calculateTrend(methane, prevMethane, 5.0);
    String levelTrend = calculateTrend(slurryLevel, prevLevel, 1.0);
    
    // Sauvegarder pour prochaine comparaison
    prevTemp = temperature;
    prevPressure = pressure;
    prevMethane = methane;
    prevLevel = slurryLevel;
    
    // Afficher dans le moniteur série
    Serial.printf("Temp: %.1f°C | Press: %.2f bar | CH4: %.0f ppm | Niveau: %.1f%%\n",
                  temperature, pressure, methane, slurryLevel);
    
    // Envoyer à Supabase
    sendToSupabase(temperature, pressure, methane, slurryLevel,
                   tempTrend, pressTrend, methaneTrend, levelTrend);
    
    // Envoyer le statut ESP32
    sendEsp32Status();
  }
}

// ═══════════════════════════════════════════════════════════════
// LECTURE DES CAPTEURS
// ═══════════════════════════════════════════════════════════════

double readTemperature() {
  tempSensor.requestTemperatures();
  double temp = tempSensor.getTempCByIndex(0);
  if (temp < -10 || temp > 85) temp = 0;  // Valeur invalide
  return temp;
}

double readPressure() {
  float pressure = bmpSensor.readPressure();
  if (pressure < 0) return 0;
  return pressure / 100000.0;  // Pa → bar
}

double readMethane() {
  int raw = analogRead(MQ4_PIN);
  // Conversion ADC → ppm (calibration approximative MQ-4)
  // MQ-4: 200-10000 ppm, sortie 0-3.3V
  double voltage = raw * 3.3 / 4095.0;
  double ppm = voltage * 300;  // Ajuster selon calibration
  return ppm;
}

double readSlurryLevel() {
  // Mesure distance avec ultrason
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  
  long duration = pulseIn(ECHO_PIN, HIGH);
  double distance = duration * 0.034 / 2;  // cm
  
  // Conversion distance → niveau %
  // Supposer cuve de 100cm de haut
  double cuveHeight = 100.0;
  double level = ((cuveHeight - distance) / cuveHeight) * 100.0;
  
  if (level < 0) level = 0;
  if (level > 100) level = 100;
  
  return level;
}

// ═══════════════════════════════════════════════════════════════
// CALCUL DE TENDANCE
// ═══════════════════════════════════════════════════════════════

String calculateTrend(double current, double previous, double threshold) {
  if (previous == 0) return "stable";
  double diff = current - previous;
  if (diff > threshold) return "rising";
  if (diff < -threshold) return "falling";
  return "stable";
}

// ═══════════════════════════════════════════════════════════════
// ENVOI À SUPABASE
// ═══════════════════════════════════════════════════════════════

void sendToSupabase(double temp, double pressure, double methane, 
                    double level, String tempT, String pressT, 
                    String methT, String levT) {
  if (WiFi.status() != WL_CONNECTED) return;
  
  HTTPClient http;
  String url = String(SUPABASE_URL) + "/rest/v1/sensor_readings";
  
  http.begin(url);
  http.addHeader("Content-Type", "application/json");
  http.addHeader("apikey", SUPABASE_ANON_KEY);
  http.addHeader("Authorization", String("Bearer ") + SUPABASE_ANON_KEY);
  http.addHeader("Prefer", "return=minimal");
  
  // Construire le JSON
  StaticJsonDocument<512> doc;
  doc["user_id"] = USER_ID;
  doc["temperature"] = temp;
  doc["pressure"] = pressure;
  doc["methane"] = methane;
  doc["slurry_level"] = level;
  doc["temperature_trend"] = tempT;
  doc["pressure_trend"] = pressT;
  doc["methane_trend"] = methT;
  doc["slurry_trend"] = levT;
  
  String json;
  serializeJson(doc, json);
  
  int httpCode = http.POST(json);
  
  if (httpCode == 201) {
    Serial.println("  [OK] Donnees envoyees a Supabase");
  } else {
    Serial.printf("  [ERREUR] HTTP %d\n", httpCode);
  }
  
  http.end();
}

void sendEsp32Status() {
  if (WiFi.status() != WL_CONNECTED) return;
  
  HTTPClient http;
  String url = String(SUPABASE_URL) + "/rest/v1/esp32_status";
  
  http.begin(url);
  http.addHeader("Content-Type", "application/json");
  http.addHeader("apikey", SUPABASE_ANON_KEY);
  http.addHeader("Authorization", String("Bearer ") + SUPABASE_ANON_KEY);
  http.addHeader("Prefer", "return=minimal,resolution=merge-duplicates");
  
  StaticJsonDocument<512> doc;
  doc["user_id"] = USER_ID;
  doc["connected"] = true;
  doc["wifi_signal"] = WiFi.RSSI();
  doc["firmware_version"] = "v1.0.0";
  doc["battery_level"] = 100;  // Modifier si batterie
  doc["ip_address"] = WiFi.localIP().toString();
  doc["cpu_temp"] = temperatureRead();  // Température CPU ESP32
  doc["uptime"] = String(millis() / 1000);
  
  String json;
  serializeJson(doc, json);
  
  int httpCode = http.POST(json);
  http.end();
}

// ═══════════════════════════════════════════════════════════════
// CONNEXION WIFI
// ═══════════════════════════════════════════════════════════════

void connectWiFi() {
  Serial.printf("Connexion WiFi: %s", WIFI_SSID);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 30) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n[OK] WiFi connecte!");
    Serial.print("  IP: ");
    Serial.println(WiFi.localIP());
    Serial.printf("  Signal: %d dBm\n", WiFi.RSSI());
  } else {
    Serial.println("\n[ERREUR] WiFi echec");
  }
}
