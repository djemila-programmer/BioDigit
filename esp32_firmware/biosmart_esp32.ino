/*
 * BioSmart ESP32 Firmware v2.4.1-bf
 * Biodigester IoT Monitoring System
 * 
 * Sensors:
 *   - DS18B20 (Temperature)
 *   - BMP280  (Pressure + Altitude)
 *   - MQ-4    (Methane Gas CH4)
 *   - HC-SR04 (Ultrasonic Slurry Level)
 * 
 * Sends real-time data to Firebase Realtime Database.
 * Designed for Burkina Faso biodigester monitoring.
 * 
 * Libraries required:
 *   - WiFi.h
 *   - Firebase_ESP_Client.h
 *   - OneWire.h
 *   - DallasTemperature.h
 *   - Adafruit_BMP280.h
 *   - ArduinoJson.h
 */

#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <Adafruit_BMP280.h>
#include <ArduinoJson.h>

// ─── Configuration ────────────────────────────────────────────────────────

#define WIFI_SSID       "YOUR_WIFI_SSID"
#define WIFI_PASSWORD   "YOUR_WIFI_PASSWORD"

#define FIREBASE_HOST   "your-project-default-rtdb.firebaseio.com"
#define FIREBASE_API_KEY "YOUR_FIREBASE_API_KEY"
#define FIREBASE_USER_EMAIL "YOUR_ESP32_DEVICE_EMAIL"
#define FIREBASE_USER_PASSWORD "YOUR_ESP32_DEVICE_PASSWORD"

// ─── Pin Definitions ──────────────────────────────────────────────────────

#define DS18B20_PIN     4    // Temperature sensor data pin
#define BMP280_SDA      21   // I2C SDA
#define BMP280_SCL      22   // I2C SCL
#define MQ4_ANALOG      34   // MQ-4 analog output
#define HC_TRIG_PIN     12   // HC-SR04 trigger
#define HC_ECHO_PIN     13   // HC-SR04 echo
#define LED_STATUS      2    // Built-in LED

// ─── Sensor Objects ───────────────────────────────────────────────────────

OneWire oneWire(DS18B20_PIN);
DallasTemperature ds18b20(&oneWire);
Adafruit_BMP280 bmp280;

// ─── Firebase Objects ─────────────────────────────────────────────────────

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// ─── Timing ───────────────────────────────────────────────────────────────

unsigned long lastSend = 0;
const unsigned long SEND_INTERVAL = 5000; // 5 seconds

unsigned long lastWifiCheck = 0;
const unsigned long WIFI_CHECK_INTERVAL = 30000; // 30 seconds

unsigned long startTime = 0;

// ─── Threshold Constants ──────────────────────────────────────────────────

const float TEMP_MIN = 25.0;
const float TEMP_MAX = 40.0;
const float PRESSURE_MIN = 0.8;
const float PRESSURE_MAX = 1.5;
const float METHANE_MIN = 150.0;
const float METHANE_MAX = 500.0;
const float SLURRY_MIN = 20.0;
const float SLURRY_MAX = 90.0;
const float TANK_HEIGHT_CM = 200.0; // Total tank height in cm

// ─── Previous Values for Trend Detection ──────────────────────────────────

float prevTemp = 0;
float prevPressure = 0;
float prevMethane = 0;
float prevSlurry = 0;

// ─── Setup ────────────────────────────────────────────────────────────────

void setup() {
  Serial.begin(115200);
  Serial.println("\n=== BioSmart ESP32 v2.4.1-bf ===");
  Serial.println("Biodigester Monitoring System");
  Serial.println("Plateau Central, Burkina Faso\n");

  startTime = millis();
  pinMode(LED_STATUS, OUTPUT);
  pinMode(HC_TRIG_PIN, OUTPUT);
  pinMode(HC_ECHO_PIN, INPUT);

  // Connect to WiFi
  connectWiFi();

  // Initialize sensors
  initSensors();

  // Configure Firebase
  configFirebase();

  Serial.println("System ready. Sending data every 5 seconds.\n");
}

// ─── Main Loop ────────────────────────────────────────────────────────────

