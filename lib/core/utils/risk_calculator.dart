import 'dart:math';
import '../constants/app_constants.dart';

/// Motor de evaluación financiera — Score RiskMobile (0–100)
/// Ponderación:
///   40% Capacidad de pago
///   30% Nivel de endeudamiento
///   20% Estabilidad laboral
///   10% Historial financiero declarado
class RiskCalculator {
  /// Calcula el Score RiskMobile
  static int calculateScore({
    required double monthlyIncome,
    required double totalMonthlyObligations,
    required String economicActivity,
    required bool hasFinancialHistory,
    int? monthsInActivity,
  }) {
    // 1. Capacidad de pago (40%)
    final double paymentCapacityRatio = _paymentCapacityScore(
      monthlyIncome,
      totalMonthlyObligations,
    );

    // 2. Nivel de endeudamiento (30%)
    final double debtLevelScore = _debtLevelScore(
      monthlyIncome,
      totalMonthlyObligations,
    );

    // 3. Estabilidad laboral (20%)
    final double stabilityScore = _stabilityScore(
      economicActivity,
      monthsInActivity ?? 0,
    );

    // 4. Historial financiero (10%)
    final double historyScore = hasFinancialHistory ? 80.0 : 60.0;

    final double rawScore =
        (paymentCapacityRatio * AppConstants.weightPaymentCapacity) +
        (debtLevelScore * AppConstants.weightDebtLevel) +
        (stabilityScore * AppConstants.weightLaborStability) +
        (historyScore * AppConstants.weightFinancialHistory);

    return rawScore.clamp(0, 100).round();
  }

  /// Calcula el monto máximo estimado de crédito
  static double calculateMaxCredit({
    required double availableCapacity,
    required double monthlyRate,
    required int termMonths,
  }) {
    if (monthlyRate <= 0 || termMonths <= 0 || availableCapacity <= 0) {
      return 0;
    }
    final double rate = monthlyRate / 100;
    // Fórmula de valor presente de annuity: PV = PMT * (1 - (1+r)^-n) / r
    final double pv =
        availableCapacity * (1 - pow(1 + rate, -termMonths)) / rate;
    return pv;
  }

  /// Calcula la cuota mensual dado un monto de crédito
  static double calculateMonthlyPayment({
    required double principal,
    required double monthlyRate,
    required int termMonths,
  }) {
    if (monthlyRate <= 0 || termMonths <= 0 || principal <= 0) return 0;
    final double rate = monthlyRate / 100;
    // PMT = PV * r * (1+r)^n / ((1+r)^n - 1)
    final double powVal = pow(1 + rate, termMonths).toDouble();
    return principal * rate * powVal / (powVal - 1);
  }

  /// Nivel de endeudamiento en porcentaje
  static double debtPercentage({
    required double monthlyIncome,
    required double totalObligations,
  }) {
    if (monthlyIncome <= 0) return 0;
    return (totalObligations / monthlyIncome) * 100;
  }

  /// Capacidad disponible real
  static double availableCapacity({
    required double monthlyIncome,
    required double totalObligations,
  }) {
    return max(0, (monthlyIncome * AppConstants.debtCapacityLimit) - totalObligations);
  }

  // ---- Helpers privados ----

  static double _paymentCapacityScore(double income, double obligations) {
    if (income <= 0) return 0;
    final capacity = income * AppConstants.debtCapacityLimit - obligations;
    final ratio = capacity / income;
    if (ratio >= 0.40) return 100;
    if (ratio >= 0.30) return 85;
    if (ratio >= 0.20) return 70;
    if (ratio >= 0.10) return 50;
    if (ratio >= 0) return 30;
    return 0;
  }

  static double _debtLevelScore(double income, double obligations) {
    if (income <= 0) return obligations > 0 ? 0 : 100;
    final debtRatio = obligations / income;
    if (debtRatio <= 0.20) return 100;
    if (debtRatio <= 0.30) return 85;
    if (debtRatio <= 0.40) return 65;
    if (debtRatio <= 0.50) return 40;
    if (debtRatio <= 0.70) return 20;
    return 5;
  }

  static double _stabilityScore(String activity, int months) {
    double baseScore;
    switch (activity) {
      case 'Empleado':
        baseScore = 90;
        break;
      case 'Pensionado':
        baseScore = 95;
        break;
      case 'Profesional independiente':
        baseScore = 75;
        break;
      case 'Comerciante':
        baseScore = 70;
        break;
      case 'Independiente':
        baseScore = 65;
        break;
      default:
        baseScore = 60;
    }
    // Bonus por tiempo en actividad
    if (months >= 24) baseScore = min(100, baseScore + 5);
    if (months >= 48) baseScore = min(100, baseScore + 5);
    return baseScore;
  }
}
