import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:fableaderpapp/screens/products/view/import_product_screen.dart';
import 'package:fableaderpapp/core/widgets/calculator_widget.dart';

void main() {
  testWidgets('ImportProductScreen renders all components and matches design',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) {
          return const MaterialApp(
            home: ImportProductScreen(),
          );
        },
      ),
    );

    // Verify Title
    expect(find.text('Import Products'), findsOneWidget);

    // Verify Header Row in Card
    expect(
      find.text('Upload CSV or Excel File (.csv / .xlsx)'),
      findsOneWidget,
    );
    expect(find.text('Download Sample File'), findsOneWidget);

    // Verify Upload Drop Zone
    expect(
      find.text('Drag and drop a CSV or Excel (.xlsx) file to upload'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.cloud_upload_outlined), findsOneWidget);

    // Verify Action Buttons
    expect(find.text('Submit'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Verify Mapping Reference Table entries
    expect(find.text('Item/Model (Name)'), findsOneWidget);
    expect(
      find.text('Excel: "Item/Model" column | CSV: "name"'),
      findsOneWidget,
    );

    expect(find.text('Category'), findsOneWidget);
    expect(
      find.text('Excel: "Product" column | CSV: "category"'),
      findsOneWidget,
    );

    expect(find.text('Brand'), findsOneWidget);
    expect(
      find.text('Excel: "Brand" column — auto-created in brand table first'),
      findsOneWidget,
    );

    expect(find.text('SKU / Item Code'), findsOneWidget);
    expect(
      find.text('Excel: "Item Code" column | CSV: "sku"'),
      findsOneWidget,
    );

    expect(find.text('Selling Price'), findsOneWidget);
    expect(
      find.text('Excel: "Selling Price" column | CSV: "price"'),
      findsOneWidget,
    );

    expect(find.text('HSN Code'), findsOneWidget);
    expect(
      find.text('Excel: "HSN/SAC" column | CSV: "hsn_code" — optional'),
      findsOneWidget,
    );

    expect(find.text('Unit'), findsOneWidget);
    expect(
      find.text('Excel: "UQC" column | CSV: "unit" — e.g. pcs, kg'),
      findsOneWidget,
    );

    expect(find.text('Status'), findsOneWidget);
    expect(
      find.text('Excel: "Status" column — Active/Inactive'),
      findsOneWidget,
    );

    // Verify Footer Copyright
    expect(
      find.text('© 2026 Copyright - Fablead Developers Technolab'),
      findsOneWidget,
    );

    // Test Download Sample File
    await tester.tap(find.text('Download Sample File'));
    await tester.pump();
    expect(
      find.text(
        'Sample template "products_sample.xlsx" downloaded successfully.',
      ),
      findsOneWidget,
    );

    // Test Submit without selecting file shows warning SnackBar
    await tester.tap(find.text('Submit'));
    await tester.pump();
    expect(
      find.text('Please select a CSV or Excel file before submitting.'),
      findsOneWidget,
    );

    // Test File Selection via Modal Bottom Sheet
    await tester.tap(find.byIcon(Icons.cloud_upload_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Select a file to upload'), findsOneWidget);

    await tester.tap(find.text('sample_products_data.xlsx'));
    await tester.pumpAndSettle();

    // Verify file name now appears in drop zone
    expect(find.text('sample_products_data.xlsx'), findsOneWidget);

    // Test Submit with selected file
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(find.text('Import Successful'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Test Floating Calculator Button
    expect(find.byType(CalculatorWidget), findsNothing);
    await tester.tap(find.byIcon(Icons.calculate_rounded));
    await tester.pump();
    expect(find.byType(CalculatorWidget), findsOneWidget);
    expect(find.text('Calculator'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    expect(find.byType(CalculatorWidget), findsNothing);
  });
}
