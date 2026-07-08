# BioDigit - BioSmart Africa Monitoring System

## Système intelligent de suivi de biodigesteur pour l'Afrique de l'Ouest

Application Flutter IoT pour le monitoring en temps réel de biodigesteurs agricoles au Burkina Faso. Connexion ESP8266 + capteurs → Supabase Realtime → Application mobile/desktop.

---

## Table des matières

1. [Architecture globale](#architecture-globale)
2. [Stack technique](#stack-technique)
3. [Structure du projet](#structure-du-projet)
4. [Installation et configuration](#installation-et-configuration)
5. [Variables d'environnement](#variables-denvironnement)
6. [Base de données Supabase](#base-de-données-supabase)
7. [Authentification](#authentification)
8. [Écrans et navigation](#écrans-et-navigation)
9. [Services](#services)
10. [Modèles de données](#modèles-de-données)
11. [Providers (State Management)](#providers-state-management)
12. [Widgets réutilisables](#widgets-réutilisables)
13. [Thème et dark mode](#thème-et-dark-mode)
14. [Localisation FR/EN](#localisation-fr-en)
15. [Connexion ESP8266 et capteurs](#connexion-esp8266-et-capteurs)
16. [Tables Supabase pour ESP8266](#tables-supabase-pour-esp8266)
17. [Flux de données temps réel](#flux-de-données-temps-réel)
18. [Système d'alertes](#système-dalertes)
19. [Détection d'anomalies IA](#détection-danomalies-ia)
20. [Génération de rapports](#génération-de-rapports)
21. [Cache hors-ligne](#cache-hors-ligne)
22. [Notifications push](#notifications-push)
23. [Sécurité](#sécurité)
24. [Build et déploiement](#build-et-déploiement)
25. [Matériel nécessaire](#matériel-nécessaire)

---

## Architecture globale

```
┌─────────────────────────────────────────────────────────────────┐
│                        ESP8266 + Capteurs                          │
│  DHT22    │  BMP280  │  MQ-4  │  HC-SR04                        │
│  (Temp)   │ (Press.) │ (CH4)  │  (Niveau)                       │
└──────────────────────┬──────────────────────────────────────────┘
                       │ WiFi → HTTP POST
                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                     Supabase (Backend)                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │ PostgreSQL    │  │ Realtime     │  │ Auth (Email/Google)  │  │
│  │ sensor_       │  │ sensor_      │  │ profiles table       │  │
│  │ readings      │  │ readings     │  │                      │  │
│  │ alerts        │  │ esp32_status │  │ RLS Policies         │  │
│  │ config        │  │              │  │                      │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
└──────────────────────┬──────────────────────────────────────────┘
                       │ Realtime WebSocket
                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Application Flutter                            │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Provider (State Management)                              │   │
│  │  AuthProvider │ SensorProvider │ AlertProvider │ ...      │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │  Services                                                 │   │
│  │  AuthService │ SensorService │ AlertService │ ...        │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │  Écrans (23 screens)                                      │   │
│  │  Dashboard │ Live │ Alerts │ History │ Reports │ Admin   │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │  Cache Hive (hors-ligne) │ Notifications locales          │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## Stack technique

| Couche | Technologie |
|--------|-------------|
| Framework UI | Flutter 3.8+ / Dart |
| Backend | Supabase (PostgreSQL + Realtime + Auth) |
| State Management | Provider (ChangeNotifier) |
| Cache local | Hive |
| Authentification | Supabase Auth (email/password + Google OAuth) |
| Temps réel | Supabase Realtime (WebSocket) |
| Notifications | flutter_local_notifications |
| Charts | fl_chart |
| Export PDF | pdf + printing |
| Export Excel | excel |
| Variables env | flutter_dotenv |
| Police | Google Fonts |
| Connectivité | connectivity_plus |
| Partage | share_plus |

---

## Structure du projet

```
biodigit_app/
├── lib/
│   ├── main.dart                    # Point d'entrée, MultiProvider, MaterialApp
│   ├── routes.dart                  # 22 routes + AuthGuard
│   ├── supabase.dart                # Configuration et initialisation Supabase
│   │
│   ├── core/
│   │   ├── app_env.dart             # Lecture variables .env
│   │   └── app_localizations.dart   # Traductions FR/EN (312 lignes)
│   │
│   ├── models/
│   │   ├── user_model.dart          # UserModel + FarmManager
│   │   ├── sensor_model.dart        # SensorModel + DashboardMetric
│   │   ├── alert_model.dart         # AlertModel (critical/warning/info)
│   │   └── biodigester_model.dart   # BiodigesterModel, ESP8266Status, ThresholdConfig,
│   │                                  ProductionData, FeedingSchedule, MaintenanceItem
│   │
│   ├── screens/                     # 23 écrans
│   │   ├── splash_screen.dart       # Écran de chargement initial
│   │   ├── landing_screen.dart      # Page d'accueil publique
│   │   ├── onboarding_screen.dart   # 3 pages de présentation
│   │   ├── login_screen.dart        # Connexion email/password + Google
│   │   ├── register_screen.dart     # Inscription → redirige vers login
│   │   ├── forgot_password_screen.dart
│   │   ├── reset_password_screen.dart
│   │   ├── change_password_screen.dart
│   │   ├── main_dashboard.dart      # Tableau de bord principal (capteurs temps réel)
│   │   ├── live_monitoring.dart     # Monitoring live avec jauges + maintenance
│   │   ├── sensor_management.dart   # Gestion des capteurs (ajout, calibration)
│   │   ├── alerts_screen.dart       # Liste des alertes avec filtres
│   │   ├── history_screen.dart      # Historique et graphiques de production
│   │   ├── reports_screen.dart      # Rapports PDF/Excel
│   │   ├── anomaly_detection.dart   # Détection IA d'anomalies
│   │   ├── notifications_center.dart # Centre de notifications
│   │   ├── farm_management.dart     # Gestion de la ferme (bétail, alimentation)
│   │   ├── user_profile.dart        # Profil utilisateur
│   │   ├── settings_screen.dart     # Paramètres (thème, langue, notifications)
│   │   ├── admin_dashboard.dart     # Dashboard admin (utilisateurs, config)
│   │   ├── threshold_management.dart # Configuration des seuils d'alerte
│   │   ├── not_found_screen.dart    # Erreur 404
│   │   └── server_error_screen.dart # Erreur 500
│   │
│   ├── services/                    # 12 services
│   │   ├── auth_service.dart        # signIn, signUp, signOut, resetPassword, Google
│   │   ├── sensor_service.dart      # Flux temps réel sensor_readings + esp32_status
│   │   ├── alert_service.dart       # CRUD alertes depuis Supabase
│   │   ├── anomaly_service.dart     # Détection d'anomalies (algorithmes ML)
│   │   ├── farm_service.dart        # Gestion ferme (bétail, alimentation, énergie)
│   │   ├── history_service.dart     # Historique de production (weekly/monthly/yearly)
│   │   ├── notification_service.dart # Notifications locales + vérification seuils
│   │   ├── cache_service.dart       # Cache Hive (sensorCache, alertCache, farmCache)
│   │   ├── pdf_service.dart         # Génération rapports PDF
│   │   ├── excel_service.dart       # Export données en Excel
│   │   ├── simulation_service.dart  # Jumeau numérique (données simulées)
│   │   └── providers.dart           # Tous les ChangeNotifier providers
│   │
│   ├── theme/
│   │   └── app_theme.dart           # Thème Material 3 (light + dark + helpers)
│   │
│   └── widgets/
│       ├── auth_guard.dart          # Garde de route (auth + rôle)
│       ├── bottom_nav_bar.dart      # Barre de navigation inférieure
│       ├── app_header.dart          # En-tête d'écran personnalisé
│       └── common_widgets.dart      # Widgets réutilisables (BiodigesterVisual,
│                                      MetricCard, ESP8266StatusCard, SupabaseStatusCard,
│                                      TrendIndicator, etc.)
│
├── .env                             # Variables d'environnement (NON commité)
├── .gitignore
├── pubspec.yaml
└── analysis_options.yaml
```

---

## Installation et configuration

### Prérequis
- Flutter SDK 3.8+
- Dart SDK 3.8+
- Compte Supabase
- Android Studio / VS Code
- (Optionnel) ESP8266 + capteurs pour données réelles

### Étapes

```bash
# 1. Cloner le projet
git clone <repository-url>
cd biodigit_app

# 2. Installer les dépendances
flutter pub get

# 3. Créer le fichier .env (voir section Variables d'environnement)
cp .env.example .env
# Éditer .env avec vos valeurs Supabase

# 4. Lancer l'application
flutter run -d windows    # Windows
flutter run -d chrome     # Web
flutter run -d android    # Android
flutter run -d ios        # iOS

# 5. Build production
flutter build windows
flutter build apk --release
```

---

## Variables d'environnement

Fichier `biodigit_app/.env` (jamais commité, protégé par `.gitignore`) :

```env
# Obligatoire
SUPABASE_URL=https://votre-projet.supabase.co
SUPABASE_ANON_KEY=votre-cle-anon-supabase

# Fallback (compatibilité web)
NEXT_PUBLIC_SUPABASE_URL=https://votre-projet.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=votre-cle-anon-supabase

# Optionnel
SUPABASE_REDIRECT_URL=biodigitapp://reset-password
APP_NAME=BioDigit
APP_URL=https://biodigit.bf
```

---

## Base de données Supabase

### Tables requises

```sql
-- Profils utilisateurs
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  full_name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT DEFAULT '',
  farm_name TEXT DEFAULT '',
  role TEXT DEFAULT 'user',        -- 'user' | 'admin'
  profile_image_url TEXT DEFAULT '',
  biodigester_type TEXT,
  biodigester_capacity DOUBLE PRECISION,
  location TEXT DEFAULT 'Plateau Central, Burkina Faso',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Lectures capteurs temps réel
CREATE TABLE sensor_readings (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES profiles(id),
  temperature DOUBLE PRECISION DEFAULT 0,
  pressure DOUBLE PRECISION DEFAULT 0,
  methane DOUBLE PRECISION DEFAULT 0,
  slurry_level DOUBLE PRECISION DEFAULT 0,
  temperature_trend TEXT DEFAULT 'stable',
  pressure_trend TEXT DEFAULT 'stable',
  methane_trend TEXT DEFAULT 'stable',
  slurry_trend TEXT DEFAULT 'stable',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Statut ESP8266
CREATE TABLE esp32_status (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES profiles(id),
  connected BOOLEAN DEFAULT false,
  wifi_signal INTEGER DEFAULT 0,
  firmware_version TEXT DEFAULT 'N/A',
  battery_level INTEGER DEFAULT 0,
  ip_address TEXT DEFAULT 'N/A',
  last_sync TIMESTAMPTZ,
  cpu_temp DOUBLE PRECISION DEFAULT 0,
  uptime TEXT DEFAULT '0',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Alertes
CREATE TABLE alerts (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES profiles(id),
  title TEXT NOT NULL,
  description TEXT,
  severity TEXT DEFAULT 'info',     -- 'critical' | 'warning' | 'info'
  sensor_id TEXT,
  location TEXT,
  acknowledged BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Historique de production
CREATE TABLE production_logs (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES profiles(id),
  period TEXT NOT NULL,             -- 'daily' | 'weekly' | 'monthly'
  production DOUBLE PRECISION DEFAULT 0,
  efficiency DOUBLE PRECISION DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Configuration (seuils, etc.)
CREATE TABLE config (
  id BIGSERIAL PRIMARY KEY,
  key TEXT UNIQUE NOT NULL,
  value JSONB NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Santé des capteurs
CREATE TABLE sensor_health (
  id TEXT PRIMARY KEY,
  sensor_model TEXT NOT NULL,
  status TEXT DEFAULT 'unknown',
  battery_level INTEGER DEFAULT 100,
  signal_quality TEXT DEFAULT 'Unknown',
  last_calibration TIMESTAMPTZ,
  next_maintenance TIMESTAMPTZ,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Politiques RLS (Row Level Security)

```sql
-- Activer RLS sur toutes les tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE sensor_readings ENABLE ROW LEVEL SECURITY;
ALTER TABLE esp32_status ENABLE ROW LEVEL SECURITY;
ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE production_logs ENABLE ROW LEVEL SECURITY;

-- Politique: chaque utilisateur voit ses propres données
CREATE POLICY "Users see own profiles" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users see own readings" ON sensor_readings
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users insert own readings" ON sensor_readings
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users see own alerts" ON alerts
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users see own status" ON esp32_status
  FOR SELECT USING (auth.uid() = user_id);

-- ESP8266 peut insérer des lectures
CREATE POLICY "ESP8266 insert readings" ON sensor_readings
  FOR INSERT WITH CHECK (true);
```

### Activer Realtime

```sql
-- Activer Realtime sur les tables critiques
ALTER PUBLICATION supabase_realtime ADD TABLE sensor_readings;
ALTER PUBLICATION supabase_realtime ADD TABLE esp32_status;
ALTER PUBLICATION supabase_realtime ADD TABLE alerts;
```

---

## Authentification

### Flux d'authentification

```
Inscription → Page de connexion → Connexion → Dashboard
    │                                    │
    │  email/password + profil           │  email/password
    │  → crée dans auth.users           │  → vérifie rôle
    │  → crée dans profiles             │  → charge profil
    │  → redirige vers /login           │  → démarre listeners
    │                                    │
    └────────────────────────────────────┘
```

### Méthodes d'authentification

| Méthode | Service | Écran |
|---------|---------|-------|
| Email + mot de passe | `AuthService.signIn()` | `login_screen.dart` |
| Google OAuth | `AuthService.signInWithGoogle()` | `login_screen.dart` |
| Inscription | `AuthService.signUp()` | `register_screen.dart` |
| Réinitialisation mot de passe | `AuthService.sendPasswordResetEmail()` | `forgot_password_screen.dart` |
| Nouveau mot de passe | `AuthService.completePasswordReset()` | `reset_password_screen.dart` |
| Changement mot de passe | `AuthService.changePassword()` | `change_password_screen.dart` |
| Déconnexion | `AuthService.signOut()` | Menu profil + sidebar admin |

### Rôles

- **user** : accès dashboard, monitoring, alertes, historique, rapports, profil
- **admin** : accès supplémentaire → admin dashboard, gestion utilisateurs, configuration système

### AuthGuard

Widget de protection des routes :

```dart
// Route protégée (authentification requise)
AuthGuard(child: MainDashboard())

// Route admin (rôle admin requis)
AuthGuard(role: 'admin', child: AdminDashboard())
```

Comportement :
- Non authentifié → redirige vers `/login`
- Rôle incorrect → redirige vers `/main-dashboard`
- Authentifié + rôle OK → affiche l'écran

---

## Écrans et navigation

### Routes publiques

| Route | Écran | Description |
|-------|-------|-------------|
| `/` | `SplashScreen` | Chargement initial, vérification session |
| `/landing` | `LandingScreen` | Page d'accueil marketing |
| `/onboarding` | `OnboardingScreen` | 3 pages de présentation |
| `/login` | `LoginScreen` | Connexion email/password + Google |
| `/register` | `RegisterScreen` | Inscription nouveau compte |
| `/forgot-password` | `ForgotPasswordScreen` | Demande réinitialisation |
| `/reset-password` | `ResetPasswordScreen` | Nouveau mot de passe |
| `/404` | `NotFoundScreen` | Page erreur 404 |
| `/500` | `ServerErrorScreen` | Page erreur serveur |

### Routes protégées (authentification requise)

| Route | Écran | Description |
|-------|-------|-------------|
| `/main-dashboard` | `MainDashboard` | Tableau de bord principal |
| `/live-monitoring` | `LiveMonitoring` | Monitoring temps réel (jauges) |
| `/sensor-management` | `SensorManagement` | Gestion capteurs |
| `/alerts` | `AlertsScreen` | Liste alertes avec filtres |
| `/history` | `HistoryScreen` | Historique production |
| `/reports` | `ReportsScreen` | Rapports PDF/Excel |
| `/anomaly-detection` | `AnomalyDetection` | Détection IA anomalies |
| `/notifications` | `NotificationsCenter` | Centre notifications |
| `/farm-management` | `FarmManagement` | Gestion ferme |
| `/user-profile` | `UserProfile` | Profil utilisateur |
| `/settings` | `SettingsScreen` | Paramètres |
| `/change-password` | `ChangePasswordScreen` | Changement mot de passe |
| `/threshold-management` | `ThresholdManagement` | Configuration seuils |

### Route admin

| Route | Écran | Description |
|-------|-------|-------------|
| `/admin-dashboard` | `AdminDashboard` | Dashboard administration (rôle admin) |

---

## Services

### AuthService (`auth_service.dart`)

| Méthode | Description |
|---------|-------------|
| `signIn(email, password, expectedRole)` | Connexion email/password |
| `signInWithGoogle(expectedRole)` | Connexion Google OAuth |
| `signUp(email, password, fullName, phone, farmName, ...)` | Inscription |
| `sendPasswordResetEmail(email)` | Envoi email réinitialisation |
| `completePasswordReset(newPassword)` | Finaliser réinitialisation |
| `changePassword(currentPassword, newPassword)` | Changement mot de passe |
| `signOut()` | Déconnexion |
| `getCurrentUserProfile()` | Charger profil depuis Supabase |
| `updateUserProfile(updates)` | Mettre à jour profil |
| `uploadAvatar(filePath)` | Upload image profil |

### SensorService (`sensor_service.dart`)

| Méthode | Description |
|---------|-------------|
| `sensorDataStream()` | Stream temps réel de toutes les lectures capteur |
| `singleSensorStream(sensorKey)` | Stream d'un seul capteur |
| `esp32StatusStream()` | Stream statut ESP8266 |
| `getCurrentReadings()` | Lecture ponctuelle des valeurs actuelles |
| `getEsp32Status()` | Statut actuel ESP8266 |
| `getThresholdConfig()` | Configuration seuils depuis Supabase |
| `saveThresholdConfig(config)` | Sauvegarder seuils |
| `getSensorHealthRecords()` | Historique santé capteurs |
| `updateSensorHealth(sensorId, data)` | Mettre à jour santé capteur |

### AlertService (`alert_service.dart`)

| Méthode | Description |
|---------|-------------|
| `getAlerts()` | Charger toutes les alertes |
| `getUnreadCount()` | Nombre d'alertes non lues |
| `acknowledgeAlert(id)` | Marquer comme lue |
| `createAlert(alert)` | Créer une alerte |
| `alertStream()` | Stream temps réel des alertes |

### AnomalyService (`anomaly_service.dart`)

| Méthode | Description |
|---------|-------------|
| `analyzeReading(reading)` | Analyser une lecture pour anomalies |
| `getAnomalyHistory()` | Historique des anomalies détectées |
| `getRiskScore()` | Score de risque actuel (0-100) |

### FarmService (`farm_service.dart`)

| Méthode | Description |
|---------|-------------|
| `getFarms()` | Liste des fermes |
| `getLivestock()` | Inventaire bétail |
| `getFeedingSchedule()` | Planning d'alimentation |
| `getEnergyMetrics()` | Métriques énergie |
| `getSystemStats()` | Statistiques système globales |

### HistoryService (`history_service.dart`)

| Méthode | Description |
|---------|-------------|
| `loadProduction(period)` | Charger production (weekly/monthly/yearly) |
| `logReading(reading)` | Enregistrer une lecture dans l'historique |
| `getProductionLogs()` | Logs de production |

### NotificationService (`notification_service.dart`)

| Méthode | Description |
|---------|-------------|
| `initialize()` | Initialiser le service |
| `checkAndNotify(reading)` | Vérifier seuils et notifier |
| `showNotification(title, body)` | Afficher notification locale |

### CacheService (`cache_service.dart`)

| Méthode | Description |
|---------|-------------|
| `initialize()` | Ouvrir les boxes Hive |
| `cacheSensorReading(reading)` | Mettre en cache lecture capteur |
| `getLastCachedReading()` | Dernière lecture en cache |
| `cacheAlerts(alerts)` | Mettre en cache alertes |
| `getCachedAlerts()` | Alertes en cache |

### PdfService (`pdf_service.dart`)

| Méthode | Description |
|---------|-------------|
| `generateReport(data)` | Générer rapport PDF |
| `shareReport(pdf)` | Partager le rapport |

### ExcelService (`excel_service.dart`)

| Méthode | Description |
|---------|-------------|
| `exportToExcel(data)` | Exporter données en Excel |
| `shareExcel(file)` | Partager le fichier Excel |

### SimulationService (`simulation_service.dart`)

| Méthode | Description |
|---------|-------------|
| `start(intervalSeconds)` | Démarrer simulation (jumeau numérique) |
| `stop()` | Arrêter simulation |

**NOTE** : La simulation est activée par défaut. L'affichage montre les données simulées tant que l'ESP8266 n'envoie pas de données réelles.

---

## Modèles de données

### UserModel

```dart
class UserModel {
  String id;              // UUID Supabase
  String fullName;
  String email;
  String phone;
  String farmName;
  String role;            // 'user' | 'admin'
  String profileImageUrl;
  String? biodigesterType;
  double? biodigesterCapacity;
  String? location;
  DateTime? createdAt;
}
```

### SensorReading (dans sensor_service.dart)

```dart
class SensorReading {
  double temperature;     // °C (25-40 optimal)
  double pressure;        // bar (0.8-1.5 normal)
  double methane;         // ppm (150-500 normal)
  double slurryLevel;     // % (20-90 optimal)
  DateTime timestamp;
  String? temperatureTrend;  // 'rising' | 'falling' | 'stable'
  String? pressureTrend;
  String? methaneTrend;
  String? slurryTrend;
}
```

### AlertModel

```dart
class AlertModel {
  String id;
  String title;
  String description;
  String severity;        // 'critical' | 'warning' | 'info'
  String timeAgo;
  String location;
  String sensorId;
  IconData icon;
}
```

### Esp32StatusData

```dart
class Esp32StatusData {
  bool connected;
  int wifiSignal;         // force signal WiFi
  String firmwareVersion;
  int batteryLevel;
  String ipAddress;
  DateTime? lastSync;
  double cpuTemp;
  String uptime;
}
```

---

## Providers (State Management)

### AuthProvider

```dart
class AuthProvider extends ChangeNotifier {
  User? get user;
  bool get isAuthenticated;
  bool get isLoading;
  bool get isPasswordRecovery;
  
  Future<bool> signIn(email, password, role);
  Future<bool> signUp(email, password, fullName, phone, farmName, ...);
  Future<bool> signInWithGoogle(expectedRole);
  Future<void> signOut();
  Future<void> sendPasswordReset(email);
}
```

### SensorProvider

```dart
class SensorProvider extends ChangeNotifier {
  SensorReading? get latestReading;
  Esp32StatusData? get esp32Status;
  bool get isLoading;
  bool get isOnline;
  bool get isSimulation;
  
  void startListening();   // Démarre écoute temps réel
  void stopListening();
  void loadCached();       // Charge depuis cache hors-ligne
}
```

### AlertProvider

```dart
class AlertProvider extends ChangeNotifier {
  List<AlertModel> get alerts;
  int get unreadCount;
  
  void startListening();
  void acknowledgeAlert(String id);
}
```

### Autres Providers

| Provider | Rôle |
|----------|------|
| `AnomalyProvider` | Score de risque, historique anomalies |
| `HistoryProvider` | Données de production (weekly/monthly/yearly) |
| `FarmProvider` | Fermes, bétail, alimentation, statistiques |
| `NotificationProvider` | Notifications locales |
| `ThemeProvider` | Mode thème (light/dark/system) persisté via Hive |
| `LocaleProvider` | Langue (FR/EN) persistée via Hive |
| `ConnectivityProvider` | État connexion réseau |

---

## Widgets réutilisables

### AuthGuard (`auth_guard.dart`)

Protection des routes avec authentification et rôle optionnel.

### BottomNavBar (`bottom_nav_bar.dart`)

Barre de navigation inférieure avec 5 onglets : Dashboard, Alerts, History, Reports, Profile.

### AppHeader (`app_header.dart`)

En-tête d'écran personnalisé avec bouton retour.

### Common Widgets (`common_widgets.dart`)

| Widget | Description |
|--------|-------------|
| `BiodigesterVisual` | Représentation visuelle du biodigesteur |
| `MetricCard` | Carte de métrique avec jauge de progression |
| `ESP8266StatusCard` | Carte statut ESP8266 (connecté/déconnecté) |
| `SupabaseStatusCard` | Carte statut connexion Supabase |
| `TrendIndicator` | Indicateur de tendance (↑↓→) |
| `BiogasProductionCard` | Carte production biogaz avec graphique |
| `EnergyImpactCard` | Carte impact énergétique |

---

## Thème et dark mode

### Architecture

Le thème utilise Material 3 avec adaptation automatique dark mode :

```dart
// Dans chaque écran
final cs = Theme.of(context).colorScheme;

// Utiliser les couleurs du ColorScheme (s'adapte automatiquement)
backgroundColor: cs.surface
cardColor: cs.surfaceContainerHighest
textColor: cs.onSurface
subtextColor: cs.onSurfaceVariant
borderColor: cs.outlineVariant
```

### Couleurs

| Propriété | Light | Dark |
|-----------|-------|------|
| `surface` | `#F9F9F9` | `#0D1B0F` |
| `onSurface` | `#1A1C1C` | `#E8EDE8` |
| `onSurfaceVariant` | `#41493E` | `#9CAE9C` |
| `surfaceContainerHighest` | `#E2E2E2` | `#1A2E20` |
| `outlineVariant` | `#C0C9BB` | `#1F3524` |
| `primary` | `#00450D` | `#8BD88B` |

### Persistence

Le thème sélectionné est sauvegardé dans Hive (`themeBox`) et restauré au démarrage.

---

## Localisation FR/EN

### Architecture

Système de localisation personnalisé dans `app_localizations.dart` :

```dart
// Utilisation
AppLocalizations.of(context).translate('key')

// Raccourci
final loc = AppLocalizations.of(context);
Text(loc.welcomeMessage)
```

### Langues supportées

| Code | Langue |
|------|--------|
| `fr` | Français (par défaut) |
| `en` | Anglais |

### Persistence

La langue sélectionnée est sauvegardée dans Hive (`localeBox`).

---

## Connexion ESP8266 et capteurs

### Matériel requis

| Composant | Modèle | Rôle |
|-----------|--------|------|
| Microcontrôleur | ESP8266 | WiFi + GPIO |
| Capteur température | DHT22 | Température bouillie |
| Capteur gaz | MQ-4 | Concentration méthane (CH4) |
| Capteur pression | BMP280 | Pression interne |
| Capteur ultrason | HC-SR04 | Niveau de bouillie |
| Breadboard | - | Prototypage |
| Fils jumper | Mâle-Mâle, Mâle-Femelle | Connexions |
| Câble USB | - | Alimentation ESP8266 |

### Schéma de câblage

```
ESP8266 Pinout:
┌──────────────────────────────┐
│  DHT22 (Temp)       → GPIO 4 │
│  BMP280 (Press/I2C) → SDA=4, SCL=5 │
│  MQ-4 (CH4)         → A0 (ADC) │
│  HC-SR04 (Level)    → Trig=12, Echo=14 │
│  3.3V / GND         → Alimentation capteurs │
└──────────────────────────────┘
```

### Code ESP8266 (Arduino)

L'ESP8266 doit envoyer les données à Supabase via HTTP POST :

```cpp
// Exemple de payload envoyé par l'ESP8266
POST https://votre-projet.supabase.co/rest/v1/sensor_readings
Headers:
  Authorization: Bearer VOTRE_CLE_ANON
  Content-Type: application/json
  Prefer: return=minimal

Body:
{
  "user_id": "UUID_UTILISATEUR",
  "temperature": 36.5,
  "pressure": 1.05,
  "methane": 320,
  "slurry_level": 72.5,
  "temperature_trend": "stable",
  "pressure_trend": "rising",
  "methane_trend": "stable",
  "slurry_trend": "falling"
}
```

### Fréquence d'envoi

Recommandé : toutes les 5 secondes pour un suivi temps réel fluide.

---

## Tables Supabase pour ESP8266

L'ESP8266 interagit principalement avec 2 tables :

### `sensor_readings` (INSERT)

L'ESP8266 insère les lectures capteur. L'application Flutter les reçoit en temps réel via Supabase Realtime.

### `esp32_status` (UPSERT)

L'ESP8266 met à jour son statut (connecté, signal WiFi, batterie, etc.).

---

## Flux de données temps réel

```
1. ESP8266 lit les capteurs (toutes les 5s)
2. ESP8266 envoie POST à Supabase → sensor_readings
3. Supabase Realtime détecte l'insert
4. WebSocket pousse la donnée à l'application Flutter
5. SensorProvider reçoit la lecture
6. UI se met à jour automatiquement (Provider notifyListeners)
7. NotificationService vérifie les seuils
8. Si seuil dépassé → notification locale + alerte Supabase
9. CacheService met en cache pour mode hors-ligne
10. HistoryService enregistre dans l'historique
```

### Comportement sans ESP8266

Quand aucun ESP8266 n'est connecté :
- L'écran affiche **"Aucun capteur connecté"**
- Message : **"Connectez votre ESP8266 pour voir les données en temps réel."**
- Icône capteur désactivé affichée
- Pas de données simulées (simulation désactivée)

---

## Système d'alertes

### Niveaux de sévérité

| Niveau | Couleur | Déclenchement |
|--------|---------|---------------|
| `critical` | Rouge `#BA1A1A` | Danger immédiat (fuite gaz, pression critique) |
| `warning` | Orange `#7A5649` | Seuil approché (température haute, batterie faible) |
| `info` | Gris `#717A6D` | Information (connexion rétablie, maintenance planifiée) |

### Déclenchement automatique

Le `NotificationService` vérifie chaque lecture capteur contre les seuils configurés :

```dart
// Seuils par défaut
temperature: 25°C - 40°C
pressure: 0.8 - 1.5 bar
methane: 150 - 500 ppm
slurryLevel: 20% - 90%
```

Si une valeur sort des limites → alerte créée + notification locale.

---

## Détection d'anomalies IA

Le `AnomalyService` analyse les lectures pour détecter des patterns anormaux :

- Dérive lente de température
- Chutes soudaines de pression
- Patterns méthane inhabituels
- Corrélations entre capteurs

Score de risque : 0 (normal) à 100 (critique).

---

## Génération de rapports

### Formats supportés

| Format | Service | Usage |
|--------|---------|-------|
| PDF | `PdfService` | Rapport complet avec graphiques |
| Excel | `ExcelService` | Export données brutes |

### Contenu du rapport

- Période sélectionnée (jour/semaine/mois/année)
- Graphiques de production
- Métriques clés (température, pression, méthane, niveau)
- Alertes de la période
- Recommandations

---

## Cache hors-ligne

### Boxes Hive

| Box | Contenu |
|-----|---------|
| `themeBox` | Mode thème (light/dark/system) |
| `localeBox` | Langue sélectionnée (fr/en) |
| `sensorCache` | Dernière lecture capteur |
| `alertCache` | Alertes récentes |
| `farmCache` | Données ferme |
| `metaCache` | Métadonnées diverses |

### Comportement hors-ligne

Quand la connexion est perdue :
- Affichage des dernières données en cache
- Indicateur "Hors ligne" visible
- Tentative de reconnexion automatique
- Synchronisation au retour de la connexion

---

## Notifications push

### Types de notifications

| Type | Déclenchement |
|------|---------------|
| Seuil dépassé | Température/pression/méthane hors limites |
| Capteur déconnecté | ESP8266 ne répond plus |
| Batterie faible | Batterie capteur < 20% |
| Maintenance requise | Date de maintenance atteinte |
| Anomalie détectée | Score de risque > 70 |

---

## Sécurité

### Variables d'environnement

- `.env` jamais commité (`.gitignore`)
- Clé anon Supabase uniquement côté client
- RLS activé sur toutes les tables

### Authentification

- Mots de passe hashés par Supabase (bcrypt)
- Sessions JWT avec refresh automatique
- Google OAuth via token ID
- Protection des routes par `AuthGuard`

### RLS (Row Level Security)

Chaque utilisateur ne voit que ses propres données :

```sql
-- Exemple : un utilisateur ne voit que SES lectures capteur
SELECT * FROM sensor_readings WHERE user_id = auth.uid();
```

---

## Build et déploiement

### Commands

```bash
# Analyse statique
flutter analyze

# Build Windows
flutter build windows

# Build Android
flutter build apk --release

# Build Web
flutter build web

# Test
flutter test
```

### Version

Version actuelle : `1.0.0+1` (dans `pubspec.yaml`)

---

## Matériel nécessaire

### Kit de base

| Quantité | Composant | Prix estimé |
|----------|-----------|-------------|
| 1 | Carte ESP8266 NodeMCU | ~8€ |
| 1 | Capteur température DHT22 | ~3€ |
| 1 | Capteur gaz MQ-4 | ~4€ |
| 1 | Capteur pression BMP280 | ~5€ |
| 1 | Capteur ultrason HC-SR04 | ~2€ |
| 1 | Breadboard 400 points | ~3€ |
| 1 | Kit fils jumper (40 pcs) | ~2€ |
| 1 | Câble USB Micro-USB | ~2€ |
| 1 | Alimentation 5V 2A | ~5€ |

**Total estimé : ~34€**

### Fournisseurs recommandés

- AliExpress (livraison 2-4 semaines)
- Amazon (livraison rapide)
- Locaux : revendeurs électronique Burkina Faso

---

## Licence

Projet privé - BioSmart Africa / BioDigit

---

## Contact

Développé pour le monitoring de biodigesteurs au Burkina Faso.
Plateau Central, Burkina Faso.
