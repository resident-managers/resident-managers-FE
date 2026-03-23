import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'core/app_flavor.dart';
import 'app_admin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.flavor = AppFlavor.admin;
  await dotenv.load(fileName: '.env');
  await initHiveForFlutter();
  runApp(const ProviderScope(child: AppAdmin()));
}
