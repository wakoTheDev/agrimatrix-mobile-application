import 'package:flutter_test/flutter_test.dart';
import 'package:agrimatrix/main.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    // Load the app
    await tester.pumpWidget(const MyApp());

    
    await tester.pump(const Duration(seconds: 5));

    // Let any pending animations or transitions settle
    await tester.pumpAndSettle();

    // Check that the app is still running by asserting presence of a known widget
    expect(find.byType(MyApp), findsOneWidget);
  });
}
