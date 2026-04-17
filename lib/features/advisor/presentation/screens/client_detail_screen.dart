import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/auth_service.dart';
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
  bool _updatingStatus = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await ref
        .read(firestoreServiceProvider)
        .getFinancialProfile(widget.profileId);
    if (!mounted) return;
    setState(() {
      _profile = p;
      _isLoading = false;
    });
  }

  Future<void> _updateStatus(String status) async {
    final current = _profile;
    if (current == null || current.caseStatus == status) return;
    setState(() => _updatingStatus = true);
    try {
      final fs = ref.read(firestoreServiceProvider);
      final advisorUid = ref.read(authServiceProvider).currentUser?.uid ?? 'unknown';
      await fs.updateCaseStatus(widget.profileId, status);
      await fs.appendCaseStatusHistory(
        caseId: widget.profileId,
        fromStatus: current.caseStatus,
        toStatus: status,
        changedByUid: advisorUid,
      );
      await fs.createNotification(
        userId: current.clientId,
        title: 'Actualización de tu caso',
        message:
            'Tu caso cambió de "${current.caseStatus}" a "$status".',
        caseId: current.id,
        type: 'case_status_changed',
      );
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estado actualizado: $status')),
        );
      }
    } finally {
      if (mounted) setState(() => _updatingStatus = false);
    }
  }

  Future<void> _updateDocumentStatus({
    required String documentId,
    required String clientId,
    required String caseId,
    required String fileName,
    required String newStatus,
  }) async {
    final fs = ref.read(firestoreServiceProvider);
    await fs.updateDocumentStatus(documentId, newStatus);
    if (newStatus == AppConstants.documentRejectedNeedsResend) {
      await fs.createNotification(
        userId: clientId,
        title: 'Documento requiere reenvio',
        message: 'Tu documento "$fileName" fue rechazado. Sube uno nuevo.',
        caseId: caseId,
        documentId: documentId,
        type: 'document_rejected',
      );
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Documento actualizado: $newStatus')),
    );
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
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.assignment_outlined,
                                  color: AppColors.primaryBlue, size: 22),
                              const SizedBox(width: 10),
                              Text(
                                'Datos de la entrevista',
                                style:
                                    Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                              'Actividad económica', p.economicActivity),
                          if (p.contractType != null &&
                              p.contractType!.isNotEmpty)
                            _InfoRow('Tipo de contrato', p.contractType!),
                          _InfoRow('Antigüedad laboral',
                              '${p.seniorityMonths} meses'),
                          if (p.desiredCreditType != null)
                            _InfoRow(
                              'Producto de interés', p.desiredCreditType!),
                          _InfoRow(
                            'Obligaciones declaradas',
                            '${p.obligations.length}',
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 80.ms),
                    const SizedBox(height: 16),
                    // Financial summary
                    Text('Perfil financiero',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    _InfoRow('Ingresos mensuales',
                        AppFormatters.currency(p.monthlyIncome)),
                    _InfoRow('Total cuotas actuales',
                        AppFormatters.currency(p.totalMonthlyPayments)),
                    _InfoRow('Capacidad disponible',
                        AppFormatters.currency(p.availableCapacity),
                        isHighlight: true),
                    _InfoRow('Monto deseado',
                        AppFormatters.currency(p.desiredAmount)),
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
                                      if (o.bankExtractFileName != null &&
                                          o.bankExtractFileName!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            'Extracto: ${o.bankExtractFileName}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.primaryBlueDark,
                                            ),
                                          ),
                                        ),
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
                    Row(
                      children: [
                        Text('Estado del caso',
                            style: Theme.of(context).textTheme.titleLarge),
                        if (_updatingStatus) ...[
                          const SizedBox(width: 10),
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ],
                      ],
                    ),
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
                        onChanged: _updatingStatus
                            ? null
                            : (v) {
                                if (v != null) _updateStatus(v);
                              },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Historial de estados',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    StreamBuilder<QuerySnapshot>(
                      stream: ref
                          .read(firestoreServiceProvider)
                          .streamCaseStatusHistory(p.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final history = snapshot.data?.docs ?? [];
                        if (history.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              'Aún no hay cambios de estado registrados.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          );
                        }
                        return Column(
                          children: history.map((h) {
                            final data = h.data() as Map<String, dynamic>;
                            final from = (data['fromStatus'] as String?) ?? 'Sin estado';
                            final to = (data['toStatus'] as String?) ?? 'Sin estado';
                            final changedAt = (data['changedAt'] as Timestamp?)?.toDate();
                            return Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$from  →  $to',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (changedAt != null)
                                    Text(
                                      AppFormatters.date(changedAt),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Text('Documentos del caso',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    StreamBuilder<QuerySnapshot>(
                      stream: ref
                          .read(firestoreServiceProvider)
                          .streamCaseDocuments(p.id),
                      builder: (context, snapshot) {
                        final docs = snapshot.data?.docs ?? [];
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(12),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (docs.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              'Este caso no tiene documentos cargados.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          );
                        }
                        return Column(
                          children: docs.map((d) {
                            final data = d.data() as Map<String, dynamic>;
                            final status = (data['status'] as String?) ??
                                AppConstants.documentPendingReview;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (data['fileName'] as String?) ?? 'Documento',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    (data['documentType'] as String?) ??
                                        'Soporte general',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    value: AppConstants.documentStates.contains(status)
                                        ? status
                                        : AppConstants.documentPendingReview,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: OutlineInputBorder(),
                                    ),
                                    items: AppConstants.documentStates
                                        .map((s) => DropdownMenuItem(
                                              value: s,
                                              child: Text(s),
                                            ))
                                        .toList(),
                                    onChanged: (v) {
                                      if (v != null) {
                                        _updateDocumentStatus(
                                          documentId: d.id,
                                          clientId: p.clientId,
                                          caseId: p.id,
                                          fileName:
                                              (data['fileName'] as String?) ??
                                                  'Documento',
                                          newStatus: v,
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
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
