import 'app_constants.dart';

/// Parámetros de simulación por **línea de crédito** (tasa referencia, plazos, tope de monto).
///
/// El cupo máximo estimado (PV) se calcula con capacidad de pago + tasa + plazo;
/// si [maxAmountCap] > 0, el monto viable no supera ese tope (p. ej. microcrédito).
class CreditLineParams {
  /// Tasa de interés mensual de referencia (%), dentro del rango global del simulador.
  final double referenceMonthlyRate;

  /// Plazo por defecto al elegir esta línea (meses).
  final int defaultTermMonths;

  final int minTermMonths;
  final int maxTermMonths;

  /// Tope máximo de crédito en pesos (0 = sin tope además del PV).
  final double maxAmountCap;

  const CreditLineParams({
    required this.referenceMonthlyRate,
    required this.defaultTermMonths,
    required this.minTermMonths,
    required this.maxTermMonths,
    this.maxAmountCap = 0,
  });
}

class CreditLineParamsRegistry {
  CreditLineParamsRegistry._();

  static const CreditLineParams _fallback = CreditLineParams(
    referenceMonthlyRate: 1.5,
    defaultTermMonths: 36,
    minTermMonths: 6,
    maxTermMonths: 120,
  );

  /// Parámetros por tipo de crédito (alineados a [AppConstants.creditTypes]).
  static CreditLineParams forLine(String creditType) {
    switch (creditType) {
      case 'Libre inversión':
        return const CreditLineParams(
          referenceMonthlyRate: 1.5,
          defaultTermMonths: 48,
          minTermMonths: 6,
          maxTermMonths: 120,
        );
      case 'Vivienda':
        return const CreditLineParams(
          referenceMonthlyRate: 1.0,
          defaultTermMonths: 240,
          minTermMonths: 60,
          maxTermMonths: 240,
        );
      case 'Vehículo':
        return const CreditLineParams(
          referenceMonthlyRate: 1.4,
          defaultTermMonths: 60,
          minTermMonths: 12,
          maxTermMonths: 84,
        );
      case 'Libranza':
        return const CreditLineParams(
          referenceMonthlyRate: 1.2,
          defaultTermMonths: 48,
          minTermMonths: 12,
          maxTermMonths: 84,
        );
      case 'Crédito educativo':
        return const CreditLineParams(
          referenceMonthlyRate: 1.3,
          defaultTermMonths: 36,
          minTermMonths: 6,
          maxTermMonths: 120,
        );
      case 'Microcrédito':
        return const CreditLineParams(
          referenceMonthlyRate: 2.0,
          defaultTermMonths: 24,
          minTermMonths: 6,
          maxTermMonths: 36,
          maxAmountCap: 15000000,
        );
      default:
        return _fallback;
    }
  }

  static double clampRate(double reference) {
    return reference.clamp(
      AppConstants.minInterestRate,
      AppConstants.maxInterestRate,
    );
  }

  /// RF18: presets 6M, 1A, 2A, 3A, 5A, 7A dentro del rango de la línea.
  static List<int> quickTermPresetsForLine(String creditType) {
    final p = forLine(creditType);
    return AppConstants.globalTermPresetsMonths
        .where((m) => m >= p.minTermMonths && m <= p.maxTermMonths)
        .toList();
  }

  static String presetLabel(int months) {
    switch (months) {
      case 6:
        return '6M';
      case 12:
        return '1A';
      case 24:
        return '2A';
      case 36:
        return '3A';
      case 60:
        return '5A';
      case 84:
        return '7A';
      default:
        return months >= 12 ? '${months ~/ 12}A' : '${months}M';
    }
  }

  /// RF18: plazo en múltiplos de 6 meses dentro del rango del producto.
  static int snapTermMonths(int value, CreditLineParams line) {
    final min = line.minTermMonths;
    final max = line.maxTermMonths;
    final clamped = value.clamp(min, max);
    final stepsFromMin = ((clamped - min) / 6).round();
    final snapped = min + stepsFromMin * 6;
    return snapped.clamp(min, max);
  }
}
