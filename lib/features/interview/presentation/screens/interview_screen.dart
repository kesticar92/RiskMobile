import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/navigation_helpers.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/models/financial_profile_model.dart';
import '../../../../core/services/firestore_service.dart';

class InterviewScreen extends ConsumerStatefulWidget {
  const InterviewScreen({super.key});

  @override
  ConsumerState<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends ConsumerState<InterviewScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // Step 1 — Actividad económica
  String? _selectedActivity;
  String? _selectedContractType;
  final _seniorityCtrl = TextEditingController();
  final _incomeCtrl = TextEditingController();

  // Step 2 — Obligaciones
  bool _hasObligations = false;
  final List<FinancialObligation> _obligations = [];

  // Step 3 — Intención
  final _desiredAmountCtrl = TextEditingController();
  String? _selectedCreditType;

  final _totalPages = 3;

  void _onFormFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _seniorityCtrl.addListener(_onFormFieldChanged);
    _incomeCtrl.addListener(_onFormFieldChanged);
    _desiredAmountCtrl.addListener(_onFormFieldChanged);
  }

  @override
  void dispose() {
    _seniorityCtrl.removeListener(_onFormFieldChanged);
    _incomeCtrl.removeListener(_onFormFieldChanged);
    _desiredAmountCtrl.removeListener(_onFormFieldChanged);
    _pageController.dispose();
    _seniorityCtrl.dispose();
    _incomeCtrl.dispose();
    _desiredAmountCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _submit();
    }
  }

  void _back() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      popOrGo(context, AppRoutes.clientHome);
    }
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final auth = ref.read(authServiceProvider);
      final uid = auth.currentUser?.uid ?? '';
      final userData = await auth.getUserData(uid);
      final fs = ref.read(firestoreServiceProvider);

      final profile = FinancialProfileModel(
        id: '',
        clientId: uid,
        clientName: userData?.name ?? 'Cliente',
        economicActivity: _selectedActivity ?? '',
        contractType: _selectedContractType,
        seniorityMonths: int.tryParse(_seniorityCtrl.text.replaceAll(',', '')) ?? 0,
        monthlyIncome: double.tryParse(_incomeCtrl.text.replaceAll(',', '')) ?? 0,
        obligations: _hasObligations ? _obligations : [],
        desiredAmount: double.tryParse(_desiredAmountCtrl.text.replaceAll(',', '')) ?? 0,
        desiredCreditType: _selectedCreditType,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final savedId = await fs.saveFinancialProfile(profile);
      if (!mounted) return;
      // Quitar la entrevista de la pila y abrir calculadora con el caso guardado.
      // Así el "atrás" vuelve al home (o a la calculadora vacía si vino de ahí).
      if (context.canPop()) {
        context.pop();
        if (!mounted) return;
        context.pushReplacement(AppRoutes.calculator, extra: savedId);
      } else {
        context.go(AppRoutes.calculator, extra: savedId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: ${e.toString()}')),
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
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _back,
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Entrevista financiera',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          'Paso ${_currentPage + 1} de $_totalPages',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _totalPages,
                    effect: ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      activeDotColor: AppColors.primaryBlue,
                      dotColor: AppColors.blueTranslucent,
                      expansionFactor: 3,
                    ),
                  ),
                ],
              ),
            ),
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentPage + 1) / _totalPages,
                  minHeight: 4,
                  backgroundColor: AppColors.blueTranslucent,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _ActivityPage(
                    selectedActivity: _selectedActivity,
                    selectedContractType: _selectedContractType,
                    seniorityCtrl: _seniorityCtrl,
                    incomeCtrl: _incomeCtrl,
                    onActivitySelected: (a) => setState(() {
                      _selectedActivity = a;
                      if (a != 'Empleado' &&
                          a != 'Profesional independiente') {
                        _selectedContractType = null;
                      }
                    }),
                    onContractTypeSelected: (v) =>
                        setState(() => _selectedContractType = v),
                  ),
                  _ObligationsPage(
                    hasObligations: _hasObligations,
                    obligations: _obligations,
                    onHasObligationsChanged: (v) =>
                        setState(() {
                          _hasObligations = v;
                          if (!v) {
                            _obligations.clear();
                          }
                        }),
                    onObligationsChanged: (list) =>
                        setState(() => _obligations
                          ..clear()
                          ..addAll(list)),
                  ),
                  _IntentionPage(
                    desiredAmountCtrl: _desiredAmountCtrl,
                    selectedCreditType: _selectedCreditType,
                    onCreditTypeSelected: (t) =>
                        setState(() => _selectedCreditType = t),
                  ),
                ],
              ),
            ),
            // Bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: GradientButton(
                label: _currentPage == _totalPages - 1
                    ? 'Calcular mi perfil financiero'
                    : 'Continuar',
                onPressed: _canProceed ? _next : null,
                isLoading: _isLoading,
                icon: _currentPage == _totalPages - 1
                    ? Icons.analytics_outlined
                    : Icons.arrow_forward_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _canProceed {
    final income = double.tryParse(_incomeCtrl.text.replaceAll(',', '').trim()) ?? -1;
    final seniority =
        int.tryParse(_seniorityCtrl.text.replaceAll(',', '').trim()) ?? 0;
    final desiredAmount =
        double.tryParse(_desiredAmountCtrl.text.replaceAll(',', '').trim()) ?? -1;
    final needsContract = _selectedActivity == 'Empleado' ||
        _selectedActivity == 'Profesional independiente';

    switch (_currentPage) {
      case 0:
        return _selectedActivity != null &&
            income >= 0 &&
            seniority >= 0 &&
            (!needsContract || _selectedContractType != null);
      case 1:
        if (!_hasObligations) return true;
        if (_obligations.isEmpty) return false;
        // Datos mínimos por obligación. Los extractos por deuda (RF12) se exigen
        // en la pantalla de documentos, no aquí — exigirlos bloqueaba "Continuar"
        // con 3+ deudas y rompía la demo.
        return _obligations.every((o) =>
            o.entity.trim().length >= 2 &&
            o.creditType.trim().isNotEmpty &&
            o.monthlyPayment > 0);
      case 2:
        if (_selectedCreditType == null) return false;
        if (desiredAmount < 0) return false;
        if (desiredAmount > 0 && desiredAmount < 1000) return false;
        return true;
      default:
        return false;
    }
  }
}

