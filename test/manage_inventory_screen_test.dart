import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:fableaderpapp/screens/manageinventory/view/manage_inventory_screen.dart';
import 'package:fableaderpapp/screens/manageinventory/view/view_inventory_screen.dart';

void main() {
  testWidgets('ManageInventoryScreen renders exact mobile layout with cards and actions',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) {
          return const GetMaterialApp(
            home: ManageInventoryScreen(),
          );
        },
      ),
    );

    // Verify Title and New Product button
    expect(find.text('All Inventory'), findsOneWidget);
    expect(find.text('New Product'), findsOneWidget);
    // Back button removed from header
    expect(find.byIcon(Icons.arrow_back), findsNothing);

    // Verify Search Box and Date pickers
    expect(find.text('Search product...'), findsOneWidget);
    expect(find.text('Start Date'), findsOneWidget);
    expect(find.text('End Date'), findsOneWidget);
    expect(find.text('dd-mm-yyyy'), findsNWidgets(2));

    // Verify Stats Labels inside Cards
    expect(find.text('Initial Stock'), findsWidgets);
    expect(find.text('Current Stock'), findsWidgets);
    expect(find.text('Remarks'), findsWidgets);

    // Verify Sample Products from screenshot
    expect(find.text('Test-Disha-2'), findsOneWidget);
    expect(find.text('₹ 500.00'), findsOneWidget);

    expect(find.text('Abc'), findsOneWidget);
    expect(find.text('₹ 600.00'), findsOneWidget);

    expect(find.text('SUPER WIDE LEG'), findsOneWidget);
    expect(find.text('₹ 550.00'), findsNWidgets(2));

    expect(find.text('Mung 30kg EVERYDAY'), findsOneWidget);
    expect(find.text('₹ 90.00'), findsOneWidget);

    expect(find.text('BAJARA-26K.G DAYMAND'), findsOneWidget);
    expect(find.text('₹ 30.00'), findsOneWidget);

    expect(find.text('Sofa Set'), findsOneWidget);
    expect(find.text('₹ 34,999.00'), findsOneWidget);

    // Verify 3 Action Buttons on each Card
    expect(find.text('View History'), findsWidgets);
    expect(find.text('Add / Edit Stock'), findsWidgets);
    expect(find.text('Transfer Stock'), findsWidgets);

    // Verify three-dot menu icons
    expect(find.byIcon(Icons.more_vert_rounded), findsWidgets);

    // Test Search filter
    await tester.enterText(find.byType(TextField).first, 'Sofa');
    await tester.pump();
    expect(find.text('Sofa Set'), findsOneWidget);
    expect(find.text('Test-Disha-2'), findsNothing);

    // Clear search
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pump();
    expect(find.text('Test-Disha-2'), findsOneWidget);

    // Test View History Navigation
    await tester.tap(find.text('View History').first);
    await tester.pumpAndSettle();
    expect(find.byType(ViewInventoryScreen), findsOneWidget);
    expect(find.text('View Inventory'), findsOneWidget);
    await tester.tap(find.byTooltip('Back').first);
    await tester.pumpAndSettle();

    // Test Add / Edit Stock Dialog
    await tester.tap(find.text('Add / Edit Stock').first);
    await tester.pumpAndSettle();
    expect(find.text('Enter quantity to add'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Test Transfer Stock Dialog matching new reference design
    await tester.tap(find.text('Transfer Stock').first);
    await tester.pumpAndSettle();
    expect(find.text('Product'), findsOneWidget);
    expect(find.text('Available Stock'), findsOneWidget);
    expect(find.text('From Branch'), findsOneWidget);
    expect(find.text('Main Branch'), findsOneWidget);
    expect(find.text('To Branch'), findsOneWidget);
    expect(find.text('Select Target Branch'), findsOneWidget);
    expect(find.text('Transfer Quantity'), findsOneWidget);
    expect(find.text('Enter transfer quantity'), findsOneWidget);
    expect(find.text('Remarks'), findsWidgets);
    expect(find.text('Enter remarks (optional)'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();

    // Verify Calculator FAB exists
    expect(find.byIcon(Icons.calculate_rounded), findsOneWidget);
  });
}
