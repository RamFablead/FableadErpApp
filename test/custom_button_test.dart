import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fableaderpapp/core/widgets/custom_button.dart';

void main() {
  testWidgets('CustomButton primary renders with text and responds to taps', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: CustomButton.primary(
              text: 'Sign In',
              suffixIconData: Icons.login_rounded,
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.byIcon(Icons.login_rounded), findsOneWidget);

    await tester.tap(find.text('Sign In'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('CustomButton outlined renders with camera icon and text', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: CustomButton.outlined(
              text: 'Login with Face',
              prefixIconData: Icons.camera_alt_rounded,
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Login with Face'), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);

    await tester.tap(find.text('Login with Face'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
