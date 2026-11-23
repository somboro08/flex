import 'package:flutter_test/flutter_test.dart';
import 'package:flex_app/main.dart';
import 'package:flex_app/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({'onboarding_done': false});
  });

  testWidgets('App smoke test reaches onboarding on first launch', (WidgetTester tester) async {
    // Match a common mobile viewport and verify the first-run navigation path.
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const FlexApp(),
      ),
    );

    expect(find.byType(FlexApp), findsOneWidget);
    expect(find.text('Chez vous, partout.'), findsOneWidget);

    // Complete the splash delay and route to onboarding.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Bienvenue sur Flex'), findsOneWidget);
  });
}
