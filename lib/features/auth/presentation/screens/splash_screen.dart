import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/user_preferences.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  static const int _splashDurationMs = 2500;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _splashDurationMs),
    )..forward();
    _navigate();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  bool _biometricFailed = false;
  bool _biometricLoading = false;

  Future<void> _goToRoleHome(String uid) async {
    final authService = ref.read(authServiceProvider);
    final userData = await authService.getUserData(uid);
    if (!mounted) return;
    if (userData?.isAdvisor == true) {
      context.go(AppRoutes.advisorDashboard);
    } else {
      context.go(AppRoutes.clientHome);
    }
  }

  /// RF03: si hay sesión Firebase y biometría activada, exigir local_auth antes de entrar.
  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: _splashDurationMs));
    if (!mounted) return;

    final authService = ref.read(authServiceProvider);
    final user = authService.currentUser;

    if (user == null) {
      context.go(AppRoutes.login);
      return;
    }

    final prefs = await UserPreferences.instance();
    if (prefs.biometricEnabled) {
      setState(() => _biometricLoading = true);
      final ok = await authService.authenticateWithBiometrics();
      if (!mounted) return;
      setState(() => _biometricLoading = false);
      if (!ok) {
        setState(() => _biometricFailed = true);
        return;
      }
    }

    await _goToRoleHome(user.uid);
  }

  Future<void> _retryBiometric() async {
    setState(() => _biometricFailed = false);
    final authService = ref.read(authServiceProvider);
    final user = authService.currentUser;
    if (user == null) {
      if (mounted) context.go(AppRoutes.login);
      return;
    }
    setState(() => _biometricLoading = true);
    final ok = await authService.authenticateWithBiometrics();
    if (!mounted) return;
    setState(() => _biometricLoading = false);
    if (ok) {
      await _goToRoleHome(user.uid);
    } else {
      setState(() => _biometricFailed = true);
    }
  }

  Future<void> _signOutFromSplash() async {
    await ref.read(authServiceProvider).signOut();
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE3F2FD),
              Color(0xFFF3E5F5),
              Color(0xFFFFFFFF),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  // Logo
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: AppColors.secondaryPurple.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      color: Colors.white,
                      size: 56,
                    ),
                  )
                      .animate()
                      .scale(
                          delay: 200.ms,
                          duration: 600.ms,
                          curve: Curves.elasticOut)
                      .fadeIn(delay: 200.ms, duration: 400.ms),
                  const SizedBox(height: 28),
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.primaryGradient.createShader(bounds),
                    child: const Text(
                      'RiskMobile',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 500.ms)
                      .slideY(begin: 0.3, delay: 600.ms, duration: 500.ms),
                  const SizedBox(height: 10),
                  Text(
                    'Tu asesoría crediticia, en tu mano',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ).animate().fadeIn(delay: 900.ms, duration: 500.ms),
                  const Spacer(flex: 2),
                  if (_biometricLoading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: CircularProgressIndicator(),
                    )
                  else
                    SizedBox(
                      width: 200,
                      child: AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, _) => LinearProgressIndicator(
                          value: _progressController.value,
                          backgroundColor: AppColors.blueTranslucent,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primaryBlue),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ).animate().fadeIn(delay: 1200.ms, duration: 400.ms),
                  const SizedBox(height: 12),
                  Text(
                    'v1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ).animate().fadeIn(delay: 1400.ms),
                  const SizedBox(height: 40),
                ],
              ),
              if (_biometricFailed)
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 32,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.fingerprint,
                                  color: AppColors.primaryBlue, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'No pudimos validar tu biometría',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Reintenta o cierra sesión para entrar con correo y contraseña.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _biometricLoading ? null : _retryBiometric,
                            child: const Text('Reintentar'),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed:
                                _biometricLoading ? null : _signOutFromSplash,
                            child: const Text('Cerrar sesión'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
