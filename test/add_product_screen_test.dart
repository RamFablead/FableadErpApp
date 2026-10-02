import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:fableaderpapp/screens/products/view/add_product_screen.dart';

void main() {
  testWidgets('AddProductScreen renders form fields and handles interactions', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) {
          return const MaterialApp(
            home: AddProductScreen(),
          );
        },
      ),
    );

    // Verify Product Type radio options
    expect(find.text('Product Type'), findsOneWidget);
    expect(find.text('Normal Product'), findsOneWidget);
    expect(find.text('Variant Product'), findsOneWidget);
    expect(find.text('Grocery Product'), findsOneWidget);

    // Verify Normal Fields
    expect(find.text('Product Name'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Add Category'), findsOneWidget);
    expect(find.text('Brand'), findsOneWidget);
    expect(find.text('Add Brand'), findsOneWidget);
    expect(find.text('SKU'), findsOneWidget);
    expect(find.text('HSN Code'), findsOneWidget);
    expect(find.text('GST Option'), findsOneWidget);
    expect(find.text('Unit'), findsOneWidget);
    expect(find.text('Add Unit'), findsOneWidget);
    expect(find.text('Quantity'), findsOneWidget);
    expect(find.text('Price'), findsOneWidget);
    expect(find.text('MRP'), findsOneWidget);
    expect(find.text('Available for Rent'), findsOneWidget);

    // Switch to Variant Product
    await tester.tap(find.text('Variant Product'));
    await tester.pumpAndSettle();

    // Verify Product Variants table appears
    expect(find.text('Product Variants'), findsOneWidget);
    expect(find.text('Add More'), findsOneWidget);
    expect(find.text('Size'), findsOneWidget);
    expect(find.text('Color'), findsOneWidget);
    expect(find.text('Qty'), findsOneWidget);

    // Tap Add More
    await tester.tap(find.text('Add More'));
    await tester.pumpAndSettle();

    // There should now be 2 delete buttons
    expect(find.byIcon(Icons.delete_outline_rounded), findsNWidgets(2));

    // Tap delete on first row
    await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
    await tester.pumpAndSettle();

    // Should now have 1 delete button left
    expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);

    // Dynamic Rent Fields appear on checking "Available for Rent"
    expect(find.text('Rent Type'), findsNothing);
    await tester.tap(find.text('Available for Rent'));
    await tester.pumpAndSettle();
    expect(find.text('Rent Type'), findsOneWidget);
    expect(find.text('Rent Price'), findsOneWidget);

    // Dialog test: Add Unit
    await tester.tap(find.text('Add Unit'));
    await tester.pumpAndSettle();
    expect(find.text('Add New Unit'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);

    // Close Dialog
    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();
  });
}
