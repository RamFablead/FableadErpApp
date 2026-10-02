import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// A full-featured interactive calculator matching the ERP design specification.
class CalculatorWidget extends StatefulWidget {
  final VoidCallback onClose;

  const CalculatorWidget({
    super.key,
    required this.onClose,
  });

  @override
  State<CalculatorWidget> createState() => _CalculatorWidgetState();
}

class _CalculatorWidgetState extends State<CalculatorWidget> {
  String _display = '0';
  double? _firstOperand;
  String? _operator;
  bool _shouldResetDisplay = false;

  void _onDigitPressed(String digit) {
    setState(() {
      if (_display == '0' || _shouldResetDisplay) {
        _display = digit;
        _shouldResetDisplay = false;
      } else {
        if (_display.length < 12) {
          _display += digit;
        }
      }
    });
  }

  void _onDecimalPressed() {
    setState(() {
      if (_shouldResetDisplay) {
        _display = '0.';
        _shouldResetDisplay = false;
      } else if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  void _onOperatorPressed(String op) {
    setState(() {
      if (_firstOperand != null && _operator != null && !_shouldResetDisplay) {
        _calculateResult();
      }
      _firstOperand = double.tryParse(_display);
      _operator = op;
      _shouldResetDisplay = true;
    });
  }

  void _onPercentagePressed() {
    setState(() {
      final val = double.tryParse(_display);
      if (val != null) {
        final result = val / 100;
        _display = _formatNumber(result);
      }
    });
  }

  void _onClearPressed() {
    setState(() {
      _display = '0';
      _firstOperand = null;
      _operator = null;
      _shouldResetDisplay = false;
    });
  }

  void _onBackspacePressed() {
    setState(() {
      if (_shouldResetDisplay) {
        _display = '0';
        _shouldResetDisplay = false;
        return;
      }
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = '0';
      }
    });
  }

  void _onEqualsPressed() {
    setState(() {
      if (_firstOperand != null && _operator != null) {
        _calculateResult();
        _firstOperand = null;
        _operator = null;
        _shouldResetDisplay = true;
      }
    });
  }

  void _calculateResult() {
    final secondOperand = double.tryParse(_display);
    if (_firstOperand == null || secondOperand == null || _operator == null) return;

    double result = 0;
    switch (_operator) {
      case '+':
        result = _firstOperand! + secondOperand;
        break;
      case '-':
        result = _firstOperand! - secondOperand;
        break;
      case '*':
        result = _firstOperand! * secondOperand;
        break;
      case '/':
        if (secondOperand == 0) {
          _display = 'Error';
          return;
        }
        result = _firstOperand! / secondOperand;
        break;
    }
    _display = _formatNumber(result);
  }

  String _formatNumber(double num) {
    if (num.isNaN || num.isInfinite) return 'Error';
    if (num == num.roundToDouble()) {
      return num.toInt().toString();
    }
    String str = num.toStringAsFixed(4);
    while (str.contains('.') && (str.endsWith('0') || str.endsWith('.'))) {
      str = str.substring(0, str.length - 1);
    }
    return str;
  }

  @override
  Widget build(BuildContext context) {
    const Color headerBlue = Color(0xFF1E88E5);
    const Color clearGray = Color(0xFF64748B);
    const Color operatorCyan = Color(0xFF00C3F8);
    const Color equalsOrange = Color(0xFFFFA043);
    const Color digitBg = Colors.white;
    const Color digitBorder = Color(0xFFE2E8F0);
    const Color digitText = Color(0xFF0F172A);

    return Container(
      width: 290,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 18,
            offset: Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Blue Header: Icon, "Calculator" title, Close Button
          Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              color: headerBlue,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calculate_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Calculator',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: widget.onClose,
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Display Screen
                Container(
                  height: 52,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(
                      _display,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Calculator Keypad Grid
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left 3 columns
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Row 1: C, Backspace, /
                          Row(
                            children: [
                              Expanded(
                                child: _buildButton(
                                  label: 'C',
                                  bgColor: clearGray,
                                  textColor: Colors.white,
                                  onTap: _onClearPressed,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildIconButton(
                                  icon: Icons.backspace_outlined,
                                  bgColor: clearGray,
                                  iconColor: Colors.white,
                                  onTap: _onBackspacePressed,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildButton(
                                  label: '/',
                                  bgColor: operatorCyan,
                                  textColor: Colors.white,
                                  onTap: () => _onOperatorPressed('/'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Row 2: 7, 8, 9
                          Row(
                            children: [
                              Expanded(
                                child: _buildButton(
                                  label: '7',
                                  bgColor: digitBg,
                                  borderColor: digitBorder,
                                  textColor: digitText,
                                  onTap: () => _onDigitPressed('7'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildButton(
                                  label: '8',
                                  bgColor: digitBg,
                                  borderColor: digitBorder,
                                  textColor: digitText,
                                  onTap: () => _onDigitPressed('8'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildButton(
                                  label: '9',
                                  bgColor: digitBg,
                                  borderColor: digitBorder,
                                  textColor: digitText,
                                  onTap: () => _onDigitPressed('9'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Row 3: 4, 5, 6
                          Row(
                            children: [
                              Expanded(
                                child: _buildButton(
                                  label: '4',
                                  bgColor: digitBg,
                                  borderColor: digitBorder,
                                  textColor: digitText,
                                  onTap: () => _onDigitPressed('4'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildButton(
                                  label: '5',
                                  bgColor: digitBg,
                                  borderColor: digitBorder,
                                  textColor: digitText,
                                  onTap: () => _onDigitPressed('5'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildButton(
                                  label: '6',
                                  bgColor: digitBg,
                                  borderColor: digitBorder,
                                  textColor: digitText,
                                  onTap: () => _onDigitPressed('6'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Row 4: 1, 2, 3
                          Row(
                            children: [
                              Expanded(
                                child: _buildButton(
                                  label: '1',
                                  bgColor: digitBg,
                                  borderColor: digitBorder,
                                  textColor: digitText,
                                  onTap: () => _onDigitPressed('1'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildButton(
                                  label: '2',
                                  bgColor: digitBg,
                                  borderColor: digitBorder,
                                  textColor: digitText,
                                  onTap: () => _onDigitPressed('2'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildButton(
                                  label: '3',
                                  bgColor: digitBg,
                                  borderColor: digitBorder,
                                  textColor: digitText,
                                  onTap: () => _onDigitPressed('3'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Row 5: 0, ., %
                          Row(
                            children: [
                              Expanded(
                                child: _buildButton(
                                  label: '0',
                                  bgColor: digitBg,
                                  borderColor: digitBorder,
                                  textColor: digitText,
                                  onTap: () => _onDigitPressed('0'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildButton(
                                  label: '.',
                                  bgColor: digitBg,
                                  borderColor: digitBorder,
                                  textColor: digitText,
                                  onTap: _onDecimalPressed,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildButton(
                                  label: '%',
                                  bgColor: operatorCyan,
                                  textColor: Colors.white,
                                  onTap: _onPercentagePressed,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Rightmost column: *, -, +, and tall =
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildButton(
                            label: '*',
                            bgColor: operatorCyan,
                            textColor: Colors.white,
                            onTap: () => _onOperatorPressed('*'),
                          ),
                          const SizedBox(height: 8),
                          _buildButton(
                            label: '-',
                            bgColor: operatorCyan,
                            textColor: Colors.white,
                            onTap: () => _onOperatorPressed('-'),
                          ),
                          const SizedBox(height: 8),
                          _buildButton(
                            label: '+',
                            bgColor: operatorCyan,
                            textColor: Colors.white,
                            onTap: () => _onOperatorPressed('+'),
                          ),
                          const SizedBox(height: 8),
                          // Tall equals button
                          _buildButton(
                            label: '=',
                            bgColor: equalsOrange,
                            textColor: Colors.white,
                            height: 94,
                            onTap: _onEqualsPressed,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required Color bgColor,
    Color? borderColor,
    required Color textColor,
    required VoidCallback onTap,
    double height = 43,
  }) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: borderColor != null ? Border.all(color: borderColor) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color bgColor,
    Color? borderColor,
    required Color iconColor,
    required VoidCallback onTap,
    double height = 43,
  }) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: borderColor != null ? Border.all(color: borderColor) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Center(
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
