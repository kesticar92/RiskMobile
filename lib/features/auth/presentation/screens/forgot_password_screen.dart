import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/glass_card.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });

    try {
      await ref.read(authServiceProvider).sendPasswordReset(_emailCtrl.text.trim());
      if (!mounted) return;
      setState(() { _sent = true; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() {
        _error = 'No pudimos enviar el correo. Verifica el email e intenta de nuevo.';
        _isLoading = false;
      });
    }
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
                  const SizedBox(height: 24),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 18),
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 32),
                  Text(
                    'Recuperar contraseña',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, duration: 400.ms),
                  const SizedBox(height: 8),
                  Text(
                    'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(delay: 150.ms),
                  const SizedBox(height: 32),
                  if (_sent) ...[
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(Icons.mark_email_read_outlined,
                              size: 56, color: AppColors.primaryBlue),
                          const SizedBox(height: 16),
                          Text(
                            'Revisa tu correo',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Te enviamos un enlace a ${_emailCtrl.text.trim()} para restablecer tu contraseña.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: 24),
                    GradientButton(
                      label: 'Volver al inicio de sesión',
                      onPressed: () => context.pop(),
                      icon: Icons.arrow_back,
                    ),
                  ] else ...[
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
                                v?.trim().isNotEmpty == true && v!.contains('@')
                                    ? null
                                    : 'Ingresa un correo válido',
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
                                    child: Text(_error!,
                                        style: TextStyle(
                                            color: AppColors.riskHigh,
                                            fontSize: 13)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, duration: 400.ms),
                    const SizedBox(height: 24),
                    GradientButton(
                      label: 'Enviar enlace',
                      onPressed: _sendReset,
                      isLoading: _isLoading,
                      icon: Icons.send_rounded,
                    ).animate().fadeIn(delay: 300.ms),
                  ],
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
