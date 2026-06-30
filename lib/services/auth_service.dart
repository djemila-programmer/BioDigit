import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../main.dart';
import '../models/user_model.dart';

/// Firebase Authentication service for user registration, login, logout,
/// and password reset.
class AuthService {
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;

  FirebaseAuth? get _authInstance {
    if (!firebaseReady) return null;
    _auth ??= FirebaseAuth.instance;
    return _auth;
  }

  FirebaseFirestore? get _firestoreInstance {
    if (!firebaseReady) return null;
    _firestore ??= FirebaseFirestore.instance;
    return _firestore;
  }

  /// Current authenticated user (null if signed out).
  User? get currentUser => _authInstance?.currentUser;

  /// Auth state stream.
  Stream<User?> get authStateChanges {
    if (_authInstance != null) return _authInstance!.authStateChanges();
    return Stream.value(null);
  }

  /// Sign in with email and password.
  /// expectedRole must be either "admin" or "user".
  Future<UserModel?> signIn({
    required String email,
    required String password,
    required String expectedRole,
  }) async {
    if (_authInstance == null || _firestoreInstance == null) {
      throw AuthException('Firebase non configuré.');
    }
    try {
      final credential = await _authInstance!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        final profile = await _fetchUserProfile(credential.user!.uid);
        if (profile == null) return null;
        if (profile.role != expectedRole) {
          throw AuthException('Rôle incorrect pour ce compte.');
        }
        return profile;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e.code));
    } catch (e) {
      throw AuthException('Erreur inattendue: ${e.toString()}');
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
    if (_authInstance == null || _firestoreInstance == null) {
      throw AuthException('Firebase non configuré.');
    }
    try {
      final credential = await _authInstance!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) throw AuthException('Échec de création du compte.');
      await user.updateDisplayName(fullName);
      final profile = UserModel(
        id: user.uid,
        fullName: fullName,
        email: email,
        phone: phone,
        farmName: farmName,
        role: 'user',
        profileImageUrl: '',
        biodigesterType: biodigesterType,
        biodigesterCapacity: biodigesterCapacity,
        location: location ?? 'Plateau Central, Burkina Faso',
        createdAt: DateTime.now(),
      );
      await _firestoreInstance
          ?.collection('users')
          .doc(user.uid)
          .set(profile.toJson());
      return profile;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e.code));
    } catch (e) {
      throw AuthException('Erreur inattendue: ${e.toString()}');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (_authInstance == null || _firestoreInstance == null) {
      throw AuthException('Firebase non configuré.');
    }
    try {
      await _authInstance!.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e.code));
    }
  }

  Future<void> signOut() async {
    await _authInstance?.signOut();
  }

  Future<UserModel?> _fetchUserProfile(String uid) async {
    final doc = await _firestoreInstance?.collection('users').doc(uid).get();
    if (doc != null && doc.exists) return UserModel.fromJson(doc.data()!);
    return null;
  }

  Future<UserModel?> getCurrentUserProfile() async {
    if (_authInstance == null || _firestoreInstance == null) {
      throw AuthException('Firebase non configuré.');
    }
    final user = _authInstance!.currentUser;
    if (user == null) return null;
    return await _fetchUserProfile(user.uid);
  }

  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    if (_authInstance == null) return;
    final user = _authInstance!.currentUser;
    if (user == null) throw AuthException('Non connecté.');
    await _firestoreInstance?.collection('users').doc(user.uid).update(updates);
  }

  /// Change password for the current user.
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (_authInstance == null || _firestoreInstance == null) {
      throw AuthException('Firebase non configuré.');
    }
    final user = _authInstance!.currentUser;
    if (user == null) throw AuthException('Non connecté.');
    try {
      // Re-authenticate to confirm identity
      final credential = EmailAuthProvider.credential(
        email: user.email ?? '',
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e.code));
    }
  }

  /// Upload avatar image to Firebase Storage and return download URL.
  Future<String?> uploadAvatar(String filePath) async {
    if (_authInstance == null) return null;
    final user = _authInstance!.currentUser;
    if (user == null) throw AuthException('Non connecté.');
    try {
      final ref = FirebaseStorage.instance.ref().child(
        'avatars/${user.uid}.jpg',
      );
      await ref.putFile(File(filePath));
      final url = await ref.getDownloadURL();
      // Update user profile
      await _firestoreInstance?.collection('users').doc(user.uid).update({
        'profileImageUrl': url,
      });
      return url;
    } catch (e) {
      throw AuthException('Erreur upload avatar: ${e.toString()}');
    }
  }

  /// Map Firebase error codes to French messages.
  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Aucun compte trouvé avec cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé.';
      case 'weak-password':
        return 'Le mot de passe est trop faible (min. 6 caractères).';
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard.';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      case 'network-request-failed':
        return 'Erreur réseau. Vérifiez votre connexion.';
      default:
        return 'Erreur d\'authentification: $code';
    }
  }
}

/// Custom auth exception with user-friendly message.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
