import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../services/pdf_invoice_service.dart';

class InvoicePdfViewerScreen extends StatefulWidget {
  final dynamic orderId;
  final String orderNumber;
  final String? pdfUrl;

  const InvoicePdfViewerScreen({
    super.key,
    required this.orderId,
    required this.orderNumber,
    this.pdfUrl,
  });

  @override
  State<InvoicePdfViewerScreen> createState() => _InvoicePdfViewerScreenState();
}

class _InvoicePdfViewerScreenState extends State<InvoicePdfViewerScreen> {
  final PdfInvoiceService _pdfService = PdfInvoiceService();
  late final PdfViewerController _pdfViewerController;

  late String _resolvedUrl;
  bool _isLoading = true;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 0;
  String? _downloadedFilePath;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _resolvedUrl = _pdfService.resolveInvoicePdfUrl(
      orderId: widget.orderId,
      rawPdfUrl: widget.pdfUrl,
    );
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  Future<void> _handleDownloadPdf({bool openAfter = false}) async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      final path = await _pdfService.downloadInvoicePdf(
        orderId: widget.orderId,
        orderNumber: widget.orderNumber,
        rawPdfUrl: widget.pdfUrl,
        onProgress: (received, total) {
          if (mounted && total > 0) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      if (!mounted) return;

      setState(() {
        _isDownloading = false;
        _downloadedFilePath = path;
      });

      if (openAfter) {
        await _pdfService.openPdfFile(path);
      } else {
        Get.snackbar(
          'Invoice Downloaded',
          'Saved #${widget.orderNumber} successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 4),
          mainButton: TextButton(
            onPressed: () => _pdfService.openPdfFile(path),
            child: const Text(
              'OPEN',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isDownloading = false;
      });

      Get.snackbar(
        'Download Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    }
  }

  Future<void> _handleOpenInBrowser() async {
    final success = await _pdfService.openPdfInBrowser(_resolvedUrl);
    if (!success) {
      Get.snackbar(
        'Cannot Open Browser',
        'Could not launch URL in external browser: $_resolvedUrl',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    'Bill #${widget.orderNumber}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                if (_totalPages > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                    ),
                    child: Text(
                      '$_currentPage / $_totalPages',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFF6B2C),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Text(
              'Official Invoice PDF',
              style: TextStyle(
                fontSize: 10.5.sp,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          // Open in Browser
          IconButton(
            icon: const Icon(Icons.open_in_browser_rounded, color: Color(0xFF64748B)),
            tooltip: 'Open in Browser',
            onPressed: _handleOpenInBrowser,
          ),

          // Download PDF Action
          IconButton(
            icon: _isDownloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFFF6B2C),
                    ),
                  )
                : const Icon(Icons.download_rounded, color: Color(0xFFFF6B2C)),
            tooltip: 'Download Invoice',
            onPressed: () => _handleDownloadPdf(openAfter: false),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: Stack(
        children: [
          if (_errorMessage != null)
            _buildErrorState()
          else
            SfPdfViewer.network(
              _resolvedUrl,
              controller: _pdfViewerController,
              canShowScrollHead: true,
              canShowScrollStatus: true,
              onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _totalPages = details.document.pages.count;
                    _errorMessage = null;
                  });
                }
              },
              onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _errorMessage = details.error;
                  });
                }
              },
              onPageChanged: (PdfPageChangedDetails details) {
                if (mounted) {
                  setState(() {
                    _currentPage = details.newPageNumber;
                  });
                }
              },
            ),

          // Loading overlay
          if (_isLoading && _errorMessage == null)
            Container(
              color: Colors.white.withValues(alpha: 0.9),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF7ED),
                        shape: BoxShape.circle,
                      ),
                      child: const CircularProgressIndicator(
                        color: Color(0xFFFF6B2C),
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading Invoice PDF...',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bill #${widget.orderNumber}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Downloading Progress Bar overlay
          if (_isDownloading)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFF0F172A),
                child: Row(
                  children: [
                    const Icon(Icons.downloading_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Downloading invoice...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${(_downloadProgress * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Color(0xFFFF6B2C),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: _downloadProgress > 0 ? _downloadProgress : null,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B2C)),
                            minHeight: 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.picture_as_pdf_outlined,
                color: Color(0xFFEF4444),
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to display PDF preview',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? 'The PDF file could not be rendered directly.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                    });
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Retry'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _handleOpenInBrowser,
                  icon: const Icon(Icons.open_in_browser_rounded, size: 18, color: Colors.white),
                  label: const Text('Open in Browser', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B2C),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Open in Browser Button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _handleOpenInBrowser,
              icon: const Icon(Icons.launch_rounded, size: 18),
              label: const Text('Browser View'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0F172A),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Download & Open Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _handleDownloadPdf(openAfter: true),
              icon: const Icon(Icons.download_rounded, size: 18, color: Colors.white),
              label: Text(
                _downloadedFilePath != null ? 'Open PDF' : 'Download PDF',
                style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B2C),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
