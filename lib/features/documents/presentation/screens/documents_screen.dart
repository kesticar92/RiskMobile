import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/glass_card.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  final String? caseId;
  const DocumentsScreen({super.key, this.caseId});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  final List<_DocItem> _documents = [];
  final _picker = ImagePicker();

  Future<void> _pickFromCamera() async {
    final img = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (img != null && mounted) {
      setState(() => _documents.add(_DocItem(
        name: 'Foto_${DateTime.now().millisecondsSinceEpoch}.jpg',
        type: 'image',
        path: img.path,
      )));
    }
  }

  Future<void> _pickFromGallery() async {
    final img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (img != null && mounted) {
      setState(() => _documents.add(_DocItem(
        name: img.name,
        type: 'image',
        path: img.path,
      )));
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
    );
    if (result != null && result.files.single.path != null && mounted) {
      final f = result.files.single;
      setState(() => _documents.add(_DocItem(
        name: f.name,
        type: f.extension ?? 'file',
        path: f.path!,
      )));
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
                  Text('Mis documentos',
                      style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassCard(
                      color: AppColors.blueTranslucent,
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: AppColors.primaryBlueDark, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Adjunta soportes de ingresos y obligaciones. Formatos aceptados: PDF, JPG, PNG.',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primaryBlueDark),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                    const SizedBox(height: 20),
                    Text('Tipo de documentos',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    ...const [
                      ('Certificado laboral / desprendible', Icons.badge_outlined),
                      ('Extractos bancarios', Icons.account_balance_outlined),
                      ('RUT / Cámara de comercio', Icons.description_outlined),
                      ('Resolución de pensión', Icons.elderly),
                    ].asMap().entries.map((e) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Icon(e.value.$2,
                                  color: AppColors.primaryBlue, size: 18),
                              const SizedBox(width: 12),
                              Text(e.value.$1,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ).animate().fadeIn(
                            delay: Duration(milliseconds: e.key * 60))),
                    const SizedBox(height: 20),
                    // Upload buttons
                    Row(
                      children: [
                        Expanded(
                          child: _UploadButton(
                            icon: Icons.camera_alt_outlined,
                            label: 'Tomar foto',
                            onTap: _pickFromCamera,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _UploadButton(
                            icon: Icons.photo_library_outlined,
                            label: 'Galería',
                            onTap: _pickFromGallery,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _UploadButton(
                            icon: Icons.upload_file_outlined,
                            label: 'Archivo',
                            onTap: _pickFile,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms),
                    if (_documents.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text('Documentos adjuntados',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 10),
                      ..._documents.asMap().entries.map((e) {
                        final doc = e.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.blueTranslucent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  doc.type == 'pdf'
                                      ? Icons.picture_as_pdf
                                      : Icons.image_outlined,
                                  color: AppColors.primaryBlue,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(doc.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13),
                                        overflow: TextOverflow.ellipsis),
                                    Text(doc.type.toUpperCase(),
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textLight)),
                                  ],
                                ),
                              ),
                              Icon(Icons.check_circle,
                                  color: AppColors.riskLow, size: 18),
                              IconButton(
                                icon: const Icon(Icons.close,
                                    size: 16, color: AppColors.textLight),
                                onPressed: () => setState(
                                    () => _documents.removeAt(e.key)),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 50.ms).slideX(begin: 0.2);
                      }),
                      const SizedBox(height: 20),
                      GradientButton(
                        label: 'Guardar documentos',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Documentos guardados exitosamente')),
                          );
                          context.pop();
                        },
                        icon: Icons.cloud_upload_outlined,
                      ),
                    ],
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
}

class _DocItem {
  final String name;
  final String type;
  final String path;
  _DocItem({required this.name, required this.type, required this.path});
}

class _UploadButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _UploadButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.blueTranslucent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 24),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    color: AppColors.primaryBlueDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
