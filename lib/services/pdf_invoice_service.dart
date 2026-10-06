import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/api_constants.dart';

class PdfInvoiceService {
  static final PdfInvoiceService _instance = PdfInvoiceService._internal();
  factory PdfInvoiceService() => _instance;
  PdfInvoiceService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  /// Resolves the absolute URL for the invoice PDF.
  /// Example: https://erp-demo.fableadtech.com/sales/invoice/pdf/228
  String resolveInvoicePdfUrl({
    required dynamic orderId,
    String? rawPdfUrl,
  }) {
    if (rawPdfUrl != null && rawPdfUrl.trim().isNotEmpty) {
      final trimmed = rawPdfUrl.trim();
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        return trimmed;
      }
      final cleanPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
      return '${ApiConstants.baseUrl}$cleanPath';
    }
    return '${ApiConstants.baseUrl}/sales/invoice/pdf/$orderId';
  }

  /// Downloads the invoice PDF to device storage and returns the local file path.
  Future<String> downloadInvoicePdf({
    required dynamic orderId,
    required String orderNumber,
    String? rawPdfUrl,
    void Function(int received, int total)? onProgress,
  }) async {
    final pdfUrl = resolveInvoicePdfUrl(orderId: orderId, rawPdfUrl: rawPdfUrl);

    // Sanitize order number for file name
    final sanitizedNumber = orderNumber
        .replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    final fileName = 'Invoice_$sanitizedNumber.pdf';

    Directory? targetDir;
    try {
      if (Platform.isAndroid) {
        // First try standard external downloads or external storage
        try {
          targetDir = await getDownloadsDirectory();
        } catch (_) {}
        targetDir ??= await getExternalStorageDirectory();
      } else if (Platform.isIOS || Platform.isMacOS) {
        targetDir = await getApplicationDocumentsDirectory();
      } else {
        // Windows / Linux / other
        try {
          targetDir = await getDownloadsDirectory();
        } catch (_) {}
        targetDir ??= await getApplicationDocumentsDirectory();
      }
    } catch (e) {
      debugPrint('Error getting target directory: $e');
      targetDir = await getApplicationDocumentsDirectory();
    }

    targetDir ??= await getApplicationDocumentsDirectory();

    final filePath = '${targetDir.path}/$fileName';
    debugPrint('Downloading PDF from: $pdfUrl');
    debugPrint('Saving to: $filePath');

    final response = await _dio.download(
      pdfUrl,
      filePath,
      onReceiveProgress: (received, total) {
        if (onProgress != null && total > 0) {
          onProgress(received, total);
        }
      },
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 206) {
      final file = File(filePath);
      if (await file.exists() && await file.length() > 0) {
        return filePath;
      }
    }

    throw Exception('Failed to download invoice PDF (Status: ${response.statusCode})');
  }

  /// Opens the downloaded PDF file using OpenFilex
  Future<OpenResult> openPdfFile(String filePath) async {
    return await OpenFilex.open(filePath);
  }

  /// Opens the invoice PDF directly in the external web browser
  Future<bool> openPdfInBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
    return false;
  }
}
