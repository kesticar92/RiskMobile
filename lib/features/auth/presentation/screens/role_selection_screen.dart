import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/gradient_button.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Selecciona tu rol',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 32),
              GradientButton(
                label: 'Soy Cliente',
                onPressed: () => context.go(AppRoutes.clientHome),
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              GradientButton(
                label: 'Soy Asesor',
                onPressed: () => context.go(AppRoutes.advisorDashboard),
                icon: Icons.business_center_outlined,
                gradient: AppColors.advisorGradient,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
