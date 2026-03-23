import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'core/graphql_client.dart';
import 'screens/login/login_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/home/admin_dashboard_screen.dart';
import 'screens/admin/user_management_screen.dart';
import 'screens/admin/user_form_screen.dart';
import 'models/user_model.dart';

final _adminRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/forgot-password',
      builder: (_, _) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (_, state) =>
          ResetPasswordScreen(email: state.extra as String? ?? ''),
    ),
    GoRoute(
      path: '/admin-dashboard',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/user-management',
      builder: (context, state) => const UserManagementScreen(),
    ),
    GoRoute(
      path: '/user-management/create',
      builder: (_, _) => const UserFormScreen(),
    ),
    GoRoute(
      path: '/user-management/:id/edit',
      builder: (_, state) => UserFormScreen(
        user: state.extra as UserModel?,
      ),
    ),
  ],
);

class AppAdmin extends StatelessWidget {
  const AppAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: GraphQLConfig.client,
      child: MaterialApp.router(
        title: 'Quản Lý Dân Cư - Admin',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF137fec),
            primary: const Color(0xFF137fec),
          ),
          useMaterial3: true,
          fontFamily: 'Public Sans',
        ),
        routerConfig: _adminRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
