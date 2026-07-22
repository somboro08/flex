import 'package:flutter_test/flutter_test.dart';
import 'package:flex_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Note: Splash screen might prevent finding home screen elements immediately.
    await tester.pumpWidget(const FlexApp());
    
    // Verify that the app title is present (or at least the app builds)
    expect(find.byType(FlexApp), findsOneWidget);
  });
}
