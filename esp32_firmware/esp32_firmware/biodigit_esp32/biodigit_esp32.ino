/*
 * BioDigit - ESP8266 + DHT22 Sensor Firmware
 * ============================================
 * Envoie les données capteurs à Supabase en temps réel.
 * 
 * MATÉRIEL :
 * - ESP8266 (NodeMCU ou Wemos D1 Mini)
 * - DHT22    → Température + Humidité (GPIO 4 / D2)
 * - BMP280   → Pression (I2C: SDA=D2, SCL=D1)
 * - MQ-4     → Méthane CH4 (A0 avec diviseur tension)
 * - HC-SR04  → Niveau (Trig=D5, Echo=D6)
 * 
 * ⚠️ MQ-4 : branché directement sur A0 (sans diviseur pour simulation)
 *    En production, ajouter diviseur 10kΩ + 47kΩ
 * 
 * Bibliothèques Arduino IDE :
 * - ESP8266WiFi (inclus avec le board ESP8266)
 * - DHT sensor library by Adafruit
 * - Adafruit BMP280 Library
 * - ArduinoJson by Benoit Blanchon
 */

#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClient.h>
#include <ArduinoJson.h>
#include <DHT.h>
#include <Wire.h>
#include <Adafruit_BMP280.h>

// ═══════════════════════════════════════════════════════════════
// CONFIGURATION - MODIFIER CES VALEURS
// ═══════════════════════════════════════════════════════════════

// WiFi
const char* WIFI_SSID     = "Famille BAMBARA-5G";
const char* WIFI_PASSWORD  = "Blaise@2384";

// Supabase
const char* SUPABASE_URL   = "https://azhisnlnwstzasfvrlox.supabase.co";
const char* SUPABASE_ANON_KEY = "sb_publishable_iK-seWo_z_NROUrFAHTwEw_M--5pxXA";
const char* USER_ID        = "efbdcbf0-d9fc-4537-882f-80a8c951f9b2";

// Intervalle d'envoi (secondes)
const int SEND_INTERVAL = 5;

// ═══════════════════════════════════════════════════════════════
// BROCHES ESP8266 (NodeMCU)
// ═══════════════════════════════════════════════════════════════

// DHT22 - Température + Humidité
#define DHT_PIN 4       // GPIO 4 = D2 sur NodeMCU
#define DHT_TYPE DHT22
DHT dht(DHT_PIN, DHT_TYPE);

// BMP280 - Pression (I2C)
// SDA = GPIO 4 (D2), SCL = GPIO 5 (D1) - par défaut sur ESP8266
Adafruit_BMP280 bmpSensor;

// MQ-4 - Méthane (analogique, sans diviseur)
#define MQ4_PIN A0      // A0 sur ESP8266

// HC-SR04 - Ultrason (niveau)
#define TRIG_PIN 14     // GPIO 14 = D5 sur NodeMCU
#define ECHO_PIN 12     // GPIO 12 = D6 sur NodeMCU

// ═══════════════════════════════════════════════════════════════
// VARIABLES
// ═══════════════════════════════════════════════════════════════

unsigned long lastSendTime = 0;
double prevTemp = 0, prevPressure = 0, prevMethane = 0, prevLevel = 0;

// ═══════════════════════════════════════════════════════════════
// SETUP
// ═══════════════════════════════════════════════════════════════

void setup() {
  Serial.begin(115200);
  Serial.println("\n=== BioDigit ESP8266 + DHT22 ===");
  
  // Configuration des broches
  pinMode(MQ4_PIN, INPUT);
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  
  // Initialisation DHT22
  dht.begin();
  Serial.println("[OK] DHT22 initialise");
  
  // Initialisation BMP280 (I2C par défaut: SDA=D2, SCL=D1)
  if (bmpSensor.begin(0x76)) {
    Serial.println("[OK] BMP280 initialise (adresse 0x76)");
  } else if (bmpSensor.begin(0x77)) {
    Serial.println("[OK] BMP280 initialise (adresse 0x77)");
  } else {
    Serial.println("[ERREUR] BMP280 non trouve - verifier SDA/SCL");
  }
  
  // Connexion WiFi
  connectWiFi();
}

// ═══════════════════════════════════════════════════════════════
// LOOP PRINCIPALE
// ═══════════════════════════════════════════════════════════════