void loop() {
  unsigned long now = millis();

  // Check WiFi periodically
  if (now - lastWifiCheck > WIFI_CHECK_INTERVAL) {
    if (WiFi.status() != WL_CONNECTED) {
      Serial.println("WiFi lost! Reconnecting...");
      connectWiFi();
    }
    lastWifiCheck = now;
  }

  // Send sensor data
  if (now - lastSend > SEND_INTERVAL) {
    readAndSendData();
    lastSend = now;
  }

  delay(100);
}

// ─── WiFi Connection ──────────────────────────────────────────────────────

void connectWiFi() {
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi");
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 30) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nWiFi Connected!");
    Serial.print("IP: ");
    Serial.println(WiFi.localIP());
    Serial.print("Signal: ");
    Serial.print(WiFi.RSSI());
    Serial.println(" dBm");
    digitalWrite(LED_STATUS, HIGH);
  } else {
    Serial.println("\nWiFi connection failed!");
    digitalWrite(LED_STATUS, LOW);
  }
}

// ─── Sensor Initialization ───────────────────────────────────────────────

void initSensors() {
  // DS18B20
  ds18b20.begin();
  Serial.println("DS18B20 Temperature sensor initialized.");

  // BMP280
  Wire.begin(BMP280_SDA, BMP280_SCL);
  if (!bmp280.begin(0x76)) {
    Serial.println("BMP280 not found! Check wiring.");
  } else {
    Serial.println("BMP280 Pressure sensor initialized.");
    bmp280.setSampling(Adafruit_BMP280::MODE_NORMAL,
                       Adafruit_BMP280::SAMPLING_X2,
                       Adafruit_BMP280::SAMPLING_X16,
                       Adafruit_BMP280::FILTER_X16,
                       Adafruit_BMP280::STANDBY_MS_500);
  }

  // MQ-4 is analog, no init needed
  Serial.println("MQ-4 Methane sensor initialized (analog pin 34).");

  // HC-SR04
  Serial.println("HC-SR04 Ultrasonic sensor initialized.");
}

// ─── Firebase Configuration ──────────────────────────────────────────────

void configFirebase() {
  config.api_key = FIREBASE_API_KEY;
  config.database_url = "https://" FIREBASE_HOST;

  auth.user.email = FIREBASE_USER_EMAIL;
  auth.user.password = FIREBASE_USER_PASSWORD;

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  Serial.println("Firebase configured. Authenticating...");
}

// ─── Read All Sensors and Send to Firebase ────────────────────────────────

void readAndSendData() {
  // Read temperature
  ds18b20.requestTemperatures();
  float temperature = ds18b20.getTempCByIndex(0);
  if (temperature == DEVICE_DISCONNECTED_C) {
    temperature = -999; // Error value
    Serial.println("DS18B20 disconnected!");
  }

  // Read pressure (convert Pa to bar)
  float pressure = bmp280.readPressure() / 100000.0;

  // Read methane (MQ-4 analog 0-4095 mapped to 0-1000 ppm)
  int mq4Raw = analogRead(MQ4_ANALOG);
  float methane = map(mq4Raw, 0, 4095, 0, 1000);

  // Read slurry level (HC-SR04 ultrasonic)
  float slurryLevel = readUltrasonicLevel();

  // Detect trends
  String tempTrend = detectTrend(temperature, prevTemp);
  String pressTrend = detectTrend(pressure, prevPressure);
  String methaneTrend = detectTrend(methane, prevMethane);
  String slurryTrend = detectTrend(slurryLevel, prevSlurry);

  // Store previous values
  prevTemp = temperature;
  prevPressure = pressure;
  prevMethane = methane;
  prevSlurry = slurryLevel;

  // Build JSON payload
  JsonDocument doc;
  doc["temperature"]["value"] = temperature;
  doc["temperature"]["unit"] = "°C";
  doc["temperature"]["sensor"] = "DS18B20";
  doc["temperature"]["status"] = (temperature >= TEMP_MIN && temperature <= TEMP_MAX) ? "Normal" : "Alert";
  
  doc["pressure"]["value"] = pressure;
  doc["pressure"]["unit"] = "bar";
  doc["pressure"]["sensor"] = "BMP280";
  doc["pressure"]["status"] = (pressure >= PRESSURE_MIN && pressure <= PRESSURE_MAX) ? "Normal" : "Alert";
  
  doc["methane"]["value"] = methane;
  doc["methane"]["unit"] = "ppm";
  doc["methane"]["sensor"] = "MQ-4";
  doc["methane"]["status"] = (methane >= METHANE_MIN && methane <= METHANE_MAX) ? "Normal" : "Alert";
  
  doc["slurryLevel"]["value"] = slurryLevel;
  doc["slurryLevel"]["unit"] = "%";
  doc["slurryLevel"]["sensor"] = "HC-SR04";
  doc["slurryLevel"]["status"] = (slurryLevel >= SLURRY_MIN && slurryLevel <= SLURRY_MAX) ? "Normal" : "Alert";

  doc["temperatureTrend"] = tempTrend;
  doc["pressureTrend"] = pressTrend;
  doc["methaneTrend"] = methaneTrend;
  doc["slurryTrend"] = slurryTrend;
  doc["timestamp"] = getTimestamp();

  // Send sensor data to Firebase RTDB
  String jsonStr;
  serializeJson(doc, jsonStr);

  if (Firebase.RTDB.setJSON(&fbdo, "/sensors", &doc)) {
    Serial.println("Sensor data sent successfully.");
  } else {
    Serial.print("Firebase send error: ");
    Serial.println(fbdo.errorReason());
  }

  // Update ESP32 status
  updateESP32Status();

  // Print readings
  Serial.printf("T: %.1f°C | P: %.3f bar | CH4: %.0f ppm | Level: %.1f%%\n",
                temperature, pressure, methane, slurryLevel);
}

