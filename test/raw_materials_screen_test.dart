import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:fableaderpapp/screens/products/view/raw_materials_screen.dart';
import 'package:fableaderpapp/core/widgets/calculator_widget.dart';

void main() {
  testWidgets('RawMaterialsScreen renders table, search, and displays action buttons',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) {
          return const GetMaterialApp(
            home: RawMaterialsScreen(),
          );
        },
      ),
    );

    // Verify Title and Add Raw Material button
    expect(find.text('All Raw Materials'), findsOneWidget);
    expect(find.text('Add Raw Material'), findsOneWidget);

    // Verify Table Headers
    expect(find.text('Material Name'), findsOneWidget);
    expect(find.text('SKU'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Stock'), findsOneWidget);
    expect(find.text('Unit Cost'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Action'), findsOneWidget);

    // Verify Sample Material item
    expect(find.text('Stainless Steel Sheet 304'), findsOneWidget);

    // Test Search filter
    await tester.enterText(
      find.byType(TextField).first,
      'Cotton',
    );
    await tester.pump();
    expect(find.text('Combed Cotton Yarn 30s'), findsOneWidget);
    expect(find.text('Stainless Steel Sheet 304'), findsNothing);

    // Clear Search
    await tester.enterText(
      find.byType(TextField).first,
      '',
    );
    await tester.pump();
    expect(find.text('Stainless Steel Sheet 304'), findsOneWidget);

    // Verify Delete Buttons exist in the table
    expect(find.byIcon(Icons.delete_outline_rounded), findsWidgets);

    // Verify Calculator FAB exists
    expect(find.byIcon(Icons.calculate_rounded), findsOneWidget);
  });
}
