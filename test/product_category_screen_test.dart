import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:fableaderpapp/screens/catalogsetup/view/product_category_screen.dart';
import 'package:fableaderpapp/screens/catalogsetup/view/add_product_category_screen.dart';
import 'package:fableaderpapp/core/widgets/calculator_widget.dart';

void main() {
  testWidgets('ProductCategoryScreen renders table, handles search, edit, delete, and add navigation',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) {
          return const GetMaterialApp(
            home: ProductCategoryScreen(),
          );
        },
      ),
    );

    // Verify Title
    expect(find.text('All Categories'), findsOneWidget);

    // Verify New Category Button
    expect(find.text('New Category'), findsOneWidget);

    // Verify Search Box
    expect(find.text('Search...'), findsOneWidget);

    // Verify Table Headers
    expect(find.text('Category Name'), findsOneWidget);
    expect(find.text('Created At'), findsOneWidget);
    expect(find.text('Action'), findsOneWidget);

    // Verify sample categories in table
    expect(find.text('Male1'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Furniture'), findsOneWidget);

    // Verify Footer
    expect(
      find.text('© 2026 Copyright - Fablead Developers Technolab'),
      findsOneWidget,
    );

    // Test Search filter
    await tester.enterText(find.byType(TextField).first, 'Food');
    await tester.pump();

    expect(find.text('Food'), findsNWidgets(2)); // in search field and table row
    expect(find.text('Male1'), findsNothing);

    // Clear search
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pump();
    expect(find.text('Male1'), findsOneWidget);

    // Test Delete Dialog
    final deleteButtons = find.byIcon(Icons.delete_outline_rounded);
    await tester.tap(deleteButtons.first);
    await tester.pumpAndSettle();

    expect(find.text('Delete Category'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Test Edit Dialog
    final editButtons = find.byIcon(Icons.edit_outlined);
    await tester.tap(editButtons.first);
    await tester.pumpAndSettle();

    expect(find.text('Edit Category'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Test Tap New Category navigates to AddProductCategoryScreen
    await tester.tap(find.text('New Category'));
    await tester.pumpAndSettle();
    expect(find.byType(AddProductCategoryScreen), findsOneWidget);

    // Pop back to ProductCategoryScreen
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(ProductCategoryScreen), findsOneWidget);

    // Test Calculator Floating Button
    expect(find.byType(CalculatorWidget), findsNothing);
    await tester.tap(find.byIcon(Icons.calculate_rounded));
    await tester.pump();
    expect(find.byType(CalculatorWidget), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    expect(find.byType(CalculatorWidget), findsNothing);
  });
}
