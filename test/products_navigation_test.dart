import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:fableaderpapp/widgets/custom_drawer.dart';
import 'package:fableaderpapp/screens/products/view/product_screen.dart';
import 'package:fableaderpapp/screens/products/view/add_product_screen.dart';
import 'package:fableaderpapp/screens/products/view/raw_materials_screen.dart';
import 'package:fableaderpapp/screens/products/view/import_product_screen.dart';
import 'package:fableaderpapp/screens/manageinventory/view/manage_inventory_screen.dart';
import 'package:fableaderpapp/screens/catalogsetup/view/product_category_screen.dart';
import 'package:fableaderpapp/screens/accounting/view/account_ledger_screen.dart';

Widget createTestApp({
  required String activeItem,
  required ValueChanged<String> onItemSelected,
}) {
  return Sizer(
    builder: (context, orientation, deviceType) {
      return GetMaterialApp(
        home: Scaffold(
          drawer: CustomDrawer(
            isDarkMode: false,
            activeItem: activeItem,
            onItemSelected: onItemSelected,
          ),
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => Scaffold.of(ctx).openDrawer(),
              child: const Text('Open Drawer'),
            ),
          ),
        ),
      );
    },
  );
}

void main() {
  testWidgets('CustomDrawer displays Products banner and all 4 sub-items',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      createTestApp(
        activeItem: 'Products',
        onItemSelected: (_) {},
      ),
    );

    await tester.tap(find.text('Open Drawer'));
    await tester.pumpAndSettle();

    expect(find.text('Products'), findsOneWidget);
    expect(find.text('All Products'), findsOneWidget);
    expect(find.text('New Product'), findsOneWidget);
    expect(find.text('All Raw Materials'), findsOneWidget);
    expect(find.text('Import Products'), findsOneWidget);
  });

  testWidgets('CustomDrawer navigates to All Products using Get.to',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    String selected = '';
    await tester.pumpWidget(
      createTestApp(
        activeItem: 'Products',
        onItemSelected: (item) => selected = item,
      ),
    );

    await tester.tap(find.text('Open Drawer'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('All Products'));
    await tester.pumpAndSettle();

    expect(selected, 'All Products');
    expect(find.byType(ProductScreen), findsOneWidget);
  });

  testWidgets('CustomDrawer navigates to New Product using Get.to',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    String selected = '';
    await tester.pumpWidget(
      createTestApp(
        activeItem: 'Products',
        onItemSelected: (item) => selected = item,
      ),
    );

    await tester.tap(find.text('Open Drawer'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New Product'));
    await tester.pumpAndSettle();

    expect(selected, 'New Product');
    expect(find.byType(AddProductScreen), findsOneWidget);
  });

  testWidgets('CustomDrawer navigates to All Raw Materials using Get.to',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    String selected = '';
    await tester.pumpWidget(
      createTestApp(
        activeItem: 'Products',
        onItemSelected: (item) => selected = item,
      ),
    );

    await tester.tap(find.text('Open Drawer'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('All Raw Materials'));
    await tester.pumpAndSettle();

    expect(selected, 'All Raw Materials');
    expect(find.byType(RawMaterialsScreen), findsOneWidget);
  });

  testWidgets('CustomDrawer navigates to Import Products using Get.to',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    String selected = '';
    await tester.pumpWidget(
      createTestApp(
        activeItem: 'Products',
        onItemSelected: (item) => selected = item,
      ),
    );

    await tester.tap(find.text('Open Drawer'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Import Products'));
    await tester.pumpAndSettle();

    expect(selected, 'Import Products');
    expect(find.byType(ImportProductScreen), findsOneWidget);
  });

  testWidgets('CustomDrawer navigates to Manage Inventory using Get.to',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    String selected = '';
    await tester.pumpWidget(
      createTestApp(
        activeItem: 'ERP',
        onItemSelected: (item) => selected = item,
      ),
    );

    await tester.tap(find.text('Open Drawer'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Manage Inventory'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Manage Inventory'));
    await tester.pumpAndSettle();

    expect(selected, 'Manage Inventory');
    expect(find.byType(ManageInventoryScreen), findsOneWidget);
  });

  testWidgets('CustomDrawer navigates to Catalog Setup using Get.to',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    String selected = '';
    await tester.pumpWidget(
      createTestApp(
        activeItem: 'ERP',
        onItemSelected: (item) => selected = item,
      ),
    );

    await tester.tap(find.text('Open Drawer'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Catalog Setup'));
    await tester.pumpAndSettle();

    expect(selected, 'Catalog Setup');
    expect(find.byType(ProductCategoryScreen), findsOneWidget);
  });

  testWidgets('CustomDrawer navigates to Account Ledger using Get.to',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    String selected = '';
    await tester.pumpWidget(
      createTestApp(
        activeItem: 'Accounting',
        onItemSelected: (item) => selected = item,
      ),
    );

    await tester.tap(find.text('Open Drawer'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Account Ledger'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Account Ledger'));
    await tester.pumpAndSettle();

    expect(selected, 'Account Ledger');
    expect(find.byType(AccountLedgerScreen), findsOneWidget);
  });
}

