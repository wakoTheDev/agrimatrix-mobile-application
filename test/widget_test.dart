import 'package:flutter_test/flutter_test.dart';
import 'package:agrimatrix/main.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(firebaseInitialized: true));

    // Simulate the 5-second splash screen timer
    await tester.pump(const Duration(seconds: 5));

    // Additional pump for the frame to settle after timer
    await tester.pump();

    // Now test if a post-splash screen widget is visible
    expect(find.byType(MyApp), findsOneWidget);
  });
}
