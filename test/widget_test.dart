import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myteam_project/main.dart';

// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

void main() {
  testWidgets('user can open dashboard from login screen', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Selamat Datang di MyTeam'), findsOneWidget);
    final loginButton = find.text('Masuk ke MyTeam  →');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('Rekomendasi Tim'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Inovasi PKM-KC Unand'), 240, scrollable: find.byType(Scrollable).first);
    expect(find.text('Inovasi PKM-KC Unand'), findsOneWidget);
  });

  testWidgets('search filters teams by PRD search fields', (tester) async {
    await tester.pumpWidget(const MyApp());
    final loginButton = find.text('Masuk ke MyTeam  →');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'hackathon');
    await tester.pump();

    await tester.scrollUntilVisible(find.text('Fintech Hackathon Syariah'), 240, scrollable: find.byType(Scrollable).first);
    expect(find.text('Fintech Hackathon Syariah'), findsOneWidget);
    expect(find.text('Inovasi PKM-KC Unand'), findsNothing);
  });
}
