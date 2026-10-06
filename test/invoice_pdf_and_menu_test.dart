import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:fableaderpapp/core/constants/api_constants.dart';
import 'package:fableaderpapp/models/order_model.dart';
import 'package:fableaderpapp/services/pdf_invoice_service.dart';
import 'package:fableaderpapp/screens/sales&bills/view/invoice_pdf_viewer_screen.dart';

void main() {
  group('Invoice PDF URL & Service Tests', () {
    final pdfService = PdfInvoiceService();

    test('resolveInvoicePdfUrl correctly generates default url from orderId', () {
      final url = pdfService.resolveInvoicePdfUrl(orderId: 228);
      expect(url, 'https://erp-demo.fableadtech.com/sales/invoice/pdf/228');
    });

    test('resolveInvoicePdfUrl preserves full http/https URLs', () {
      const fullUrl = 'https://erp-demo.fableadtech.com/sales/invoice/pdf/228';
      final url = pdfService.resolveInvoicePdfUrl(orderId: 228, rawPdfUrl: fullUrl);
      expect(url, fullUrl);
    });

    test('resolveInvoicePdfUrl properly prepends base URL for relative paths', () {
      final url = pdfService.resolveInvoicePdfUrl(orderId: 228, rawPdfUrl: '/sales/invoice/pdf/228');
      expect(url, 'https://erp-demo.fableadtech.com/sales/invoice/pdf/228');
    });

    test('OrderItemModel.effectiveInvoicePdfUrl correctly returns PDF URL', () {
      // 1. When invoice_pdf_url is in JSON
      final orderWithPdf = OrderItemModel.fromJson({
        'id': 228,
        'order_number': 'ORD-228',
        'invoice_pdf_url': 'https://erp-demo.fableadtech.com/sales/invoice/pdf/228',
      });
      expect(orderWithPdf.effectiveInvoicePdfUrl,
          'https://erp-demo.fableadtech.com/sales/invoice/pdf/228');

      // 2. When invoice_pdf_url is absent/null, falls back to standard endpoint
      final orderWithoutPdf = OrderItemModel.fromJson({
        'id': 228,
        'order_number': 'ORD-228',
      });
      expect(orderWithoutPdf.effectiveInvoicePdfUrl,
          'https://erp-demo.fableadtech.com/sales/invoice/pdf/228');
    });

    test('SalesDetailHeaderModel.effectiveInvoicePdfUrl correctly returns PDF URL', () {
      final headerWithPdf = SalesDetailHeaderModel.fromJson({
        'id': 228,
        'order_number': 'ORD-228',
        'invoice_pdf_url': 'https://erp-demo.fableadtech.com/sales/invoice/pdf/228',
      });
      expect(headerWithPdf.effectiveInvoicePdfUrl,
          'https://erp-demo.fableadtech.com/sales/invoice/pdf/228');

      final headerFallback = SalesDetailHeaderModel.fromJson({
        'id': 228,
        'order_number': 'ORD-228',
      });
      expect(headerFallback.effectiveInvoicePdfUrl,
          'https://erp-demo.fableadtech.com/sales/invoice/pdf/228');
    });
  });

  group('Invoice PDF Viewer Widget Tests', () {
    testWidgets('InvoicePdfViewerScreen instantiates and renders app bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return const GetMaterialApp(
              home: InvoicePdfViewerScreen(
                orderId: 228,
                orderNumber: 'INV-GST-2026-0157',
                pdfUrl: 'https://erp-demo.fableadtech.com/sales/invoice/pdf/228',
              ),
            );
          },
        ),
      );

      // Expect title & bill number
      expect(find.text('Bill #INV-GST-2026-0157'), findsWidgets);
      expect(find.text('Official Invoice PDF'), findsOneWidget);
      expect(find.byIcon(Icons.open_in_browser_rounded), findsOneWidget);
      expect(find.byIcon(Icons.download_rounded), findsWidgets);
      expect(find.text('Browser View'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
    });
  });

  group('Bill Actions Menu Tests', () {
    testWidgets('Action menu renders History, View, Edit, Invoice, Print Invoice, Delete and EXCLUDES Upload QR and Raise Ticket',
        (WidgetTester tester) async {
      final sampleOrder = OrderItemModel.fromJson({
        'id': 228,
        'order_number': 'INV-228',
        'total_amount': '1500.00',
        'invoice_pdf_url': 'https://erp-demo.fableadtech.com/sales/invoice/pdf/228',
      });

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return GetMaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (ctx) => Center(
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'history', child: Text('History')),
                        const PopupMenuItem(value: 'view', child: Text('View')),
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'invoice', child: Text('Invoice')),
                        const PopupMenuItem(value: 'print', child: Text('Print Invoice')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );

      // Open popup menu
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();

      // Verify required menu items are present
      expect(find.text('History'), findsOneWidget);
      expect(find.text('View'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Invoice'), findsOneWidget);
      expect(find.text('Print Invoice'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // Verify removed menu items are NOT present
      expect(find.text('Upload QR'), findsNothing);
      expect(find.text('Raise Ticket'), findsNothing);
    });
  });
}
