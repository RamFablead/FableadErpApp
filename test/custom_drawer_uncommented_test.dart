import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:fableaderpapp/widgets/custom_drawer.dart';

void main() {
  testWidgets('CustomDrawer renders all 7 top-level categories matching user screenshots', (WidgetTester tester) async {
    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) {
          return GetMaterialApp(
            home: Scaffold(
              drawer: const CustomDrawer(
                isDarkMode: false,
                activeItem: 'Dashboard',
              ),
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    child: const Text('Open Drawer'),
                  );
                },
              ),
            ),
          );
        },
      ),
    );

    // Open Drawer
    await tester.tap(find.text('Open Drawer'));
    await tester.pumpAndSettle();

    // Verify Brand
    expect(find.text('FABLEAD ERP'), findsOneWidget);

    // Verify All 7 Top-Level Categories from Image 1
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('ERP'), findsOneWidget);
    expect(find.text('CRM'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('Accounting'), findsOneWidget);
    expect(find.text('HR'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Verify Logout is rendered at the bottom
    expect(find.text('Logout Account'), findsOneWidget);
  });

  testWidgets('CustomDrawer ERP module displays all 10 sub-items from screenshot', (WidgetTester tester) async {
    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) {
          return GetMaterialApp(
            home: Scaffold(
              drawer: const CustomDrawer(
                isDarkMode: false,
                activeItem: 'ERP',
              ),
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    child: const Text('Open Drawer'),
                  );
                },
              ),
            ),
          );
        },
      ),
    );

    await tester.tap(find.text('Open Drawer'));
    await tester.pumpAndSettle();

    // All 10 ERP items from Image 2
    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Catalog Setup'), findsOneWidget);
    expect(find.text('Sales & Bills'), findsOneWidget);
    expect(find.text('Products Delivery'), findsOneWidget);
    expect(find.text('Purchases'), findsOneWidget);
    expect(find.text('Vendors'), findsOneWidget);
    expect(find.text('Manufacture Product'), findsOneWidget);
    expect(find.text('Financers'), findsOneWidget);
    expect(find.text('Manage Inventory'), findsOneWidget);
    expect(find.text('Returns'), findsOneWidget);
  });

  testWidgets('CustomDrawer CRM module displays all 5 sub-items from screenshot', (WidgetTester tester) async {
    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) {
          return GetMaterialApp(
            home: Scaffold(
              drawer: const CustomDrawer(
                isDarkMode: false,
                activeItem: 'CRM',
              ),
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    child: const Text('Open Drawer'),
                  );
                },
              ),
            ),
          );
        },
      ),
    );

    await tester.tap(find.text('Open Drawer'));
    await tester.pumpAndSettle();

    // All 5 CRM items from Image 3
    expect(find.text('Customers'), findsOneWidget);
    expect(find.text('Manage Leads'), findsOneWidget);
    expect(find.text('Follow Ups'), findsOneWidget);
    expect(find.text('Meetings'), findsOneWidget);
    expect(find.text('Tickets'), findsOneWidget);
  });

  testWidgets('CustomDrawer Reports module displays all 6 sub-items from screenshot', (WidgetTester tester) async {
    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) {
          return GetMaterialApp(
            home: Scaffold(
              drawer: const CustomDrawer(
                isDarkMode: false,
                activeItem: 'Reports',
              ),
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    child: const Text('Open Drawer'),
                  );
                },
              ),
            ),
          );
        },
      ),
    );

    await tester.tap(find.text('Open Drawer'));
    await tester.pumpAndSettle();

    // All 6 Reports items from Image 4
    expect(find.text('Sales Report'), findsOneWidget);
    expect(find.text('Sales Pool Report'), findsOneWidget);
    expect(find.text('TDS Report'), findsOneWidget);
    expect(find.text('Purchase Report'), findsOneWidget);
    expect(find.text('Expenses Report'), findsOneWidget);
    expect(find.text('Profit & Loss Statement'), findsOneWidget);
  });

  testWidgets('CustomDrawer Accounting module displays all 6 sub-items from screenshot', (WidgetTester tester) async {
    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) {
          return GetMaterialApp(
            home: Scaffold(
              drawer: const CustomDrawer(
                isDarkMode: false,
                activeItem: 'Accounting',
              ),
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    child: const Text('Open Drawer'),
                  );
                },
              ),
            ),
          );
        },
      ),
    );

    await tester.tap(find.text('Open Drawer'));
    await tester.pumpAndSettle();

    // All 6 Accounting items from Image 5
    expect(find.text('Manage Accounting'), findsOneWidget);
    expect(find.text('Receipt & Payment'), findsOneWidget);
    expect(find.text('Expenses'), findsOneWidget);
    expect(find.text('Cash & Bank'), findsOneWidget);
    expect(find.text('Credit/Debit Notes'), findsOneWidget);
    expect(find.text('GST Reports'), findsOneWidget);
  });

  testWidgets('CustomDrawer HR module displays all 6 sub-items from screenshot', (WidgetTester tester) async {
    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) {
          return GetMaterialApp(
            home: Scaffold(
              drawer: const CustomDrawer(
                isDarkMode: false,
                activeItem: 'HR',
              ),
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    child: const Text('Open Drawer'),
                  );
                },
              ),
            ),
          );
        },
      ),
    );

    await tester.tap(find.text('Open Drawer'));
    await tester.pumpAndSettle();

    // All 6 HR items from screenshot
    expect(find.text('Staff'), findsOneWidget);
    expect(find.text('Attendance'), findsOneWidget);
    expect(find.text('Leaves'), findsOneWidget);
    expect(find.text('Payroll'), findsOneWidget);
    expect(find.text('Advance Pay'), findsOneWidget);
    expect(find.text('My Branch'), findsOneWidget);
  });

  testWidgets('CustomDrawer Settings module displays all sub-items from screenshot', (WidgetTester tester) async {
    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) {
          return GetMaterialApp(
            home: Scaffold(
              drawer: const CustomDrawer(
                isDarkMode: false,
                activeItem: 'Settings',
              ),
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    child: const Text('Open Drawer'),
                  );
                },
              ),
            ),
          );
        },
      ),
    );

    await tester.tap(find.text('Open Drawer'));
    await tester.pumpAndSettle();

    // Verify Settings items from screenshot
    expect(find.text('Plans'), findsOneWidget);
    expect(find.text('My Plan Details'), findsOneWidget);
    expect(find.text('Change Password'), findsOneWidget);
    expect(find.text('Shop Settings'), findsOneWidget);
    expect(find.text('Smtp Settings'), findsOneWidget);
    expect(find.text('WhatsApp Configuration'), findsOneWidget);
    expect(find.text('Tax Rates'), findsOneWidget);
    expect(find.text('Departments'), findsOneWidget);
    expect(find.text('Designations'), findsOneWidget);
    expect(find.text('Leave Types'), findsOneWidget);
    expect(find.text('Manage Holidays'), findsOneWidget);
    expect(find.text('Holiday Calendar'), findsOneWidget);
    expect(find.text('Table Truncate'), findsOneWidget);
    expect(find.text('Company Profile'), findsOneWidget);
  });
}
