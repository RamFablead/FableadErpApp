import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fableaderpapp/core/widgets/custom_textfield.dart';

void main() {
  testWidgets('CustomTextField renders label, prefix icon, and toggles password visibility', (WidgetTester tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: CustomTextField(
              label: 'Password',
              isRequired: true,
              hintText: 'Enter your password',
              controller: controller,
              isPassword: true,
              prefixIconData: Icons.lock_rounded,
            ),
          ),
        ),
      ),
    );

    // Verify label & required star
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('*'), findsOneWidget);

    // Verify prefix icon
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);

    // Verify password visibility icon initially obscure
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

    // Tap toggle visibility
    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();

    // Verify icon switches to visibility_outlined
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
  });
}
