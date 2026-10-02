import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:fableaderpapp/screens/financers/view/financers_screen.dart';
import 'package:fableaderpapp/screens/financers/view/import_financers_screen.dart';
import 'package:fableaderpapp/core/widgets/calculator_widget.dart';

void main() {
  testWidgets('FinancersScreen renders all components, handles search, add, and navigation',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) {
          return const GetMaterialApp(
            home: FinancersScreen(),
          );
        },
      ),
    );

    // 1. Verify No SafeArea is used
    expect(find.byType(SafeArea), findsNothing);

    // 2. Verify Header and Action Buttons
    expect(find.text('All Financers'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
    expect(find.text('Import'), findsOneWidget);

    // 3. Verify Search Bar
    expect(find.text('Search...'), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);

    // 4. Verify Sample Financers from Screenshot
    // Ram Financer
    expect(find.text('Ram Financer'), findsOneWidget);
    expect(find.text('09428618514'), findsOneWidget);
    expect(find.text('Surat'), findsNWidgets(2)); // Card 1 & Card 3

    // test-financer
    expect(find.text('test-financer'), findsOneWidget);
    expect(find.text('1235647854'), findsOneWidget);

    // Test
    expect(find.text('Test'), findsOneWidget);
    expect(find.text('6654321234'), findsOneWidget);

    // Bhavik
    expect(find.text('Bhavik'), findsOneWidget);

    // sneha makvana
    expect(find.text('sneha makvana'), findsOneWidget);

    // Verify Active status badges
    expect(find.text('Active'), findsNWidgets(5));

    // Verify Labels
    expect(find.text('Phone'), findsNWidgets(5));
    expect(find.text('City'), findsNWidgets(5));

    // 5. Test Search Filter
    await tester.enterText(find.byType(TextField).first, 'Bhavik');
    await tester.pumpAndSettle();
    expect(find.text('Bhavik'), findsNWidgets(2)); // in search box and on card
    expect(find.text('Ram Financer'), findsNothing);

    // Clear search
    await tester.tap(find.byIcon(Icons.clear_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Ram Financer'), findsOneWidget);

    // 6. Test Add Financer Dialog
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('Add Financer'), findsOneWidget);
    expect(find.text('Financier Name'), findsOneWidget);
    expect(find.text('Save Financer'), findsOneWidget);

    // Enter name into Financier Name field (index 1) and save
    await tester.enterText(find.byType(TextField).at(1), 'Hitesh Financer');
    await tester.tap(find.text('Save Financer'));
    await tester.pumpAndSettle();

    // Verify new financer added to top
    expect(find.text('Hitesh Financer'), findsOneWidget);

    // 7. Test Card Tap opens Financer Details
    await tester.tap(find.text('Hitesh Financer'));
    await tester.pumpAndSettle();
    expect(find.text('Financer Details'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Financer Details'), findsNothing);

    // 8. Test Navigation to ImportFinancersScreen on tap of Import
    await tester.tap(find.text('Import'));
    await tester.pumpAndSettle();
    expect(find.byType(ImportFinancersScreen), findsOneWidget);
    expect(find.text('Import Financers'), findsOneWidget);

    // Go back to FinancersScreen
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(FinancersScreen), findsOneWidget);

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
