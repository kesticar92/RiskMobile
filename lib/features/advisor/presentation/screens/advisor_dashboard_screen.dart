import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/financial_profile_model.dart';
import '../../../../shared/models/user_model.dart';

enum _ClientSort { byUpdatedDesc, byNameAsc, byFollowUpAsc }

/// RF-K20: filtros rápidos por ventana del próximo seguimiento (`nextFollowUpAt`).
enum _FollowUpCRMFilter { all, overdue, today, nextSevenDays, none }

DateTime _crmDateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool _crmMatchesFollowUpFilter(
  FinancialProfileModel p,
  _FollowUpCRMFilter f,
  DateTime now,
) {
  final startToday = _crmDateOnly(now);
  final fu = p.nextFollowUpAt;
  switch (f) {
    case _FollowUpCRMFilter.all:
      return true;
    case _FollowUpCRMFilter.none:
      return fu == null;
    case _FollowUpCRMFilter.overdue:
      if (fu == null) return false;
      return _crmDateOnly(fu).isBefore(startToday);
    case _FollowUpCRMFilter.today:
      if (fu == null) return false;
      return _crmDateOnly(fu) == startToday;
    case _FollowUpCRMFilter.nextSevenDays:
      if (fu == null) return false;
      final d = _crmDateOnly(fu);
      if (!d.isAfter(startToday)) return false;
      final lastInclusive = startToday.add(const Duration(days: 7));
      return !d.isAfter(lastInclusive);
  }
}

String _crmPhoneDigits(String? raw) =>
    (raw ?? '').replaceAll(RegExp(r'\D'), '');

String _crmFilteredSig(List<FinancialProfileModel> f) {
  final ids = f.map((e) => e.id).toList()..sort();
  return '${f.length}:${ids.join(",")}';
}

String _crmTagLabel(String stored) {
  if (stored.isEmpty) return stored;
  return stored[0].toUpperCase() + stored.substring(1);
}

class AdvisorDashboardScreen extends ConsumerStatefulWidget {
  const AdvisorDashboardScreen({super.key});

  @override
  ConsumerState<AdvisorDashboardScreen> createState() =>
      _AdvisorDashboardScreenState();
}

class _AdvisorDashboardScreenState
    extends ConsumerState<AdvisorDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserModel? _advisor;
  String _filterStatus = 'Todos';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAdvisor();
  }

  Future<void> _loadAdvisor() async {
    final auth = ref.read(authServiceProvider);
    if (auth.currentUser != null) {
      final u = await auth.getUserData(auth.currentUser!.uid);
      if (mounted) setState(() => _advisor = u);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ClientsTab(
                    filterStatus: _filterStatus,
                    onFilterChanged: (s) =>
                        setState(() => _filterStatus = s),
                  ),
                  const _FinancialsTab(),
                  _ProfileTab(advisor: _advisor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, ${_advisor?.name.split(' ').first ?? 'Asesor'} 👋',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text('Panel de gestión',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.advisorGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child:
                    const Icon(Icons.business_center, color: Colors.white, size: 22),
              ),
            ],
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppColors.advisorGradient,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Clientes'),
          Tab(text: 'Financiero'),
          Tab(text: 'Perfil'),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }
}

// ---- Tab 1: Clients ----
class _ClientsTab extends ConsumerStatefulWidget {
  final String filterStatus;
  final ValueChanged<String> onFilterChanged;

  const _ClientsTab({
    required this.filterStatus,
    required this.onFilterChanged,
  });

  @override
  ConsumerState<_ClientsTab> createState() => _ClientsTabState();
}

class _ClientsTabState extends ConsumerState<_ClientsTab> {
  final _searchCtrl = TextEditingController();
  final _minAmountCtrl = TextEditingController();
  final _maxAmountCtrl = TextEditingController();
  String _search = '';
  final Set<String> _selectedStatuses = {};
  int? _lastDays;
  _ClientSort _sortMode = _ClientSort.byUpdatedDesc;
  bool _filterPriorityOnly = false;
  bool _includeArchived = false;
  final Set<String> _selectedTags = {};

