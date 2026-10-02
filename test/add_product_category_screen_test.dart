import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:fableaderpapp/screens/catalogsetup/view/add_product_category_screen.dart';
import 'package:fableaderpapp/core/widgets/calculator_widget.dart';

void main() {
  testWidgets('AddProductCategoryScreen renders all components and handles input',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) {
          return const MaterialApp(
            home: AddProductCategoryScreen(),
          );
        },
      ),
    );

    // Verify Title and Back button
    expect(find.text('Add Product Category'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

    // Verify Fields
    expect(find.text('Category Name'), findsOneWidget);
    expect(find.text('*'), findsOneWidget);
    expect(find.text('Category Image'), findsOneWidget);

    // Verify Upload Drop Zone
    expect(find.text('Drag and drop a file to upload'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_upload_outlined), findsOneWidget);

    // Verify Action Buttons
    expect(find.text('Submit'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Verify Footer Copyright
    expect(
      find.text('© 2026 Copyright - Fablead Developers Technolab'),
      findsOneWidget,
    );

    // Test Submit with empty Category Name triggers warning SnackBar
    await tester.tap(find.text('Submit'));
    await tester.pump();
    expect(find.text('Please enter a category name.'), findsOneWidget);

    // Enter Category Name
    await tester.enterText(
      find.byType(TextField).first,
      'Electronics & Gadgets',
    );
    await tester.pump();
    expect(find.text('Electronics & Gadgets'), findsOneWidget);

    // Test Image File Picker Modal Bottom Sheet
    await tester.tap(find.byIcon(Icons.cloud_upload_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Select Category Image'), findsOneWidget);

    await tester.tap(find.text('category_banner.png'));
    await tester.pumpAndSettle();
    expect(find.text('category_banner.png'), findsOneWidget);

    // Test Submit with valid data shows success dialog
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(find.text('Category Saved'), findsOneWidget);
    expect(
      find.text(
        'Product category "Electronics & Gadgets" has been created successfully.',
      ),
      findsOneWidget,
    );

    // Close Dialog
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Verify fields reset after submit
    expect(find.text('Drag and drop a file to upload'), findsOneWidget);

    // Test Calculator Floating Action Button
    expect(find.byType(CalculatorWidget), findsNothing);
    await tester.tap(find.byIcon(Icons.calculate_rounded));
    await tester.pump();
    expect(find.byType(CalculatorWidget), findsOneWidget);
    expect(find.text('Calculator'), findsOneWidget);

    // Close Calculator
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    expect(find.byType(CalculatorWidget), findsNothing);
  });
}
