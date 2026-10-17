import 'package:flutter_test/flutter_test.dart';
import 'package:myteam/main.dart';

void main() {
  testWidgets('MyTeamApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyTeamApp(isLoggedIn: false));
    await tester.pumpAndSettle(const Duration(seconds: 4));
    expect(find.byType(MyTeamApp), findsOneWidget);
  });
}
