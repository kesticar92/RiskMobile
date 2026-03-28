import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import 'app_router.dart';

/// Si hay historial hace [pop]; si no (p. ej. se llegó con [GoRouter.go]), va a [fallbackRoute].
void popOrGo(BuildContext context, String fallbackRoute) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(fallbackRoute);
  }
}

/// Igual que [popOrGo] pero si no hay historial envía al home según rol (cliente / asesor).
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
