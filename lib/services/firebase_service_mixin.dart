import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../main.dart';

/// Shared lazy Firebase instance accessors. All return null when
/// [firebaseReady] is false so services degrade gracefully without Firebase.
mixin FirebaseServiceMixin {
  FirebaseFirestore? _firestoreInstance;
  FirebaseAuth? _authInstanceField;
  FirebaseMessaging? _messagingInstance;

  FirebaseFirestore? get firestoreOrNull {
    if (!firebaseReady) return null;
    return _firestoreInstance ??= FirebaseFirestore.instance;
  }

  FirebaseAuth? get authOrNull {
    if (!firebaseReady) return null;
    return _authInstanceField ??= FirebaseAuth.instance;
  }

  FirebaseMessaging? get messagingOrNull {
    if (!firebaseReady) return null;
    return _messagingInstance ??= FirebaseMessaging.instance;
  }
}