  /// RF-K20
  _FollowUpCRMFilter _followUpCRMFilter = _FollowUpCRMFilter.all;
  /// RF-K21 — cache `clientId` → usuario Firestore para email/teléfono en búsqueda.
  Map<String, UserModel> _userByClientId = {};
  String? _contactsLoadedSig;
  /// RF-K24 — firma ya resuelta (evita consultas repetidas si la vista no cambia).
  String? _lastPendingFetchedSig;
  int _pendingDocsCount = 0;
  bool _pendingDocsBusy = false;
  /// Última lista filtrada (sincronizada en cada build) para descartar respuestas obsoletas.
  String _crmFilteredSigLive = '';

  static const String _crmEmptyFilteredSig = '0:';

  @override
  void dispose() {
    _searchCtrl.dispose();
    _minAmountCtrl.dispose();
    _maxAmountCtrl.dispose();
    super.dispose();
  }

  double? _parseAmount(String raw) {
    final sanitized = raw.replaceAll('.', '').replaceAll(',', '.').trim();
    if (sanitized.isEmpty) return null;
    return double.tryParse(sanitized);
  }

  bool get _hasAdvancedFilters =>
      _selectedStatuses.isNotEmpty ||
      _lastDays != null ||
      _minAmountCtrl.text.trim().isNotEmpty ||
      _maxAmountCtrl.text.trim().isNotEmpty ||
      _filterPriorityOnly ||
      _selectedTags.isNotEmpty ||
      _includeArchived ||
      _followUpCRMFilter != _FollowUpCRMFilter.all;

  Future<void> _ensureContactsLoaded(List<FinancialProfileModel> profiles) async {
    final ids = profiles
        .map((p) => p.clientId)
        .where((id) => id.isNotEmpty)
        .toSet();
    final sig = (ids.toList()..sort()).join('|');
    if (sig == _contactsLoadedSig) return;
    _contactsLoadedSig = sig;
    if (ids.isEmpty) {
      setState(() => _userByClientId = {});
      return;
    }
    final map = await ref.read(firestoreServiceProvider).getUsersByIds(ids);
    if (!mounted || _contactsLoadedSig != sig) return;
    setState(() => _userByClientId = map);
  }

  bool _crmMatchesProfileSearch(FinancialProfileModel p, String qLower) {
    if (qLower.isEmpty) return true;
    if (p.clientName.toLowerCase().contains(qLower)) return true;
    if (p.id.toLowerCase().contains(qLower)) return true;
    final u = _userByClientId[p.clientId];
    if (u == null) return false;
    if (u.email.toLowerCase().contains(qLower)) return true;
    final qDigits = _crmPhoneDigits(qLower);
    if (qDigits.length >= 3) {
      final ph = _crmPhoneDigits(u.phone);
      if (ph.contains(qDigits)) return true;
    }
    final rawPhone = (u.phone ?? '').toLowerCase();
    if (rawPhone.isNotEmpty && rawPhone.contains(qLower)) return true;
    return false;
  }

  void _schedulePendingDocCount(List<FinancialProfileModel> filtered) {
    final sig = _crmFilteredSig(filtered);
    if (filtered.isEmpty) {
      if (_lastPendingFetchedSig == _crmEmptyFilteredSig &&
          _pendingDocsCount == 0 &&
          !_pendingDocsBusy) {
        return;
      }
      setState(() {
        _pendingDocsCount = 0;
        _pendingDocsBusy = false;
        _lastPendingFetchedSig = _crmEmptyFilteredSig;
      });
      return;
    }
    if (sig == _lastPendingFetchedSig && !_pendingDocsBusy) return;
    final capturedSig = sig;
    setState(() => _pendingDocsBusy = true);
    ref
        .read(firestoreServiceProvider)
        .countDocumentsPendingReviewForCases(
          filtered.map((e) => e.id).toList(),
        )
        .then((n) {
          if (!mounted) return;
          if (_crmFilteredSigLive != capturedSig) {
            setState(() => _pendingDocsBusy = false);
            return;
          }
          setState(() {
            _pendingDocsCount = n;
            _pendingDocsBusy = false;
            _lastPendingFetchedSig = capturedSig;
          });
        });
  }

