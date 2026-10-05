import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:fableaderpapp/widgets/custom_app_bar.dart';
import 'package:fableaderpapp/widgets/custom_bottom_bar.dart';

void main() {
  group('CustomAppBar & CustomBottomBar Widget Tests', () {
    testWidgets('CustomAppBar renders title, drawer menu, and action buttons',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 850);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool themeToggled = false;

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              home: Scaffold(
                appBar: CustomAppBar(
                  title: 'Sales & Bills',
                  showBackButton: false,
                  onThemeToggle: () {
                    themeToggled = true;
                  },
                ),
              ),
            );
          },
        ),
      );

      // Verify Title
      expect(find.text('Sales & Bills'), findsOneWidget);

      // Verify Menu button exists
      expect(find.byIcon(Icons.menu_rounded), findsOneWidget);

      // Verify Notifications icon
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

      // Verify Notification counter badge
      expect(find.text('3'), findsOneWidget);

      // Verify Profile avatar text
      expect(find.text('FE'), findsOneWidget);

      // Test theme toggle button tap
      final themeBtn = find.byIcon(Icons.dark_mode_rounded);
      expect(themeBtn, findsOneWidget);
      await tester.tap(themeBtn);
      await tester.pump();
      expect(themeToggled, isTrue);
    });

    testWidgets('CustomAppBar with back button renders back arrow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 850);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return const MaterialApp(
              home: Scaffold(
                appBar: CustomAppBar(
                  title: 'Product Details',
                  showBackButton: true,
                ),
              ),
            );
          },
        ),
      );

      expect(find.text('Product Details'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    });

    testWidgets('CustomBottomBar renders all 4 modules and handles tab switches',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 850);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      int tappedIndex = -1;

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              home: Scaffold(
                bottomNavigationBar: CustomBottomBar(
                  selectedIndex: 0,
                  onItemTapped: (index) {
                    tappedIndex = index;
                  },
                ),
              ),
            );
          },
        ),
      );

      // Verify all 4 tab labels
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Products'), findsOneWidget);
      expect(find.text('Sale'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Verify active dashboard icon
      expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);

      // Tap 'Sale' tab (index 2)
      await tester.tap(find.text('Sale'));
      await tester.pump();
      expect(tappedIndex, 2);

      // Tap 'Profile' tab (index 3)
      await tester.tap(find.text('Profile'));
      await tester.pump();
      expect(tappedIndex, 3);
    });
  });
}
