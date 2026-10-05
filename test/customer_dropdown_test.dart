import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:fableaderpapp/screens/sales&bills/view/sales_screen.dart';

void main() {
  testWidgets('Customer dropdown opens search sheet, searches, and selects or adds new customer',
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

    // Initial state: "Select Customer"
    expect(find.text('Select Customer'), findsWidgets);

    // Tap on Customer selector to open bottom sheet
    await tester.tap(find.text('Select Customer').first);
    await tester.pumpAndSettle();

    // Verify Customer Search BottomSheet opened
    expect(find.text('Select Customer'), findsWidgets);
    expect(find.text('Search customer name, phone, code...'), findsOneWidget);
    expect(find.text('Default Customer'), findsOneWidget);
    expect(find.text('damodar'), findsOneWidget);

    // 1. Test Selecting an existing customer: 'damodar'
    await tester.tap(find.text('damodar'));
    await tester.pumpAndSettle();

    // Verify 'damodar' is selected and phone '0000078454' is autofilled
    expect(find.text('damodar'), findsOneWidget);
    expect(find.text('0000078454'), findsOneWidget);

    // 2. Open sheet again to test search & dynamic add
    await tester.tap(find.text('damodar'));
    await tester.pumpAndSettle();

    // Search for a non-existing customer
    await tester.enterText(
        find.widgetWithText(TextField, 'Search customer name, phone, code...'),
        'Ketan Soni');
    await tester.pumpAndSettle();

    // Verify Add Ketan Soni option is shown
    expect(find.text('Add "Ketan Soni"'), findsWidgets);

    // Tap Add "Ketan Soni"
    await tester.tap(find.text('Add "Ketan Soni"').first);
    await tester.pumpAndSettle();

    // Verify Ketan Soni is now selected in the sales screen
    expect(find.text('Ketan Soni'), findsOneWidget);

    // Let snackbar timer and dismiss animation settle
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
