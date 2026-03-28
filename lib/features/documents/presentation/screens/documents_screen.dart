import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/navigation_helpers.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/models/financial_profile_model.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/glass_card.dart';

/// RF08 — Cámara · RF09 — Archivos (PDF/imagen) · RF35 — Firebase Storage por usuario/caso.
class DocumentsScreen extends ConsumerStatefulWidget {
  final String? caseId;
  const DocumentsScreen({super.key, this.caseId});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  static const _allowedExt = {'pdf', 'jpg', 'jpeg', 'png'};
  static const _uuid = Uuid();
  static const _documentTypes = [
    'Extracto bancario',
    'Certificado laboral',
    'RUT / Camara de comercio',
    'Resolucion de pension',
    'Otro soporte',
  ];

  final List<_DocItem> _documents = [];
  final _picker = ImagePicker();

  String? _resolvedCaseFolder;
  bool _resolvingCase = true;
  bool _uploading = false;
  double _uploadProgress = 0;
  bool _requiresBankStatement = false;
  int _requiredExtractCount = 0;
  String _selectedDocumentType = _documentTypes.first;
  int _currentUploadIndex = 0;
  int _currentUploadTotal = 0;
  DateTime? _uploadStartedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveCase());
  }

  Future<void> _resolveCase() async {
    if (widget.caseId != null && widget.caseId!.isNotEmpty) {
      if (mounted) {
        setState(() {
          _resolvedCaseFolder = widget.caseId;
          _resolvingCase = false;
        });
      }
      return;
    }
    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid == null) {
      if (mounted) {
        setState(() {
          _resolvedCaseFolder = 'pending';
          _resolvingCase = false;
        });
      }
      return;
    }
    final fs = ref.read(firestoreServiceProvider);
    final id = await fs.getLatestCaseIdForClient(uid);
    FinancialProfileModel? profile;
    if (id != null) {
      profile = await fs.getFinancialProfile(id);
    }
    if (!mounted) return;
    setState(() {
      _resolvedCaseFolder = id ?? 'pending';
      _resolvingCase = false;
      _requiresBankStatement = (profile?.obligations.isNotEmpty ?? false);
      _requiredExtractCount = profile?.obligations.length ?? 0;
    });
  }

  int get _attachedExtractCount =>
      _documents.where((d) => d.documentType == 'Extracto bancario').length;

  bool _isAllowedPath(String pathOrName) {
    final parts = pathOrName.split('.');
    if (parts.length < 2) return false;
    return _allowedExt.contains(parts.last.toLowerCase());
  }

  String _typeFromName(String name) {
    final ext = name.split('.').last.toLowerCase();
    return ext == 'pdf' ? 'pdf' : 'image';
  }

  Future<void> _pickFromCamera() async {
    final img = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (img == null || !mounted) return;
    final path = img.path;
    if (!_isAllowedPath(path)) {
      _showErr('Formato no permitido.');
      return;
    }
    setState(() => _documents.add(_DocItem(
          id: _uuid.v4(),
          name: 'Foto_${DateTime.now().millisecondsSinceEpoch}.jpg',
          type: 'image',
          path: path,
          documentType: _selectedDocumentType,
        )));
  }

  Future<void> _pickFromGallery() async {
    final img = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (img == null || !mounted) return;
    final path = img.path;
    final name = img.name;
    if (!_isAllowedPath(path) && !_isAllowedPath(name)) {
      _showErr('Solo JPG o PNG desde galeria.');
      return;
    }
    setState(() => _documents.add(_DocItem(
          id: _uuid.v4(),
          name: name.isNotEmpty ? name : 'imagen.jpg',
          type: _typeFromName(name.isNotEmpty ? name : path),
          path: path,
          documentType: _selectedDocumentType,
        )));
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
    );
    if (result == null || result.files.single.path == null || !mounted) return;
    final f = result.files.single;
    final path = f.path!;
    if (!_isAllowedPath(f.name)) {
      _showErr('Formato no permitido (PDF, JPG, PNG, JPEG).');
      return;
    }
    setState(() => _documents.add(_DocItem(
          id: _uuid.v4(),
          name: f.name,
          type: _typeFromName(f.name),
          path: path,
          documentType: _selectedDocumentType,
        )));
  }

  void _showErr(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _saveDocuments() async {
    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid == null) {
      _showErr('Debes iniciar sesion.');
      return;
    }
    if (_resolvedCaseFolder == null) {
      _showErr('Espera un momento a resolver el caso.');
      return;
    }
    if (_documents.isEmpty) return;
    if (_requiresBankStatement &&
        _attachedExtractCount < _requiredExtractCount) {
      _showErr(
        'Debes adjuntar minimo $_requiredExtractCount extracto(s) bancario(s) por tus obligaciones declaradas.',
      );
      return;
    }

    setState(() {
      _uploading = true;
      _uploadProgress = 0;
      _currentUploadIndex = 0;
      _currentUploadTotal = _documents.length;
      _uploadStartedAt = DateTime.now();
    });

    final storage = ref.read(storageServiceProvider);
    final total = _documents.length;

    try {
      for (var i = 0; i < _documents.length; i++) {
        final doc = _documents[i];
        if (mounted) {
          setState(() {
            _currentUploadIndex = i + 1;
          });
        }
        await storage.uploadCaseDocument(
          localPath: doc.path,
          originalFileName: doc.name,
          userId: uid,
          caseFolder: _resolvedCaseFolder!,
          documentType: doc.documentType,
          onProgress: (p) {
            if (mounted) {
              setState(() => _uploadProgress = (i + p) / total);
            }
          },
        );
        if (mounted) setState(() => _uploadProgress = (i + 1) / total);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Documentos subidos correctamente a la nube.'),
        ),
      );
      popOrGo(context, AppRoutes.clientHome);
    } catch (e) {
      if (mounted) {
        _showErr('Error al subir: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _uploading = false;
          _uploadProgress = 0;
          _currentUploadIndex = 0;
          _currentUploadTotal = 0;
          _uploadStartedAt = null;
        });
      }
    }
  }

  void _removeById(String id) {
    setState(() => _documents.removeWhere((d) => d.id == id));
  }

  String _estimateRemaining() {
    final started = _uploadStartedAt;
    if (started == null || _uploadProgress <= 0) return '--';
    final elapsedMs = DateTime.now().difference(started).inMilliseconds;
    if (elapsedMs <= 0) return '--';
    final totalEstimateMs = (elapsedMs / _uploadProgress).round();
    final remainingMs = (totalEstimateMs - elapsedMs).clamp(0, 99999999);
    final secs = (remainingMs / 1000).round();
    if (secs < 60) return '${secs}s';
    final min = secs ~/ 60;
    final sec = secs % 60;
    return '${min}m ${sec}s';
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
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Mis documentos',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
            ),
            if (_uploading) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(value: _uploadProgress.clamp(0.0, 1.0)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUploadTotal > 0
                          ? 'Subiendo $_currentUploadIndex/$_currentUploadTotal ... ${(_uploadProgress * 100).toStringAsFixed(0)}%'
                          : 'Subiendo... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    if (_uploadStartedAt != null && _uploadProgress > 0)
                      Text(
                        'Tiempo estimado restante: ${_estimateRemaining()}',
                        style: TextStyle(fontSize: 11, color: AppColors.textLight),
                      ),
                  ],
                ),
              ),
            ],
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_resolvingCase)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    GlassCard(
                      color: AppColors.blueTranslucent,
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: AppColors.primaryBlueDark, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _resolvedCaseFolder == 'pending'
                                  ? 'Sin caso de entrevista aun: los archivos se guardan en tu carpeta hasta asociar un caso.'
                                  : 'Adjunta soportes de ingresos y obligaciones. Formatos: PDF, JPG, PNG. Max. 15 MB por archivo.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryBlueDark,
                              ),
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
                      ('RUT / Camara de comercio', Icons.description_outlined),
                      ('Resolucion de pension', Icons.elderly),
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
                    const SizedBox(height: 14),
                    Text(
                      'Tipo de soporte a cargar',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _documentTypes.map((type) {
                          final isSelected = _selectedDocumentType == type;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(type),
                              selected: isSelected,
                              onSelected: _uploading
                                  ? null
                                  : (_) => setState(
                                      () => _selectedDocumentType = type,
                                    ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_requiresBankStatement) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.riskMedium.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Se requieren $_requiredExtractCount extracto(s) bancario(s). Adjuntos: $_attachedExtractCount.',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: _UploadButton(
                            icon: Icons.camera_alt_outlined,
                            label: 'Tomar foto',
                            onTap: _uploading ? null : _pickFromCamera,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _UploadButton(
                            icon: Icons.photo_library_outlined,
                            label: 'Galeria',
                            onTap: _uploading ? null : _pickFromGallery,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _UploadButton(
                            icon: Icons.upload_file_outlined,
                            label: 'Archivo',
                            onTap: _uploading ? null : _pickFile,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms),
                    if (_documents.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text('Documentos adjuntados',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 10),
                      ..._documents.map((doc) {
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
                                    Text(
                                      doc.documentType,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.check_circle,
                                  color: AppColors.riskLow, size: 18),
                              IconButton(
                                icon: const Icon(Icons.close,
                                    size: 16, color: AppColors.textLight),
                                onPressed: _uploading
                                    ? null
                                    : () => _removeById(doc.id),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 50.ms).slideX(begin: 0.2);
                      }),
                      const SizedBox(height: 20),
                      GradientButton(
                        label: 'Guardar y subir documentos',
                        isLoading: _uploading,
                        onPressed: (_uploading || _resolvingCase)
                            ? null
                            : _saveDocuments,
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
  final String id;
  final String name;
  final String type;
  final String path;
  final String documentType;

  _DocItem({
    required this.id,
    required this.name,
    required this.type,
    required this.path,
    required this.documentType,
  });
}

class _UploadButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _UploadButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: GestureDetector(
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
      ),
    );
  }
}
