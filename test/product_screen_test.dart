import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:fableaderpapp/screens/products/view/product_screen.dart';

void main() {
  testWidgets('ProductScreen renders without errors and shows header and table', (WidgetTester tester) async {
    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) {
          return const MaterialApp(
            home: ProductScreen(),
          );
        },
      ),
    );

    // Verify Header
    expect(find.text('All Products'), findsOneWidget);
    expect(find.text('Import Products'), findsOneWidget);
    expect(find.text('New Product'), findsOneWidget);

    // Verify Filter controls
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Category'), findsNWidgets(2));
    expect(find.text('Brand'), findsNWidgets(2));

    // Verify Action buttons
    expect(find.text('Excel'), findsOneWidget);
    expect(find.text('PDF'), findsOneWidget);
    expect(find.text('All Barcodes'), findsOneWidget);
    expect(find.text('Price History'), findsOneWidget);

    // Verify Data Table columns
    expect(find.text('Product Name'), findsOneWidget);
    expect(find.text('Rent Availability'), findsOneWidget);
    expect(find.text('Available'), findsWidgets);
  });
}
