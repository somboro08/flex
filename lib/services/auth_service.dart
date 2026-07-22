import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Identifiant Google
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '272797549782-asb4ov7vib75dhi09uukr8riod1bk9c4.apps.googleusercontent.com',
  );

  // --- CONFIGURATION DEV ---
  // Mettez à 'true' pour passer l'erreur Google et accéder à l'app
  bool get isMockMode => true; 
  // --------------------------

  Stream<User?> get user => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<dynamic> signInWithGoogle() async {
    if (isMockMode) {
      debugPrint('--- MODE SIMULATION ACTIVÉ ---');
      await Future.delayed(const Duration(seconds: 1)); // Simule un temps de chargement
      debugPrint('Simulation : Connexion Google réussie (Mock)');
      return "mock_user_credential"; // On retourne une chaîne non-nulle pour valider le succès
    }

    try {
      debugPrint('--- DEBUT GOOGLE SIGN-IN REEL ---');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Erreur réelle Google : $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (isMockMode) {
      debugPrint('Simulation : Déconnexion (Mock)');
      return;
    }
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Simulation pour le téléphone aussi si besoin
  Future<void> verifyPhone({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    if (isMockMode) {
      await Future.delayed(const Duration(seconds: 1));
      codeSent("mock_verification_id", 123456);
      return;
    }
    // ... reste de l'implémentation réelle
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 60),
    );
  }
}
