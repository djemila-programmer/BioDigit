import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app_env.dart';

class SupabaseConfig {
  static String get url => AppEnv.supabaseUrl;
  static String get anonKey => AppEnv.supabaseAnonKey;
}

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey, // ignore: deprecated_member_use
  );
}

SupabaseClient get supabase => Supabase.instance.client;

User? get currentUser => supabase.auth.currentUser;

bool get isAuthenticated => currentUser != null;

Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;
