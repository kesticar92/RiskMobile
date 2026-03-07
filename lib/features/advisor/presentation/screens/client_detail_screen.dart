import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/financial_profile_model.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/risk_score_widget.dart';

class ClientDetailScreen extends ConsumerStatefulWidget {
  final String profileId;
  const ClientDetailScreen({super.key, required this.profileId});

  @override
  ConsumerState<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends ConsumerState<ClientDetailScreen> {
  FinancialProfileModel? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await ref
        .read(firestoreServiceProvider)
        .getFinancialProfile(widget.profileId);
    setState(() {
      _profile = p;
      _isLoading = false;
    });
  }

  Future<void> _updateStatus(String status) async {
    await ref
        .read(firestoreServiceProvider)
        .updateCaseStatus(widget.profileId, status);
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estado actualizado: $status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cliente')),
        body: const Center(child: Text('No encontrado')),
      );
    }

    final p = _profile!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(p),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Score
                    GlassCard(
                      child: Row(
                        children: [
                          RiskScoreWidget(
                            score: p.riskScore,
                            label: p.riskLabel,
                            size: 90,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Score RiskMobile',
                                    style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 6),
                                DebtGaugeWidget(
                                  debtPercentage: p.debtLevel * 100,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: 16),
                    // Financial summary
                    Text('Perfil financiero',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    _InfoRow('Actividad económica', p.economicActivity),
                    _InfoRow('Ingresos mensuales',
                        AppFormatters.currency(p.monthlyIncome)),
                    _InfoRow('Total cuotas actuales',
                        AppFormatters.currency(p.totalMonthlyPayments)),
                    _InfoRow('Capacidad disponible',
                        AppFormatters.currency(p.availableCapacity),
                        isHighlight: true),
                    _InfoRow('Monto deseado',
                        AppFormatters.currency(p.desiredAmount)),
                    if (p.desiredCreditType != null)
                      _InfoRow('Tipo de crédito', p.desiredCreditType!),
                    const SizedBox(height: 16),
                    // Obligations
                    if (p.obligations.isNotEmpty) ...[
                      Text('Obligaciones actuales',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 10),
                      ...p.obligations.map((o) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.credit_card_outlined,
                                    color: AppColors.secondaryPurple, size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(o.entity,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13)),
                                      Text(o.creditType,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                                Text(
                                  AppFormatters.currency(o.monthlyPayment),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 16),
                    ],
                    // Status update
                    Text('Estado del caso',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: p.caseStatus,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: AppConstants.caseStates
                            .map((s) =>
                                DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) _updateStatus(v);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Actions
                    GradientButton(
                      label: 'Chat con cliente',
                      onPressed: () => context.push(
                        AppRoutes.chat,
                        extra: {
                          'otherUserId': p.clientId,
                          'otherUserName': p.clientName,
                          'caseId': p.id,
                        },
                      ),
                      icon: Icons.chat_bubble_outline,
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => context.push(
                          AppRoutes.simulator, extra: p.id),
                      icon: const Icon(Icons.calculate_outlined),
                      label: const Text('Ver simulador'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(FinancialProfileModel p) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                p.clientName.isNotEmpty ? p.clientName[0].toUpperCase() : '?',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.clientName,
                    style: Theme.of(context).textTheme.headlineSmall),
                Text(AppFormatters.date(p.createdAt),
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _InfoRow(this.label, this.value, {this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
              color: isHighlight ? AppColors.primaryBlue : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
