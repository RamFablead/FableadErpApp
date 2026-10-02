import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:fableaderpapp/screens/sales&bills/view/all_sales_screen.dart';
import 'package:fableaderpapp/screens/sales&bills/view/sales_screen.dart';
import 'package:fableaderpapp/core/widgets/calculator_widget.dart';

Widget createTestApp() {
  return Sizer(
    builder: (context, orientation, deviceType) {
      return const GetMaterialApp(
        home: AllSalesScreen(),
      );
    },
  );
}

void main() {
  testWidgets('AllSalesScreen renders all elements, handles filters, modals, and actions',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    // 1. App Bar Header
    expect(find.text('All Sales & Bills'), findsOneWidget);
    expect(find.text('All Drafts'), findsOneWidget);
    expect(find.text('Import'), findsOneWidget);
    expect(find.text('New Bill'), findsOneWidget);

    // 2. GST Tabs
    expect(find.text('Without GST Bills'), findsOneWidget);
    expect(find.text('With GST Bills'), findsOneWidget);

    // 3. Search Bar
    expect(find.byType(TextField), findsWidgets);
    expect(find.text('Search order number, customer...'), findsOneWidget);

    // 4. Filter Dropdowns
    expect(find.text('All Months'), findsOneWidget);
    expect(find.text('All Years'), findsOneWidget);
    expect(find.text('All Financial Years'), findsOneWidget);
    expect(find.text('All Staff'), findsOneWidget);
    expect(find.text('Choose Date'), findsOneWidget);
    expect(find.text('All Order Types'), findsOneWidget);
    expect(find.text('All Statuses'), findsOneWidget);
    expect(find.text('Latest First'), findsOneWidget);

    // 5. Summary Statistics & Export
    expect(find.text('Total Pending'), findsOneWidget);
    expect(find.text('Total Paid'), findsOneWidget);
    expect(find.text('Excel'), findsOneWidget);
    expect(find.text('PDF'), findsOneWidget);

    // 6. Bills Cards from Screenshot
    expect(find.text('SI/HO/148'), findsOneWidget);
    expect(find.text('Rahul Sharma'), findsOneWidget);
    expect(find.text('SI/HO/147'), findsOneWidget);
    expect(find.text('Priya Patel'), findsWidgets);

    // 7. Test Tab Switching to With GST Bills
    await tester.tap(find.text('With GST Bills'));
    await tester.pumpAndSettle();
    expect(find.text('SI/GST/201'), findsOneWidget);

    // Switch back to Without GST Bills
    await tester.tap(find.text('Without GST Bills'));
    await tester.pumpAndSettle();
    expect(find.text('SI/HO/148'), findsOneWidget);

    // 8. Test Search Filter
    await tester.enterText(find.byType(TextField).first, 'Rahul');
    await tester.pumpAndSettle();
    expect(find.text('SI/HO/148'), findsOneWidget);
    expect(find.text('SI/HO/147'), findsNothing);

    // Clear search
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pumpAndSettle();
    expect(find.text('SI/HO/147'), findsOneWidget);

    // 9. Test Drafts Modal Dialog
    await tester.tap(find.text('All Drafts'));
    await tester.pumpAndSettle();
    expect(find.textContaining('All Draft Bills'), findsOneWidget);
    expect(find.text('Draft - Rahul Sharma'), findsOneWidget);
    // Dismiss
    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();

    // 10. Test Import Modal Dialog
    await tester.ensureVisible(find.text('Import'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import'));
    await tester.pumpAndSettle();
    expect(find.text('Import Sales & Bills'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // 11. Test Action Menu for a bill
    final moreButtons = find.byIcon(Icons.more_vert_rounded);
    expect(moreButtons, findsWidgets);
    await tester.tap(moreButtons.first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Order Options'), findsOneWidget);
    expect(find.text('View Bill Details'), findsOneWidget);
    expect(find.text('Print Thermal Receipt'), findsOneWidget);
    expect(find.text('Download PDF Invoice'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();

    // 12. Test Floating Calculator FAB
    expect(find.byIcon(Icons.calculate_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.calculate_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(CalculatorWidget), findsOneWidget);

    // Close calculator
    await tester.tap(find.byIcon(Icons.calculate_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(CalculatorWidget), findsNothing);

    // 13. Test "+ New Bill" navigates to SalesScreen
    await tester.ensureVisible(find.text('New Bill'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New Bill'));
    await tester.pumpAndSettle();
    expect(find.byType(SalesScreen), findsOneWidget);
    expect(find.text('Bill 1'), findsOneWidget);
  });
}
