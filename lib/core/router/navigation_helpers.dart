import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import 'app_router.dart';

/// Hace pop si hay historial; si no, navega al fallback.
void popOrGo(BuildContext context, String fallbackRoute) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(fallbackRoute);
  }
}

/// Hace pop si hay historial; si no, redirige al home segun rol.
Future<void> popOrHomeAsync(BuildContext context, WidgetRef ref) async {
  if (context.canPop()) {
    context.pop();
    return;
  }
  final auth = ref.read(authServiceProvider);
  final uid = auth.currentUser?.uid;
  if (uid == null) {
    if (context.mounted) context.go(AppRoutes.login);
    return;
  }
  final user = await auth.getUserData(uid);
  if (!context.mounted) return;
  context.go(
    user?.isAdvisor == true ? AppRoutes.advisorDashboard : AppRoutes.clientHome,
  );
}
