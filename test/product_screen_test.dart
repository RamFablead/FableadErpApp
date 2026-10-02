import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:fableaderpapp/screens/products/view/product_screen.dart';

void main() {
  testWidgets('ProductScreen renders exact mobile layout with cards, dropdowns, and actions',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

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
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);

    // Verify Search Bar and Dropdowns
    expect(find.text('Search product...'), findsOneWidget);
    expect(find.text('Category'), findsWidgets);
    expect(find.text('Brand'), findsWidgets);
    expect(find.text('All Categories'), findsOneWidget);
    expect(find.text('All Brands'), findsOneWidget);

    // Verify Action buttons
    expect(find.text('Excel'), findsOneWidget);
    expect(find.text('PDF'), findsOneWidget);
    expect(find.text('All Barcodes'), findsOneWidget);
    expect(find.text('Price History'), findsOneWidget);

    // Verify Sample Products from screenshot
    expect(find.text('Test-Disha-2'), findsOneWidget);
    expect(find.text('Abc'), findsOneWidget);
    expect(find.text('SUPER WIDE LEG'), findsOneWidget);
    expect(find.text('Mung 30kg EVERYDAY'), findsOneWidget);
    expect(find.text('BAJARA-26K.G DAYMAND'), findsOneWidget);
    expect(find.text('Sofa Set'), findsOneWidget);
    expect(find.text('Abc-Test'), findsOneWidget);

    // Verify Attributes Labels
    expect(find.text('SKU'), findsWidgets);
    expect(find.text('Unit'), findsWidgets);
    expect(find.text('Rent Availability'), findsWidgets);
    expect(find.text('Available'), findsWidgets);
    expect(find.text('Not Available'), findsWidgets);

    // Verify More Options button
    expect(find.byIcon(Icons.more_horiz_rounded), findsWidgets);

    // Test Search filtering
    await tester.enterText(find.byType(TextField).first, 'Sofa');
    await tester.pump();
    expect(find.text('Sofa Set'), findsOneWidget);
    expect(find.text('Test-Disha-2'), findsNothing);

    // Clear search
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pump();
    expect(find.text('Test-Disha-2'), findsOneWidget);

    // Test All Barcodes dialog
    await tester.tap(find.text('All Barcodes'));
    await tester.pumpAndSettle();
    expect(find.text('All Product Barcodes'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    // Test Price History dialog
    await tester.tap(find.text('Price History'));
    await tester.pumpAndSettle();
    expect(find.text('Price History Audit'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    // Verify Calculator FAB exists
    expect(find.byIcon(Icons.calculate_rounded), findsOneWidget);
  });
}
