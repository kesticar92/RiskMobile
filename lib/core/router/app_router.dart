import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/interview/presentation/screens/interview_screen.dart';
import '../../features/documents/presentation/screens/documents_screen.dart';
import '../../features/calculator/presentation/screens/calculator_screen.dart';
import '../../features/simulator/presentation/screens/simulator_screen.dart';
import '../../features/advisor/presentation/screens/advisor_dashboard_screen.dart';
import '../../features/advisor/presentation/screens/client_detail_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/payments/presentation/screens/payments_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/auth/presentation/screens/client_home_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const roleSelection = '/role-selection';
  static const clientHome = '/client-home';
  static const interview = '/interview';
  static const documents = '/documents';
  static const calculator = '/calculator';
  static const simulator = '/simulator';
  static const advisorDashboard = '/advisor-dashboard';
  static const clientDetail = '/client-detail';
  static const chat = '/chat';
  static const payments = '/payments';
  static const settings = '/settings';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const LoginScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const RegisterScreen(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const RoleSelectionScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.clientHome,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const ClientHomeScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.interview,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const InterviewScreen(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.documents,
        pageBuilder: (context, state) {
          final caseId = state.extra as String?;
          return CustomTransitionPage(
            child: DocumentsScreen(caseId: caseId),
            transitionsBuilder: _slideTransition,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.calculator,
        pageBuilder: (context, state) {
          final profileId = state.extra as String?;
          return CustomTransitionPage(
            child: CalculatorScreen(profileId: profileId),
            transitionsBuilder: _slideTransition,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.simulator,
        pageBuilder: (context, state) {
          final profileId = state.extra as String?;
          return CustomTransitionPage(
            child: SimulatorScreen(profileId: profileId),
            transitionsBuilder: _slideTransition,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.advisorDashboard,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const AdvisorDashboardScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.clientDetail,
        pageBuilder: (context, state) {
          final profileId = state.extra as String;
          return CustomTransitionPage(
            child: ClientDetailScreen(profileId: profileId),
            transitionsBuilder: _slideTransition,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.chat,
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, String>;
          return CustomTransitionPage(
            child: ChatScreen(
              otherUserId: args['otherUserId']!,
              otherUserName: args['otherUserName']!,
              caseId: args['caseId'],
            ),
            transitionsBuilder: _slideTransition,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.payments,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const PaymentsScreen(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SettingsScreen(),
          transitionsBuilder: _slideTransition,
        ),
      ),
    ],
  );
});

Widget _fadeTransition(context, animation, secondaryAnimation, child) {
  return FadeTransition(opacity: animation, child: child);
}

Widget _slideTransition(context, animation, secondaryAnimation, child) {
  const begin = Offset(1.0, 0.0);
  const end = Offset.zero;
  final tween = Tween(begin: begin, end: end).chain(
    CurveTween(curve: Curves.easeOutCubic),
  );
  return SlideTransition(
    position: animation.drive(tween),
    child: child,
  );
}
