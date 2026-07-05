import 'dart:io';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../supabase.dart';
import '../models/user_model.dart';
import '../core/app_env.dart';

/// Supabase Authentication service for user registration, login, logout,
/// and password reset.
class AuthService {
  /// Current authenticated user (null if signed out).
  User? get currentUser => supabase.auth.currentUser;

  /// Auth state stream.
  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;

  /// Sign in with email and password.
  /// expectedRole must be either "admin" or "user".
  Future<UserModel?> signIn({
    required String email,
    required String password,
    required String expectedRole,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw AuthException('Échec de connexion.');
      }
      final profile = await _fetchOrCreateProfile(response.user!, expectedRole);
      if (profile.role != expectedRole) {
        throw AuthException('Rôle incorrect pour ce compte.');
      }
      return profile;
    } on AuthException catch (e) {
      throw AuthException(_mapAuthError(e.message));
    } catch (e) {
      throw AuthException('Erreur inattendue: ${e.toString()}');
    }
  }

  /// Sign in with Google.
  Future<UserModel?> signInWithGoogle({String expectedRole = 'user'}) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException('Connexion Google annulée.');
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );
      if (response.user == null) {
        throw AuthException('Échec de connexion Google.');
      }
      return await _fetchOrCreateProfile(response.user!, expectedRole);
    } on AuthException catch (e) {
      throw AuthException(_mapAuthError(e.message));
    } on MissingPluginException {
      throw AuthException('Google Sign-In n\'est pas disponible sur cette plateforme. Utilisez email/mot de passe.');
    } catch (e) {
      throw AuthException('Erreur Google: ${e.toString()}');
    }
  }

  /// Register a new user with email and password.
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String farmName,
    String? biodigesterType,
    double? biodigesterCapacity,
    String? location,
    String role = 'user',
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
          'farm_name': farmName,
        },
      );
      if (response.user == null) {
        throw AuthException('Échec de création du compte.');
      }
      final profile = UserModel(
        id: response.user!.id,
        fullName: fullName,
        email: email,
        phone: phone,
        farmName: farmName,
        role: role,
        profileImageUrl: '',
        biodigesterType: biodigesterType,
        biodigesterCapacity: biodigesterCapacity,
        location: location ?? 'Plateau Central, Burkina Faso',
        createdAt: DateTime.now(),
      );
      // Insert or update profile in the profiles table
      await supabase.from('profiles').upsert(profile.toJson());
      return profile;
    } on AuthException catch (e) {
      throw AuthException(_mapAuthError(e.message));
    } catch (e) {
      throw AuthException('Erreur inattendue: ${e.toString()}');
    }
  }

  /// Send password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: AppEnv.supabaseRedirectUrl,
      );
    } on AuthException catch (e) {
      throw AuthException(_mapAuthError(e.message));
    }
  }

  /// Complete a recovery flow by setting a brand new password.
  Future<void> completePasswordReset(String newPassword) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw AuthException('Non connecté.');
    try {
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw AuthException(_mapAuthError(e.message));
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  /// Fetch user profile from the profiles table.
  Future<UserModel?> _fetchUserProfile(String uid) async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', uid)
          .maybeSingle();
      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Fetch or create user profile (for OAuth users).
  Future<UserModel> _fetchOrCreateProfile(User user, String role) async {
    var profile = await _fetchUserProfile(user.id);
    if (profile != null) return profile;
    // Create profile
    final newProfile = UserModel(
      id: user.id,
      fullName: user.userMetadata?['full_name'] ?? user.email ?? 'Utilisateur',
      email: user.email ?? '',
      phone: user.userMetadata?['phone'] ?? '',
      farmName: user.userMetadata?['farm_name'] ?? '',
      role: role,
      profileImageUrl: user.userMetadata?['avatar_url'] ?? '',
      biodigesterType: null,
      biodigesterCapacity: null,
      location: 'Plateau Central, Burkina Faso',
      createdAt: DateTime.now(),
    );
    await supabase.from('profiles').upsert(newProfile.toJson());
    return newProfile;
  }

  /// Get current user profile.
  Future<UserModel?> getCurrentUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;
    return await _fetchUserProfile(user.id);
  }

  /// Update user profile fields.
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw AuthException('Non connecté.');
    await supabase.from('profiles').update(updates).eq('id', user.id);
  }

  /// Change password for the current user.
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw AuthException('Non connecté.');
    try {
      // Supabase doesn't require re-authentication for password change
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw AuthException(_mapAuthError(e.message));
    }
  }

  /// Upload avatar image to Supabase Storage and return public URL.
  Future<String?> uploadAvatar(String filePath) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw AuthException('Non connecté.');
    try {
      final file = File(filePath);
      final fileName = '${user.id}.jpg';
      await supabase.storage.from('avatars').upload(fileName, file);
      final publicUrl = supabase.storage.from('avatars').getPublicUrl(fileName);
      // Update user profile
      await supabase.from('profiles').update({
        'profile_image_url': publicUrl,
      }).eq('id', user.id);
      return publicUrl;
    } catch (e) {
      throw AuthException('Erreur upload avatar: ${e.toString()}');
    }
  }

  /// Map Supabase error messages to French messages.
  String _mapAuthError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('missing email') || lower.contains('missing phone') ||
        lower.contains('validation_failed')) {
      return 'Email et mot de passe requis.';
    }
    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid email or password')) {
      return 'Email ou mot de passe incorrect.';
    }
    if (lower.contains('email already registered') ||
        lower.contains('already been registered')) {
      return 'Cet email est déjà utilisé.';
    }
    if (lower.contains('password')) {
      return 'Le mot de passe est trop faible (min. 6 caractères).';
    }
    if (lower.contains('invalid email')) {
      return 'Adresse email invalide.';
    }
    if (lower.contains('too many') || lower.contains('rate limit')) {
      return 'Trop de tentatives. Attendez quelques minutes.';
    }
    if (lower.contains('user disabled') || lower.contains('user banned')) {
      return 'Ce compte a été désactivé.';
    }
    if (lower.contains('network') || lower.contains('connection')) {
      return 'Erreur réseau. Vérifiez votre connexion.';
    }
    return 'Erreur d\'authentification: $message';
  }
}

/// Custom auth exception with user-friendly message.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
