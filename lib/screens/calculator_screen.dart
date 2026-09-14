import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _input = '';
  String _result = '0';

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _input = '';
        _result = '0';
      } else if (value == '⌫') {
        if (_input.isNotEmpty) {
          _input = _input.substring(0, _input.length - 1);
        }
      } else if (value == '=') {
        _calculateResult();
      } else {
        if (_isOperator(value) && _input.isNotEmpty) {
          final lastChar = _input[_input.length - 1];

          if (_isOperator(lastChar)) {
            _input =
                _input.substring(0, _input.length - 1) + value;
            return;
          }
        }

        _input += value;
      }
    });
  }

  bool _isOperator(String ch) {
    return ch == '+' ||
        ch == '-' ||
        ch == '×' ||
        ch == '÷' ||
        ch == '%';
  }

  void _calculateResult() {
    if (_input.isEmpty) return;

    try {
      final finalInput = _input
          .replaceAll('×', '*')
          .replaceAll('÷', '/');

      final calculated = _evaluateMath(finalInput);

      if (calculated.isNaN || calculated.isInfinite) {
        _result = 'ত্রুটি';
      } else if (calculated % 1 == 0) {
        _result = calculated.toInt().toString();
      } else {
        _result = calculated
            .toStringAsFixed(4)
            .replaceAll(RegExp(r'0+$'), '')
            .replaceAll(RegExp(r'\.$'), '');
      }
    } catch (e) {
      _result = 'ত্রুটি';
    }
  }

  double _evaluateMath(String expression) {
    final List<String> tokens = [];
    String numberBuffer = '';

    for (int i = 0; i < expression.length; i++) {
      final char = expression[i];

      if ('+-*/%'.contains(char)) {
        if (numberBuffer.isNotEmpty) {
          tokens.add(numberBuffer);
          numberBuffer = '';
        }

        tokens.add(char);
      } else {
        numberBuffer += char;
      }
    }

    if (numberBuffer.isNotEmpty) {
      tokens.add(numberBuffer);
    }

    if (tokens.isEmpty) return 0;

    // Percentage calculation
    final List<String> pass1 = [];

    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i] == '%') {
        if (pass1.isNotEmpty) {
          final prevNum =
              double.tryParse(pass1.removeLast()) ?? 0;

          pass1.add((prevNum / 100).toString());
        }
      } else {
        pass1.add(tokens[i]);
      }
    }

    // Multiplication and division
    final List<String> pass2 = [];
    int i = 0;

    while (i < pass1.length) {
      if (pass1[i] == '*' || pass1[i] == '/') {
        final op = pass1[i];

        final prev =
            double.tryParse(pass2.removeLast()) ?? 0;

        final next =
            double.tryParse(pass1[i + 1]) ?? 0;

        double eval = 0;

        if (op == '*') {
          eval = prev * next;
        }

        if (op == '/') {
          eval = next != 0 ? prev / next : double.nan;
        }

        pass2.add(eval.toString());
        i += 2;
      } else {
        pass2.add(pass1[i]);
        i++;
      }
    }

    // Addition and subtraction
    if (pass2.isEmpty) return 0;

    double result =
        double.tryParse(pass2[0]) ?? 0;

    int j = 1;

    while (j < pass2.length) {
      final op = pass2[j];
      final next =
          double.tryParse(pass2[j + 1]) ?? 0;

      if (op == '+') {
        result += next;
      }

      if (op == '-') {
        result -= next;
      }

      j += 2;
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = AppTheme.isDark;

    // =========================
    // MODE BASED COLORS
    // =========================

    final Color screenBackground =
        AppTheme.background;

    final Color displayBackground =
        isDark
            ? AppTheme.cardColor
            : Colors.white;

    final Color displayInputColor =
        isDark
            ? AppTheme.textMuted
            : const Color(0xFF555555);

    final Color displayResultColor =
        isDark
            ? AppTheme.goldLight
            : const Color(0xFF0F5132);

    final Color numberButtonBackground =
        isDark
            ? AppTheme.cardLight
            : const Color(0xFFF1F3F2);

    final Color numberTextColor =
        isDark
            ? AppTheme.textDark
            : const Color(0xFF17201C);

    final Color operatorButtonBackground =
        isDark
            ? AppTheme.primaryLight
            : const Color(0xFFE4EFEA);

    final Color operatorTextColor =
        isDark
            ? AppTheme.goldLight
            : const Color(0xFF0F5132);

    final Color borderColor =
        isDark
            ? AppTheme.gold.withValues(alpha: 0.25)
            : const Color(0xFFB8C8C0);

    final List<String> buttons = [
      'C',
      '÷',
      '×',
      '⌫',
      '7',
      '8',
      '9',
      '-',
      '4',
      '5',
      '6',
      '+',
      '1',
      '2',
      '3',
      '%',
      '00',
      '0',
      '.',
      '=',
    ];

    return Scaffold(
      backgroundColor: screenBackground,

      appBar: AppBar(
        title: const Text('ক্যালকুলেটর'),
      ),

      body: SafeArea(
        child: Column(
          children: [

            // =========================
            // DISPLAY
            // =========================

            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  12,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),

                decoration: BoxDecoration(
                  color: displayBackground,
                  borderRadius:
                      BorderRadius.circular(24),

                  border: Border.all(
                    color: isDark
                        ? AppTheme.gold.withValues(
                            alpha: 0.5,
                          )
                        : const Color(0xFFB7C8BE),
                    width: 1,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.3 : 0.10,
                      ),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.end,

                  crossAxisAlignment:
                      CrossAxisAlignment.end,

                  children: [

                    // Input
                    SingleChildScrollView(
                      scrollDirection:
                          Axis.horizontal,
                      reverse: true,

                      child: Text(
                        _input.isEmpty
                            ? '0'
                            : _input,

                        style: TextStyle(
                          color:
                              displayInputColor,
                          fontSize: 26,
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Result
                    SingleChildScrollView(
                      scrollDirection:
                          Axis.horizontal,
                      reverse: true,

                      child: Text(
                        _result,

                        style: TextStyle(
                          color:
                              displayResultColor,
                          fontSize: 40,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // =========================
            // KEYPAD
            // =========================

            Expanded(
              flex: 6,

              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  16,
                ),

                child: GridView.builder(
                  physics:
                      const NeverScrollableScrollPhysics(),

                  itemCount: buttons.length,

                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.15,
                  ),

                  itemBuilder:
                      (context, index) {

                    final String btn =
                        buttons[index];

                    final bool isOperator = [
                      '÷',
                      '×',
                      '-',
                      '+',
                      '%',
                    ].contains(btn);

                    final bool isEqual =
                        btn == '=';

                    final bool isClear = [
                      'C',
                      '⌫',
                    ].contains(btn);

                    Color btnBg =
                        numberButtonBackground;

                    Color textColor =
                        numberTextColor;

                    Color btnBorder =
                        borderColor;

                    // =====================
                    // EQUAL BUTTON
                    // =====================

                    if (isEqual) {
                      btnBg = AppTheme.gold;
                      textColor = Colors.black;
                      btnBorder =
                          AppTheme.gold;
                    }

                    // =====================
                    // OPERATOR BUTTON
                    // =====================

                    else if (isOperator) {
                      btnBg =
                          operatorButtonBackground;
                      textColor =
                          operatorTextColor;
                      btnBorder =
                          isDark
                              ? AppTheme.gold
                              : const Color(
                                  0xFF8EAF9F,
                                );
                    }

                    // =====================
                    // CLEAR BUTTON
                    // =====================

                    else if (isClear) {
                      btnBg = isDark
                          ? AppTheme.danger
                              .withValues(
                              alpha: 0.85,
                            )
                          : const Color(
                              0xFFFFE6E4,
                            );

                      textColor = isDark
                          ? Colors.white
                          : const Color(
                              0xFFB3261E,
                            );

                      btnBorder = isDark
                          ? AppTheme.danger
                          : const Color(
                              0xFFE0AAA6,
                            );
                    }

                    return Material(
                      color: Colors.transparent,

                      borderRadius:
                          BorderRadius.circular(16),

                      child: InkWell(
                        onTap: () =>
                            _onButtonPressed(btn),

                        borderRadius:
                            BorderRadius.circular(16),

                        splashColor:
                            AppTheme.gold
                                .withValues(
                          alpha: 0.25,
                        ),

                        child: Ink(
                          decoration:
                              BoxDecoration(
                            color: btnBg,

                            borderRadius:
                                BorderRadius
                                    .circular(16),

                            border: Border.all(
                              color: btnBorder,
                              width:
                                  isOperator ||
                                          isEqual
                                      ? 1
                                      : 0.6,
                            ),

                            boxShadow: [
                              if (!isDark)
                                BoxShadow(
                                  color: Colors.black
                                      .withValues(
                                    alpha: 0.06,
                                  ),
                                  blurRadius: 5,
                                  offset:
                                      const Offset(
                                    0,
                                    3,
                                  ),
                                ),
                            ],
                          ),

                          child: Center(
                            child: Text(
                              btn,

                              style: TextStyle(
                                color: textColor,
                                fontSize: 22,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
