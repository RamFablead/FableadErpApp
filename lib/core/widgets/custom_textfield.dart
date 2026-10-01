import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A premium custom text field widget matching modern design standards.
///
/// Features:
/// - Distinct top label with optional required mark (`*`).
/// - Outer rounded border container.
/// - Left prefix icon slot with brand accent (e.g. orange lock).
/// - Inner softly-tinted container holding the text field and suffix icon.
/// - Automatic password visibility toggle when [isPassword] is true.
/// - Integrated form validation and error message display.
/// - Full customization of colors, borders, controllers, and focus nodes.
class CustomTextField extends StatefulWidget {
  final String? label;
  final TextStyle? labelStyle;
  final bool isRequired;
  final String? hintText;
  final TextStyle? hintStyle;
  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool isPassword;
  final Widget? prefixIcon;
  final IconData? prefixIconData;
  final Color? prefixIconColor;
  final Widget? suffixIcon;
  final IconData? suffixIconData;
  final Color? suffixIconColor;
  final VoidCallback? onSuffixTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final bool readOnly;
  final bool enabled;
  final bool autofocus;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final Color? outerBorderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final Color? innerFillColor;
  final Color? backgroundColor;
  final double borderRadius;
  final double innerBorderRadius;
  final double height;
  final EdgeInsetsGeometry? contentPadding;
  final AutovalidateMode? autovalidateMode;

  const CustomTextField({
    super.key,
    this.label,
    this.labelStyle,
    this.isRequired = false,
    this.hintText,
    this.hintStyle,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.isPassword = false,
    this.prefixIcon,
    this.prefixIconData,
    this.prefixIconColor,
    this.suffixIcon,
    this.suffixIconData,
    this.suffixIconColor,
    this.onSuffixTap,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.outerBorderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.innerFillColor,
    this.backgroundColor,
    this.borderRadius = 10.0,
    this.innerBorderRadius = 8.0,
    this.height = 50.0,
    this.contentPadding,
    this.autovalidateMode,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;
  late FocusNode _focusNode;
  bool _isInternalFocusNode = false;
  bool _isFocused = false;
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword ? true : widget.obscureText;

    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _isInternalFocusNode = true;
    }
    _focusNode.addListener(_handleFocusChange);

    if (widget.controller == null && widget.initialValue != null) {
      _controller = TextEditingController(text: widget.initialValue);
    }
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      if (_isInternalFocusNode) {
        _focusNode.removeListener(_handleFocusChange);
        _focusNode.dispose();
        _isInternalFocusNode = false;
      }
      if (widget.focusNode != null) {
        _focusNode = widget.focusNode!;
      } else {
        _focusNode = FocusNode();
        _isInternalFocusNode = true;
      }
      _focusNode.addListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (_isInternalFocusNode) {
      _focusNode.dispose();
    }
    _controller?.dispose();
    super.dispose();
  }

  TextEditingController get _effectiveController =>
      widget.controller ?? _controller ?? TextEditingController();

  Widget? _buildPrefixIcon() {
    if (widget.prefixIcon != null) {
      return widget.prefixIcon;
    }
    if (widget.prefixIconData != null) {
      return Icon(
        widget.prefixIconData,
        size: 20,
        color: widget.prefixIconColor ?? const Color(0xFFF58220),
      );
    }
    return null;
  }

  Widget? _buildSuffixIcon() {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 20,
          color: widget.suffixIconColor ?? const Color(0xFF8F9CAE),
        ),
        splashRadius: 18,
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    if (widget.suffixIcon != null) {
      return widget.suffixIcon;
    }

    if (widget.suffixIconData != null) {
      return IconButton(
        icon: Icon(
          widget.suffixIconData,
          size: 20,
          color: widget.suffixIconColor ?? const Color(0xFF8F9CAE),
        ),
        splashRadius: 18,
        onPressed: widget.onSuffixTap,
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final prefixWidget = _buildPrefixIcon();
    final suffixWidget = _buildSuffixIcon();

    final Color effectiveOuterBorderColor = widget.outerBorderColor ?? const Color(0xFFD6E2EC);
    final Color effectiveFocusedBorderColor = widget.focusedBorderColor ?? const Color(0xFF3B82F6);
    final Color effectiveErrorBorderColor = widget.errorBorderColor ?? const Color(0xFFEF4444);
    final Color effectiveInnerFillColor = widget.innerFillColor ?? const Color(0xFFEEF4FA);
    final Color effectiveBackgroundColor = widget.backgroundColor ?? Colors.white;

    return FormField<String>(
      initialValue: _effectiveController.text,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      builder: (FormFieldState<String> field) {
        final bool hasError = field.hasError;

        Color currentBorderColor;
        if (hasError) {
          currentBorderColor = effectiveErrorBorderColor;
        } else if (_isFocused) {
          currentBorderColor = effectiveFocusedBorderColor;
        } else {
          currentBorderColor = effectiveOuterBorderColor;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Label section
            if (widget.label != null && widget.label!.isNotEmpty) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label!,
                    style: widget.labelStyle ??
                        const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                          letterSpacing: -0.2,
                        ),
                  ),
                  if (widget.isRequired) ...[
                    const SizedBox(width: 4),
                    const Text(
                      '*',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Input Container matching the reference design
            Container(
              height: widget.maxLines > 1 ? null : widget.height,
              constraints: widget.maxLines > 1
                  ? BoxConstraints(minHeight: widget.height)
                  : null,
              decoration: BoxDecoration(
                color: effectiveBackgroundColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: currentBorderColor,
                  width: _isFocused || hasError ? 1.5 : 1.2,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                crossAxisAlignment: widget.maxLines > 1
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  // Prefix Icon (e.g. orange lock)
                  if (prefixWidget != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: prefixWidget,
                    ),

                  // Inner soft-colored container housing the input & suffix
                  Expanded(
                    child: Container(
                      height: widget.maxLines > 1 ? null : double.infinity,
                      decoration: BoxDecoration(
                        color: effectiveInnerFillColor,
                        borderRadius: BorderRadius.circular(widget.innerBorderRadius),
                      ),
                      padding: widget.contentPadding ??
                          const EdgeInsets.symmetric(horizontal: 12.0),
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _effectiveController,
                              focusNode: _focusNode,
                              obscureText: _obscureText,
                              obscuringCharacter: '•',
                              keyboardType: widget.keyboardType,
                              textInputAction: widget.textInputAction,
                              readOnly: widget.readOnly,
                              enabled: widget.enabled,
                              autofocus: widget.autofocus,
                              maxLines: widget.maxLines,
                              minLines: widget.minLines,
                              maxLength: widget.maxLength,
                              inputFormatters: widget.inputFormatters,
                              style: const TextStyle(
                                fontSize: 14.5,
                                color: Color(0xFF1E293B),
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                hintText: widget.hintText,
                                hintStyle: widget.hintStyle ??
                                    const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF94A3B8),
                                      fontWeight: FontWeight.w400,
                                    ),
                                counterText: '',
                              ),
                              onChanged: (val) {
                                field.didChange(val);
                                if (widget.onChanged != null) {
                                  widget.onChanged!(val);
                                }
                              },
                              onSubmitted: widget.onSubmitted,
                            ),
                          ),
                          ?suffixWidget,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Validation error display
            if (hasError && field.errorText != null) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text(
                  field.errorText!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
