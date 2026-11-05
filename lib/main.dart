import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/session_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/sync_provider.dart';
import 'services/firebase_setup.dart';
import 'services/local_store.dart';
import 'widgets/notice_banner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  await setUpFirebase();
  final prefs = await SharedPreferences.getInstance();
  final store = LocalStore(prefs);
  await store.dropLegacyData();
  runApp(
    ProviderScope(
      overrides: [localStoreProvider.overrideWithValue(store)],
      child: const AluBugBountyApp(),
    ),
  );
}

class AluBugBountyApp extends ConsumerWidget {
  const AluBugBountyApp({super.key});

  static final _messenger = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(writeErrorsProvider, (_, message) {
      if (message == null) return;
      _messenger.currentState?.showSnackBar(SnackBar(content: Text(message)));
      ref.read(writeErrorsProvider.notifier).clear();
    });
    final reduceMotion = ref.watch(
      settingsProvider.select((settings) => settings.reduceMotion),
    );
    return MaterialApp.router(
      title: 'ALU Bug Bounty',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _messenger,
      theme: AppTheme.light,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) {
        final app = Stack(children: [child!, const NoticeLayer()]);
        if (!reduceMotion) return app;
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: app,
        );
      },
    );
  }
}