// ─── Ultrasonic Level Reading ─────────────────────────────────────────────

float readUltrasonicLevel() {
  digitalWrite(HC_TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(HC_TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(HC_TRIG_PIN, LOW);

  long duration = pulseIn(HC_ECHO_PIN, HIGH, 30000); // 30ms timeout
  if (duration == 0) return -1; // Timeout

  float distanceCm = duration * 0.034 / 2.0;
  
  // Convert distance to percentage (full tank = 0cm, empty = TANK_HEIGHT cm)
  float levelPercent = ((TANK_HEIGHT_CM - distanceCm) / TANK_HEIGHT_CM) * 100.0;
  return constrain(levelPercent, 0, 100);
}

// ─── Trend Detection ─────────────────────────────────────────────────────

String detectTrend(float current, float previous) {
  if (previous == 0) return "stable";
  float diff = current - previous;
  if (diff > 0.5) return "rising";
  if (diff < -0.5) return "falling";
  return "stable";
}

// ─── ESP32 Status Update ──────────────────────────────────────────────────

void updateESP32Status() {
  JsonDocument espDoc;
  espDoc["connected"] = WiFi.status() == WL_CONNECTED;
  espDoc["wifiSignal"] = WiFi.RSSI();
  espDoc["firmwareVersion"] = "v2.4.1-bf";
  espDoc["batteryLevel"] = readBatteryLevel();
  espDoc["ipAddress"] = WiFi.localIP().toString();
  espDoc["lastSync"] = getTimestamp();
  espDoc["cpuTemp"] = temperatureRead(); // ESP32 internal temp
  espDoc["uptime"] = formatUptime(millis() - startTime);

  Firebase.RTDB.setJSON(&fbdo, "/esp32", &espDoc);
}

// ─── Battery Level (ADC) ──────────────────────────────────────────────────

int readBatteryLevel() {
  int adc = analogRead(35); // Battery voltage divider on GPIO 35
  float voltage = (adc / 4095.0) * 3.3 * 2.0; // Voltage divider factor
  int percent = map((int)(voltage * 100), 300, 420, 0, 100);
  return constrain(percent, 0, 100);
}

// ─── Utility Functions ────────────────────────────────────────────────────

String getTimestamp() {
  // Use NTP time if available, otherwise use millis
  struct tm timeinfo;
  if (getLocalTime(&timeinfo)) {
    char buf[30];
    strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%S", &timeinfo);
    return String(buf);
  }
  return String(millis());
}

String formatUptime(unsigned long ms) {
  unsigned long seconds = ms / 1000;
  unsigned long minutes = seconds / 60;
  unsigned long hours = minutes / 60;
  unsigned long days = hours / 24;
  char buf[30];
  sprintf(buf, "%lud %luh %lum", days, hours % 24, minutes % 60);
  return String(buf);
}
