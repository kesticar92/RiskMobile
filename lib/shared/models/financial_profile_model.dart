import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import '../../core/constants/app_constants.dart';

class FinancialObligation {
  final String entity;
  final String creditType;
  final double monthlyPayment;
  final double? balance;

  /// RF12: nombre del extracto bancario adjunto como soporte de la obligación.
  final String? bankExtractFileName;

  /// Identidad estable en la UI (entrevista); no se persiste en Firestore.
  final String? clientRowId;

  const FinancialObligation({
    required this.entity,
    required this.creditType,
    required this.monthlyPayment,
    this.balance,
    this.bankExtractFileName,
    this.clientRowId,
  });

  /// Solo campos que van a Firestore (sin `clientRowId`).
  Map<String, dynamic> toFirestoreMap() => {
        'entity': entity,
        'creditType': creditType,
        'monthlyPayment': monthlyPayment,
        'balance': balance,
        'bankExtractFileName': bankExtractFileName,
      };

  Map<String, dynamic> toMap() => toFirestoreMap();

  FinancialObligation copyWith({
    String? entity,
    String? creditType,
    double? monthlyPayment,
    double? balance,
    String? bankExtractFileName,
    String? clientRowId,
  }) =>
      FinancialObligation(
        entity: entity ?? this.entity,
        creditType: creditType ?? this.creditType,
        monthlyPayment: monthlyPayment ?? this.monthlyPayment,
        balance: balance ?? this.balance,
        bankExtractFileName: bankExtractFileName ?? this.bankExtractFileName,
        clientRowId: clientRowId ?? this.clientRowId,
      );

  factory FinancialObligation.fromMap(Map<String, dynamic> map) =>
      FinancialObligation(
        entity: map['entity'] ?? '',
        creditType: map['creditType'] ?? '',
        monthlyPayment: (map['monthlyPayment'] ?? 0).toDouble(),
        balance: map['balance']?.toDouble(),
        bankExtractFileName: map['bankExtractFileName'] as String?,
        clientRowId: null,
      );
}

class FinancialProfileModel {
  final String id;
  final String clientId;
  final String clientName;

  // Actividad económica
  final String economicActivity;
  final String? contractType;
  final int seniorityMonths;
  final double monthlyIncome;

  // Obligaciones
  final List<FinancialObligation> obligations;

  // Cálculos derivados
  double get totalMonthlyPayments =>
      obligations.fold(0, (acc, o) => acc + o.monthlyPayment);

  double get debtLevel =>
      monthlyIncome > 0 ? totalMonthlyPayments / monthlyIncome : 0;

  double get availableCapacity =>
      math.max(0, (monthlyIncome * AppConstants.debtCapacityLimit) - totalMonthlyPayments);

  // Intención del cliente
  double desiredAmount;
  String? desiredCreditType;

  // Score RiskMobile
  int riskScore;

  String get riskLabel {
    if (riskScore >= AppConstants.scoreRiskLow) return 'Riesgo Bajo';
    if (riskScore >= AppConstants.scoreRiskMedium) return 'Riesgo Medio';
    if (riskScore >= AppConstants.scoreRiskHigh) return 'Riesgo Alto';
    return 'Riesgo Muy Alto';
  }

  String get debtLevelLabel {
    final pct = (debtLevel * 100).toStringAsFixed(1);
    if (debtLevel < 0.30) return 'Nivel bajo ($pct%)';
    if (debtLevel < 0.40) return 'Nivel medio ($pct%)';
    return 'Nivel alto ($pct%)';
  }

  // Estado del caso
  String caseStatus;

  // Metadatos
  final DateTime createdAt;
  DateTime updatedAt;

  // Monto estimado viable (calculado por el simulador)
  double? estimatedViableAmount;

  /// Nota interna del asesor (solo CRM). No se envía desde flujos cliente en toFirestore.
  final String? advisorInternalNote;
  final DateTime? advisorNoteUpdatedAt;

  /// Prioridad alta marcada por el asesor (solo vía CRM). No va en toFirestore del cliente.
  final bool casePriority;

  FinancialProfileModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.economicActivity,
    this.contractType,
    this.seniorityMonths = 0,
    required this.monthlyIncome,
    required this.obligations,
    this.desiredAmount = 0,
    this.desiredCreditType,
    this.riskScore = 0,
    this.caseStatus = 'Entrevista completada',
    required this.createdAt,
    required this.updatedAt,
    this.estimatedViableAmount,
    this.advisorInternalNote,
    this.advisorNoteUpdatedAt,
    this.casePriority = false,
  });

  factory FinancialProfileModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return FinancialProfileModel(
      id: doc.id,
      clientId: d['clientId'] ?? '',
      clientName: d['clientName'] ?? '',
      economicActivity: d['economicActivity'] ?? '',
      contractType: d['contractType'],
      seniorityMonths: (d['seniorityMonths'] ?? 0).toInt(),
      monthlyIncome: (d['monthlyIncome'] ?? 0).toDouble(),
      obligations: (d['obligations'] as List<dynamic>? ?? [])
          .map((o) => FinancialObligation.fromMap(o as Map<String, dynamic>))
          .toList(),
      desiredAmount: (d['desiredAmount'] ?? 0).toDouble(),
      desiredCreditType: d['desiredCreditType'],
      riskScore: (d['riskScore'] ?? 0).toInt(),
      caseStatus: d['caseStatus'] ?? 'Entrevista completada',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      estimatedViableAmount: d['estimatedViableAmount']?.toDouble(),
      advisorInternalNote: d['advisorInternalNote'] as String?,
      advisorNoteUpdatedAt:
          (d['advisorNoteUpdatedAt'] as Timestamp?)?.toDate(),
      casePriority: d['casePriority'] == true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clientId': clientId,
      'clientName': clientName,
      'economicActivity': economicActivity,
      'contractType': contractType,
      'seniorityMonths': seniorityMonths,
      'monthlyIncome': monthlyIncome,
      'obligations': obligations.map((o) => o.toFirestoreMap()).toList(),
      'totalMonthlyPayments': totalMonthlyPayments,
      'debtLevel': debtLevel,
      'availableCapacity': availableCapacity,
      'desiredAmount': desiredAmount,
      'desiredCreditType': desiredCreditType,
      'riskScore': riskScore,
      'caseStatus': caseStatus,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'estimatedViableAmount': estimatedViableAmount,
    };
  }
}
