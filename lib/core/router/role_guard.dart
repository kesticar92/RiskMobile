import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import 'app_router.dart';

/// RF04: pantallas solo asesor — redirige clientes al home cliente.
class AdvisorRouteGate extends ConsumerStatefulWidget {
  final Widget child;

  const AdvisorRouteGate({super.key, required this.child});

  @override
  ConsumerState<AdvisorRouteGate> createState() => _AdvisorRouteGateState();
}

class _AdvisorRouteGateState extends ConsumerState<AdvisorRouteGate> {
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _verify());
  }

  Future<void> _verify() async {
    final auth = ref.read(authServiceProvider);
    final uid = auth.currentUser?.uid;
    if (uid == null) {
      if (mounted) context.go(AppRoutes.login);
      return;
    }
    final user = await auth.getUserData(uid);
    if (!mounted) return;
    if (user != null && !user.isAdvisor) {
      context.go(AppRoutes.clientHome);
      return;
    }
    setState(() => _checked = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return widget.child;
  }
}

/// RF04: pantallas solo cliente — redirige asesores al CRM.
class ClientRouteGate extends ConsumerStatefulWidget {
  final Widget child;

  const ClientRouteGate({super.key, required this.child});

  @override
  ConsumerState<ClientRouteGate> createState() => _ClientRouteGateState();
}

class _ClientRouteGateState extends ConsumerState<ClientRouteGate> {
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _verify());
  }

  Future<void> _verify() async {
    final auth = ref.read(authServiceProvider);
    final uid = auth.currentUser?.uid;
    if (uid == null) {
      if (mounted) context.go(AppRoutes.login);
      return;
    }
    final user = await auth.getUserData(uid);
    if (!mounted) return;
    if (user != null && user.isAdvisor) {
      context.go(AppRoutes.advisorDashboard);
      return;
    }
    setState(() => _checked = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return widget.child;
  }
}