// ---- Page 1: Economic Activity ----
class _ActivityPage extends StatelessWidget {
  final String? selectedActivity;
  final String? selectedContractType;
  final TextEditingController seniorityCtrl;
  final TextEditingController incomeCtrl;
  final ValueChanged<String> onActivitySelected;
  final ValueChanged<String?> onContractTypeSelected;

  const _ActivityPage({
    required this.selectedActivity,
    required this.selectedContractType,
    required this.seniorityCtrl,
    required this.incomeCtrl,
    required this.onActivitySelected,
    required this.onContractTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text('¿Cuál es tu actividad\neconómica?',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text('Esto nos ayuda a entender mejor tu perfil financiero',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          ...AppConstants.economicActivities.asMap().entries.map((e) {
            final activity = e.value;
            final isSelected = selectedActivity == activity;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onActivitySelected(activity),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.primaryGradient : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : AppColors.border,
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryBlue.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _activityIcon(activity),
                        color: isSelected ? Colors.white : AppColors.primaryBlue,
                        size: 22,
                      ),
                      const SizedBox(width: 14),
                      Text(
                        activity,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: Colors.white, size: 20),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: e.key * 60))
                    .slideX(begin: 0.2),
              ),
            );
          }),
          const SizedBox(height: 20),
          if (selectedActivity == 'Empleado' ||
              selectedActivity == 'Profesional independiente') ...[
            Text('Tipo de contrato', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedContractType,
              decoration: const InputDecoration(
                labelText: 'Selecciona tu tipo de contrato',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              items: const [
                DropdownMenuItem(
                    value: 'Término indefinido', child: Text('Término indefinido')),
                DropdownMenuItem(
                    value: 'Término fijo', child: Text('Término fijo')),
                DropdownMenuItem(
                    value: 'Prestación de servicios',
                    child: Text('Prestación de servicios')),
                DropdownMenuItem(
                    value: 'Independiente', child: Text('Independiente')),
              ],
              onChanged: onContractTypeSelected,
            ),
            const SizedBox(height: 18),
          ],
          Text('Antigüedad laboral (meses)',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          TextFormField(
            controller: seniorityCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: '¿Cuántos meses llevas en tu actividad?',
              prefixIcon: Icon(Icons.timeline_outlined),
              hintText: '0',
            ),
          ),
          const SizedBox(height: 18),
          Text('Ingreso mensual', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          TextFormField(
            controller: incomeCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: '¿Cuánto ganas al mes?',
              prefixIcon: Icon(Icons.attach_money),
              hintText: '0',
              prefixText: '\$ ',
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  IconData _activityIcon(String activity) {
    switch (activity) {
      case 'Empleado': return Icons.work_outline;
      case 'Independiente': return Icons.self_improvement;
      case 'Pensionado': return Icons.elderly;
      case 'Comerciante': return Icons.storefront_outlined;
      case 'Profesional independiente': return Icons.school_outlined;
      default: return Icons.person_outline;
    }
  }
}

// ---- Page 2: Obligations ----
class _ObligationsPage extends StatefulWidget {
  final bool hasObligations;
  final List<FinancialObligation> obligations;
  final ValueChanged<bool> onHasObligationsChanged;
  final ValueChanged<List<FinancialObligation>> onObligationsChanged;

  const _ObligationsPage({
    required this.hasObligations,
    required this.obligations,
    required this.onHasObligationsChanged,
    required this.onObligationsChanged,
  });

  @override
  State<_ObligationsPage> createState() => _ObligationsPageState();
}

class _ObligationsPageState extends State<_ObligationsPage> {
  final List<FinancialObligation> _localList = [];

  @override
  void initState() {
    super.initState();
    _localList.addAll(widget.obligations);
  }

  @override
  void didUpdateWidget(covariant _ObligationsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.hasObligations) {
      if (_localList.isNotEmpty) {
        _localList.clear();
      }
      return;
    }
    // No resincronizar por solo `length`: podía pisar la lista local y provocar
    // pérdida de filas o índices inconsistentes. La lista la gobierna este State
    // vía `onObligationsChanged` desde el padre.
  }

  void _addObligation() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddObligationSheet(
        onAdd: (ob) {
          setState(() => _localList.add(ob));
          widget.onObligationsChanged(List<FinancialObligation>.from(_localList));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text('Tus obligaciones\nfinancieras',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text('Necesitamos conocer tus cuotas actuales',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          // Toggle
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '¿Tienes créditos o cuotas actualmente?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Switch.adaptive(
                  value: widget.hasObligations,
                  onChanged: widget.onHasObligationsChanged,
                  activeColor: AppColors.primaryBlue,
                ),
              ],
            ),
          ),
          if (widget.hasObligations) ...[
            const SizedBox(height: 16),
            if (_localList.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.blueTranslucent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.add_card_outlined,
                        size: 40, color: AppColors.primaryBlue),
                    const SizedBox(height: 10),
                    Text(
                      'Agrega tus obligaciones\nfinancieras actuales',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(_localList.length, (i) {
                final ob = _localList[i];
                return _ObligationTile(
                  key: ValueKey(
                    ob.clientRowId ??
                        '${ob.entity}_${ob.creditType}_${ob.monthlyPayment}_$i',
                  ),
                  obligation: ob,
                  onRemove: () {
                    setState(() {
                      if (ob.clientRowId != null) {
                        _localList.removeWhere(
                          (x) => x.clientRowId == ob.clientRowId,
                        );
                      } else {
                        final j = _localList.indexWhere(
                          (x) =>
                              x.entity == ob.entity &&
                              x.creditType == ob.creditType &&
                              x.monthlyPayment == ob.monthlyPayment &&
                              x.balance == ob.balance &&
                              x.bankExtractFileName == ob.bankExtractFileName,
                        );
                        if (j >= 0) {
                          _localList.removeAt(j);
                        }
                      }
                      widget.onObligationsChanged(
                        List<FinancialObligation>.from(_localList),
                      );
                    });
                  },
                  onUpdate: (updated) {
                    setState(() {
                      if (ob.clientRowId != null) {
                        final j = _localList.indexWhere(
                          (x) => x.clientRowId == ob.clientRowId,
                        );
                        if (j >= 0) {
                          _localList[j] = updated;
                        }
                      } else {
                        final j = _localList.indexWhere(
                          (x) =>
                              x.entity == ob.entity &&
                              x.creditType == ob.creditType &&
                              x.monthlyPayment == ob.monthlyPayment &&
                              x.balance == ob.balance &&
                              x.bankExtractFileName == ob.bankExtractFileName,
                        );
                        if (j >= 0) {
                          _localList[j] = updated;
                        }
                      }
                      widget.onObligationsChanged(
                        List<FinancialObligation>.from(_localList),
                      );
                    });
                  },
                );
              }),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _addObligation,
              icon: const Icon(Icons.add),
              label: const Text('Agregar obligación'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ObligationTile extends StatelessWidget {
  final FinancialObligation obligation;
  final VoidCallback onRemove;
  final ValueChanged<FinancialObligation> onUpdate;

  const _ObligationTile({
    super.key,
    required this.obligation,
    required this.onRemove,
    required this.onUpdate,
  });

  Future<void> _pickExtract(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || result.files.isEmpty) return;
    final name = result.files.single.name;
    if (name.isEmpty) return;
    onUpdate(obligation.copyWith(bankExtractFileName: name));
  }

  @override
  Widget build(BuildContext context) {
    final extract = obligation.bankExtractFileName;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.purpleTranslucent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.credit_card_outlined,
                    color: AppColors.secondaryPurple, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(obligation.entity,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(
                      '${obligation.creditType} • \$${obligation.monthlyPayment.toStringAsFixed(0)}/mes',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close,
                    size: 18, color: AppColors.textLight),
                onPressed: onRemove,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                extract != null
                    ? Icons.attach_file
                    : Icons.warning_amber_rounded,
                size: 16,
                color: extract != null ? AppColors.riskLow : AppColors.riskMedium,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  extract != null
                      ? 'Extracto: $extract'
                      : 'Adjunta extracto bancario (PDF o imagen)',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _pickExtract(context),
                icon: const Icon(Icons.upload_file_outlined, size: 16),
                label: Text(extract == null ? 'Adjuntar' : 'Cambiar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddObligationSheet extends StatefulWidget {
  final ValueChanged<FinancialObligation> onAdd;
  const _AddObligationSheet({required this.onAdd});

  @override
  State<_AddObligationSheet> createState() => _AddObligationSheetState();
}

class _AddObligationSheetState extends State<_AddObligationSheet> {
  final _entityCtrl = TextEditingController();
  final _paymentCtrl = TextEditingController();
  final _balanceCtrl = TextEditingController();
  String _type = AppConstants.creditTypes.first;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Agregar obligación',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          TextFormField(
            controller: _entityCtrl,
            decoration: const InputDecoration(
              labelText: 'Entidad financiera',
              prefixIcon: Icon(Icons.account_balance_outlined),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _type,
            decoration: const InputDecoration(
              labelText: 'Tipo de crédito',
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: AppConstants.creditTypes
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _type = v!),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _paymentCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Cuota mensual',
              prefixIcon: Icon(Icons.attach_money),
              prefixText: '\$ ',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _balanceCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Saldo pendiente (opcional)',
              prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              prefixText: '\$ ',
            ),
          ),
          const SizedBox(height: 24),
          GradientButton(
            label: 'Agregar',
            onPressed: () {
              final entity = _entityCtrl.text.trim();
              final payment = double.tryParse(_paymentCtrl.text) ?? 0;
              final balance = _balanceCtrl.text.trim().isEmpty
                  ? null
                  : (double.tryParse(_balanceCtrl.text) ?? 0);
              if (entity.length < 2 || payment <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Completa entidad y cuota mensual con valores válidos.'),
                  ),
                );
                return;
              }
              final ob = FinancialObligation(
                entity: entity,
                creditType: _type,
                monthlyPayment: payment,
                balance: balance,
                clientRowId: const Uuid().v4(),
              );
              widget.onAdd(ob);
              Navigator.pop(context);
            },
            icon: Icons.check,
          ),
        ],
      ),
    );
  }
}

