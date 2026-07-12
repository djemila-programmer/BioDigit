-- ═══════════════════════════════════════════════════════════════
-- BioDigit - Script SQL Complet pour Supabase
-- ═══════════════════════════════════════════════════════════════
-- Exécuter ce script dans Supabase SQL Editor
-- Supabase Dashboard → SQL Editor → New Query → Coller ce script → Run
-- ═══════════════════════════════════════════════════════════════

-- 1. PROFILS UTILISATEURS
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL DEFAULT '',
  email TEXT NOT NULL UNIQUE,  -- UNIQUE: un seul compte par email
  phone TEXT DEFAULT '',
  farm_name TEXT DEFAULT '',
  role TEXT DEFAULT 'user',
  profile_image_url TEXT DEFAULT '',
  biodigester_type TEXT,
  biodigester_capacity DOUBLE PRECISION,
  location TEXT DEFAULT 'Plateau Central, Burkina Faso',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. LECTURES CAPTEURS (Temps réel)
CREATE TABLE IF NOT EXISTS sensor_readings (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
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

-- 3. STATUT ESP8266
CREATE TABLE IF NOT EXISTS esp32_status (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  connected BOOLEAN DEFAULT false,
  wifi_signal INTEGER DEFAULT 0,
  firmware_version TEXT DEFAULT 'N/A',
  battery_level INTEGER DEFAULT 0,
  ip_address TEXT DEFAULT 'N/A',
  cpu_temp DOUBLE PRECISION DEFAULT 0,
  uptime TEXT DEFAULT '0',
  last_sync TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. ALERTES
CREATE TABLE IF NOT EXISTS alerts (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL DEFAULT '',
  description TEXT DEFAULT '',
  severity TEXT DEFAULT 'info',
  sensor_id TEXT DEFAULT '',
  location TEXT DEFAULT '',
  acknowledged BOOLEAN DEFAULT false,
  resolved BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. CONFIGURATION (seuils, etc.)
CREATE TABLE IF NOT EXISTS config (
  id BIGSERIAL PRIMARY KEY,
  key TEXT UNIQUE NOT NULL,
  value JSONB NOT NULL DEFAULT '{}',
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. SANTÉ DES CAPTEURS
CREATE TABLE IF NOT EXISTS sensor_health (
  id TEXT PRIMARY KEY,
  sensor_model TEXT DEFAULT '',
  status TEXT DEFAULT 'unknown',
  battery_level INTEGER DEFAULT 100,
  signal_quality TEXT DEFAULT 'Unknown',
  last_calibration TIMESTAMPTZ,
  next_maintenance TIMESTAMPTZ,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. NOTIFICATIONS
CREATE TABLE IF NOT EXISTS notifications (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL DEFAULT '',
  body TEXT DEFAULT '',
  type TEXT DEFAULT 'info',
  read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. HISTORIQUE ANOMALIES
CREATE TABLE IF NOT EXISTS anomaly_history (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  anomaly_type TEXT DEFAULT '',
  severity TEXT DEFAULT 'info',
  description TEXT DEFAULT '',
  confidence DOUBLE PRECISION DEFAULT 0,
  sensor_data JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. HISTORIQUE LECTURES
CREATE TABLE IF NOT EXISTS history_readings (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  temperature DOUBLE PRECISION DEFAULT 0,
  pressure DOUBLE PRECISION DEFAULT 0,
  methane DOUBLE PRECISION DEFAULT 0,
  slurry_level DOUBLE PRECISION DEFAULT 0,
  period TEXT DEFAULT 'daily',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. FERMES
CREATE TABLE IF NOT EXISTS farms (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL DEFAULT '',
  location TEXT DEFAULT '',
  size DOUBLE PRECISION DEFAULT 0,
  biodigester_type TEXT DEFAULT '',
  biodigester_capacity DOUBLE PRECISION DEFAULT 0,
  cows INTEGER DEFAULT 0,
  pigs INTEGER DEFAULT 0,
  goats INTEGER DEFAULT 0,
  poultry INTEGER DEFAULT 0,
  waste_production DOUBLE PRECISION DEFAULT 0,
  energy_production DOUBLE PRECISION DEFAULT 0,
  status TEXT DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 11. ALIMENTATION (feedings)
CREATE TABLE IF NOT EXISTS feedings (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  farm_id BIGINT REFERENCES farms(id) ON DELETE CASCADE,
  feed_type TEXT DEFAULT '',
  amount DOUBLE PRECISION DEFAULT 0,
  scheduled_time TIMESTAMPTZ DEFAULT NOW(),
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ═══════════════════════════════════════════════════════════════
-- POLITIQUES RLS (Row Level Security)
-- ═══════════════════════════════════════════════════════════════

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE sensor_readings ENABLE ROW LEVEL SECURITY;
ALTER TABLE esp32_status ENABLE ROW LEVEL SECURITY;
ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE config ENABLE ROW LEVEL SECURITY;
ALTER TABLE sensor_health ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE anomaly_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE history_readings ENABLE ROW LEVEL SECURITY;
ALTER TABLE farms ENABLE ROW LEVEL SECURITY;
ALTER TABLE feedings ENABLE ROW LEVEL SECURITY;

-- Politique: chaque utilisateur voit ses propres données
DROP POLICY IF EXISTS "profiles_select" ON profiles;
CREATE POLICY "profiles_select" ON profiles FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "profiles_insert" ON profiles;
CREATE POLICY "profiles_insert" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "profiles_update" ON profiles;
CREATE POLICY "profiles_update" ON profiles FOR UPDATE USING (auth.uid() = id);

-- sensor_readings: l'utilisateur voit SES propres lectures uniquement
DROP POLICY IF EXISTS "sensor_readings_select" ON sensor_readings;
CREATE POLICY "sensor_readings_select" ON sensor_readings FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "sensor_readings_insert" ON sensor_readings;
CREATE POLICY "sensor_readings_insert" ON sensor_readings FOR INSERT WITH CHECK (true);

-- esp32_status: l'utilisateur voit SES propres statuts uniquement
DROP POLICY IF EXISTS "esp32_status_select" ON esp32_status;
CREATE POLICY "esp32_status_select" ON esp32_status FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "esp32_status_insert" ON esp32_status;
CREATE POLICY "esp32_status_insert" ON esp32_status FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "esp32_status_update" ON esp32_status;
CREATE POLICY "esp32_status_update" ON esp32_status FOR UPDATE USING (true);

-- alerts: utilisateur voit ses alertes
DROP POLICY IF EXISTS "alerts_select" ON alerts;
CREATE POLICY "alerts_select" ON alerts FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "alerts_insert" ON alerts;
CREATE POLICY "alerts_insert" ON alerts FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "alerts_update" ON alerts;
CREATE POLICY "alerts_update" ON alerts FOR UPDATE USING (auth.uid() = user_id);

-- config: lecture publique, écriture authentifiée
DROP POLICY IF EXISTS "config_select" ON config;
CREATE POLICY "config_select" ON config FOR SELECT USING (true);

DROP POLICY IF EXISTS "config_upsert" ON config;
CREATE POLICY "config_upsert" ON config FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "config_update" ON config;
CREATE POLICY "config_update" ON config FOR UPDATE USING (auth.uid() IS NOT NULL);

-- sensor_health: lecture/écriture publique (pour capteurs)
DROP POLICY IF EXISTS "sensor_health_select" ON sensor_health;
CREATE POLICY "sensor_health_select" ON sensor_health FOR SELECT USING (true);

DROP POLICY IF EXISTS "sensor_health_upsert" ON sensor_health;
CREATE POLICY "sensor_health_upsert" ON sensor_health FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "sensor_health_update" ON sensor_health;
CREATE POLICY "sensor_health_update" ON sensor_health FOR UPDATE USING (true);

-- notifications: utilisateur voit ses notifications
DROP POLICY IF EXISTS "notifications_select" ON notifications;
CREATE POLICY "notifications_select" ON notifications FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "notifications_insert" ON notifications;
CREATE POLICY "notifications_insert" ON notifications FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "notifications_update" ON notifications;
CREATE POLICY "notifications_update" ON notifications FOR UPDATE USING (auth.uid() = user_id);

-- anomaly_history: utilisateur voit son historique
DROP POLICY IF EXISTS "anomaly_history_select" ON anomaly_history;
CREATE POLICY "anomaly_history_select" ON anomaly_history FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "anomaly_history_insert" ON anomaly_history;
CREATE POLICY "anomaly_history_insert" ON anomaly_history FOR INSERT WITH CHECK (auth.uid() = user_id);

-- history_readings: utilisateur voit son historique
DROP POLICY IF EXISTS "history_readings_select" ON history_readings;
CREATE POLICY "history_readings_select" ON history_readings FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "history_readings_insert" ON history_readings;
CREATE POLICY "history_readings_insert" ON history_readings FOR INSERT WITH CHECK (auth.uid() = user_id);

-- farms: utilisateur voit ses fermes
DROP POLICY IF EXISTS "farms_select" ON farms;
CREATE POLICY "farms_select" ON farms FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "farms_insert" ON farms;
CREATE POLICY "farms_insert" ON farms FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "farms_update" ON farms;
CREATE POLICY "farms_update" ON farms FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "farms_delete" ON farms;
CREATE POLICY "farms_delete" ON farms FOR DELETE USING (auth.uid() = user_id);

-- feedings: utilisateur voit ses alimentations
DROP POLICY IF EXISTS "feedings_select" ON feedings;
CREATE POLICY "feedings_select" ON feedings FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "feedings_insert" ON feedings;
CREATE POLICY "feedings_insert" ON feedings FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "feedings_update" ON feedings;
CREATE POLICY "feedings_update" ON feedings FOR UPDATE USING (auth.uid() = user_id);

-- ═══════════════════════════════════════════════════════════════
-- ACTIVER REALTIME (WebSocket temps réel)
-- ══════════════════════════════════════════════════════════════
-- Note: si une table est déjà dans la publication, cette ligne peut être ignorée

DO $$
BEGIN
  -- Ajouter sensor_readings si pas déjà fait
  IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'sensor_readings') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE sensor_readings;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'esp32_status') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE esp32_status;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'alerts') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE alerts;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'notifications') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
  END IF;
END $$;

-- ═══════════════════════════════════════════════════════════════
-- STORAGE BUCKET (avatars)
-- ═══════════════════════════════════════════════════════════════

INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- Politique storage: chacun peut uploader son avatar
DROP POLICY IF EXISTS "avatars_upload" ON storage.objects;
CREATE POLICY "avatars_upload" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'avatars' AND auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "avatars_read" ON storage.objects;
CREATE POLICY "avatars_read" ON storage.objects
  FOR SELECT USING (bucket_id = 'avatars');

-- ═══════════════════════════════════════════════════════════════
-- DONNÉES INITIALES (seuils par défaut)
-- ═══════════════════════════════════════════════════════════════

INSERT INTO config (key, value) VALUES ('thresholds', '{
  "temperature": {"min": 25.0, "max": 40.0, "unit": "°C"},
  "pressure": {"min": 0.8, "max": 1.5, "unit": "bar"},
  "methane": {"min": 150.0, "max": 500.0, "unit": "ppm"},
  "slurry_level": {"min": 20.0, "max": 90.0, "unit": "%"}
}') ON CONFLICT (key) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════
-- FONCTIONS RPC (pour l'admin - contournent le RLS)
-- ═══════════════════════════════════════════════════════════════

-- Retourne toutes les fermes (admin uniquement)
CREATE OR REPLACE FUNCTION get_all_farms()
RETURNS SETOF farms
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT * FROM farms ORDER BY created_at DESC;
$$;

-- Retourne tous les profils (admin uniquement)
CREATE OR REPLACE FUNCTION get_all_profiles()
RETURNS SETOF profiles
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT * FROM profiles ORDER BY created_at DESC;
$$;

-- Retourne toutes les alertes (admin uniquement)
CREATE OR REPLACE FUNCTION get_all_alerts()
RETURNS SETOF alerts
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT * FROM alerts ORDER BY created_at DESC;
$$;

-- ═══════════════════════════════════════════════════════════════
-- INDEX (performance)
-- ═══════════════════════════════════════════════════════════════

CREATE INDEX IF NOT EXISTS idx_sensor_readings_user ON sensor_readings(user_id);
CREATE INDEX IF NOT EXISTS idx_sensor_readings_created ON sensor_readings(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_esp32_status_user ON esp32_status(user_id);
CREATE INDEX IF NOT EXISTS idx_alerts_user ON alerts(user_id);
CREATE INDEX IF NOT EXISTS idx_alerts_created ON alerts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_history_readings_user ON history_readings(user_id);
CREATE INDEX IF NOT EXISTS idx_history_readings_created ON history_readings(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_anomaly_history_user ON anomaly_history(user_id);
CREATE INDEX IF NOT EXISTS idx_farms_user ON farms(user_id);
CREATE INDEX IF NOT EXISTS idx_feedings_user ON feedings(user_id);

-- ═══════════════════════════════════════════════════════════════
-- COMPTE ADMIN
-- ═══════════════════════════════════════════════════════════════
-- Après avoir créé votre compte via l'application (inscription),
-- exécutez cette requête pour le promouvoir admin :
--
-- UPDATE profiles SET role = 'admin' WHERE email = 'votre@email.com';
--
-- Ou créez un utilisateur directement dans Supabase Dashboard :
-- Authentication → Users → Add user → puis exécutez :
-- ═══════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════
-- NETTOYAGE DOUBLONS (si nécessaire)
-- ═══════════════════════════════════════════════════════════════
-- Si vous avez des doublons d'email dans profiles, exécutez :
--
-- DELETE FROM profiles a USING profiles b
-- WHERE a.id < b.id AND a.email = b.email;
--
-- Puis ajoutez la contrainte UNIQUE :
-- ALTER TABLE profiles ADD CONSTRAINT profiles_email_key UNIQUE (email);
-- ═══════════════════════════════════════════════════════════════
