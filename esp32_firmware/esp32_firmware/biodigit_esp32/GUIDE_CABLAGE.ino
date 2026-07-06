/*
 * GUIDE DE CABLAGE - BioDigit ESP8266 + DHT22
 * ==============================================
 * 
 * MATÉRIEL :
 * ----------
 * 1x ESP8266 (NodeMCU ou Wemos D1 Mini)
 * 1x DHT22 (capteur température + humidité)
 * 1x BMP280 (capteur pression I2C)
 * 1x MQ-4 (capteur gaz méthane)
 * 1x HC-SR04 (capteur ultrason)
 * 1x Breadboard 400+ points
 * Fils jumper mâle-mâle et mâle-femelle
 * 1x Câble USB Micro-USB
 * 
 * ALIMENTATION :
 * --------------
 * ESP8266   → 5V via USB (régulé en 3.3V interne)
 * DHT22     → 3.3V ou 5V + GND
 * BMP280    → 3.3V + GND
 * MQ-4      → 5V + GND  (ATTENTION: 5V requis!)
 * HC-SR04   → 5V + GND  (ATTENTION: 5V requis!)
 * 
 * ═══════════════════════════════════════════════════════════════
 * SCHÉMA DE CÂBLAGE - ESP8266 NodeMCU
 * ═══════════════════════════════════════════════════════════════
 * 
 * ESP8266 NodeMCU Pinout :
 * ┌─────────────────────────────────────────────────────────────┐
 * │  3V3 ──── DHT22 VCC, BMP280 VCC                            │
 * │  GND ─── Tous les GND                                      │
 * │  D1 (GPIO 5)  ── BMP280 SCL                                 │
 * │  D2 (GPIO 4)  ── DHT22 DATA, BMP280 SDA                    │
 * │  D5 (GPIO 14) ── HC-SR04 Trig                               │
 * │  D6 (GPIO 12) ── HC-SR04 Echo                               │
 *  │  A0           ── MQ-4 AOUT (direct)                      │
 * │  Vin (5V)    ── MQ-4 VCC, HC-SR04 VCC                      │
 * └─────────────────────────────────────────────────────────────┘
 * 
 * ═══════════════════════════════════════════════════════════════
 * CÂBLAGE PAR CAPTEUR
 * ═══════════════════════════════════════════════════════════════
 * 
 * ┌─────────────────────────────────────────────────────────────┐
 * │ 1. DHT22 - TEMPÉRATURE + HUMIDITÉ                           │
 * │                                                             │
 * │  DHT22          ESP8266                                     │
 * │  ─────          ───────                                      │
 * │  VCC (rouge) →  3V3 (ou Vin 5V)                             │
 * │  GND (noir)  →  GND                                         │
 * │  DATA (jaune)→  D2 (GPIO 4)                                 │
 * │                                                             │
 * │  Pas de résistance nécessaire avec le module DHT22          │
 * │  (résistance pull-up intégrée sur le module)                │
 * │                                                             │
 * └─────────────────────────────────────────────────────────────┘
 * 
 * ┌─────────────────────────────────────────────────────────────┐
 * │ 2. BMP280 - PRESSION (I2C)                                  │
 * │                                                             │
 * │  BMP280         ESP8266                                     │
 * │  ────────        ───────                                     │
 * │  VIN/VCC  →  3V3                                            │
 * │  GND      →  GND                                            │
 * │  SCL      →  D1 (GPIO 5)                                    │
 * │  SDA      →  D2 (GPIO 4)                                    │
 * │                                                             │
 * │  Adresse I2C : 0x76 (défaut) ou 0x77                        │
 * │  Le code teste les deux adresses automatiquement            │
 * │                                                             │
 * └─────────────────────────────────────────────────────────────┘
 * 
 * ┌─────────────────────────────────────────────────────────────┐
 * │ 3. MQ-4 - GAZ MÉTHANE                                       │
 * │                                                             │
 * │  MQ-4           ESP8266                                     │
 * │  ────            ───────                                     │
 * │  VCC    →  Vin (5V)    ⚠️ 5V REQUIS!                        │
 * │  GND    →  GND                                              │
 * │  AOUT   →  A0 (connexion directe)                           │
 * │                                                             │
 * │  ⚠️ Mode simulation : pas de diviseur de tension nécessaire │
 * │  Le code calibre la lecture software                        │
 * │  ️ Chauffer 24h avant première utilisation                 │
 * │                                                             │
 * │  Schéma :                                                   │
 * │  MQ-4 AOUT ──────────→ A0 (ESP8266)                        │
 * │                                                             │
 * └─────────────────────────────────────────────────────────────┘
 * 
 * ┌─────────────────────────────────────────────────────────────┐
 * │ 4. HC-SR04 - NIVEAU ULTRASON                                │
 * │                                                             │
 * │  HC-SR04        ESP8266                                     │
 * │  ─────────       ───────                                     │
 * │  VCC    →  Vin (5V)                                         │
 * │  GND    →  GND                                              │
 * │  Trig   →  D5 (GPIO 14)                                     │
 * │  Echo   →  D6 (GPIO 12)                                     │
 * │                                                             │
 * │  ✅ Pas de diviseur nécessaire en mode simulation          │
 * │                                                             │
 * └─────────────────────────────────────────────────────────────┘
 * 
 * ═══════════════════════════════════════════════════════════════
 * INSTALLATION ARDUINO IDE
 * ═══════════════════════════════════════════════════════════════
 * 
 * 1. Installer Arduino IDE : https://www.arduino.cc/en/software
 * 
 * 2. Ajouter le support ESP8266 :
 *    - Fichier → Préférences
 *    - URL de gestionnaire de cartes :
 *      http://arduino.esp8266.com/stable/package_esp8266com_index.json
 *    - Outils → Type de carte → Gestionnaire de cartes
 *    - Chercher "ESP8266" et installer "esp8266 by ESP8266 Community"
 * 
 * 3. Installer les bibliothèques :
 *    - Croquis → Inclure bibliothèque → Gérer les bibliothèques
 *    - Installer :
 *      • "DHT sensor library" by Adafruit
 *      • "Adafruit BMP280 Library" by Adafruit
 *      • "ArduinoJson" by Benoit Blanchon
 *      • "ESP8266WiFi" (inclus dans le package ESP8266)
 *      • "ESP8266HTTPClient" (inclus dans le package ESP8266)
 * 
 * 4. Sélectionner la carte :
 *    - Outils → Type de carte → NodeMCU 1.0 (ESP-12E Module)
 *    - Port : COMx (choisir le bon port)
 *    - Upload Speed : 115200
 * 
 * 5. Modifier les valeurs dans biodigit_esp32.ino :
 *    - WIFI_SSID et WIFI_PASSWORD
 *    - SUPABASE_URL et SUPABASE_ANON_KEY
 *    - USER_ID (UUID de l'utilisateur dans Supabase)
 * 
 * 6. Téléverser : bouton "Téléverser" (flèche)
 * 
 * ══════════════════════════════════════════════════════════════
 * TROUVER L'USER_ID DANS SUPABASE
 * ═══════════════════════════════════════════════════════════════
 * 
 * 1. Supabase Dashboard → votre projet
 * 2. Authentication → Users
 * 3. Cliquer sur l'utilisateur
 * 4. Copier l'UID (ex: "efbdcbf0-d9fc-4537-882f-80a8c951f9b2")
 * 5. Coller dans USER_ID dans le code
 * 
 * ═══════════════════════════════════════════════════════════════
 * VÉRIFICATION
 * ═══════════════════════════════════════════════════════════════
 * 
 * 1. Ouvrir le Moniteur Série (115200 bauds)
 * 2. Vous devriez voir :
 *    === BioDigit ESP8266 + DHT22 ===
 *    [OK] DHT22 initialise
 *    [OK] BMP280 initialise (adresse 0x76)
 *    Connexion WiFi: VOTRE_WIFI.....
 *    [OK] WiFi connecte!
 *      IP: 192.168.1.xxx
 *    Temp: 36.5°C | Press: 1.05 bar | CH4: 320 ppm | Niveau: 72.5%
 *      [OK] Envoye a Supabase
 * 
 * 3. Vérifier dans Supabase :
 *    - Table Editor → sensor_readings
 *    - Les lignes doivent apparaître toutes les 5 secondes
 * 
 * 4. Dans l'application Flutter :
 *    - Se connecter avec le même compte
 *    - Le dashboard affiche les données en temps réel
 * 
 * ═══════════════════════════════════════════════════════════════
 * PROBLÈMES COURANTS
 * ═══════════════════════════════════════════════════════════════
 * 
 * "BMP280 non trouve"
 *   → Vérifier câblage I2C (SDA=D2, SCL=D1)
 *   → Vérifier adresse (0x76 ou 0x77)
 *   → Vérifier alimentation 3.3V
 * 
 * "DHT22 lecture NaN"
 *   → Vérifier broche DATA sur D2
 *   → Vérifier alimentation (3.3V ou 5V)
 *   → Attendre 2s entre les lectures
 * 
 * "MQ-4 ne lit rien"
 *   → Attendre 24h de préchauffage
 *   → Vérifier alimentation 5V
 *   → Vérifier connexion AOUT → A0
 * 
 * "WiFi echec"
 *   → Vérifier SSID et mot de passe
 *   → WiFi 2.4GHz uniquement (ESP8266 ne supporte pas 5GHz)
 * 
 * "HTTP 401"
 *   → Vérifier SUPABASE_ANON_KEY
 *   → Vérifier USER_ID
 * 
 * "HTTP 403"
 *   → Vérifier les politiques RLS dans Supabase
 *   → La table sensor_readings doit autoriser l'insert
 * 
 * "Données pas dans l'app"
 *   → Vérifier Realtime activé sur sensor_readings
 *   → Vérifier USER_ID correspond au compte connecté
 *   → Redémarrer l'application Flutter
 */
