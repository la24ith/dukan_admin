// lib/core/routing/app_router.dart
import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_shell.dart';

class AppRoutes {
  static const splash = '/';
  static const auth = '/auth';
  static const dashboard = '/dashboard';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.auth:
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardShell());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('صفحة غير موجودة'))),
        );
    }
  }
}
