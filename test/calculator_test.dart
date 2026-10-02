import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:fableaderpapp/screens/products/view/product_screen.dart';
import 'package:fableaderpapp/core/widgets/calculator_widget.dart';

void main() {
  testWidgets('Floating button toggles calculator and performs calculation', (WidgetTester tester) async {
    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) {
          return const MaterialApp(
            home: ProductScreen(),
          );
        },
      ),
    );

    // Calculator initially not open
    expect(find.byType(CalculatorWidget), findsNothing);

    // Tap FAB to open calculator
    await tester.tap(find.byIcon(Icons.calculate_rounded));
    await tester.pump();

    // Verify calculator is open
    expect(find.byType(CalculatorWidget), findsOneWidget);
    expect(find.text('Calculator'), findsOneWidget);

    // Tap 7 + 8 =
    await tester.tap(find.text('7'));
    await tester.pump();

    await tester.tap(find.text('+'));
    await tester.pump();

    await tester.tap(find.text('8'));
    await tester.pump();

    await tester.tap(find.text('='));
    await tester.pump();

    // Result should be 15
    expect(find.text('15'), findsOneWidget);

    // Tap close button (Icons.close_rounded)
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();

    // Verify calculator closed
    expect(find.byType(CalculatorWidget), findsNothing);
  });
}
