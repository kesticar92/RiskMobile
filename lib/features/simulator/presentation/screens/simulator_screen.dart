import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/risk_calculator.dart';
import '../../../../shared/models/financial_profile_model.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/gradient_button.dart';

class SimulatorScreen extends ConsumerStatefulWidget {
  final String? profileId;
  const SimulatorScreen({super.key, this.profileId});

  @override
  ConsumerState<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends ConsumerState<SimulatorScreen> {
  FinancialProfileModel? _profile;
  bool _isLoading = true;

  // Simulator controls
  double _interestRate = AppConstants.defaultInterestRate;
  int _termMonths = AppConstants.defaultTermMonths;
  String _selectedCreditType = AppConstants.creditTypes.first;

  double get _availableCapacity {
    if (_profile == null) return 0;
    return RiskCalculator.availableCapacity(
      monthlyIncome: _profile!.monthlyIncome,
      totalObligations: _profile!.totalMonthlyPayments,
    );
  }

  double get _maxCredit {
    return RiskCalculator.calculateMaxCredit(
      availableCapacity: _availableCapacity,
      monthlyRate: _interestRate,
      termMonths: _termMonths,
    );
  }

  double _customAmount = 0;

  double get _monthlyPayment {
    final amount = _customAmount > 0 ? _customAmount : _maxCredit;
    return RiskCalculator.calculateMonthlyPayment(
      principal: amount,
      monthlyRate: _interestRate,
      termMonths: _termMonths,
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.profileId != null) {
      final p = await ref
          .read(firestoreServiceProvider)
          .getFinancialProfile(widget.profileId!);
      setState(() {
        _profile = p;
        if (p != null) {
          _selectedCreditType =
              p.desiredCreditType ?? AppConstants.creditTypes.first;
          _customAmount = p.desiredAmount;
        }
      });
    }
    setState(() => _isLoading = false);
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
                  : _buildSimulator(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
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
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Simulador de crédito',
                  style: Theme.of(context).textTheme.headlineSmall),
              Text('Ajusta y descubre tu cuota',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimulator() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Result hero
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Cuota mensual estimada',
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14),
                ),
                const SizedBox(height: 10),
                Text(
                  AppFormatters.currency(_monthlyPayment),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Monto máximo: ${AppFormatters.compactCurrency(_maxCredit)}',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _MiniStat(label: 'Tasa', value: '${_interestRate.toStringAsFixed(2)}% M.V.'),
                    const SizedBox(width: 20),
                    _MiniStat(label: 'Plazo', value: '$_termMonths meses'),
                    const SizedBox(width: 20),
                    _MiniStat(
                      label: 'Total a pagar',
                      value: AppFormatters.compactCurrency(_monthlyPayment * _termMonths),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),
          const SizedBox(height: 20),
          // Tipo de crédito
          Text('Tipo de crédito', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: AppConstants.creditTypes.map((type) {
                final isSelected = _selectedCreditType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCreditType = type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppColors.primaryGradient : null,
                        color: isSelected ? null : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : AppColors.border,
                        ),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          // Sliders
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Interest rate
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tasa de interés mensual',
                        style: Theme.of(context).textTheme.titleMedium),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_interestRate.toStringAsFixed(2)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _interestRate,
                  min: AppConstants.minInterestRate,
                  max: AppConstants.maxInterestRate,
                  divisions: 70,
                  onChanged: (v) => setState(() => _interestRate = v),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${AppConstants.minInterestRate}%',
                        style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                    Text('${AppConstants.maxInterestRate}%',
                        style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                // Term
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Plazo',
                        style: Theme.of(context).textTheme.titleMedium),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.purpleTranslucent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_termMonths meses (${(_termMonths / 12).toStringAsFixed(1)} años)',
                        style: TextStyle(
                          color: AppColors.secondaryPurpleDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _termMonths.toDouble(),
                  min: AppConstants.minTermMonths.toDouble(),
                  max: AppConstants.maxTermMonths.toDouble(),
                  divisions: (AppConstants.maxTermMonths - AppConstants.minTermMonths) ~/ 6,
                  onChanged: (v) => setState(() => _termMonths = v.round()),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${AppConstants.minTermMonths} meses',
                        style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                    Text('${AppConstants.maxTermMonths} meses',
                        style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                // Custom amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Monto deseado',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      AppFormatters.compactCurrency(_customAmount > 0 ? _customAmount : _maxCredit),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                if (_maxCredit > 0) ...[
                  Slider(
                    value: (_customAmount > 0 ? _customAmount : _maxCredit)
                        .clamp(0, _maxCredit * 2),
                    min: 0,
                    max: _maxCredit * 2,
                    divisions: 40,
                    onChanged: (v) => setState(() => _customAmount = v),
                  ),
                ],
              ],
            ),
          ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2),
          const SizedBox(height: 16),
          // Quick presets
          Row(
            children: [6, 12, 24, 36, 60, 84].map((months) {
              final isSelected = _termMonths == months;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => setState(() => _termMonths = months),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryBlue : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          months >= 12 ? '${months ~/ 12}A' : '${months}M',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 24),
          if (_profile != null) ...[
            // Desired vs viable
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Comparación de montos',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 14),
                  _CompareRow(
                    label: 'Monto deseado',
                    value: _profile!.desiredAmount,
                    color: AppColors.secondaryPurple,
                    maxValue: _maxCredit > 0 ? _maxCredit * 1.5 : _profile!.desiredAmount + 1,
                  ),
                  const SizedBox(height: 12),
                  _CompareRow(
                    label: 'Monto viable (estimado)',
                    value: _maxCredit,
                    color: AppColors.primaryBlue,
                    maxValue: _maxCredit > 0 ? _maxCredit * 1.5 : _profile!.desiredAmount + 1,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 250.ms),
            const SizedBox(height: 24),
          ],
          GradientButton(
            label: 'Hablar con un asesor',
            onPressed: () => context.push(
              AppRoutes.chat,
              extra: {
                'otherUserId': 'advisor',
                'otherUserName': 'Asesor financiero',
                'caseId': widget.profileId,
              },
            ),
            icon: Icons.chat_bubble_outline,
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
      ],
    );
  }
}

class _CompareRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final double maxValue;

  const _CompareRow({
    required this.label,
    required this.value,
    required this.color,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            Text(
              AppFormatters.compactCurrency(value),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
