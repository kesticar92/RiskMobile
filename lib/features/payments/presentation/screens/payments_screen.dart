import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/financial_profile_model.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/glass_card.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameCtrl = TextEditingController();
  final _creditAmountCtrl = TextEditingController();
  final _commissionCtrl = TextEditingController();
  final _costsCtrl = TextEditingController();
  bool _isLoading = false;
  String? _linkedCaseId;
  String _linkedClientId = '';

  @override
  void dispose() {
    _clientNameCtrl.dispose();
    _creditAmountCtrl.dispose();
    _commissionCtrl.dispose();
    _costsCtrl.dispose();
    super.dispose();
  }

  double get _profit {
    final commission = double.tryParse(_commissionCtrl.text) ?? 0;
    final costs = double.tryParse(_costsCtrl.text) ?? 0;
    return commission - costs;
  }

  void _applyCase(FinancialProfileModel profile) {
    setState(() {
      _linkedCaseId = profile.id;
      _linkedClientId = profile.clientId;
      _clientNameCtrl.text = profile.clientName;
      final amount = profile.estimatedViableAmount ?? profile.desiredAmount;
      if (amount > 0) {
        _creditAmountCtrl.text = amount.toStringAsFixed(0);
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final commission = double.tryParse(_commissionCtrl.text) ?? 0;
    final costs = double.tryParse(_costsCtrl.text) ?? 0;
    if (costs > commission) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Costos mayores que comisión'),
          content: const Text(
            'Los costos superan la comisión; la utilidad será negativa. '
            '¿Deseas registrar igualmente?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Revisar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Registrar'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = ref.read(authServiceProvider);
      final advisorId = auth.currentUser?.uid ?? '';
      await ref.read(firestoreServiceProvider).saveCommission(
            advisorId: advisorId,
            clientId: _linkedClientId,
            clientName: _clientNameCtrl.text.trim(),
            creditAmount: double.tryParse(_creditAmountCtrl.text) ?? 0,
            commissionAmount: commission,
            costs: costs,
            caseId: _linkedCaseId ?? '',
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comisión registrada exitosamente')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
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
                  Expanded(
                    child: Text(
                      'Registrar comisión',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<FinancialProfileModel>>(
                stream: ref.read(firestoreServiceProvider).streamAllProfiles(),
                builder: (context, snap) {
                  final cases = (snap.data ?? [])
                      .where(
                        (p) =>
                            p.caseStatus == AppConstants.caseCreditApproved ||
                            AppConstants.isCaseInProgress(p.caseStatus),
                      )
                      .toList()
                    ..sort(
                      (a, b) => a.clientName
                          .toLowerCase()
                          .compareTo(b.clientName.toLowerCase()),
                    );

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: AppColors.advisorGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primaryBlue.withOpacity(0.25),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Utilidad estimada',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  AppFormatters.currency(_profit),
                                  style: TextStyle(
                                    color: _profit >= 0
                                        ? Colors.white
                                        : const Color(0xFFFFCDD2),
                                    fontSize: 34,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Comisión − costos',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 400.ms),
                          const SizedBox(height: 24),
                          GlassCard(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Vincular a caso (opcional)',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 12),
                                if (cases.isEmpty)
                                  Text(
                                    'No hay casos activos para vincular. '
                                    'Puedes registrar manualmente.',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  )
                                else
                                  DropdownButtonFormField<String>(
                                    value: _linkedCaseId,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Caso en cartera',
                                      prefixIcon:
                                          Icon(Icons.folder_open_outlined),
                                    ),
                                    items: [
                                      const DropdownMenuItem<String>(
                                        value: null,
                                        child: Text('Sin vincular'),
                                      ),
                                      ...cases.map(
                                        (p) => DropdownMenuItem(
                                          value: p.id,
                                          child: Text(
                                            '${p.clientName} · ${p.caseStatus}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                    onChanged: (id) {
                                      if (id == null) {
                                        setState(() {
                                          _linkedCaseId = null;
                                          _linkedClientId = '';
                                        });
                                        return;
                                      }
                                      final p = cases.firstWhere(
                                        (e) => e.id == id,
                                      );
                                      _applyCase(p);
                                    },
                                  ),
                                const SizedBox(height: 20),
                                Text(
                                  'Datos del registro',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _clientNameCtrl,
                                  textCapitalization:
                                      TextCapitalization.words,
                                  decoration: const InputDecoration(
                                    labelText: 'Nombre del cliente',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  validator: (v) =>
                                      v?.trim().isNotEmpty == true
                                          ? null
                                          : 'Requerido',
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: _creditAmountCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Valor del crédito',
                                    prefixIcon: Icon(
                                      Icons.account_balance_outlined,
                                    ),
                                    prefixText: '\$ ',
                                  ),
                                  validator: (v) =>
                                      (double.tryParse(v ?? '') ?? 0) > 0
                                          ? null
                                          : 'Ingresa un valor válido',
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: _commissionCtrl,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                  decoration: const InputDecoration(
                                    labelText: 'Comisión cobrada',
                                    prefixIcon:
                                        Icon(Icons.payments_outlined),
                                    prefixText: '\$ ',
                                  ),
                                  validator: (v) {
                                    final n = double.tryParse(v ?? '');
                                    if (n == null || n <= 0) {
                                      return 'Ingresa una comisión mayor a 0';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: _costsCtrl,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                  decoration: const InputDecoration(
                                    labelText: 'Costos del proceso',
                                    prefixIcon:
                                        Icon(Icons.remove_circle_outline),
                                    prefixText: '\$ ',
                                    hintText: '0',
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return null;
                                    }
                                    final n = double.tryParse(v);
                                    if (n == null || n < 0) {
                                      return 'Costo inválido';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
                          const SizedBox(height: 24),
                          GradientButton(
                            label: 'Registrar comisión',
                            onPressed: _save,
                            isLoading: _isLoading,
                            icon: Icons.check_circle_outline,
                            gradient: AppColors.advisorGradient,
                          ).animate().fadeIn(delay: 200.ms),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
