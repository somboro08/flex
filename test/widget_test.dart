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
  });
}