  /// KPI locales RF-K24 sobre una lista ya filtrada.
  Future<void> _copyKpisFromView({
    required List<FinancialProfileModel> filtered,
    required BuildContext outerContext,
  }) async {
    final startToday = _crmDateOnly(DateTime.now());
    int overdueFu = 0;
    int todayFu = 0;
    int priorityN = 0;
    int inProgressN = 0;
    int approvedN = 0;
    for (final p in filtered) {
      if (p.casePriority) priorityN++;
      if (AppConstants.isCaseInProgress(p.caseStatus)) inProgressN++;
      if (p.caseStatus == AppConstants.caseCreditApproved) approvedN++;
      final fu = p.nextFollowUpAt;
      if (fu != null) {
        final d = _crmDateOnly(fu);
        if (d.isBefore(startToday)) overdueFu++;
        if (d == startToday) todayFu++;
      }
    }
    final pendingLine = _pendingDocsBusy
        ? 'Documentos pendientes revisión (vista): (cargando…)'
        : 'Documentos pendientes revisión (vista): $_pendingDocsCount';
    final text = [
      'RiskMobile — KPIs vista actual',
      'Casos en vista: ${filtered.length}',
      'Prioridad alta: $priorityN',
      'En proceso: $inProgressN',
      'Aprobados: $approvedN',
      'Seguimiento vencido: $overdueFu',
      'Seguimiento hoy: $todayFu',
      pendingLine,
    ].join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (outerContext.mounted) {
      ScaffoldMessenger.of(outerContext).showSnackBar(
        const SnackBar(content: Text('KPIs copiados al portapapeles.')),
      );
    }
  }

