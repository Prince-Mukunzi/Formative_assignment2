import 'package:flutter_test/flutter_test.dart';
import 'package:alu_bug_bounty/main.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const AluBugBountyApp());
    expect(find.text('ALU BUG BOUNTY'), findsOneWidget);
  });
}
