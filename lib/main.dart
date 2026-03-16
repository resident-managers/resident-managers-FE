import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'core/graphql_client.dart';
import 'screens/resident/resident_directory_screen.dart';
import 'screens/resident/add_resident_screen.dart';
import 'screens/resident/resident_detail_screen.dart';
import 'screens/household/household_list_screen.dart';
import 'screens/household/household_detail_screen.dart';
import 'screens/household/setup_household_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/home/dashboard_screen.dart';
import 'screens/resident/edit_resident_screen.dart';
import 'models/resident.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await initHiveForFlutter();
  runApp(const ProviderScope(child: MyApp()));
}

final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
    GoRoute(
      path: '/directory',
      builder: (context, state) => const ResidentDirectoryScreen(),
    ),
    GoRoute(
      path: '/add-resident',
      builder: (context, state) => const AddResidentScreen(),
    ),
    GoRoute(
      path: '/resident-detail/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ResidentDetailScreen(residentId: id);
      },
    ),
    GoRoute(
      path: '/resident-detail/:id/edit',
      builder: (context, state) {
        final resident = state.extra as Resident;
        return EditResidentScreen(resident: resident);
      },
    ),
    GoRoute(
      path: '/households',
      builder: (context, state) => const HouseholdListScreen(),
    ),
    GoRoute(
      path: '/household/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return HouseholdDetailScreen(householdId: id);
      },
    ),
    GoRoute(
      path: '/setup-household',
      builder: (context, state) => const SetupHouseholdScreen(isEditMode: false),
    ),
    GoRoute(
      path: '/household/:id/edit',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return SetupHouseholdScreen(
          isEditMode: true,
          householdId: id,
        );
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: GraphQLConfig.client,
      child: MaterialApp.router(
        title: 'Quản Lý Dân Cư',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF137fec),
            primary: const Color(0xFF137fec),
          ),
          useMaterial3: true,
          fontFamily: 'Public Sans',
        ),
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
