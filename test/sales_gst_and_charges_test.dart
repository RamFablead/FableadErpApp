import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:fableaderpapp/screens/sales&bills/view/sales_screen.dart';

void main() {
  testWidgets(
      'SalesScreen tests: Labour removed, Other Charges & Remarks bottom sheets, and With GST calculations',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) {
          return const GetMaterialApp(
            home: SalesScreen(),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Labour option is REMOVED
    expect(find.text('Labour +'), findsNothing);

    // 2. Verify Other Charges + and Remarks + are present
    expect(find.text('Other Charges +'), findsOneWidget);
    expect(find.text('Remarks +'), findsOneWidget);

    // 3. Test Other Charges Bottom Sheet (Screenshot 2)
    await tester.ensureVisible(find.text('Other Charges +'));
    await tester.tap(find.text('Other Charges +'));
    await tester.pumpAndSettle();

    expect(find.text('Other Charges'), findsWidgets);
    expect(find.text('Charge Name'), findsOneWidget);
    expect(find.text('Amount'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline_rounded), findsWidgets);
    expect(find.text('Apply & Close'), findsOneWidget);

    // Enter a charge
    await tester.enterText(
        find.widgetWithText(TextField, 'Charge Name').first, 'Packaging');
    await tester.enterText(
        find.widgetWithText(TextField, 'Amount').first, '50');
    await tester.pumpAndSettle();

    // Apply & Close
    await tester.tap(find.text('Apply & Close'));
    await tester.pumpAndSettle();

    // Verify pill updated to show count
    expect(find.text('Other Charges (1) +'), findsOneWidget);

    // 4. Test Remarks (Optional) Bottom Sheet (Screenshot 3)
    await tester.ensureVisible(find.text('Remarks +'));
    await tester.tap(find.text('Remarks +'));
    await tester.pumpAndSettle();

    expect(find.text('Remarks (Optional)'), findsOneWidget);
    expect(find.text('Enter remarks...'), findsOneWidget);
    expect(find.text('Save Remarks'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextField, 'Enter remarks...'), 'Urgent delivery');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Remarks'));
    await tester.pumpAndSettle();

    // Verify pill shows remarks added
    expect(find.text('Remarks (Added)'), findsOneWidget);

    // 5. Add a product to cart: Basmati Rice (price: 180.00, qty: 1)
    await tester.ensureVisible(find.text('Basmati Rice').first);
    await tester.tap(find.text('Basmati Rice').first);
    await tester.pumpAndSettle();

    // Verify Without GST mode initial state
    expect(find.text('Sub Total: '), findsOneWidget);
    expect(find.text('Final Total: '), findsOneWidget);
    expect(find.text('Product GST Total:'), findsNothing);

    // 6. Switch to "With GST" mode
    await tester.ensureVisible(find.text('With GST'));
    await tester.tap(find.text('With GST'));
    await tester.pumpAndSettle();

    // Verify With GST calculations and widgets matching Screenshot 5
    // Price = 180.00, CGST 9% = 16.20, SGST 9% = 16.20, GST Total = 32.40, With GST = 212.40
    expect(find.text('Product GST Total:'), findsOneWidget);
    expect(find.text('CGST: 9.00% (₹16.20)'), findsOneWidget);
    expect(find.text('SGST: 9.00% (₹16.20)'), findsOneWidget);
    expect(find.text('₹32.40'), findsWidgets);
    expect(find.text('Product GST WITH Total: ₹212.40'), findsOneWidget);
    expect(find.text('GST Inc: '), findsOneWidget);

    // Switch back to Without GST
    await tester.ensureVisible(find.text('Without GST'));
    await tester.tap(find.text('Without GST'));
    await tester.pumpAndSettle();
    expect(find.text('Product GST Total:'), findsNothing);
  });
}
