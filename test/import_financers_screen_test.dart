import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:fableaderpapp/screens/financers/view/import_financers_screen.dart';
import 'package:fableaderpapp/core/widgets/calculator_widget.dart';

void main() {
  testWidgets('ImportFinancersScreen renders all components and matches design',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) {
          return const GetMaterialApp(
            home: ImportFinancersScreen(),
          );
        },
      ),
    );

    // 1. Verify No SafeArea is used
    expect(find.byType(SafeArea), findsNothing);

    // 2. Verify Header and Subtitle
    expect(find.text('Import Financers'), findsOneWidget);
    expect(find.text('Upload CSV, XLS, or XLSX files with financer details.'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

    // 3. Verify Supported Columns Alert Card
    expect(find.text('Supported columns:'), findsOneWidget);
    expect(find.textContaining('S.No, Financier Name, Address Line1'), findsOneWidget);
    expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);

    // 4. Verify Upload Financer File Card
    expect(find.text('Upload Financer File'), findsOneWidget);
    expect(find.text('*'), findsOneWidget);
    expect(find.text('Drag and drop a file to upload'), findsOneWidget);
    expect(find.text('Supported formats: CSV, XLS, XLSX'), findsOneWidget);
    expect(find.text('CSV'), findsOneWidget);

    // 5. Verify Choose File Button
    expect(find.text('Choose File'), findsOneWidget);
    expect(find.byIcon(Icons.folder_rounded), findsOneWidget);

    // 6. Verify Bottom Action Buttons
    expect(find.text('Import'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.byIcon(Icons.file_upload_outlined), findsOneWidget);

    // 7. Verify Floating Calculator FAB
    expect(find.byIcon(Icons.calculate_rounded), findsOneWidget);

    // 8. Test Import with no file selected first
    await tester.tap(find.text('Import'));
    await tester.pump();
    expect(find.text('File Required'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3)); // let snackbar dismiss

    // Test File Picking flow
    await tester.tap(find.text('Choose File'));
    await tester.pumpAndSettle();
    expect(find.text('Select Financers File'), findsOneWidget);
    expect(find.text('financers_master_data.xlsx'), findsOneWidget);

    // Pick file
    await tester.tap(find.text('financers_master_data.xlsx'));
    await tester.pumpAndSettle();
    expect(find.textContaining('financers_master_data.xlsx'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    // Test Clear file
    await tester.tap(find.byIcon(Icons.cancel_rounded));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle_rounded), findsNothing);

    // Pick file again and test Import
    await tester.tap(find.text('Choose File'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('financers_import_template.csv'));
    await tester.pumpAndSettle();
    expect(find.textContaining('financers_import_template.csv'), findsOneWidget);

    await tester.tap(find.text('Import'));
    await tester.pump();
    expect(find.text('Import Successful'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));

    // 9. Test Calculator FAB toggle
    expect(find.byType(CalculatorWidget), findsNothing);
    await tester.tap(find.byIcon(Icons.calculate_rounded));
    await tester.pump();
    expect(find.byType(CalculatorWidget), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    expect(find.byType(CalculatorWidget), findsNothing);
  });
}
