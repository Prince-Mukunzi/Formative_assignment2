import 'package:alu_bug_bounty/main.dart';
import 'package:alu_bug_bounty/models/auth_user.dart';
import 'package:alu_bug_bounty/providers/auth_provider.dart';
import 'package:alu_bug_bounty/providers/session_provider.dart';
import 'package:alu_bug_bounty/services/auth_service.dart';
import 'package:alu_bug_bounty/services/local_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _SignedOutAuth implements AuthService {
  @override
  Stream<AuthUser?> get changes => Stream.value(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('a signed out user is asked who they are', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStoreProvider.overrideWithValue(LocalStore(prefs)),
          authServiceProvider.overrideWithValue(_SignedOutAuth()),
        ],
        child: const AluBugBountyApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Student'), findsOneWidget);
    expect(find.text('Faculty'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
  });
}
