import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/financial_profile_model.dart';

/// RF37: historial de evaluaciones del cliente ordenadas por fecha.
class EvaluationsHistoryScreen extends ConsumerWidget {
  const EvaluationsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Debes iniciar sesión.')));
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Historial de evaluaciones')),
      body: StreamBuilder<List<FinancialProfileModel>>(
        stream: ref.read(firestoreServiceProvider).streamClientProfiles(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Text(
                'No hay evaluaciones registradas.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final p = items[i];
              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => context.push(AppRoutes.calculator, extra: p.id),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppFormatters.date(p.createdAt),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _tag('Score: ${p.riskScore}'),
                          _tag('Endeudamiento: ${(p.debtLevel * 100).toStringAsFixed(1)}%'),
                          _tag('Estado: ${p.caseStatus}'),
                          _tag('Actividad: ${p.economicActivity}'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: () => _showDocumentsByCase(
                            context: context,
                            ref: ref,
                            userId: uid,
                            caseId: p.id,
                          ),
                          icon: const Icon(Icons.folder_open_outlined, size: 18),
                          label: const Text('Ver documentos del caso'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _tag(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(text, style: const TextStyle(fontSize: 12)),
      );

  void _showDocumentsByCase({
    required BuildContext context,
    required WidgetRef ref,
    required String userId,
    required String caseId,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          minChildSize: 0.45,
          maxChildSize: 0.9,
          builder: (ctx, controller) {
            return StreamBuilder(
              stream: ref
                  .read(firestoreServiceProvider)
                  .streamUserCaseDocuments(userId: userId, caseId: caseId),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(
                    child: Text('No hay documentos cargados para este caso.'),
                  );
                }
                return ListView.separated(
                  controller: controller,
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(height: 12),
                  itemBuilder: (_, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    final fileName = (data['fileName'] ?? 'Documento') as String;
                    final docType =
                        (data['documentType'] ?? 'Sin tipo') as String;
                    final status = (data['status'] ?? 'Sin estado') as String;
                    final downloadUrl =
                        (data['downloadUrl'] as String?)?.trim() ?? '';
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        (data['mimeType'] as String?)?.contains('pdf') == true
                            ? Icons.picture_as_pdf
                            : Icons.image_outlined,
                      ),
                      title: Text(
                        fileName,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text('$docType • $status'),
                      trailing: downloadUrl.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Abrir enlace del archivo',
                              icon: const Icon(Icons.open_in_new, size: 20),
                              onPressed: () async {
                                final uri = Uri.tryParse(downloadUrl);
                                if (uri == null) return;
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              },
                            ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
