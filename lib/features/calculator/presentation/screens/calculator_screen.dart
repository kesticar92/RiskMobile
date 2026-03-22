import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/navigation_helpers.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/financial_profile_model.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/risk_score_widget.dart';

class CalculatorScreen extends ConsumerStatefulWidget {
  final String? profileId;
  const CalculatorScreen({super.key, this.profileId});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  FinancialProfileModel? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.profileId == null) {
      setState(() => _isLoading = false);
      return;
    }
    final profile = await ref.read(firestoreServiceProvider).getFinancialProfile(widget.profileId!);
    setState(() {
      _profile = profile;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _profile == null
                      ? _buildEmpty()
                      : _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => popOrGo(context, AppRoutes.clientHome),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.arrow_back_ios_new, size: 16),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Text('Perfil financiero',
              style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.analytics_outlined, size: 60, color: AppColors.textLight),
          const SizedBox(height: 12),
          Text('No hay datos', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          GradientButton(
            label: 'Realizar entrevista',
            onPressed: () => context.push(AppRoutes.interview),
            width: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final p = _profile!;
    final debtPct = p.debtLevel * 100;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Score card
          GlassCard(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                Text('Score RiskMobile',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text('Tu perfil de riesgo financiero',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
                RiskScoreWidget(
                  score: p.riskScore,
                  label: p.riskLabel,
                  size: 140,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.blueTranslucent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline,
                          size: 18, color: AppColors.primaryBlueDark),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'El Score RiskMobile es informativo y se calcula con los datos que declaras. '
                          'No reemplaza el score oficial de Datacrédito u otras centrales de riesgo.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryBlueDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
          const SizedBox(height: 16),
          // Debt level
          GlassCard(
            child: DebtGaugeWidget(debtPercentage: debtPct),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
          const SizedBox(height: 16),
          // Financial summary
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'Ingresos\nmensuales',
                  value: AppFormatters.currency(p.monthlyIncome),
                  icon: Icons.trending_up,
                  color: AppColors.riskLow,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  label: 'Total cuotas\nactuales',
                  value: AppFormatters.currency(p.totalMonthlyPayments),
                  icon: Icons.trending_down,
                  color: p.debtLevel > 0.4 ? AppColors.riskHigh : AppColors.riskMedium,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'Capacidad\ndisponible',
                  value: AppFormatters.currency(p.availableCapacity),
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  label: 'Monto\ndeseado',
                  value: AppFormatters.currency(p.desiredAmount),
                  icon: Icons.stars_outlined,
                  color: AppColors.secondaryPurple,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),
          // Gap analysis
          if (p.availableCapacity > 0)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: AppColors.primaryBlueDark),
                      const SizedBox(width: 8),
                      Text('Análisis de capacidad',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (p.desiredAmount > 0)
                    _buildGapRow(p),
                  const Divider(height: 20),
                  Text(
                    'Con tu capacidad mensual disponible de ${AppFormatters.currency(p.availableCapacity)}, '
                    'podrías acceder a créditos estimados entre '
                    '${AppFormatters.compactCurrency(p.availableCapacity * 12)} y '
                    '${AppFormatters.compactCurrency(p.availableCapacity * 60)} '
                    'dependiendo del plazo y la tasa.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 250.ms),
          const SizedBox(height: 24),
          // Actions
          GradientButton(
            label: 'Ir al simulador de crédito',
            onPressed: () => context.push(AppRoutes.simulator, extra: _profile!.id),
            icon: Icons.calculate_outlined,
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.push(
              AppRoutes.chat,
              extra: {
                'otherUserId': 'advisor',
                'otherUserName': 'Asesor financiero',
                'caseId': _profile!.id,
              },
            ),
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Hablar con un asesor'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ).animate().fadeIn(delay: 350.ms),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGapRow(FinancialProfileModel p) {
    final gap = p.desiredAmount - p.availableCapacity;
    final feasible = p.availableCapacity >= (p.desiredAmount * 0.01);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Monto deseado', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text(AppFormatters.currency(p.desiredAmount),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: feasible ? AppColors.riskLow.withOpacity(0.1) : AppColors.riskHigh.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                feasible ? Icons.check_circle_outline : Icons.warning_outlined,
                size: 14,
                color: feasible ? AppColors.riskLow : AppColors.riskHigh,
              ),
              const SizedBox(width: 4),
              Text(
                feasible ? 'Viable' : 'Brecha: ${AppFormatters.compactCurrency(gap.abs())}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: feasible ? AppColors.riskLow : AppColors.riskHigh,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
