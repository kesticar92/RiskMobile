import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../constants/app_constants.dart';
import 'firestore_service.dart';

final storageServiceProvider =
    Provider<StorageService>((ref) => StorageService(ref.read(firestoreServiceProvider)));

/// Subida a Firebase Storage: `documents/{userId}/{caseId}/{uuid}_{nombre}` — RF35.
class StorageService {
  StorageService(this._firestore);

  final FirestoreService _firestore;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static const _uuid = Uuid();

  static const int maxFileBytes = 15 * 1024 * 1024; // 15 MB

  /// Sube archivo local y guarda metadatos en Firestore.
  Future<void> uploadCaseDocument({
    String? localPath,
    Uint8List? fileBytes,
    required String originalFileName,
    required String userId,
    required String caseFolder,
    required String documentType,
    void Function(double progress)? onProgress,
  }) async {
    if ((localPath == null || localPath.isEmpty) &&
        (fileBytes == null || fileBytes.isEmpty)) {
      throw StateError('No se recibio archivo para subir.');
    }

    final int len;
    File? file;
    if (fileBytes != null && fileBytes.isNotEmpty) {
      len = fileBytes.lengthInBytes;
    } else {
      if (kIsWeb) {
        throw StateError('En web se requieren bytes del archivo.');
      }
      file = File(localPath!);
      if (!file.existsSync()) {
        throw StateError('Archivo no encontrado o path invalido.');
      }
      len = await file.length();
    }

    if (len > maxFileBytes) {
      throw StateError('El archivo supera el maximo permitido (15 MB).');
    }

    final safe = _sanitizeFileName(originalFileName);
    final objectName = '${_uuid.v4()}_$safe';
    final ref = _storage.ref().child(AppConstants.storageDocuments).child(userId).child(caseFolder).child(objectName);

    final mime = _mimeFromName(originalFileName);
    final metadata = SettableMetadata(
      contentType: mime,
      customMetadata: {'originalName': originalFileName, 'caseId': caseFolder},
    );
    final task = (fileBytes != null && fileBytes.isNotEmpty)
        ? ref.putData(fileBytes, metadata)
        : ref.putFile(file!, metadata);

    final sub = task.snapshotEvents.listen((snap) {
      if (snap.totalBytes > 0) {
        onProgress?.call(snap.bytesTransferred / snap.totalBytes);
      }
    });
    try {
      await task;
    } finally {
      await sub.cancel();
    }

    final downloadUrl = await ref.getDownloadURL();
    final storagePath = ref.fullPath;

    await _firestore.saveDocumentMetadata(
      userId: userId,
      caseId: caseFolder,
      fileName: originalFileName,
      storagePath: storagePath,
      downloadUrl: downloadUrl,
      mimeType: mime,
      documentType: documentType,
    );
  }

  String _sanitizeFileName(String name) {
    var base = p.basename(name.trim());
    base = base.replaceAll(RegExp(r'[\\/]'), '_');
    if (base.isEmpty) base = 'documento';
    return base.length > 120 ? base.substring(0, 120) : base;
  }

  String _mimeFromName(String name) {
    final ext = p.extension(name).toLowerCase().replaceFirst('.', '');
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }
}
