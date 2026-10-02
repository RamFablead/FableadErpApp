import 'package:flutter_test/flutter_test.dart';
import 'package:fableaderpapp/main.dart';

void main() {
  testWidgets('App smoke test loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle(const Duration(seconds: 4));
    expect(find.byType(MyApp), findsOneWidget);
  });
}
