import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../../core/widgets/calculator_widget.dart';

/// Screen for importing financers from CSV, XLS, or XLSX files
/// Located at lib/screens/financers/view/import_financers_screen.dart
class ImportFinancersScreen extends StatefulWidget {
  const ImportFinancersScreen({super.key});

  @override
  State<ImportFinancersScreen> createState() => _ImportFinancersScreenState();
}

class _ImportFinancersScreenState extends State<ImportFinancersScreen> {
  bool _isCalculatorOpen = false;
  String? _selectedFileName;
  int? _selectedFileSizeKb;

  static const String _supportedColumnsText =
      'S.No, Financier Name, Address Line1, Address Line2, Address Line3, '
      'Pin Code, City/Town, State, Phone #1, Phone #2, Email Id, Credit Limit, '
      'Credit Days, PAN Status, PAN, GSTIN Status, GSTIN, Account Group, Status';

  void _handlePickFile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Financers File',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a file from your device or use a sample dataset:',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.table_chart_rounded, color: Color(0xFFFF7A1A)),
                ),
                title: Text(
                  'financers_master_data.xlsx',
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                subtitle: Text(
                  'Excel Spreadsheet • 64 KB',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _selectedFileName = 'financers_master_data.xlsx';
                    _selectedFileSizeKb = 64;
                  });
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.description_rounded, color: Color(0xFF10B981)),
                ),
                title: Text(
                  'financers_import_template.csv',
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                subtitle: Text(
                  'CSV Document • 32 KB',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _selectedFileName = 'financers_import_template.csv';
                    _selectedFileSizeKb = 32;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleImport() {
    Get.closeCurrentSnackbar();
    if (_selectedFileName == null) {
      Get.snackbar(
        'File Required',
        'Please select a CSV, XLS, or XLSX file before importing.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    Get.snackbar(
      'Import Successful',
      'Successfully imported records from $_selectedFileName.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isCalculatorOpen = !_isCalculatorOpen;
          });
        },
        backgroundColor: const Color(0xFF1E1B4B),
        elevation: 6,
        child: const Icon(
          Icons.calculate_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: topPadding > 0 ? topPadding + 12 : 20,
              left: 16,
              right: 16,
              bottom: 40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row: Back button + Title
                _buildHeader(),

                const SizedBox(height: 10),

                // Subtitle
                Text(
                  'Upload CSV, XLS, or XLSX files with financer details.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),

                const SizedBox(height: 16),

                // Supported Columns Info Card
                _buildSupportedColumnsCard(),

                const SizedBox(height: 18),

                // Upload Financer File Card
                _buildUploadFileCard(),
              ],
            ),
          ),

          // Floating Calculator Dialog Overlay
          if (_isCalculatorOpen)
            CalculatorWidget(
              onClose: () {
                setState(() {
                  _isCalculatorOpen = false;
                });
              },
            ),
        ],
      ),
    );
  }

  // --- Header: Back Arrow + Import Financers ---
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF0F172A),
            size: 24,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Get.back();
            }
          },
          tooltip: 'Back',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            'Import Financers',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
        ),
      ],
    );
  }

  // --- Supported Columns Alert Card ---
  Widget _buildSupportedColumnsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFEDD5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFFFF8A00),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.info_outline_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Supported columns:',
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _supportedColumnsText,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475569),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Upload Financer File Card ---
  Widget _buildUploadFileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Label Row: Orange File Icon + "Upload Financer File *"
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.description_rounded,
                  color: Color(0xFFFF7A1A),
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Upload Financer File',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Drag and drop dropzone box
          _buildDropZone(),

          const SizedBox(height: 16),

          // Choose File Button
          _buildChooseFileButton(),

          const SizedBox(height: 16),

          // Bottom Action Buttons: Import & Cancel
          _buildBottomActionButtons(),
        ],
      ),
    );
  }

  // --- Drag and Drop Dropzone matching graphic ---
  Widget _buildDropZone() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 180),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFCBD5E1),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Graphic Illustration (CSV Doc + Cloud Upload Icon + Rays)
          _buildIllustrationGraphic(),

          const SizedBox(height: 14),

          // Drag and drop a file to upload
          Text(
            'Drag and drop a file to upload',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),

          const SizedBox(height: 4),

          // Supported formats: CSV, XLS, XLSX
          Text(
            'Supported formats: CSV, XLS, XLSX',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),

          // If a file has been selected, display it
          if (_selectedFileName != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF10B981),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '$_selectedFileName (${_selectedFileSizeKb ?? 0} KB)',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF065F46),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedFileName = null;
                        _selectedFileSizeKb = null;
                      });
                    },
                    child: const Icon(
                      Icons.cancel_rounded,
                      color: Color(0xFF6B7280),
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- Graphic illustration matching the visual in the screenshot ---
  Widget _buildIllustrationGraphic() {
    return SizedBox(
      width: 100,
      height: 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Sunburst rays at top
          Positioned(
            top: 2,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.rotate(
                  angle: -0.4,
                  child: Container(
                    width: 3,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9900),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 3,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9900),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Transform.rotate(
                  angle: 0.4,
                  child: Container(
                    width: 3,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9900),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // File Paper Card
          Positioned(
            top: 14,
            child: Container(
              width: 58,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Folded corner
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  // CSV green badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'CSV',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF059669),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Orange Cloud Upload Badge with upward arrow
          Positioned(
            bottom: 2,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFFF7A1A),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF7A1A).withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_upward_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Choose File Button ---
  Widget _buildChooseFileButton() {
    return Material(
      color: const Color(0xFFFFF7ED),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: _handlePickFile,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFFEDD5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.folder_rounded,
                color: Color(0xFFFF7A1A),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Choose File',
                style: TextStyle(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFF7A1A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Bottom Action Buttons: Import (Orange) & Cancel (Dark Navy) ---
  Widget _buildBottomActionButtons() {
    return Row(
      children: [
        // Import Button
        Expanded(
          flex: 5,
          child: Material(
            color: const Color(0xFFFF7A1A),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: _handleImport,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 13),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.file_upload_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Import',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Cancel Button
        Expanded(
          flex: 5,
          child: Material(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Get.back();
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 13),
                child: Center(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
