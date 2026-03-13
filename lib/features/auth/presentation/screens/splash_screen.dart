import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/auth_service.dart';

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

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: _splashDurationMs));
    if (!mounted) return;

    final authService = ref.read(authServiceProvider);
    final user = authService.currentUser;

    if (user != null) {
      final userData = await authService.getUserData(user.uid);
      if (!mounted) return;
      if (userData?.isAdvisor == true) {
        context.go(AppRoutes.advisorDashboard);
      } else {
        context.go(AppRoutes.clientHome);
      }
    } else {
      context.go(AppRoutes.login);
    }
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
          child: Column(
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
                  .scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut)
                  .fadeIn(delay: 200.ms, duration: 400.ms),
              const SizedBox(height: 28),
              // Title
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
              )
                  .animate()
                  .fadeIn(delay: 900.ms, duration: 500.ms),
              const Spacer(flex: 2),
              // Loading indicator (determinado como en mockup)
              SizedBox(
                width: 200,
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, _) => LinearProgressIndicator(
                    value: _progressController.value,
                    backgroundColor: AppColors.blueTranslucent,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 1200.ms, duration: 400.ms),
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
        ),
      ),
    );
  }
}
