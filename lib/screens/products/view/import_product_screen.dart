import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/widgets/calculator_widget.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_drawer.dart';

/// A reference mapping model for displaying Excel/CSV column mapping rules.
class _MappingRule {
  final String fieldName;
  final String mappingDescription;
  final Color descriptionColor;

  const _MappingRule({
    required this.fieldName,
    required this.mappingDescription,
    required this.descriptionColor,
  });
}

/// Screen allowing users to upload CSV/Excel files for bulk product importing,
/// inspect field mapping rules, download sample templates, and access tools.
class ImportProductScreen extends StatefulWidget {
  const ImportProductScreen({super.key});

  @override
  State<ImportProductScreen> createState() => _ImportProductScreenState();
}

class _ImportProductScreenState extends State<ImportProductScreen> {
  bool _isCalculatorOpen = false;
  String? _selectedFileName;
  int? _selectedFileSizeKb;
  bool _isDraggingOver = false;

  static const List<_MappingRule> _mappingRules = [
    _MappingRule(
      fieldName: 'Item/Model (Name)',
      mappingDescription: 'Excel: "Item/Model" column | CSV: "name"',
      descriptionColor: Color(0xFF15803D), // Emerald Green
    ),
    _MappingRule(
      fieldName: 'Category',
      mappingDescription: 'Excel: "Product" column | CSV: "category"',
      descriptionColor: Color(0xFF15803D), // Emerald Green
    ),
    _MappingRule(
      fieldName: 'Brand',
      mappingDescription:
          'Excel: "Brand" column — auto-created in brand table first',
      descriptionColor: Color(0xFF0284C7), // Blue
    ),
    _MappingRule(
      fieldName: 'SKU / Item Code',
      mappingDescription: 'Excel: "Item Code" column | CSV: "sku"',
      descriptionColor: Color(0xFF15803D), // Emerald Green
    ),
    _MappingRule(
      fieldName: 'Selling Price',
      mappingDescription: 'Excel: "Selling Price" column | CSV: "price"',
      descriptionColor: Color(0xFF15803D), // Emerald Green
    ),
    _MappingRule(
      fieldName: 'HSN Code',
      mappingDescription:
          'Excel: "HSN/SAC" column | CSV: "hsn_code" — optional',
      descriptionColor: Color(0xFF0284C7), // Blue
    ),
    _MappingRule(
      fieldName: 'Unit',
      mappingDescription: 'Excel: "UQC" column | CSV: "unit" — e.g. pcs, kg',
      descriptionColor: Color(0xFF0284C7), // Blue
    ),
    _MappingRule(
      fieldName: 'Status',
      mappingDescription: 'Excel: "Status" column — Active/Inactive',
      descriptionColor: Color(0xFF0284C7), // Blue
    ),
  ];

