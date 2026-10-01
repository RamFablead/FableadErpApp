import 'package:flutter/material.dart';

/// Available button styles for [CustomButton].
enum CustomButtonType {
  primary,
  outlined,
}

/// A custom, highly reusable button widget matching the application's design system.
///
/// Supports:
/// - **Primary filled button**: Vibrant orange with a soft glow shadow, white text, and optional trailing/leading icon.
/// - **Outlined button**: Pill-shaped with subtle light-blue/gray border, white fill, dark navy text, and optional leading/trailing icon.
/// - **Loading state**: Integrated spinner when [isLoading] is true.
/// - **Stadium / Rounded border**: Pill-shaped by default (stadium border).
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonType type;
  final bool isLoading;
  final bool enabled;
  final double? width;
  final double height;
  final double borderRadius;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final Color? shadowColor;
  final Widget? prefixIcon;
  final IconData? prefixIconData;
  final Color? prefixIconColor;
  final double prefixIconSize;
  final Widget? suffixIcon;
  final IconData? suffixIconData;
  final Color? suffixIconColor;
  final double suffixIconSize;
  final double gap;
  final bool showShadow;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = CustomButtonType.primary,
    this.isLoading = false,
    this.enabled = true,
    this.width = double.infinity,
    this.height = 50.0,
    this.borderRadius = 28.0,
    this.textStyle,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.shadowColor,
    this.prefixIcon,
    this.prefixIconData,
    this.prefixIconColor,
    this.prefixIconSize = 20.0,
    this.suffixIcon,
    this.suffixIconData,
    this.suffixIconColor,
    this.suffixIconSize = 20.0,
    this.gap = 8.0,
    this.showShadow = true,
  });

  /// Factory constructor for Primary Filled Button (e.g. "Sign In ->]")
  const factory CustomButton.primary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading,
    bool enabled,
    double? width,
    double height,
    double borderRadius,
    TextStyle? textStyle,
    Color? backgroundColor,
    Color? textColor,
    Color? shadowColor,
    Widget? prefixIcon,
    IconData? prefixIconData,
    Color? prefixIconColor,
    double prefixIconSize,
    Widget? suffixIcon,
    IconData? suffixIconData,
    Color? suffixIconColor,
    double suffixIconSize,
    double gap,
    bool showShadow,
  }) = _PrimaryCustomButton;

  /// Factory constructor for Outlined Button (e.g. "Login with Face")
  const factory CustomButton.outlined({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading,
    bool enabled,
    double? width,
    double height,
    double borderRadius,
    TextStyle? textStyle,
    Color? backgroundColor,
    Color? textColor,
    Color? borderColor,
    Widget? prefixIcon,
    IconData? prefixIconData,
    Color? prefixIconColor,
    double prefixIconSize,
    Widget? suffixIcon,
    IconData? suffixIconData,
    Color? suffixIconColor,
    double suffixIconSize,
    double gap,
  }) = _OutlinedCustomButton;

  bool get _isInteractive => enabled && !isLoading && onPressed != null;

  Widget? _buildPrefixIcon(Color defaultColor) {
    if (prefixIcon != null) return prefixIcon;
    if (prefixIconData != null) {
      return Icon(
        prefixIconData,
        size: prefixIconSize,
        color: prefixIconColor ?? defaultColor,
      );
    }
    return null;
  }

  Widget? _buildSuffixIcon(Color defaultColor) {
    if (suffixIcon != null) return suffixIcon;
    if (suffixIconData != null) {
      return Icon(
        suffixIconData,
        size: suffixIconSize,
        color: suffixIconColor ?? defaultColor,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool isPrimary = type == CustomButtonType.primary;

    // Default primary orange: #FFA043 / #FF9636
    const primaryOrange = Color(0xFFFFA043);
    const darkNavyText = Color(0xFF1E293B);
    const defaultBorder = Color(0xFFD6E2EC);

    // Resolved colors
    final Color effectiveBgColor = backgroundColor ??
        (isPrimary ? primaryOrange : Colors.white);

    final Color effectiveTextColor = textColor ??
        (isPrimary ? Colors.white : darkNavyText);

    final Color effectiveBorderColor = borderColor ?? defaultBorder;

    final Color effectiveShadowColor = shadowColor ??
        (isPrimary ? const Color(0x4DFFA043) : Colors.transparent);

    final Widget? leadingWidget = _buildPrefixIcon(
      isPrimary ? Colors.white : primaryOrange,
    );
    final Widget? trailingWidget = _buildSuffixIcon(
      isPrimary ? Colors.white : darkNavyText,
    );

    final BoxBorder? boxBorder = isPrimary
        ? null
        : Border.all(color: effectiveBorderColor, width: 1.2);

    final List<BoxShadow>? shadows = (isPrimary && showShadow && _isInteractive)
        ? [
            BoxShadow(
              color: effectiveShadowColor,
              blurRadius: 16.0,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
          ]
        : null;

    return Opacity(
      opacity: _isInteractive ? 1.0 : 0.6,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: effectiveBgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: boxBorder,
          boxShadow: shadows,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isInteractive ? onPressed : null,
            borderRadius: BorderRadius.circular(borderRadius),
            splashColor: isPrimary
                ? Colors.white.withValues(alpha: 0.2)
                : primaryOrange.withValues(alpha: 0.1),
            highlightColor: isPrimary
                ? Colors.black.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.02),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            effectiveTextColor,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ?leadingWidget,
                          if (leadingWidget != null) SizedBox(width: gap),
                          Text(
                            text,
                            style: textStyle ??
                                TextStyle(
                                  color: effectiveTextColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                          ),
                          if (trailingWidget != null) SizedBox(width: gap),
                          ?trailingWidget,
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryCustomButton extends CustomButton {
  const _PrimaryCustomButton({
    super.key,
    required super.text,
    super.onPressed,
    super.isLoading,
    super.enabled,
    super.width,
    super.height,
    super.borderRadius,
    super.textStyle,
    super.backgroundColor,
    super.textColor,
    super.shadowColor,
    super.prefixIcon,
    super.prefixIconData,
    super.prefixIconColor,
    super.prefixIconSize,
    super.suffixIcon,
    super.suffixIconData,
    super.suffixIconColor,
    super.suffixIconSize,
    super.gap,
    super.showShadow,
  }) : super(type: CustomButtonType.primary);
}

class _OutlinedCustomButton extends CustomButton {
  const _OutlinedCustomButton({
    super.key,
    required super.text,
    super.onPressed,
    super.isLoading,
    super.enabled,
    super.width,
    super.height,
    super.borderRadius,
    super.textStyle,
    super.backgroundColor,
    super.textColor,
    super.borderColor,
    super.prefixIcon,
    super.prefixIconData,
    super.prefixIconColor,
    super.prefixIconSize,
    super.suffixIcon,
    super.suffixIconData,
    super.suffixIconColor,
    super.suffixIconSize,
    super.gap,
  }) : super(type: CustomButtonType.outlined, showShadow: false);
}
