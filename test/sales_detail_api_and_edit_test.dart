import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:fableaderpapp/core/constants/api_constants.dart';
import 'package:fableaderpapp/models/order_model.dart';
import 'package:fableaderpapp/models/product_model.dart';
import 'package:fableaderpapp/services/order_service.dart';
import 'package:fableaderpapp/screens/sales&bills/view/sales_screen.dart';
import 'package:fableaderpapp/screens/sales&bills/view/sales_detail_screen.dart';

void main() {
  group('Sales Detail API & Edit Mode Tests', () {
    test('ApiConstants.getSalesByIdEndpoint formats URL correctly', () {
      expect(ApiConstants.getSalesByIdEndpoint(239), '/api/getsalseById/239');
      expect(ApiConstants.getSalesByIdEndpoint('100'), '/api/getsalseById/100');
    });

    test('OrderService has getSalesById method defined', () {
      final orderService = OrderService();
      expect(orderService.getSalesById, isA<Function>());
    });

    test('SalesDetailResponseModel parses full backend payload correctly', () {
      final sampleJson = {
        "status": true,
        "sales": {
          "id": 239,
          "client_uuid": null,
          "branch_id": 1,
          "order_number": "INV-GST-2026-0157",
          "user_id": 1,
          "created_by": 1,
          "order_type": "self_pickup",
          "discount": "0.00",
          "discount_percentage": "0.00",
          "discount_amount": "0.00",
          "shipping": "0.00",
          "other_charges": null,
          "gst_option": "with_gst",
          "tds_percentage": "0.00",
          "tds_amount": "0.00",
          "total_amount": "1180.00",
          "deposit_amount": "0.00",
          "deposit_status": "held",
          "remaining_amount": "0.00",
          "payment_status": "completed",
          "rental_status": "sales",
          "delivery_status": "pending",
          "payment_method": "cash",
          "quotation_status": "sales",
          "remarks": "With GST order test",
          "created_at": "05-10-2026",
          "updated_at": "2026-10-05T10:46:19.000000Z",
          "order_items": [
            {
              "id": 482,
              "branch_id": 1,
              "order_id": 239,
              "product_id": 1,
              "product_name": "Mobile Cover",
              "price": "500.00",
              "discount_percentage": "0.00",
              "discount_amount": "0.00",
              "quantity": "2.00",
              "product_gst_details": [
                {
                  "tax_name": "CGST",
                  "tax_rate": 9,
                  "tax_amount": 90
                },
                {
                  "tax_name": "SGST",
                  "tax_rate": 9,
                  "tax_amount": 90
                }
              ],
              "product_gst_total": "180.00",
              "total_amount": "1180.00",
              "product": {
                "id": 1,
                "name": "test",
                "SKU": "123",
                "price": "1000.00",
                "purchase_price": "900.00",
                "quantity": "84.00"
              }
            }
          ],
          "user": {
            "id": 1,
            "name": "Main Branch",
            "phone": "555555555",
            "email": "admin@gmail.com",
            "gst_number": null,
            "pan_number": null,
            "profile_image_url": "https://erp-demo.fableadtech.com/public/admin/assets/img/customer/customer5.jpg"
          },
          "user_name": "Main Branch",
          "user_phone": "555555555",
          "paid_amount": "1180.00",
          "pending_amount": 0
        },
        "order_items": [
          {
            "id": 482,
            "product_name": "Mobile Cover",
            "quantity": "2.00",
            "price": "500.00",
            "discount_percentage": "0.00",
            "discount_amount": "0.00",
            "product_gst_total": "180.00",
            "total_amount": "1180.00",
            "product_tax": [
              {
                "tax_name": "CGST",
                "tax_rate": 9,
                "tax_amount": 90
              },
              {
                "tax_name": "SGST",
                "tax_rate": 9,
                "tax_amount": 90
              }
            ]
          }
        ],
        "currency_symbol": "₹",
        "currency_position": "left"
      };

      final model = SalesDetailResponseModel.fromJson(sampleJson);

      expect(model.status, isTrue);
      expect(model.sales, isNotNull);
      expect(model.sales!.id, 239);
      expect(model.sales!.orderNumber, "INV-GST-2026-0157");
      expect(model.sales!.gstOption, "with_gst");
      expect(model.sales!.quotationStatus, "sales");
      expect(model.sales!.paymentMethod, "cash");
      expect(model.sales!.totalAmount, 1180.00);
      expect(model.sales!.remarks, "With GST order test");

      // User details
      expect(model.sales!.user, isNotNull);
      expect(model.sales!.user!.id, 1);
      expect(model.sales!.user!.name, "Main Branch");
      expect(model.sales!.user!.phone, "555555555");
      expect(model.sales!.user!.email, "admin@gmail.com");

      // Order items
      expect(model.orderItems.length, 1);
      final item = model.orderItems.first;
      expect(item.id, 482);
      expect(item.productName, "Mobile Cover");
      expect(item.price, 500.00);
      expect(item.quantity, 2.00);
      expect(item.productGstTotal, 180.00);
      expect(item.totalAmount, 1180.00);
      expect(item.productGstDetails.length, 2);
      expect(item.productGstDetails[0].taxName, "CGST");
      expect(item.productGstDetails[0].taxRate, 9.0);
      expect(item.productGstDetails[0].taxAmount, 90.0);
      expect(item.productGstDetails[1].taxName, "SGST");
      expect(item.productGstDetails[1].taxRate, 9.0);
      expect(item.productGstDetails[1].taxAmount, 90.0);
    });

    test('SalesCartItem correctly computes GST and total matching API calculation', () {
      final product = ProductItemModel(
        id: 1,
        name: 'Mobile Cover',
        price: '500.00',
      );

      final cartItem = SalesCartItem(
        product: product,
        quantity: 2,
        price: 500.00,
        cgstRate: 9.0,
        sgstRate: 9.0,
      );

      expect(cartItem.subtotal, 1000.00);
      expect(cartItem.netAmount, 1000.00);
      expect(cartItem.cgstAmount, 90.00);
      expect(cartItem.sgstAmount, 90.00);
      expect(cartItem.gstTotal, 180.00);
      expect(cartItem.withGstTotal, 1180.00);
    });

    test('SalesScreen accepts editOrderId parameter', () {
      const screen = SalesScreen(editOrderId: 239);
      expect(screen.editOrderId, 239);
    });

    test('SalesDetailScreen accepts orderId and can be instantiated', () {
      final detailScreen = SalesDetailScreen(orderId: 239);
      expect(detailScreen.orderId, 239);
    });

    test('SalesDetailResponseModel parses company_info correctly', () {
      final json = {
        "status": true,
        "company_info": {
          "id": 1,
          "name": "Fablead Developer & Technola",
          "email": "info@fableadtechnolabs.com",
          "phone": "9824734531",
          "gst_num": "4324234",
          "address": "A-5001, Ascon Plaza, Adajan, Surat, Gujarat 395009 India",
          "bank_name": "SBI Bank",
          "branch": "Surat",
          "ac_no": "34234",
          "ifsc_code": "IC123452101"
        }
      };

      final model = SalesDetailResponseModel.fromJson(json);
      expect(model.companyInfo, isNotNull);
      expect(model.companyInfo!.name, "Fablead Developer & Technola");
      expect(model.companyInfo!.phone, "9824734531");
      expect(model.companyInfo!.gstNum, "4324234");
      expect(model.companyInfo!.bankName, "SBI Bank");
      expect(model.companyInfo!.acNo, "34234");
    });
  });
}
