import 'package:supabase_flutter/supabase_flutter.dart';

/// Build-time settings, passed with `--dart-define-from-file=env/local.json`.
abstract final class BackendConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );
  static const googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
  );
  static const googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
  );
}

const photoBucket = 'report-photos';

const backendTimeout = Duration(seconds: 20);

Future<void> setUpBackend() async {
  if (BackendConfig.url.isEmpty || BackendConfig.publishableKey.isEmpty) {
    throw StateError(
      'SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY are missing. '
      'Run with --dart-define-from-file=env/local.json.',
    );
  }
  await Supabase.initialize(
    url: BackendConfig.url,
    publishableKey: BackendConfig.publishableKey,
  );
}

SupabaseClient get backend => Supabase.instance.client;
