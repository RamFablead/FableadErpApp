import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:fableaderpapp/screens/manageinventory/view/view_inventory_screen.dart';
import 'package:fableaderpapp/core/widgets/calculator_widget.dart';

void main() {
  testWidgets('ViewInventoryScreen renders all components and handles interactions',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) {
          return const GetMaterialApp(
            home: ViewInventoryScreen(productName: 'test-disha-2'),
          );
        },
      ),
    );

    // 1. Verify No SafeArea is used
    expect(find.byType(SafeArea), findsNothing);

    // 2. Verify Header
    expect(find.text('View Inventory'), findsOneWidget);
    expect(find.text('test-disha-2'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

    // 3. Verify Search Bar
    expect(find.text('Search...'), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);

    // 4. Verify Column Headers / Labels
    expect(find.text('Type'), findsNWidgets(5));
    expect(find.text('Current Stock'), findsNWidgets(5));
    expect(find.text('Quantity'), findsNWidgets(5));
    expect(find.text('Date'), findsNWidgets(5));
    expect(find.text('Create By'), findsNWidgets(5));

    // 5. Verify the 5 transactions from the reference image
    // Card 1: Purchase
    expect(find.text('Purchase'), findsOneWidget);
    expect(find.text('12 Sep 2026, 10:30 AM'), findsOneWidget);

    // Card 2: Transfer In
    expect(find.text('Transfer In'), findsOneWidget);
    expect(find.text('5.00'), findsNWidgets(2)); // Current Stock & Quantity
    expect(find.text('10 Sep 2026, 02:15 PM'), findsOneWidget);
    expect(find.text('Vatsal'), findsOneWidget);

    // Card 3: Transfer Out
    expect(find.text('Transfer Out'), findsOneWidget);
    expect(find.text('3.00'), findsNWidgets(2));
    expect(find.text('05 Sep 2026, 11:20 AM'), findsOneWidget);
    expect(find.text('Akshay'), findsOneWidget);

    // Card 4: Adjustment In
    expect(find.text('Adjustment In'), findsOneWidget);
    expect(find.text('8.00'), findsNWidgets(2));
    expect(find.text('01 Sep 2026, 09:45 AM'), findsOneWidget);
    expect(find.text('Salman'), findsOneWidget);

    // Card 5: Adjustment Out
    expect(find.text('Adjustment Out'), findsOneWidget);
    expect(find.text('2.00'), findsNWidgets(2));
    expect(find.text('28 Aug 2026, 04:30 PM'), findsOneWidget);

    // 6. Test Search Filter
    await tester.enterText(find.byType(TextField).first, 'Salman');
    await tester.pumpAndSettle();
    expect(find.text('Adjustment In'), findsOneWidget);
    expect(find.text('Purchase'), findsNothing);

    // Clear search
    await tester.tap(find.byIcon(Icons.clear_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Purchase'), findsOneWidget);

    // 7. Test Card Tap opens Transaction Details Modal
    await tester.tap(find.text('Purchase'));
    await tester.pumpAndSettle();
    expect(find.text('Transaction Details'), findsOneWidget);
    expect(find.text('Reference No'), findsOneWidget);
    expect(find.text('PO-2026-0091'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);

    // Close Modal
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Transaction Details'), findsNothing);

    // 8. Test Calculator Floating Button
    expect(find.byType(CalculatorWidget), findsNothing);
    await tester.tap(find.byIcon(Icons.calculate_rounded));
    await tester.pump();
    expect(find.byType(CalculatorWidget), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    expect(find.byType(CalculatorWidget), findsNothing);
  });
}
