import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:fableaderpapp/screens/productdelivery/view/product_delivery_screen.dart';
import 'package:fableaderpapp/core/widgets/calculator_widget.dart';

void main() {
  testWidgets(
      'ProductDeliveryScreen renders all components, filters, pdf dialog, and interactions',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) {
          return const GetMaterialApp(
            home: ProductDeliveryScreen(),
          );
        },
      ),
    );

    // 1. Header checks
    expect(find.text('Products Delivery'), findsOneWidget);
    expect(
        find.text('View and manage delivery status for all sales orders'),
        findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

    // 2. Filter Section checks
    expect(find.text('Search order number'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('From'), findsOneWidget);
    expect(find.text('To'), findsOneWidget);
    expect(find.text('All Statuses'), findsOneWidget);
    expect(find.text('dd-mm-yyyy'), findsNWidgets(2));

    // 3. Card Items verification from screenshot
    expect(find.text('INV-2026-0149'), findsOneWidget);
    expect(find.text('28-Sep-2026'), findsOneWidget);
    expect(find.text('KETANKUMAR SURESHCHANDRA LAKDAWALA'), findsWidgets);
    expect(find.text('₹24,999.00'), findsOneWidget);
    expect(find.text('Main Branch'), findsWidgets);

    expect(find.text('INV-2026-0144'), findsOneWidget);
    expect(find.text('24-Sep-2026'), findsOneWidget);
    expect(find.text('₹200.00'), findsOneWidget);

    expect(find.text('SI/HO/127'), findsOneWidget);
    expect(find.text('08-Sep-2026'), findsOneWidget);
    expect(find.text('Default Customer'), findsWidgets);
    expect(find.text('₹11,998.00'), findsOneWidget);
    expect(find.text('Partially Delivered'), findsOneWidget);

    expect(find.text('SI/HO/86'), findsOneWidget);
    expect(find.text('Delivered'), findsOneWidget);

    expect(find.text('SI/HO/82'), findsOneWidget);
    expect(find.text('₹3,275.00'), findsOneWidget);

    expect(find.text('SI/HO/81'), findsOneWidget);
    expect(find.text('Bhavik'), findsOneWidget);
    expect(find.text('₹200,000.00'), findsWidgets);

    // Verify PDF buttons
    expect(find.text('PDF'), findsWidgets);

    // 4. Test Search by Order Number
    await tester.enterText(find.byType(TextField).first, 'SI/HO/127');
    await tester.pump();
    expect(find.text('SI/HO/127'), findsNWidgets(2)); // in TextField and card
    expect(find.text('INV-2026-0149'), findsNothing);

    // Clear search
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pump();
    expect(find.text('INV-2026-0149'), findsOneWidget);

    // 5. Test PDF Dialog
    await tester.tap(find.text('PDF').first);
    await tester.pumpAndSettle();
    expect(find.text('Delivery PDF'), findsOneWidget);
    expect(find.text('Order Invoice #INV-2026-0149'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    // 6. Test Card Tap (Order Details bottom sheet)
    await tester.tap(find.text('INV-2026-0149'));
    await tester.pumpAndSettle();
    expect(find.text('Order Details'), findsOneWidget);
    expect(find.text('View PDF'), findsOneWidget);
    expect(find.text('Update Status'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    // 7. Test Calculator FAB toggle
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pump();
    expect(find.byType(CalculatorWidget), findsOneWidget);
    await tester.tap(fab);
    await tester.pump();
    expect(find.byType(CalculatorWidget), findsNothing);
  });
}
