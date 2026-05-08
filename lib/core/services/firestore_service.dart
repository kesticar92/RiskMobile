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
      'lastStatusChangeAt': Timestamp.now(),
    });
  }

  /// RF-K5: nota interna visible solo en CRM asesor.
  Future<void> updateCaseAdvisorNote({
    required String caseId,
    required String note,
  }) async {
    await _db.collection(AppConstants.colCases).doc(caseId).update({
      'advisorInternalNote': note,
      'advisorNoteUpdatedAt': Timestamp.now(),
    });
  }

  /// RF-K10: prioridad alta en cartera (solo asesor).
  Future<void> updateCasePriority({
    required String caseId,
    required bool priority,
  }) async {
    await _db.collection(AppConstants.colCases).doc(caseId).update({
      'casePriority': priority,
      'updatedAt': Timestamp.now(),
    });
  }

  /// RF-K15
  Future<void> updateCaseNextFollowUp({
    required String caseId,
    DateTime? at,
  }) async {
    if (at == null) {
      await _db.collection(AppConstants.colCases).doc(caseId).update({
        'nextFollowUpAt': FieldValue.delete(),
        'updatedAt': Timestamp.now(),
      });
    } else {
      await _db.collection(AppConstants.colCases).doc(caseId).update({
        'nextFollowUpAt': Timestamp.fromDate(at),
        'updatedAt': Timestamp.now(),
      });
    }
  }

  /// RF-K16 — lista normalizada (máx. 8 strings no vacíos).
  Future<void> updateCaseTags({
    required String caseId,
    required List<String> tags,
  }) async {
    final seen = <String>{};
    final normalized = <String>[];
    for (final raw in tags) {
      final t = raw.trim().toLowerCase();
      if (t.isEmpty || seen.contains(t)) continue;
      seen.add(t);
      normalized.add(t);
      if (normalized.length >= 8) break;
    }
    await _db.collection(AppConstants.colCases).doc(caseId).update({
      'caseTags': normalized,
      'updatedAt': Timestamp.now(),
    });
  }

  /// RF-K17
  Future<void> updateCaseArchived({
    required String caseId,
    required bool archived,
  }) async {
    await _db.collection(AppConstants.colCases).doc(caseId).update({
      'caseArchived': archived,
      'updatedAt': Timestamp.now(),
    });
  }

  /// RF-K19: texto plano para portapapeles (orden cronológico).
  Future<String> getCaseStatusHistoryPlainText({
    required String caseId,
    required String clientName,
  }) async {
    final snap = await _db
        .collection(AppConstants.colCases)
        .doc(caseId)
        .collection('caseStatusHistory')
        .orderBy('changedAt', descending: false)
        .get();
    final b = StringBuffer()
      ..writeln('RiskMobile — historial de estados')
      ..writeln('Caso: $caseId')
      ..writeln('Cliente: $clientName')
      ..writeln();
    if (snap.docs.isEmpty) {
      b.writeln('(Sin registros de cambios de estado.)');
      return b.toString();
    }
    for (final doc in snap.docs) {
      final m = doc.data();
      final from = (m['fromStatus'] as String?) ?? '';
      final to = (m['toStatus'] as String?) ?? '';
      final by = (m['changedByName'] as String?)?.trim();
      final at = (m['changedAt'] as Timestamp?)?.toDate();
      final dateStr = at != null ? _formatPlainTimestamp(at) : '';
      b.write('$dateStr\t$from → $to');
      if (by != null && by.isNotEmpty) b.write('\t($by)');
      b.writeln();
    }
    return b.toString();
  }

  String _formatPlainTimestamp(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$y-$mo-$d $h:$mi';
  }

  Future<void> appendCaseStatusHistory({
    required String caseId,
    required String fromStatus,
    required String toStatus,
    required String changedByUid,
    String? changedByName,
  }) async {
    await _db
        .collection(AppConstants.colCases)
        .doc(caseId)
        .collection('caseStatusHistory')
        .add({
      'fromStatus': fromStatus,
      'toStatus': toStatus,
      'changedByUid': changedByUid,
      'changedByName': changedByName,
      'changedAt': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> streamCaseStatusHistory(String caseId) {
    return _db
        .collection(AppConstants.colCases)
        .doc(caseId)
        .collection('caseStatusHistory')
        .orderBy('changedAt', descending: true)
        .snapshots();
  }

  /// Ultimo caso del cliente (para adjuntar documentos a ese caso). RF35.
  Future<String?> getLatestCaseIdForClient(String clientId) async {
    final q = await _db
        .collection(AppConstants.colCases)
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    return q.docs.first.id;
  }

  /// Registro de documento subido (metadatos + URL). RF35.
  Future<void> saveDocumentMetadata({
    required String userId,
    required String caseId,
    required String fileName,
    required String storagePath,
    required String downloadUrl,
    required String mimeType,
    required String documentType,
  }) async {
    await _db.collection(AppConstants.colDocuments).add({
      'userId': userId,
      'caseId': caseId,
      'fileName': fileName,
      'storagePath': storagePath,
      'downloadUrl': downloadUrl,
      'mimeType': mimeType,
      'documentType': documentType,
      'status': AppConstants.documentPendingReview,
      'createdAt': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> streamCaseDocuments(String caseId) {
    return _db
        .collection(AppConstants.colDocuments)
        .where('caseId', isEqualTo: caseId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> streamUserCaseDocuments({
    required String userId,
    required String caseId,
  }) {
    return _db
        .collection(AppConstants.colDocuments)
        .where('userId', isEqualTo: userId)
        .where('caseId', isEqualTo: caseId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateDocumentStatus(String documentId, String newStatus) async {
    await _db.collection(AppConstants.colDocuments).doc(documentId).update({
      'status': newStatus,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    String? caseId,
    String? documentId,
    String? type,
  }) async {
    await _db.collection(AppConstants.colNotifications).add({
      'userId': userId,
      'title': title,
      'message': message,
      'caseId': caseId,
      'documentId': documentId,
      'type': type ?? 'info',
      'read': false,
      'createdAt': Timestamp.now(),
    });
  }

  Stream<int> streamUnreadNotificationCount(String userId) {
    return _db
        .collection(AppConstants.colNotifications)
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }

  /// RF-B8: hay avisos sin leer de tipo reenvío de documento.
  Stream<bool> streamHasUnreadDocumentRejected(String userId) {
    return _db
        .collection(AppConstants.colNotifications)
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map(
          (s) => s.docs.any(
            (d) => (d.data()['type'] as String?) == 'document_rejected',
          ),
        );
  }

  Future<void> saveSimulationResult({
    required String caseId,
    required double desiredAmount,
    required String desiredCreditType,
    required double estimatedViableAmount,
  }) async {
    await _db.collection(AppConstants.colCases).doc(caseId).update({
      'desiredAmount': desiredAmount,
      'desiredCreditType': desiredCreditType,
      'estimatedViableAmount': estimatedViableAmount,
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
