import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/widgets/calculator_widget.dart';

/// Screen for creating a new brand in the ERP catalog setup.
class AddBrandsScreen extends StatefulWidget {
  const AddBrandsScreen({super.key});

  @override
  State<AddBrandsScreen> createState() => _AddBrandsScreenState();
}

class _AddBrandsScreenState extends State<AddBrandsScreen> {
  final TextEditingController _brandNameController = TextEditingController();
  final TextEditingController _brandEmailController = TextEditingController();
  final TextEditingController _brandPhoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isCalculatorOpen = false;
  String? _selectedFileName;
  int? _selectedFileSizeKb;
  bool _isDraggingOver = false;

  @override
  void dispose() {
    _brandNameController.dispose();
    _brandEmailController.dispose();
    _brandPhoneController.dispose();
    super.dispose();
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
                'Select Brand Logo or Image',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 1.5.h),
              ListTile(
                leading: const Icon(
                  Icons.image_outlined,
                  color: Color(0xFFFFA043),
                  size: 28,
                ),
                title: Text(
                  'brand_logo.png',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                subtitle: Text(
                  'PNG Image • 95 KB',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _selectedFileName = 'brand_logo.png';
                    _selectedFileSizeKb = 95;
                  });
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.image_outlined,
                  color: Color(0xFF0284C7),
                  size: 28,
                ),
                title: Text(
                  'brand_icon.svg',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                subtitle: Text(
                  'Vector Graphic • 34 KB',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _selectedFileName = 'brand_icon.svg';
                    _selectedFileSizeKb = 34;
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

    final brandName = _brandNameController.text.trim();
    if (brandName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a brand name.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
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
              'Brand Saved',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Text(
          'Brand "$brandName" has been created successfully.',
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
              _brandNameController.clear();
              _brandEmailController.clear();
              _brandPhoneController.clear();
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
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final hasInputs = _brandNameController.text.isNotEmpty ||
        _brandEmailController.text.isNotEmpty ||
        _brandPhoneController.text.isNotEmpty ||
        _selectedFileName != null;

    if (hasInputs) {
      _brandNameController.clear();
      _brandEmailController.clear();
      _brandPhoneController.clear();
      setState(() {
        _selectedFileName = null;
        _selectedFileSizeKb = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Form inputs cleared.',
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
    // Note: SafeArea is intentionally omitted per requirements.
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
                SizedBox(height: 2.h),

                // Top Header: Title & Back Button
                _buildHeader(context),

                SizedBox(height: 2.5.h),

                // Main Form Card
                _buildFormCard(context),

                SizedBox(height: 6.h),

                // Footer Copyright
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Add Brand',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        Material(
          color: const Color(0xFFFFA043),
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
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
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'Back',
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

  Widget _buildFormCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand Name Label with Red Asterisk
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Brand Name',
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                  ),
                ),
                SizedBox(width: 1.w),
                Text(
                  '*',
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),

            // Brand Name Input Field
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Center(
                child: TextField(
                  controller: _brandNameController,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF1E293B),
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),

            SizedBox(height: 2.5.h),

            // Email and Phone row (Side by side on wider screens, stacked on mobile)
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 600;

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand Email (Optional)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Brand Email (Optional)',
                              style: TextStyle(
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF334155),
                              ),
                            ),
                            SizedBox(height: 1.h),
                            _buildInputField(
                              controller: _brandEmailController,
                              hintText: 'e.g. brand@example.com',
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 2.w),
                      // Brand Phone (Optional)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Brand Phone (Optional)',
                              style: TextStyle(
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF334155),
                              ),
                            ),
                            SizedBox(height: 1.h),
                            _buildInputField(
                              controller: _brandPhoneController,
                              hintText: 'e.g. 9876543210',
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                // Stacked layout for narrower screens
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Brand Email (Optional)',
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    _buildInputField(
                      controller: _brandEmailController,
                      hintText: 'e.g. brand@example.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Brand Phone (Optional)',
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    _buildInputField(
                      controller: _brandPhoneController,
                      hintText: 'e.g. 9876543210',
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                );
              },
            ),

            SizedBox(height: 2.5.h),

            // Brand Image Label
            Text(
              'Brand Image',
              style: TextStyle(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            SizedBox(height: 1.h),

            // Image Upload Drop Zone
            _buildImageDropZone(),

            SizedBox(height: 3.h),

            // Action Buttons: Submit & Cancel
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Center(
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF1E293B),
          ),
          decoration: InputDecoration(
            isDense: true,
            border: InputBorder.none,
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF94A3B8),
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildImageDropZone() {
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
                      // Cloud Upload Icon with Arrow
                      const Icon(
                        Icons.cloud_upload_outlined,
                        color: Color(0xFFFFA043),
                        size: 42,
                      ),
                      SizedBox(height: 1.5.h),
                      Text(
                        'Drag and drop a file to upload',
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
                        Icons.image_outlined,
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
                          '${_selectedFileSizeKb} KB • Click to change image',
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
      spacing: 14,
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
                horizontal: 32,
                vertical: 12,
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
                horizontal: 32,
                vertical: 12,
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
