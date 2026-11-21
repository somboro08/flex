import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flex_app/main.dart';
import 'package:flex_app/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const FlexApp(),
      ),
    );

    expect(find.byType(FlexApp), findsOneWidget);
    expect(find.text('Chez vous, partout.'), findsOneWidget);

    // Let the splash delay complete so its Future.delayed timer is not left
    // pending when the widget test finishes.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    await tester.pumpAndSettle();
  });
}