// ---- Page 3: Intention ----
class _IntentionPage extends StatelessWidget {
  final TextEditingController desiredAmountCtrl;
  final String? selectedCreditType;
  final ValueChanged<String> onCreditTypeSelected;

  const _IntentionPage({
    required this.desiredAmountCtrl,
    required this.selectedCreditType,
    required this.onCreditTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text('¿Cuánto deseas\nsolicitar?',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text('Compararemos con tu capacidad real',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Monto deseado',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                TextFormField(
                  controller: desiredAmountCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    hintText: 'Ej: 20000000',
                    prefixText: '\$ ',
                    prefixIcon: Icon(Icons.monetization_on_outlined),
                    labelText: 'Valor del crédito que buscas',
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Puedes dejar 0 si aún no lo tienes claro. Si indicas un monto, usa al menos \$1.000 COP.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Tipo de crédito de interés',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: AppConstants.creditTypes.map((type) {
              final isSelected = selectedCreditType == type;
              return GestureDetector(
                onTap: () => onCreditTypeSelected(type),
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
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryBlue.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : [],
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
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          GlassCard(
            color: AppColors.blueTranslucent,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primaryBlueDark, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Esta evaluación es preliminar y no genera huella en centrales de riesgo como Datacrédito.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryBlueDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
