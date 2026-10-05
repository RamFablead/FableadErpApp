import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:fableaderpapp/screens/splash_screen.dart';

void main() {
  testWidgets('SplashScreen renders light mode elements, logo, and title smoothly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 850);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) {
          return const MaterialApp(
            home: SplashScreen(),
          );
        },
      ),
    );

    // Initial frame
    await tester.pump(const Duration(milliseconds: 200));

    // Verify Title elements in Light Mode
    expect(find.text('FABLEAD'), findsOneWidget);
    expect(find.text('ERP'), findsOneWidget);
    expect(find.text('Smart Enterprise Resource Planning'), findsOneWidget);
    expect(find.text('Enterprise Edition'), findsOneWidget);
    expect(find.text('POWERED BY FABLEAD TECH'), findsOneWidget);

    // Pump forward animation
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Pump widget unmount to verify timer cleanup in dispose
    await tester.pumpWidget(Container());
  });
}

