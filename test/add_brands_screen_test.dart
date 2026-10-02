import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:fableaderpapp/screens/catalogsetup/view/add_brands_screen.dart';
import 'package:fableaderpapp/core/widgets/calculator_widget.dart';

void main() {
  testWidgets('AddBrandsScreen renders all components, validates, and handles interactions',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) {
          return const MaterialApp(
            home: AddBrandsScreen(),
          );
        },
      ),
    );

    // Verify Title and Back button
    expect(find.text('Add Brand'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

    // Verify Field Labels
    expect(find.text('Brand Name'), findsOneWidget);
    expect(find.text('*'), findsOneWidget);
    expect(find.text('Brand Email (Optional)'), findsOneWidget);
    expect(find.text('Brand Phone (Optional)'), findsOneWidget);
    expect(find.text('Brand Image'), findsOneWidget);

    // Verify Drop Zone
    expect(find.text('Drag and drop a file to upload'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_upload_outlined), findsOneWidget);

    // Verify Action Buttons
    expect(find.text('Submit'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Verify Footer
    expect(
      find.text('© 2026 Copyright - Fablead Developers Technolab'),
      findsOneWidget,
    );

    // Test Submit with empty Brand Name shows warning
    await tester.tap(find.text('Submit'));
    await tester.pump();
    expect(find.text('Please enter a brand name.'), findsOneWidget);

    // Enter Brand Details
    final textFields = find.byType(TextField);
    // Brand Name
    await tester.enterText(textFields.at(0), 'Nike');
    await tester.pump();
    expect(find.text('Nike'), findsOneWidget);

    // Brand Email
    await tester.enterText(textFields.at(1), 'contact@nike.com');
    await tester.pump();
    expect(find.text('contact@nike.com'), findsOneWidget);

    // Brand Phone
    await tester.enterText(textFields.at(2), '9876543210');
    await tester.pump();
    expect(find.text('9876543210'), findsOneWidget);

    // Test Logo Picker Modal Bottom Sheet
    await tester.tap(find.byIcon(Icons.cloud_upload_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Select Brand Logo or Image'), findsOneWidget);

    await tester.tap(find.text('brand_logo.png'));
    await tester.pumpAndSettle();
    expect(find.text('brand_logo.png'), findsOneWidget);

    // Test Submit with valid data
    await tester.ensureVisible(find.text('Submit'));
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(find.text('Brand Saved'), findsOneWidget);
    expect(find.text('Brand "Nike" has been created successfully.'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Verify Calculator Floating Button
    expect(find.byType(CalculatorWidget), findsNothing);
    await tester.tap(find.byIcon(Icons.calculate_rounded));
    await tester.pump();
    expect(find.byType(CalculatorWidget), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    expect(find.byType(CalculatorWidget), findsNothing);
  });
}
