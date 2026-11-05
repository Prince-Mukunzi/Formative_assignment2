import 'package:alu_bug_bounty/main.dart';
import 'package:alu_bug_bounty/providers/session_provider.dart';
import 'package:alu_bug_bounty/services/local_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('first launch asks who the user is', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [localStoreProvider.overrideWithValue(LocalStore(prefs))],
        child: const AluBugBountyApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Student'), findsOneWidget);
    expect(find.text('Faculty'), findsOneWidget);
  });
}