void loop() {
  if (WiFi.status() != WL_CONNECTED) {
    connectWiFi();
  }
  
  if (millis() - lastSendTime >= SEND_INTERVAL * 1000) {
    lastSendTime = millis();
    
    double temperature = readTemperature();
    double pressure = readPressure();
    double methane = readMethane();
    double slurryLevel = readSlurryLevel();
    
    String tempTrend = calculateTrend(temperature, prevTemp, 0.5);
    String pressTrend = calculateTrend(pressure, prevPressure, 0.03);
    String methaneTrend = calculateTrend(methane, prevMethane, 5.0);
    String levelTrend = calculateTrend(slurryLevel, prevLevel, 1.0);
    
    prevTemp = temperature;
    prevPressure = pressure;
    prevMethane = methane;
    prevLevel = slurryLevel;
    
    Serial.printf("Temp: %.1f°C | Press: %.2f bar | CH4: %.0f ppm | Niveau: %.1f%%\n",
                  temperature, pressure, methane, slurryLevel);
    
    sendToSupabase(temperature, pressure, methane, slurryLevel,
                   tempTrend, pressTrend, methaneTrend, levelTrend);
    
    sendStatus();
  }
}

// ═══════════════════════════════════════════════════════════════
// LECTURE CAPTEURS
// ═══════════════════════════════════════════════════════════════

double readTemperature() {
  float temp = dht.readTemperature();
  if (isnan(temp) || temp < -10 || temp > 60) return 0;
  return temp;
}

double readPressure() {
  float pressure = bmpSensor.readPressure();
  if (pressure < 0) return 0;
  return pressure / 100000.0;  // Pa → bar
}

double readMethane() {
  int raw = analogRead(MQ4_PIN);
  // Sans diviseur : lecture directe
  // En air libre : ~50-150 ppm
  // Avec gaz : valeur plus élevée
  double ppm = raw * 0.5;  // Calibration simple
  if (ppm < 0) ppm = 0;
  return ppm;
}

double readSlurryLevel() {
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  
  long duration = pulseIn(ECHO_PIN, HIGH, 30000);  // timeout 30ms
  if (duration == 0) return 0;
  
  double distance = duration * 0.034 / 2;  // cm
  double cuveHeight = 100.0;
  double level = ((cuveHeight - distance) / cuveHeight) * 100.0;
  
  if (level < 0) level = 0;
  if (level > 100) level = 100;
  return level;
}

// ═══════════════════════════════════════════════════════════════
// TENDANCE
// ═══════════════════════════════════════════════════════════════

String calculateTrend(double current, double previous, double threshold) {
  if (previous == 0) return "stable";
  double diff = current - previous;
  if (diff > threshold) return "rising";
  if (diff < -threshold) return "falling";
  return "stable";
}

// ═══════════════════════════════════════════════════════════════
// ENVOI SUPABASE
// ═══════════════════════════════════════════════════════════════

void sendToSupabase(double temp, double pressure, double methane, 
                    double level, String tempT, String pressT, 
                    String methT, String levT) {
  if (WiFi.status() != WL_CONNECTED) return;
  
  WiFiClient client;
  HTTPClient http;
  String url = String(SUPABASE_URL) + "/rest/v1/sensor_readings";
  
  http.begin(client, url);
  http.addHeader("Content-Type", "application/json");
  http.addHeader("apikey", SUPABASE_ANON_KEY);
  http.addHeader("Authorization", String("Bearer ") + SUPABASE_ANON_KEY);
  http.addHeader("Prefer", "return=minimal");
  
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
    Serial.println("  [OK] Envoye a Supabase");
  } else {
    Serial.printf("  [ERREUR] HTTP %d\n", httpCode);
  }
  
  http.end();
}

void sendStatus() {
  if (WiFi.status() != WL_CONNECTED) return;
  
  WiFiClient client;
  HTTPClient http;
  String url = String(SUPABASE_URL) + "/rest/v1/esp32_status";
  
  http.begin(client, url);
  http.addHeader("Content-Type", "application/json");
  http.addHeader("apikey", SUPABASE_ANON_KEY);
  http.addHeader("Authorization", String("Bearer ") + SUPABASE_ANON_KEY);
  http.addHeader("Prefer", "return=minimal,resolution=merge-duplicates");
  
  StaticJsonDocument<512> doc;
  doc["user_id"] = USER_ID;
  doc["connected"] = true;
  doc["wifi_signal"] = WiFi.RSSI();
  doc["firmware_version"] = "v1.0.0-esp8266";
  doc["battery_level"] = 100;
  doc["ip_address"] = WiFi.localIP().toString();
  doc["cpu_temp"] = 0;  // ESP8266 n'a pas de capteur temp interne
  doc["uptime"] = String(millis() / 1000);
  
  String json;
  serializeJson(doc, json);
  
  http.POST(json);
  http.end();
}

// ═══════════════════════════════════════════════════════════════
// WIFI
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