  /// RF-K24: resumen ejecutivo sobre la lista filtrada actual.
  Widget _buildKpiBanner({
    required BuildContext context,
    required List<FinancialProfileModel> filtered,
  }) {
    final startToday = _crmDateOnly(DateTime.now());
    var overdueFu = 0;
    var todayFu = 0;
    var priorityN = 0;
    var inProgressN = 0;
    var approvedN = 0;
    for (final p in filtered) {
      if (p.casePriority) priorityN++;
      if (AppConstants.isCaseInProgress(p.caseStatus)) inProgressN++;
      if (p.caseStatus == AppConstants.caseCreditApproved) approvedN++;
      final fu = p.nextFollowUpAt;
      if (fu != null) {
        final d = _crmDateOnly(fu);
        if (d.isBefore(startToday)) overdueFu++;
        if (d == startToday) todayFu++;
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          title: Row(
            children: [
              Icon(Icons.insights_outlined,
                  size: 20, color: AppColors.primaryBlueDark),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Indicadores de la vista actual',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _KpiChip(label: 'En vista', value: '${filtered.length}'),
                      _KpiChip(label: 'Prioridad', value: '$priorityN'),
                      _KpiChip(label: 'Seg. vencido', value: '$overdueFu'),
                      _KpiChip(label: 'Seg. hoy', value: '$todayFu'),
                      _KpiChip(label: 'En proceso', value: '$inProgressN'),
                      _KpiChip(label: 'Aprobados', value: '$approvedN'),
                      _KpiChip(
                        label: 'Docs pend. revisión',
                        value: _pendingDocsBusy ? '…' : '$_pendingDocsCount',
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _copyKpisFromView(
                        filtered: filtered,
                        outerContext: context,
                      ),
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Copiar KPIs'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FinancialProfileModel>>(
      stream: ref.read(firestoreServiceProvider).streamAllProfiles(),
      builder: (context, snapshot) {
        final minAmount = _parseAmount(_minAmountCtrl.text);
        final maxAmount = _parseAmount(_maxAmountCtrl.text);
        final now = DateTime.now();
        final allProfiles = snapshot.data ?? [];
        final approvedCount = allProfiles
            .where((p) => p.caseStatus == AppConstants.caseCreditApproved)
            .length;
        final inProgressCount = allProfiles
            .where((p) => AppConstants.isCaseInProgress(p.caseStatus))
            .length;
        final total = allProfiles.length;
        final approvedPct =
            total > 0 ? ((approvedCount / total) * 100).round() : 0;
        final inProgressPct =
            total > 0 ? ((inProgressCount / total) * 100).round() : 0;
        final q = _search.toLowerCase().trim();
        final tagOptions = <String>{};
        for (final p in allProfiles) {
          tagOptions.addAll(p.caseTags);
        }
        final sortedTags = tagOptions.toList()..sort();
        final filtered = allProfiles.where((p) {
          final matchStatus = (widget.filterStatus == 'Todos' ||
                  p.caseStatus == widget.filterStatus) &&
              (_selectedStatuses.isEmpty ||
                  _selectedStatuses.contains(p.caseStatus));
          final matchFollowUp =
              _crmMatchesFollowUpFilter(p, _followUpCRMFilter, now);
          final matchMinAmount =
              minAmount == null || p.desiredAmount >= minAmount;
          final matchMaxAmount =
              maxAmount == null || p.desiredAmount <= maxAmount;
          final matchDate = _lastDays == null ||
              now.difference(p.updatedAt).inDays <= _lastDays!;
          final matchPriority =
              !_filterPriorityOnly || p.casePriority;
          final matchArchived =
              _includeArchived || !p.caseArchived;
          final matchTags = _selectedTags.isEmpty ||
              p.caseTags.any((t) => _selectedTags.contains(t));
          return matchStatus &&
              _crmMatchesProfileSearch(p, q) &&
              matchFollowUp &&
              matchMinAmount &&
              matchMaxAmount &&
              matchDate &&
              matchPriority &&
              matchArchived &&
              matchTags;
        }).toList()
          ..sort((a, b) {
            switch (_sortMode) {
              case _ClientSort.byUpdatedDesc:
                return b.updatedAt.compareTo(a.updatedAt);
              case _ClientSort.byNameAsc:
                return a.clientName
                    .toLowerCase()
                    .compareTo(b.clientName.toLowerCase());
              case _ClientSort.byFollowUpAsc:
                final ad = a.nextFollowUpAt;
                final bd = b.nextFollowUpAt;
                if (ad == null && bd == null) return 0;
                if (ad == null) return 1;
                if (bd == null) return -1;
                return ad.compareTo(bd);
            }
          });

        _crmFilteredSigLive = _crmFilteredSig(filtered);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _ensureContactsLoaded(allProfiles);
          _schedulePendingDocCount(filtered);
        });

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  children: [
                    // Stats row
                    Row(
                      children: [
                        _StatChip(
                          label: 'Total',
                          count: total,
                          color: AppColors.primaryBlue,
                          subtitle: 'Base cartera',
                        ),
                        const SizedBox(width: 8),
                        _StatChip(
                          label: 'Aprobados',
                          count: approvedCount,
                          color: AppColors.riskLow,
                          subtitle: '$approvedPct%',
                        ),
                        const SizedBox(width: 8),
                        _StatChip(
                          label: 'En proceso',
                          count: inProgressCount,
                          color: AppColors.riskMedium,
                          subtitle: '$inProgressPct%',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildKpiBanner(context: context, filtered: filtered),
                    const SizedBox(height: 12),
                    // Search
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _search = v),
                      decoration: InputDecoration(
                        hintText:
                            'Cliente, ID de caso, email o teléfono...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _search.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _search = '');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Ordenar lista',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Última actualización'),
                          selected: _sortMode == _ClientSort.byUpdatedDesc,
                          onSelected: (_) => setState(
                            () => _sortMode = _ClientSort.byUpdatedDesc,
                          ),
                        ),
                        ChoiceChip(
                          label: const Text('Nombre A–Z'),
                          selected: _sortMode == _ClientSort.byNameAsc,
                          onSelected: (_) => setState(
                            () => _sortMode = _ClientSort.byNameAsc,
                          ),
                        ),
                        ChoiceChip(
                          label: const Text('Próx. seguimiento'),
                          selected: _sortMode == _ClientSort.byFollowUpAsc,
                          onSelected: (_) => setState(
                            () => _sortMode = _ClientSort.byFollowUpAsc,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Seguimiento (fecha próxima acción)',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Todos'),
                          selected:
                              _followUpCRMFilter == _FollowUpCRMFilter.all,
                          onSelected: (_) => setState(
                            () => _followUpCRMFilter = _FollowUpCRMFilter.all,
                          ),
                        ),
                        ChoiceChip(
                          label: const Text('Vencido'),
                          selected: _followUpCRMFilter ==
                              _FollowUpCRMFilter.overdue,
                          onSelected: (_) => setState(
                            () => _followUpCRMFilter =
                                _FollowUpCRMFilter.overdue,
                          ),
                        ),
                        ChoiceChip(
                          label: const Text('Hoy'),
                          selected:
                              _followUpCRMFilter == _FollowUpCRMFilter.today,
                          onSelected: (_) => setState(
                            () =>
                                _followUpCRMFilter = _FollowUpCRMFilter.today,
                          ),
                        ),
                        ChoiceChip(
                          label: const Text('Próx. 7 días'),
                          selected: _followUpCRMFilter ==
                              _FollowUpCRMFilter.nextSevenDays,
                          onSelected: (_) => setState(
                            () => _followUpCRMFilter =
                                _FollowUpCRMFilter.nextSevenDays,
                          ),
                        ),
                        ChoiceChip(
                          label: const Text('Sin fecha'),
                          selected:
                              _followUpCRMFilter == _FollowUpCRMFilter.none,
                          onSelected: (_) => setState(
                            () => _followUpCRMFilter = _FollowUpCRMFilter.none,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child:                     FilterChip(
                        label: Text(
                          'Solo prioridad (${allProfiles.where((x) => x.casePriority).length})',
                        ),
                        selected: _filterPriorityOnly,
                        onSelected: (v) =>
                            setState(() => _filterPriorityOnly = v),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilterChip(
                      label: Text(
                        'Incluir archivados (${allProfiles.where((x) => x.caseArchived).length})',
                      ),
                      selected: _includeArchived,
                      onSelected: (v) => setState(() => _includeArchived = v),
                    ),
                    if (sortedTags.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Filtrar por etiqueta',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                          children: sortedTags.map((tag) {
                          final sel = _selectedTags.contains(tag);
                          return FilterChip(
                            label: Text(_crmTagLabel(tag)),
                            selected: sel,
                            onSelected: (_) {
                              setState(() {
                                if (sel) {
                                  _selectedTags.remove(tag);
                                } else {
                                  _selectedTags.add(tag);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: filtered.isEmpty
                            ? null
                            : () {
                                const h =
                                    'Cliente\tID caso\tEstado\tMonto deseado\tPrioridad\tSeguimiento\tEtiquetas\tArchivado\tActualizado';
                                final rows = filtered
                                    .map(
                                      (p) =>
                                          '${p.clientName}\t${p.id}\t${p.caseStatus}\t${p.desiredAmount}\t${p.casePriority ? "Sí" : "No"}\t${p.nextFollowUpAt != null ? AppFormatters.date(p.nextFollowUpAt!) : ""}\t${p.caseTags.join(";")}\t${p.caseArchived ? "Sí" : "No"}\t${AppFormatters.dateTime(p.updatedAt)}',
                                    )
                                    .join('\n');
                                Clipboard.setData(
                                  ClipboardData(text: '$h\n$rows'),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Listado copiado (TSV). Pégalo en Excel o Sheets.',
                                    ),
                                  ),
                                );
                              },
                        icon: const Icon(Icons.table_chart_outlined, size: 18),
                        label: const Text('Copiar listado filtrado (TSV)'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.tune, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Filtros avanzados',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const Spacer(),
                              if (_hasAdvancedFilters)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedStatuses.clear();
                                      _lastDays = null;
                                      _minAmountCtrl.clear();
                                      _maxAmountCtrl.clear();
                                      _filterPriorityOnly = false;
                                      _selectedTags.clear();
                                      _includeArchived = false;
                                      _followUpCRMFilter =
                                          _FollowUpCRMFilter.all;
                                    });
                                  },
                                  child: const Text('Limpiar todo'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _minAmountCtrl,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                  decoration: const InputDecoration(
                                    labelText: 'Monto mín.',
                                    prefixText: '\$ ',
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _maxAmountCtrl,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                  decoration: const InputDecoration(
                                    labelText: 'Monto máx.',
                                    prefixText: '\$ ',
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [7, 30, 90].map((days) {
                                final selected = _lastDays == days;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text('Últimos $days días'),
                                    selected: selected,
                                    onSelected: (_) =>
                                        setState(() => _lastDays = selected ? null : days),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: AppConstants.caseStates.map((status) {
                              final selected = _selectedStatuses.contains(status);
                              return FilterChip(
                                label: Text(status),
                                selected: selected,
                                onSelected: (_) {
                                  setState(() {
                                    if (selected) {
                                      _selectedStatuses.remove(status);
                                    } else {
                                      _selectedStatuses.add(status);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Status filter
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['Todos', ...AppConstants.caseStates].map((s) {
                          final isSelected = widget.filterStatus == s;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => widget.onFilterChanged(s),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  gradient:
                                      isSelected ? AppColors.advisorGradient : null,
                                  color: isSelected ? null : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.transparent
                                        : AppColors.border,
                                  ),
                                ),
                                child: Text(
                                  s,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            if (snapshot.connectionState == ConnectionState.waiting)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (filtered.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_outline,
                          size: 56, color: AppColors.textLight),
                      const SizedBox(height: 12),
                      Text('No hay clientes',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _ClientCard(profile: filtered[i], index: i),
                    childCount: filtered.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _KpiChip extends StatelessWidget {
  final String label;
  final String value;

  const _KpiChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final String? subtitle;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 18, color: color),
            ),
            Text(label,
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(fontSize: 10, color: color),
              ),
          ],
        ),
      ),
    );
  }
}

class _ClientFollowUpChip extends StatelessWidget {
  final DateTime at;
  const _ClientFollowUpChip({required this.at});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startToday = DateTime(today.year, today.month, today.day);
    final startFu = DateTime(at.year, at.month, at.day);
    late Color bg;
    late Color fg;
    late String label;
    if (startFu.isBefore(startToday)) {
      bg = AppColors.riskHigh.withOpacity(0.18);
      fg = AppColors.riskHigh;
      label = 'Seg. vencido';
    } else if (startFu == startToday) {
      bg = AppColors.riskMedium.withOpacity(0.18);
      fg = AppColors.riskMedium;
      label = 'Seg. hoy';
    } else {
      bg = AppColors.primaryBlue.withOpacity(0.1);
      fg = AppColors.primaryBlueDark;
      label = AppFormatters.date(at);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

class _ClientCard extends ConsumerWidget {
  final FinancialProfileModel profile;
  final int index;

  const _ClientCard({required this.profile, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _statusColor(profile.caseStatus);
    final noteRaw = profile.advisorInternalNote?.trim();
    String? noteShort;
    if (noteRaw != null && noteRaw.isNotEmpty) {
      final oneLine = noteRaw.replaceAll(RegExp(r'\s+'), ' ');
      noteShort =
          oneLine.length > 48 ? '${oneLine.substring(0, 45)}…' : oneLine;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () =>
                  context.push(AppRoutes.clientDetail, extra: profile.id),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          profile.clientName.isNotEmpty
                              ? profile.clientName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (profile.casePriority) ...[
                                Icon(Icons.star,
                                    size: 17, color: AppColors.riskMedium),
                                const SizedBox(width: 4),
                              ],
                              if (profile.caseArchived) ...[
                                Icon(Icons.inventory_2_outlined,
                                    size: 16, color: AppColors.textLight),
                                const SizedBox(width: 4),
                              ],
                              Expanded(
                                child: Text(
                                  profile.clientName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _ScoreBadge(score: profile.riskScore),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${profile.economicActivity} • ${AppFormatters.currency(profile.monthlyIncome)}/mes',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (noteShort != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              noteShort,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: AppColors.primaryBlueDark,
                              ),
                            ),
                          ],
                          if (profile.caseTags.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: [
                                ...profile.caseTags
                                    .take(3)
                                    .map(
                                      (t) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryBlue
                                              .withOpacity(0.08),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          _crmTagLabel(t),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.primaryBlueDark,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                if (profile.caseTags.length > 3)
                                  Text(
                                    '+${profile.caseTags.length - 3}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            'Última actividad · ${AppFormatters.timeAgo(profile.lastStatusChangeAt ?? profile.updatedAt)}',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textLight,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  profile.caseStatus,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (profile.nextFollowUpAt != null) ...[
                                const SizedBox(width: 6),
                                _ClientFollowUpChip(
                                    at: profile.nextFollowUpAt!),
                              ],
                              if (DateTime.now()
                                      .difference(profile.updatedAt)
                                      .inDays >=
                                  7) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.riskMedium.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '+7 d sin cambios',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.riskMedium,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (profile.clientId.isNotEmpty)
            IconButton(
              tooltip: 'Chat con cliente',
              onPressed: () => context.push(
                AppRoutes.chat,
                extra: {
                  'otherUserId': profile.clientId,
                  'otherUserName': profile.clientName,
                  'caseId': profile.id,
                },
              ),
              icon: Icon(
                Icons.chat_bubble_outline,
                color: AppColors.primaryBlueDark,
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 12, right: 8),
            child: Icon(Icons.chevron_right, color: AppColors.textLight),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 60)).slideY(begin: 0.15);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Crédito aprobado': return AppColors.riskLow;
      case 'Crédito rechazado': return AppColors.riskHigh;
      case 'Análisis en proceso': return AppColors.riskMedium;
      case 'Solicitud radicada': return AppColors.primaryBlue;
      default: return AppColors.textSecondary;
    }
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;
  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.scoreColor(score);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            score.toString(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Tab 2: Financials ----
class _FinancialsTab extends ConsumerWidget {
  const _FinancialsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.read(authServiceProvider);
    final advisorId = auth.currentUser?.uid ?? '';

    return StreamBuilder(
      stream: ref.read(firestoreServiceProvider).streamAdvisorCommissions(advisorId),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        double totalCommissions = 0;
        double totalCosts = 0;
        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          totalCommissions += (data['commissionAmount'] ?? 0).toDouble();
          totalCosts += (data['costs'] ?? 0).toDouble();
        }
        final profit = totalCommissions - totalCosts;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text('Resumen financiero',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              // Summary cards
              Row(
                children: [
                  _FinCard(
                    label: 'Comisiones totales',
                    value: AppFormatters.currency(totalCommissions),
                    icon: Icons.payments_outlined,
                    color: AppColors.riskLow,
                  ),
                  const SizedBox(width: 12),
                  _FinCard(
                    label: 'Costos operativos',
                    value: AppFormatters.currency(totalCosts),
                    icon: Icons.remove_circle_outline,
                    color: AppColors.riskMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.advisorGradient,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up, color: Colors.white, size: 28),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Utilidad neta',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13)),
                        Text(
                          AppFormatters.currency(profit),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Historial de comisiones',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (docs.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 40, color: AppColors.textLight),
                        const SizedBox(height: 8),
                        Text('Sin comisiones registradas',
                            style:
                                TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                )
              else
                ...docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.riskLow.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.check_circle_outline,
                              color: AppColors.riskLow, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['clientName'] ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                              Text(
                                'Crédito: ${AppFormatters.compactCurrency((data['creditAmount'] ?? 0).toDouble())}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          AppFormatters.currency(
                              (data['commissionAmount'] ?? 0).toDouble()),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.riskLow,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

class _FinCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _FinCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
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
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14)),
            Text(label,
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3)),
          ],
        ),
      ),
    );
  }
}

// ---- Tab 3: Profile ----
class _ProfileTab extends ConsumerWidget {
  final UserModel? advisor;
  const _ProfileTab({this.advisor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: AppColors.advisorGradient,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Center(
              child: Text(
                advisor?.name.isNotEmpty == true
                    ? advisor!.name[0].toUpperCase()
                    : 'A',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(advisor?.name ?? 'Asesor financiero',
              style: Theme.of(context).textTheme.headlineMedium),
          Text(advisor?.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.advisorGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Asesor financiero independiente',
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(height: 28),
          _ProfileOption(
            icon: Icons.settings_outlined,
            label: 'Configuración',
            onTap: () => context.push(AppRoutes.settings),
          ),
          _ProfileOption(
            icon: Icons.payments_outlined,
            label: 'Registrar comisión',
            onTap: () => context.push(AppRoutes.payments),
          ),
          _ProfileOption(
            icon: Icons.help_outline,
            label: 'Soporte',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authServiceProvider).signOut();
                if (context.mounted) context.go(AppRoutes.login);
              },
              icon: const Icon(Icons.logout, color: AppColors.riskHigh),
              label: const Text('Cerrar sesión',
                  style: TextStyle(color: AppColors.riskHigh)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.riskHigh.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.blueTranslucent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primaryBlue, size: 18),
            ),
            const SizedBox(width: 14),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.textLight, size: 18),
          ],
        ),
      ),
    );
  }
}
