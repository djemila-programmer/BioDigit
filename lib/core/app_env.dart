import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  static String get supabaseUrl => _required('SUPABASE_URL', fallback: 'NEXT_PUBLIC_SUPABASE_URL');
  static String get supabaseAnonKey => _required('SUPABASE_ANON_KEY', fallback: 'NEXT_PUBLIC_SUPABASE_ANON_KEY');
  static String get supabaseRedirectUrl => _optional('SUPABASE_REDIRECT_URL') ?? 'biodigitapp://reset-password';
  static String get appName => _optional('APP_NAME') ?? 'BioDigit';
  static String get appUrl => _optional('APP_URL') ?? '';

  static String _required(String key, {String? fallback}) {
    final value = dotenv.env[key]?.trim().isNotEmpty == true ? dotenv.env[key]!.trim() : null;
    if (value != null) return value;

    if (fallback != null) {
      final fallbackValue = dotenv.env[fallback]?.trim().isNotEmpty == true ? dotenv.env[fallback]!.trim() : null;
      if (fallbackValue != null) return fallbackValue;
    }

    throw StateError('Missing required environment variable: $key');
  }

  static String? _optional(String key) {
    final value = dotenv.env[key]?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }
}