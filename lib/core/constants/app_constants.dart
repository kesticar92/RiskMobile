class AppConstants {
  // App info
  static const String appName = 'RiskMobile';
  static const String appTagline = 'Tu asesoría crediticia, en tu mano';
  static const String appVersion = '1.0.0';

  // Score RiskMobile thresholds
  static const int scoreRiskLow = 80;
  static const int scoreRiskMedium = 60;
  static const int scoreRiskHigh = 40;

  // Debt capacity limit (% standard)
  static const double debtCapacityLimit = 0.40; // 40%
  static const double debtCapacityIdeal = 0.30; // 30%

  // Credit types
  static const List<String> creditTypes = [
    'Libre inversión',
    'Vivienda',
    'Vehículo',
    'Libranza',
    'Crédito educativo',
    'Microcrédito',
  ];

  // Economic activity types
  static const List<String> economicActivities = [
    'Empleado',
    'Independiente',
    'Pensionado',
    'Comerciante',
    'Profesional independiente',
  ];

  // Case states
  static const String caseInterviewDone = 'Entrevista completada';
  static const String caseAnalysisInProgress = 'Análisis en proceso';
  static const String caseDocumentsPending = 'Documentos pendientes';
  static const String caseFiledRequest = 'Solicitud radicada';
  static const String caseCreditApproved = 'Crédito aprobado';
  static const String caseCreditRejected = 'Crédito rechazado';

  static const List<String> caseStates = [
    caseInterviewDone,
    caseAnalysisInProgress,
    caseDocumentsPending,
    caseFiledRequest,
    caseCreditApproved,
    caseCreditRejected,
  ];

  static bool isCaseInProgress(String? caseStatus) {
    if (caseStatus == null || caseStatus.isEmpty) return false;
    return caseStatus != caseCreditApproved &&
        caseStatus != caseCreditRejected;
  }

  // Document review states (RF38)
  static const String documentPendingReview = 'Pendiente de revisión';
  static const String documentApproved = 'Aprobado';
  static const String documentRejectedNeedsResend = 'Rechazado (requiere reenvío)';

  static const List<String> documentStates = [
    documentPendingReview,
    documentApproved,
    documentRejectedNeedsResend,
  ];

  // Score calculation weights
  static const double weightPaymentCapacity = 0.40;
  static const double weightDebtLevel = 0.30;
  static const double weightLaborStability = 0.20;
  static const double weightFinancialHistory = 0.10;

  // Simulator defaults
  static const double defaultInterestRate = 1.5;
  static const double minInterestRate = 0.5;
  static const double maxInterestRate = 4.0;
  static const int defaultTermMonths = 36;
  static const int minTermMonths = 6;
  static const int maxTermMonths = 240;

  // Firestore collections
  static const String colUsers = 'users';
  static const String colCases = 'cases';
  static const String colMessages = 'messages';
  static const String colDocuments = 'documents';
  static const String colCommissions = 'commissions';
  static const String colNotifications = 'notifications';
  static const String colPayments = 'payments';

  // User roles
  static const String roleClient = 'client';
  static const String roleAdvisor = 'advisor';

  // Storage paths
  static const String storageDocuments = 'documents';
  static const String storageAvatars = 'avatars';
}
