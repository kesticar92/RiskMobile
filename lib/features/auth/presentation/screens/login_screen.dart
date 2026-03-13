import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/glass_card.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });

    try {
      final user = await ref.read(authServiceProvider).loginWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      if (user?.isAdvisor == true) {
        context.go(AppRoutes.advisorDashboard);
      } else {
        context.go(AppRoutes.clientHome);
      }
    } catch (e) {
      setState(() { _error = _mapError(e.toString()); });
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  Future<void> _biometricLogin() async {
    final auth = ref.read(authServiceProvider);
    if (auth.currentUser == null) {
      _showSnack('Primero inicia sesión para activar la biometría');
      return;
    }
    final ok = await auth.authenticateWithBiometrics();
    if (ok && mounted) {
      final user = await auth.getUserData(auth.currentUser!.uid);
      if (!mounted) return;
      if (user?.isAdvisor == true) {
        context.go(AppRoutes.advisorDashboard);
      } else {
        context.go(AppRoutes.clientHome);
      }
    }
  }

  String _mapError(String e) {
    if (e.contains('user-not-found')) return 'No existe cuenta con este correo';
    if (e.contains('wrong-password')) return 'Contraseña incorrecta';
    if (e.contains('invalid-email')) return 'Correo inválido';
    if (e.contains('too-many-requests')) return 'Demasiados intentos. Espera un momento';
    return 'Error al iniciar sesión. Intenta de nuevo';
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryBlue.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.shield_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
                            child: const Text(
                              'RiskMobile',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            'Asesoría crediticia inteligente',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3),
                  const SizedBox(height: 48),
                  Text(
                    'Bienvenido',
                    style: Theme.of(context).textTheme.displayMedium,
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
                  const SizedBox(height: 6),
                  Text(
                    'Inicia sesión para continuar',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).animate().fadeIn(delay: 150.ms),
                  const SizedBox(height: 36),
                  // Form fields
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (v) =>
                              v?.contains('@') == true ? null : 'Ingresa un correo válido',
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (v) => (v?.length ?? 0) >= 6
                              ? null
                              : 'Mínimo 6 caracteres',
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.riskHigh.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline,
                                    color: AppColors.riskHigh, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: TextStyle(
                                        color: AppColors.riskHigh, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push(AppRoutes.forgotPassword),
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GradientButton(
                    label: 'Iniciar sesión',
                    onPressed: _login,
                    isLoading: _isLoading,
                    icon: Icons.login_rounded,
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
                  const SizedBox(height: 16),
                  // Biometric
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: _biometricLogin,
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Acceso biométrico'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 350.ms),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿No tienes cuenta? ',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.register),
                        child: ShaderMask(
                          shaderCallback: (b) =>
                              AppColors.primaryGradient.createShader(b),
                          child: const Text(
                            'Regístrate',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
