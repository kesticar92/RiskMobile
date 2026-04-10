import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/user_preferences.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _prefsLoaded = false;
  bool _biometricEnabled = false;
  bool _notificationsPush = true;
  bool _notificationsEmail = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final p = await UserPreferences.instance();
    if (!mounted) return;
    setState(() {
      _biometricEnabled = p.biometricEnabled;
      _notificationsPush = p.notificationsPush;
      _notificationsEmail = p.notificationsEmail;
      _prefsLoaded = true;
    });
  }

  Future<void> _setBiometric(bool value) async {
    final auth = ref.read(authServiceProvider);
    if (value && !await auth.canUseBiometrics) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Este dispositivo no tiene biometría configurada o disponible'),
          ),
        );
      }
      return;
    }
    if (value) {
      final ok = await auth.authenticateWithBiometrics();
      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Confirma tu identidad para activar la biometría')),
          );
        }
        return;
      }
    }
    final p = await UserPreferences.instance();
    await p.setBiometricEnabled(value);
    if (!mounted) return;
    setState(() => _biometricEnabled = value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Biometría activada: te pediremos validación al abrir la app'
              : 'Biometría desactivada',
        ),
      ),
    );
  }

  Future<void> _setNotificationsPush(bool value) async {
    final p = await UserPreferences.instance();
    await p.setNotificationsPush(value);
    if (!mounted) return;
    setState(() => _notificationsPush = value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Notificaciones push activadas (preferencia guardada)'
              : 'Notificaciones push desactivadas',
        ),
      ),
    );
  }

  Future<void> _setNotificationsEmail(bool value) async {
    final p = await UserPreferences.instance();
    await p.setNotificationsEmail(value);
    if (!mounted) return;
    setState(() => _notificationsEmail = value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Alertas por correo activadas (preferencia guardada)'
              : 'Alertas por correo desactivadas',
        ),
      ),
    );
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
                    onTap: () => context.pop(),
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
                  Text('Configuración',
                      style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    if (!_prefsLoaded)
                      const Padding(
                        padding: EdgeInsets.all(48),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else ...[
                      _SettingsSection(
                        title: 'Cuenta',
                        items: [
                          _SettingsItem(
                            icon: Icons.person_outline,
                            label: 'Editar perfil',
                            onTap: () {},
                          ),
                          _SettingsItem(
                            icon: Icons.lock_outline,
                            label: 'Cambiar contraseña',
                            onTap: () {},
                          ),
                          _SettingsItem(
                            icon: Icons.fingerprint,
                            label: 'Autenticación biométrica',
                            onTap: null,
                            trailing: Switch.adaptive(
                              value: _biometricEnabled,
                              onChanged: (v) => _setBiometric(v),
                              activeColor: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 16),
                      _SettingsSection(
                        title: 'Notificaciones',
                        items: [
                          _SettingsItem(
                            icon: Icons.notifications_outlined,
                            label: 'Notificaciones push',
                            onTap: null,
                            trailing: Switch.adaptive(
                              value: _notificationsPush,
                              onChanged: (v) => _setNotificationsPush(v),
                              activeColor: AppColors.primaryBlue,
                            ),
                          ),
                          _SettingsItem(
                            icon: Icons.email_outlined,
                            label: 'Notificaciones por correo',
                            onTap: null,
                            trailing: Switch.adaptive(
                              value: _notificationsEmail,
                              onChanged: (v) => _setNotificationsEmail(v),
                              activeColor: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 150.ms),
                      const SizedBox(height: 16),
                      _SettingsSection(
                        title: 'Privacidad y seguridad',
                        items: [
                        _SettingsItem(
                          icon: Icons.shield_outlined,
                          label: 'Política de privacidad',
                          onTap: () {},
                        ),
                        _SettingsItem(
                          icon: Icons.description_outlined,
                          label: 'Términos y condiciones',
                          onTap: () {},
                        ),
                        _SettingsItem(
                          icon: Icons.delete_outline,
                          label: 'Eliminar cuenta',
                          onTap: () {},
                          labelColor: AppColors.riskHigh,
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 16),
                    _SettingsSection(
                      title: 'Información',
                      items: [
                        _SettingsItem(
                          icon: Icons.info_outline,
                          label: 'Acerca de RiskMobile',
                          onTap: () {},
                          trailing: const Text(
                            'v1.0.0',
                            style: TextStyle(
                                color: AppColors.textLight, fontSize: 13),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 250.ms),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await ref.read(authServiceProvider).signOut();
                          if (context.mounted) context.go(AppRoutes.login);
                        },
                        icon: const Icon(Icons.logout,
                            color: AppColors.riskHigh),
                        label: const Text('Cerrar sesión',
                            style: TextStyle(color: AppColors.riskHigh)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: AppColors.riskHigh.withOpacity(0.3)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 40),
                    ],
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

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;

  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textLight,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final item = e.value;
              final isLast = e.key == items.length - 1;
              return Column(
                children: [
                  item,
                  if (!isLast)
                    const Divider(height: 0, indent: 52),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? labelColor;

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final child = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.blueTranslucent,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 17, color: AppColors.primaryBlue),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: labelColor ?? AppColors.textPrimary,
                ),
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right,
                    color: AppColors.textLight, size: 18),
          ],
        ),
      );
    if (onTap == null) return child;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: child,
    );
  }
}
