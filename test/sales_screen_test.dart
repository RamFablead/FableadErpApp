import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:fableaderpapp/screens/sales&bills/view/sales_screen.dart';
import 'package:fableaderpapp/core/widgets/calculator_widget.dart';

void main() {
  testWidgets(
      'SalesScreen renders all 4 mode states, category grid, fields, and handles interactions',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 900);
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

    // 1. Initial State: Quotation Mode (Screenshot 1)
    expect(find.text('Bill 1'), findsOneWidget);
    expect(find.text('Quotation'), findsOneWidget);
    expect(find.text('Quotation No: Q-13'), findsOneWidget);
    expect(find.text('Generate Quote'), findsOneWidget);

    // 2. Test Switching to Advance Receipt Mode (Screenshot 2)
    await tester.tap(find.text('Advance Receipt'));
    await tester.pump();
    expect(find.text('Advance Receipt No: ADV-3'), findsOneWidget);
    expect(find.text('Generate Advance Receipt'), findsOneWidget);
    expect(
        find.text(
            'Product price will be locked at current price when advance is paid.'),
        findsOneWidget);

    // 3. Test Switching to Rental Mode (Screenshot 3)
    await tester.tap(find.text('Rental'));
    await tester.pump();
    expect(find.text('Rental No: RO-000018'), findsOneWidget);
    expect(find.text('Generate Rental'), findsOneWidget);
    expect(find.text('Deposit / Advance'), findsOneWidget);
    expect(find.text('Enter Deposit Amount'), findsOneWidget);

    // 4. Test Category Filter & Empty State (Screenshot 3: Male1 selected)
    await tester.tap(find.text('Male1'));
    await tester.pump();
    expect(find.text('No products found in this category'), findsOneWidget);
    expect(find.text('View All Products'), findsOneWidget);

    // Return to All Products
    await tester.tap(find.text('View All Products'));
    await tester.pump();
    expect(find.text('Basmati Rice'), findsOneWidget);
    expect(find.text('Sandwitch'), findsOneWidget);

    // 5. Test Category Grid View Toggle (Screenshot 4)
    final gridToggle = find.byIcon(Icons.qr_code_scanner_rounded);
    expect(gridToggle, findsOneWidget);
    await tester.tap(gridToggle);
    await tester.pump();

    // Verify Category Grid Cards
    expect(find.text('Browse Categories'), findsOneWidget);
    expect(find.text('Drinks'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Furniture'), findsOneWidget);
    expect(find.text('Grocery'), findsOneWidget);
    expect(find.text('Electronics'), findsOneWidget);
    expect(find.text('Clothing'), findsOneWidget);

    // Tap 'Show Products View'
    await tester.tap(find.text('Show Products View'));
    await tester.pump();
    expect(find.text('Basmati Rice'), findsOneWidget);

    // 6. Test Product Cart Addition & Calculations
    expect(find.text('Total items : 0'), findsOneWidget);
    await tester.tap(find.text('Basmati Rice'));
    await tester.pump();
    expect(find.text('Total items : 1'), findsOneWidget);
    expect(find.text('Qty: 1'), findsOneWidget);

    // 7. Test Create New Bill Modal Dialog
    final plusBtn = find.byIcon(Icons.add_rounded).first;
    await tester.tap(plusBtn);
    await tester.pumpAndSettle();

    expect(find.text('Create New Bill'), findsOneWidget);
    expect(find.text('Sales'), findsOneWidget);
    await tester.tap(find.text('Sales'));
    await tester.pumpAndSettle();
    expect(find.text('Create New Bill'), findsNothing);
    expect(find.text('Order No: SI/HO/148'), findsOneWidget);
    expect(find.text('Generate Bill'), findsOneWidget);

    // 8. Test Calculator FAB
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
