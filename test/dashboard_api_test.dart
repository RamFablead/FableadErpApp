import 'package:flutter_test/flutter_test.dart';
import 'package:fableaderpapp/core/constants/api_constants.dart';
import 'package:fableaderpapp/models/dashboard_model.dart';

void main() {
  group('Dashboard API & Models Tests', () {
    test('ApiConstants.dashboardEndpoint matches expected route', () {
      expect(ApiConstants.dashboardEndpoint, '/api/dashboard-api');
    });

    test('DashboardResponseModel parses user API payload accurately', () {
      final Map<String, dynamic> sampleJson = {
        "status": true,
        "branch_id": 1,
        "data": {
          "totals": {
            "purchase": "959787.94",
            "sales": "4900258.99",
            "expense": "32000.00"
          },
          "counts": {
            "customers": 42,
            "vendors": 20,
            "purchaseInvoices": 39,
            "salesInvoices": 190
          },
          "recentProducts": [
            {
              "id": 303,
              "name": "Shoes",
              "barcode": "PRD8300715254",
              "price": "220.00",
              "quantity": "38.00",
              "image_url": []
            },
            {
              "id": 302,
              "name": "kaaaanew",
              "barcode": "PRD7723927178",
              "price": "2000.00",
              "quantity": "15.00",
              "image_url": []
            },
            {
              "id": 299,
              "name": "barfi",
              "barcode": "PRD6692824459",
              "price": "0.00",
              "quantity": "-5.00",
              "image_url": [
                "https://erp-demo.fableadtech.com/public/admin/assets/img/product/noimage.png"
              ]
            }
          ],
          "latestSales": [
            {
              "id": 482,
              "order_id": 239,
              "product_name": "test",
              "price": "500.00",
              "quantity": "2.000",
              "total_amount": "1180.00",
              "order_number": "INV-GST-2026-0157",
              "order_date": "2026-10-05 16:16:19",
              "payment_method": "cash"
            }
          ],
          "latestPurchases": [
            {
              "invoice_id": 44,
              "purchase_date": "2026-09-23 14:34:21",
              "product_name": "Football",
              "amount_total": "87200.00",
              "invoice_number": "INV-37462095",
              "grand_total": "87240.00",
              "image_url": [
                "https://erp-demo.fableadtech.com/public/storage/img/product/mUa95TuVLvuAJ2tdZ3BwW6X4Si6zh457nBn1f0NL.jpg"
              ]
            }
          ],
          "charts": {
            "sales": [0, 0, 0, 5504.2, 0, 6999, 1276061.49, 3271386.23, 317403.9, 22965.74, 0, 0],
            "purchases": [0, 0, 0, 0, 0, 436, 539930.47, 337640.23, 539894.68, 0, 0, 0],
            "salesThisYear": [0, 0, 0, 5504.2, 34247.91, 6999, 1241813.58, 3271386.23, 317403.9, 22965.74, 0, 0],
            "salesThisMonth": [600, 11895.74, 5750, 0, 4720]
          },
          "currency": {
            "symbol": "₹",
            "position": "left"
          }
        }
      };

      final model = DashboardResponseModel.fromJson(sampleJson);

      expect(model.status, true);
      expect(model.branchId, 1);
      expect(model.data, isNotNull);

      final data = model.data!;
      expect(data.totals.sales, 4900258.99);
      expect(data.totals.purchase, 959787.94);
      expect(data.totals.expense, 32000.00);

      expect(data.counts.customers, 42);
      expect(data.counts.vendors, 20);
      expect(data.counts.purchaseInvoices, 39);
      expect(data.counts.salesInvoices, 190);

      expect(data.recentProducts.length, 3);
      expect(data.recentProducts[0].name, 'Shoes');
      expect(data.recentProducts[0].price, 220.0);
      expect(data.recentProducts[0].quantity, 38.0);
      expect(data.recentProducts[2].quantity, -5.0);
      expect(data.recentProducts[2].imageUrl.first, contains('noimage.png'));

      expect(data.latestSales.length, 1);
      expect(data.latestSales[0].orderId, 239);
      expect(data.latestSales[0].productName, 'test');
      expect(data.latestSales[0].orderNumber, 'INV-GST-2026-0157');
      expect(data.latestSales[0].totalAmount, 1180.0);

      expect(data.latestPurchases.length, 1);
      expect(data.latestPurchases[0].invoiceId, 44);
      expect(data.latestPurchases[0].productName, 'Football');
      expect(data.latestPurchases[0].grandTotal, 87240.0);

      expect(data.charts, isNotNull);
      expect(data.charts!.sales.length, 12);
      expect(data.charts!.sales[6], 1276061.49);
      expect(data.charts!.purchases.length, 12);
      expect(data.charts!.salesThisMonth.length, 5);

      expect(data.currencySymbol, '₹');
    });
  });
}
