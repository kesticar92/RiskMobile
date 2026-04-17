import 'package:flutter/material.dart';
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
      _maxAmountCtrl.text.trim().isNotEmpty;

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
        final filtered = allProfiles.where((p) {
          final matchStatus = (widget.filterStatus == 'Todos' ||
                  p.caseStatus == widget.filterStatus) &&
              (_selectedStatuses.isEmpty ||
                  _selectedStatuses.contains(p.caseStatus));
          final matchSearch = _search.isEmpty ||
              p.clientName.toLowerCase().contains(_search.toLowerCase());
          final matchMinAmount =
              minAmount == null || p.desiredAmount >= minAmount;
          final matchMaxAmount =
              maxAmount == null || p.desiredAmount <= maxAmount;
          final matchDate = _lastDays == null ||
              now.difference(p.updatedAt).inDays <= _lastDays!;
          return matchStatus &&
              matchSearch &&
              matchMinAmount &&
              matchMaxAmount &&
              matchDate;
        }).toList();

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
                    // Search
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _search = v),
                      decoration: InputDecoration(
                        hintText: 'Buscar cliente...',
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

class _ClientCard extends ConsumerWidget {
  final FinancialProfileModel profile;
  final int index;

  const _ClientCard({required this.profile, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _statusColor(profile.caseStatus);
    return GestureDetector(
      onTap: () => context.push(AppRoutes.clientDetail, extra: profile.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
          children: [
            // Avatar
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                        fontSize: 12, color: AppColors.textSecondary),
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
                      const SizedBox(width: 8),
                      Text(
                        AppFormatters.timeAgo(profile.updatedAt),
                        style: TextStyle(
                            fontSize: 10, color: AppColors.textLight),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textLight),
          ],
        ),
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
