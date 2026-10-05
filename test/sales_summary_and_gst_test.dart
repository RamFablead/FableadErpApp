import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:fableaderpapp/screens/sales&bills/view/sales_screen.dart';

void main() {
  testWidgets(
      'Verify Customer GST field visibility, conditional summary rows, and calculations',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 1000);
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

    // 1. Initial State: Without GST is default
    // Customer GST no field must NOT be visible
    expect(find.text('Customer GST no'), findsNothing);

    // 2. Switch to With GST: Customer GST no field MUST appear
    await tester.ensureVisible(find.text('With GST'));
    await tester.tap(find.text('With GST'));
    await tester.pumpAndSettle();

    expect(find.text('Customer GST no'), findsOneWidget);

    // Switch back to Without GST: Customer GST no must disappear
    await tester.ensureVisible(find.text('Without GST'));
    await tester.tap(find.text('Without GST'));
    await tester.pumpAndSettle();

    expect(find.text('Customer GST no'), findsNothing);

    // 3. Add Basmati Rice to cart (price: 180.00)
    await tester.ensureVisible(find.text('Basmati Rice').first);
    await tester.tap(find.text('Basmati Rice').first);
    await tester.pumpAndSettle();

    // Scroll to Delivery & Charges card
    await tester.ensureVisible(find.text('Total (Product)').first);

    // 4. Verify Summary Breakdown when no adjustments are made:
    // TDS (0.00%) must NOT be visible because it was not added
    expect(find.text('Total (Product)'), findsOneWidget);
    expect(find.text('TDS (0.00%)'), findsNothing);
    expect(find.text('Total GST Amount'), findsNothing);
    // Before entering delivery cost, '+ ₹' is not in summary
    expect(find.textContaining('+ ₹'), findsNothing);
    // 'Discount Amount' only exists once as the field label, not in summary breakdown
    expect(find.text('Discount Amount'), findsOneWidget);
    expect(find.text('SubTotal'), findsNothing);

    // 5. Enter Delivery Cost = 50
    final deliveryCostField = find.widgetWithText(TextField, 'Delivery Cost.');
    await tester.ensureVisible(deliveryCostField);
    await tester.enterText(deliveryCostField, '50');
    await tester.pumpAndSettle();

    // Now Delivery Cost (+ ₹50.00) and SubTotal must appear
    expect(find.text('+ ₹50.00'), findsOneWidget);
    expect(find.text('SubTotal'), findsOneWidget);

    // 6. Switch to With GST
    await tester.ensureVisible(find.text('With GST'));
    await tester.tap(find.text('With GST'));
    await tester.pumpAndSettle();

    // Basmati Rice 180.00 -> GST = 32.40
    expect(find.text('Total GST Amount'), findsOneWidget);
    expect(find.text('₹32.40'), findsWidgets);

    // 7. Enter Discount % = 10%
    // 10% of 180 = 18.00
    final discountPercentField = find.ancestor(
      of: find.text('Discount (%)'),
      matching: find.byType(Column),
    );
    final discTf = find.descendant(
      of: discountPercentField,
      matching: find.byType(TextField),
    ).first;
    await tester.ensureVisible(discTf);
    await tester.enterText(discTf, '10');
    await tester.pumpAndSettle();

    // Now Discount Amount appears twice: input label + breakdown row!
    expect(find.text('Discount Amount'), findsNWidgets(2));
    expect(find.text('₹18.00'), findsWidgets);

    // 8. Enter TDS % = 5%
    // 5% of 180 = 9.00
    final tdsPercentField = find.ancestor(
      of: find.text('TDS Percentage (%)'),
      matching: find.byType(Column),
    );
    final tdsTf = find.descendant(
      of: tdsPercentField,
      matching: find.byType(TextField),
    ).first;
    await tester.ensureVisible(tdsTf);
    await tester.enterText(tdsTf, '5');
    await tester.pumpAndSettle();

    // Now TDS row MUST appear with deduction
    expect(find.text('TDS (5.00%)'), findsOneWidget);
    expect(find.text('- ₹9.00'), findsOneWidget);
  });
}
