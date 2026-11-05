import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/session_provider.dart';
import 'services/local_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [localStoreProvider.overrideWithValue(LocalStore(prefs))],
      child: const AluBugBountyApp(),
    ),
  );
}

class AluBugBountyApp extends ConsumerWidget {
  const AluBugBountyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'ALU Bug Bounty',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
