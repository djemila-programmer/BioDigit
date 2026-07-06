/*
 * GUIDE DE CABLAGE - BioDigit ESP32
 * ====================================
 * 
 * MATÉRIEL NÉCESSAIRE :
 * ---------------------
 * 1x ESP32 DevKit V1 (30 broches)
 * 1x DS18B20 (capteur température) + résistance 4.7kΩ
 * 1x BMP280 (capteur pression I2C)
 * 1x MQ-4 (capteur gaz méthane)
 * 1x HC-SR04 (capteur ultrason)
 * 1x Breadboard 400+ points
 * Fils jumper mâle-mâle et mâle-femelle
 * 1x Câble USB Micro-USB
 * 1x Alimentation 5V 2A (ou port USB PC)
 * 
 * ALIMENTATION :
 * --------------
 * ESP32     → 3.3V (via USB ou regulateur)
 * DS18B20   → 3.3V (VDD) + GND
 * BMP280    → 3.3V (VIN) + GND
 * MQ-4      → 5V (VCC) + GND  (ATTENTION: 5V requis!)
 * HC-SR04   → 5V (VCC) + GND  (ATTENTION: 5V requis!)
 * 
 * ═══════════════════════════════════════════════════════════════
 * SCHÉMA DE CÂBLAGE DÉTAILLÉ
 * ═══════════════════════════════════════════════════════════════
 * 
 * ┌─────────────────────────────────────────────────────────────────┐
 * │                         ESP32 DevKit                             │
 * │                                                                  │
 * │  3V3 ──────┬──────────────────────────────────┐                 │
 * │             │                                  │                 │
 * │  GND ───────┼──────────────────────────────────┼──────────┐      │
 * │             │                                  │          │      │
 * │  GPIO4 ─────┤ DS18B20 (Data)                   │          │      │
 * │             │   └── Résistance 4.7kΩ ── 3V3    │          │      │
 * │             │                                  │          │      │
 * │  GPIO21 ────┤ BMP280 (SDA)                     │          │      │
 * │  GPIO22 ────┤ BMP280 (SCL)                     │          │      │
 * │             │                                  │          │      │
 * │  GPIO34 ────┤ MQ-4 (AOUT - sortie analogique) │          │      │
 * │             │                                  │          │      │
 * │  GPIO5 ─────┤ HC-SR04 (Trig)                   │          │      │
 * │  GPIO18 ────┤ HC-SR04 (Echo)                   │          │      │
 * │             │                                  │          │      │
 * │  5V (VIN) ──┼──────────────────────────────────┼──────────┘      │
 * │             │                                  │                 │
 * └─────────────┴──────────────────────────────────┴─────────────────┘
 * 
 * ═══════════════════════════════════════════════════════════════
 * CÂBLAGE PAR CAPTEUR
 * ═══════════════════════════════════════════════════════════════
 * 
 * ┌─────────────────────────────────────────────────────────────┐
 * │ 1. DS18B20 - CAPTEUR TEMPÉRATURE                            │
 * │                                                             │
 * │  DS18B20        ESP32                                       │
 * │  ─────────      ─────                                       │
 * │  VCC (rouge) →  3V3                                         │
 * │  GND (noir)  →  GND                                         │
 * │  DATA(jaune) →  GPIO 4                                      │
 * │                                                             │
 * │  ⚠️ Résistance 4.7kΩ entre VCC et DATA (obligatoire!)      │
 * │                                                             │
 * │  [3V3] ──── [4.7kΩ] ──── [GPIO4/DATA]                     │
 * │                                                             │
 * └─────────────────────────────────────────────────────────────┘
 * 
 * ┌─────────────────────────────────────────────────────────────┐
 * │ 2. BMP280 - CAPTEUR PRESSION (I2C)                          │
 * │                                                             │
 * │  BMP280         ESP32                                       │
 * │  ────────        ─────                                       │
 * │  VIN    →  3V3                                               │
 * │  GND    →  GND                                               │
 * │  SCL    →  GPIO 22                                           │
 * │  SDA    →  GPIO 21                                           │
 * │                                                             │
 * │  ⚠️ Adresse I2C par défaut: 0x76                             │
 * │  ⚠️ Si module a 6 broches, vérifier SDO (0x76 ou 0x77)      │
 * │                                                             │
 * └─────────────────────────────────────────────────────────────┘
 * 
 * ┌─────────────────────────────────────────────────────────────┐
 * │ 3. MQ-4 - CAPTEUR GAZ MÉTHANE                               │
 * │                                                             │
 * │  MQ-4           ESP32                                       │
 * │  ────            ─────                                       │
 * │  VCC    →  5V (VIN)    ⚠️ 5V REQUIS!                       │
 * │  GND    →  GND                                               │
 * │  AOUT   →  GPIO 34    (sortie analogique)                   │
 * │  DOUT   →  non utilisé                                      │
 * │                                                             │
 * │  ⚠️ Chauffer 24h avant première utilisation                  │
 * │  ⚠️ Consomme ~800mA pendant chauffage                       │
 * │                                                             │
 * └─────────────────────────────────────────────────────────────┘
 * 
 * ┌─────────────────────────────────────────────────────────────┐
 * │ 4. HC-SR04 - CAPTEUR ULTRASON (NIVEAU)                      │
 * │                                                             │
 * │  HC-SR04        ESP32                                       │
 * │  ─────────       ─────                                       │
 * │  VCC    →  5V (VIN)    ⚠️ 5V REQUIS!                       │
 * │  GND    →  GND                                               │
 * │  Trig   →  GPIO 5                                            │
 * │  Echo   →  GPIO 18   ⚠️ Diviseur de tension recommandé!     │
 * │                                                             │
 * │  ⚠️ Echo sort 5V, GPIO18 accepte 3.3V max                   │
 * │  ⚠️ Utiliser diviseur: Echo → [1kΩ] → GPIO18               │
 * │                                     → [2kΩ] → GND           │
 * │                                                             │
 * └─────────────────────────────────────────────────────────────┘
 * 
 * ═══════════════════════════════════════════════════════════════
 * DIVISEUR DE TENSION POUR HC-SR04 ECHO (IMPORTANT!)
 * ═══════════════════════════════════════════════════════════════
 * 
 * Le HC-SR04 Echo sort 5V. L'ESP32 GPIO accepte 3.3V max.
 * Sans diviseur, vous RISQUEZ d'endommager l'ESP32!
 * 
 * Schéma diviseur :
 * 
 *   HC-SR04 Echo ──── [1kΩ] ────┬──── GPIO 18 (ESP32)
 *                                │
 *                              [2kΩ]
 *                                │
 *                               GND
 * 
 * Ratio: 5V × (2k/(1k+2k)) = 3.3V ✓
 * 
 * ═══════════════════════════════════════════════════════════════
 * INSTALLATION DANS L'ARDUINO IDE
 * ═══════════════════════════════════════════════════════════════
 * 
 * 1. Installer Arduino IDE : https://www.arduino.cc/en/software
 * 
 * 2. Ajouter le support ESP32 :
 *    - Fichier → Préférences
 *    - URL de gestionnaire de cartes :
 *      https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
 *    - Outils → Type de carte → Gestionnaire de cartes
 *    - Chercher "ESP32" et installer "esp32 by Espressif"
 * 
 * 3. Installer les bibliothèques :
 *    - Croquis → Inclure bibliothèque → Gérer les bibliothèques
 *    - Installer :
 *      • "OneWire" par Paul Stoffregen
 *      • "DallasTemperature" by Miles Burton
 *      • "Adafruit BMP280 Library" by Adafruit
 *      • "ArduinoJson" by Benoit Blanchon
 * 
 * 4. Sélectionner la carte :
 *    - Outils → Type de carte → ESP32 Dev Module
 *    - Port : COMx (choisir le bon port)
 * 
 * 5. Modifier les valeurs dans biodigit_esp32.ino :
 *    - WIFI_SSID et WIFI_PASSWORD
 *    - SUPABASE_URL et SUPABASE_ANON_KEY
 *    - USER_ID (UUID de l'utilisateur dans Supabase)
 * 
 * 6. Téléverser : bouton "Téléverser" (flèche)
 * 
 * ═══════════════════════════════════════════════════════════════
 * TROUVER L'USER_ID DANS SUPABASE
 * ═══════════════════════════════════════════════════════════════
 * 
 * 1. Aller sur Supabase Dashboard → votre projet
 * 2. Authentication → Users
 * 3. Cliquer sur l'utilisateur
 * 4. Copier l'UUID (ex: "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
 * 5. Coller dans USER_ID dans le code
 * 
 * ═══════════════════════════════════════════════════════════════
 * VÉRIFICATION
 * ═══════════════════════════════════════════════════════════════
 * 
 * 1. Ouvrir le Moniteur Série (115200 bauds)
 * 2. Vous devriez voir :
 *    === BioDigit ESP32 ===
 *    [OK] DS18B20 initialise
 *    [OK] BMP280 initialise
 *    Connexion WiFi: VOTRE_WIFI.....
 *    [OK] WiFi connecte!
 *      IP: 192.168.1.xxx
 *    Temp: 36.5°C | Press: 1.05 bar | CH4: 320 ppm | Niveau: 72.5%
 *      [OK] Donnees envoyees a Supabase
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
 *   → Vérifier câblage I2C (SDA=21, SCL=22)
 *   → Vérifier adresse (0x76 ou 0x77)
 *   → Vérifier alimentation 3.3V
 * 
 * "Température = -127°C"
 *   → Vérifier résistance 4.7kΩ entre VCC et DATA
 *   → Vérifier broche DATA sur GPIO 4
 * 
 * "MQ-4 ne lit rien"
 *   → Attendre 24h de préchauffage
 *   → Vérifier alimentation 5V
 *   → Vérifier AOUT sur GPIO 34
 * 
 * "WiFi echec"
 *   → Vérifier SSID et mot de passe
 *   → WiFi 2.4GHz uniquement (ESP32 ne supporte pas 5GHz)
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