  void _handleSampleDownload() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sample template "products_sample.xlsx" downloaded successfully.',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF15803D),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handlePickFile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.5.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select a file to upload',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 1.5.h),
              ListTile(
                leading: const Icon(
                  Icons.table_chart_rounded,
                  color: Color(0xFF15803D),
                  size: 28,
                ),
                title: Text(
                  'sample_products_data.xlsx',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                subtitle: Text(
                  'Excel Spreadsheet • 48 KB',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _selectedFileName = 'sample_products_data.xlsx';
                    _selectedFileSizeKb = 48;
                  });
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.insert_drive_file_outlined,
                  color: Color(0xFF0284C7),
                  size: 28,
                ),
                title: Text(
                  'product_inventory_export.csv',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                subtitle: Text(
                  'CSV Comma-Separated Values • 24 KB',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _selectedFileName = 'product_inventory_export.csv';
                    _selectedFileSizeKb = 24;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleSubmit() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (_selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a CSV or Excel file before submitting.',
            style: TextStyle(fontSize: 14.sp, color: Colors.white),
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF15803D),
              size: 28,
            ),
            SizedBox(width: 2.w),
            Text(
              'Import Successful',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Text(
          'File "$_selectedFileName" has been uploaded and queued for processing.',
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF334155),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _selectedFileName = null;
                _selectedFileSizeKb = null;
              });
            },
            child: Text(
              'OK',
              style: TextStyle(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFFFA043),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCancel() {
    if (_selectedFileName != null) {
      setState(() {
        _selectedFileName = null;
        _selectedFileSizeKb = null;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'File selection cleared.',
            style: TextStyle(fontSize: 14.sp, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF475569),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canGoBack = Navigator.canPop(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'Import Product',
        showBackButton: canGoBack,
        isDarkMode: false,
      ),
      drawer: const CustomDrawer(isDarkMode: false, activeItem: 'Products'),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isCalculatorOpen = !_isCalculatorOpen;
          });
        },
        backgroundColor: const Color(0xFF1E1B4B),
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.calculate_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Import Card
                _buildImportCard(context),

                SizedBox(height: 5.h),

                // Footer Copyright Notice
                _buildFooter(),

                SizedBox(height: 8.h),
              ],
            ),
          ),

          // Floating Calculator Dialog
          if (_isCalculatorOpen)
            Positioned(
              right: 4.w,
              bottom: 9.h,
              child: CalculatorWidget(
                onClose: () {
                  setState(() {
                    _isCalculatorOpen = false;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }



  Widget _buildImportCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Section Label & Download Sample File Button
          _buildCardHeader(),

          SizedBox(height: 3.h),

          // Content Layout: Upload Box (Left) & Mapping Reference Table (Right)
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 760;

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Upload Drop Zone & Action Buttons
                    Expanded(
                      flex: 48,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDropZone(),
                          SizedBox(height: 2.h),
                          _buildActionButtons(),
                        ],
                      ),
                    ),

                    SizedBox(width: 2.5.w),

                    // Right Column: Field Mapping Rules Table
                    Expanded(
                      flex: 52,
                      child: _buildMappingTable(),
                    ),
                  ],
                );
              }

              // Stacked Layout for mobile / narrow viewports
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDropZone(),
                  SizedBox(height: 2.h),
                  _buildActionButtons(),
                  SizedBox(height: 3.h),
                  _buildMappingTable(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 1.5.h,
      spacing: 2.w,
      children: [
        Text(
          'Upload CSV or Excel File (.csv / .xlsx)',
          style: TextStyle(
            fontSize: 14.5.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF334155),
          ),
        ),
        Material(
          color: const Color(0xFFFFA043),
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: _handleSampleDownload,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.file_download_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 1.5.w),
                  Text(
                    'Download Sample File',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropZone() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isDraggingOver = true),
      onExit: (_) => setState(() => _isDraggingOver = false),
      child: InkWell(
        onTap: _handlePickFile,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 160),
          decoration: BoxDecoration(
            color: _isDraggingOver
                ? const Color(0xFFFFF7ED)
                : const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isDraggingOver
                  ? const Color(0xFFFFA043)
                  : const Color(0xFFCBD5E1),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Center(
            child: _selectedFileName == null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Cloud Upload Icon
                      const Icon(
                        Icons.cloud_upload_outlined,
                        color: Color(0xFFFFA043),
                        size: 42,
                      ),
                      SizedBox(height: 1.5.h),
                      Text(
                        'Drag and drop a CSV or Excel (.xlsx) file to upload',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Color(0xFF15803D),
                        size: 38,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        _selectedFileName!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      if (_selectedFileSizeKb != null) ...[
                        SizedBox(height: 0.5.h),
                        Text(
                          '${_selectedFileSizeKb} KB • Click to change file',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      children: [
        // Submit Button
        Material(
          color: const Color(0xFFFFA043),
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: _handleSubmit,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 11,
              ),
              child: Text(
                'Submit',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        // Cancel Button
        Material(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: _handleCancel,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 11,
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMappingTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Table(
        border: const TableBorder(
          horizontalInside: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1,
          ),
          verticalInside: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        columnWidths: const {
          0: FlexColumnWidth(4),
          1: FlexColumnWidth(6),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: _mappingRules.map((rule) {
          return TableRow(
            children: [
              // Field Name Cell
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Text(
                  rule.fieldName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
              // Mapping Rule Cell
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Text(
                  rule.mappingDescription,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: rule.descriptionColor,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        '© 2026 Copyright - Fablead Developers Technolab',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF64748B),
        ),
      ),
    );
  }
}
