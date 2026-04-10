import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../../shared/models/user_model.dart';
import '../constants/app_constants.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _db.collection(AppConstants.colUsers).doc(uid).get();
      if (doc.exists) return UserModel.fromFirestore(doc);
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phone,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    try {
      await credential.user!.updateDisplayName(name);

      final user = UserModel(
        id: credential.user!.uid,
        name: name,
        email: email,
        role: role,
        phone: phone?.isEmpty == true ? null : phone,
        createdAt: DateTime.now(),
      );

      await _db
          .collection(AppConstants.colUsers)
          .doc(credential.user!.uid)
          .set(user.toFirestore());

      return user;
    } catch (e) {
      await credential.user?.delete();
      rethrow;
    }
  }

  Future<UserModel?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return getUserData(credential.user!.uid);
  }

  Future<bool> get canUseBiometrics async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      return supported && canCheck;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      if (!await canUseBiometrics) return false;

      return await _localAuth.authenticate(
        localizedReason: 'Autentícate para acceder a RiskMobile',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
