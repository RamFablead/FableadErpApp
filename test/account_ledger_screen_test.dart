import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:fableaderpapp/screens/accounting/view/account_ledger_screen.dart';
import 'package:fableaderpapp/core/widgets/calculator_widget.dart';

Widget createTestApp() {
  return Sizer(
    builder: (context, orientation, deviceType) {
      return const GetMaterialApp(
        home: AccountLedgerScreen(),
      );
    },
  );
}

void main() {
  testWidgets('AccountLedgerScreen renders all components, handles filters and interactions',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    // 1. Header Bar
    expect(find.text('Account Ledger'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);

    // 2. Filter Labels & Values
    expect(find.text('Type'), findsOneWidget);
    expect(find.text('Vendor'), findsOneWidget);
    expect(find.text('Vendor Name'), findsOneWidget);
    expect(find.text('All Vendors'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);
    expect(find.text('All Months'), findsOneWidget);
    expect(find.text('Year'), findsOneWidget);
    expect(find.text('2026'), findsOneWidget);

    // 3. Export Buttons
    expect(find.text('PDF'), findsOneWidget);
    expect(find.text('Excel'), findsOneWidget);

    // 4. Paid Payments Section
    expect(find.text('Paid Payments'), findsOneWidget);
    expect(find.text('Total Paid: ₹38,450.00'), findsOneWidget);
    expect(find.text('BILL-001'), findsOneWidget);
    expect(find.text('Stationery, Cleaning Items'), findsOneWidget);
    expect(find.text('BILL-002'), findsOneWidget);
    expect(find.text('Office Supplies'), findsOneWidget);
    expect(find.text('BILL-003'), findsOneWidget);
    expect(find.text('IT Equipment'), findsOneWidget);

    // 5. Pending Payments Section
    expect(find.text('Pending Payments'), findsOneWidget);
    expect(find.text('Total Pending: ₹21,300.00'), findsOneWidget);
    expect(find.text('BILL-004'), findsOneWidget);
    expect(find.text('Raw Materials'), findsOneWidget);
    expect(find.text('BILL-005'), findsOneWidget);
    expect(find.text('Packaging Items'), findsOneWidget);
    expect(find.text('BILL-006'), findsOneWidget);
    expect(find.text('Maintenance'), findsOneWidget);

    // 6. Test PDF export tap
    await tester.tap(find.text('PDF'));
    await tester.pump();
    expect(Get.isSnackbarOpen, isTrue);
    await tester.pumpAndSettle();

    // 7. Test Excel export tap
    await tester.tap(find.text('Excel'));
    await tester.pump();
    expect(Get.isSnackbarOpen, isTrue);
    await tester.pumpAndSettle();

    // 8. Test 3-Dots Action Menu on a bill
    final moreButtons = find.byIcon(Icons.more_vert_rounded);
    expect(moreButtons, findsWidgets);
    await tester.tap(moreButtons.first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Ledger Options'), findsOneWidget);
    expect(find.text('View Ledger Details'), findsOneWidget);
    expect(find.text('Download Voucher'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();

    // Ensure any open snackbars are dismissed so FAB tap isn't blocked
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
      await tester.pumpAndSettle();
    }

    // 9. Test Floating Calculator FAB
    expect(find.byIcon(Icons.calculate_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.calculate_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(CalculatorWidget), findsOneWidget);

    // Close calculator
    await tester.tap(find.byIcon(Icons.calculate_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(CalculatorWidget), findsNothing);
  });
}
