import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import 'app_router.dart';

/// RF32: cierre de sesión con confirmación y navegación al login.
Future<void> signOutWithConfirmation(
  BuildContext context,
  WidgetRef ref, {
  String message =
      '¿Deseas cerrar sesión? Deberás volver a iniciar sesión para entrar.',
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Cerrar sesión'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Cerrar sesión'),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  await ref.read(authServiceProvider).signOut();
  if (context.mounted) context.go(AppRoutes.login);
}
