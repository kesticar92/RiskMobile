import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/financial_profile_model.dart';
import '../../shared/models/user_model.dart';
import '../constants/app_constants.dart';
import '../utils/risk_calculator.dart';

final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---- Financial Profiles ----

  Future<String> saveFinancialProfile(FinancialProfileModel profile) async {
    final score = RiskCalculator.calculateScore(
      monthlyIncome: profile.monthlyIncome,
      totalMonthlyObligations: profile.totalMonthlyPayments,
      economicActivity: profile.economicActivity,
      hasFinancialHistory: profile.obligations.isNotEmpty,
      monthsInActivity: profile.seniorityMonths,
    );

    final data = profile.toFirestore();
    data['riskScore'] = score;

    if (profile.id.isEmpty) {
      final ref = await _db.collection(AppConstants.colCases).add(data);
      return ref.id;
    } else {
      await _db.collection(AppConstants.colCases).doc(profile.id).update(data);
      return profile.id;
    }
  }

  Future<FinancialProfileModel?> getFinancialProfile(String id) async {
    final doc = await _db.collection(AppConstants.colCases).doc(id).get();
    if (!doc.exists) return null;
    return FinancialProfileModel.fromFirestore(doc);
  }

  Stream<List<FinancialProfileModel>> streamClientProfiles(String clientId) {
    return _db
        .collection(AppConstants.colCases)
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(FinancialProfileModel.fromFirestore).toList());
  }

  Stream<List<FinancialProfileModel>> streamAllProfiles() {
    return _db
        .collection(AppConstants.colCases)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(FinancialProfileModel.fromFirestore).toList());
  }

  Future<void> updateCaseStatus(String caseId, String newStatus) async {
    await _db.collection(AppConstants.colCases).doc(caseId).update({
      'caseStatus': newStatus,
      'updatedAt': Timestamp.now(),
    });
  }

  // ---- Messages / Chat ----

  Stream<QuerySnapshot> streamMessages(String chatId) {
    return _db
        .collection(AppConstants.colMessages)
        .doc(chatId)
        .collection('chat')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String content,
  }) async {
    await _db
        .collection(AppConstants.colMessages)
        .doc(chatId)
        .collection('chat')
        .add({
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': Timestamp.now(),
    });
  }

  // ---- Commissions ----

  Future<void> saveCommission({
    required String advisorId,
    required String clientId,
    required String clientName,
    required double creditAmount,
    required double commissionAmount,
    required double costs,
    required String caseId,
  }) async {
    await _db.collection(AppConstants.colCommissions).add({
      'advisorId': advisorId,
      'clientId': clientId,
      'clientName': clientName,
      'creditAmount': creditAmount,
      'commissionAmount': commissionAmount,
      'costs': costs,
      'profit': commissionAmount - costs,
      'caseId': caseId,
      'createdAt': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> streamAdvisorCommissions(String advisorId) {
    return _db
        .collection(AppConstants.colCommissions)
        .where('advisorId', isEqualTo: advisorId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ---- Users ----

  Stream<List<UserModel>> streamUsers() {
    return _db
        .collection(AppConstants.colUsers)
        .snapshots()
        .map((s) => s.docs.map(UserModel.fromFirestore).toList());
  }

  /// Primer usuario con rol asesor (para que el cliente abra el mismo chatId que el asesor real).
  Future<UserModel?> getFirstAdvisorUser() async {
    final q = await _db
        .collection(AppConstants.colUsers)
        .where('role', isEqualTo: AppConstants.roleAdvisor)
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    return UserModel.fromFirestore(q.docs.first);
  }
}
