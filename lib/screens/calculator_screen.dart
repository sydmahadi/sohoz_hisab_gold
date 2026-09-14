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
        // পরপর দুটি অপারেটর ইনপুট দেওয়া প্রতিরোধ
        if (_isOperator(value) && _input.isNotEmpty) {
          String lastChar = _input[_input.length - 1];
          if (_isOperator(lastChar)) {
            _input = _input.substring(0, _input.length - 1) + value;
            return;
          }
        }
        _input += value;
      }
    });
  }

  bool _isOperator(String ch) {
    return ch == '+' || ch == '-' || ch == '×' || ch == '÷' || ch == '%';
  }

  void _calculateResult() {
    if (_input.isEmpty) return;
    try {
      String finalInput = _input.replaceAll('×', '*').replaceAll('÷', '/');
      double calculated = _evaluateMath(finalInput);

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

  // গাণিতিক সমীকরণ সঠিকভাবে সমাধান করার এলগরিদম
  double _evaluateMath(String expression) {
    List<String> tokens = [];
    String numberBuffer = '';

    for (int i = 0; i < expression.length; i++) {
      String char = expression[i];
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
    if (numberBuffer.isNotEmpty) tokens.add(numberBuffer);

    if (tokens.isEmpty) return 0;

    // ১ম ধাপ: পার্সেন্টেজ (%) হ্যান্ডেল করা (সংখ্যা/১০০)
    List<String> pass1 = [];
    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i] == '%') {
        if (pass1.isNotEmpty) {
          double prevNum = double.tryParse(pass1.removeLast()) ?? 0;
          pass1.add((prevNum / 100).toString());
        }
      } else {
        pass1.add(tokens[i]);
      }
    }

    // ২য় ধাপ: গুণ (*) এবং ভাগ (/) সমাধান করা
    List<String> pass2 = [];
    int i = 0;
    while (i < pass1.length) {
      if (pass1[i] == '*' || pass1[i] == '/') {
        String op = pass1[i];
        double prev = double.tryParse(pass2.removeLast()) ?? 0;
        double next = double.tryParse(pass1[i + 1]) ?? 0;
        double eval = 0;
        if (op == '*') eval = prev * next;
        if (op == '/') eval = next != 0 ? prev / next : double.nan;
        pass2.add(eval.toString());
        i += 2;
      } else {
        pass2.add(pass1[i]);
        i++;
      }
    }

    // ৩য় ধাপ: যোগ (+) এবং বিয়োগ (-) সমাধান করা
    if (pass2.isEmpty) return 0;
    double result = double.tryParse(pass2[0]) ?? 0;
    int j = 1;
    while (j < pass2.length) {
      String op = pass2[j];
      double next = double.tryParse(pass2[j + 1]) ?? 0;
      if (op == '+') result += next;
      if (op == '-') result -= next;
      j += 2;
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> buttons = [
      'C', '÷', '×', '⌫',
      '7', '8', '9', '-',
      '4', '5', '6', '+',
      '1', '2', '3', '%',
      '00', '0', '.', '='
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('ক্যালকুলেটর'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ডিসপ্লে পার্ট
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.gold.withValues(alpha: 0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        _input.isEmpty ? '0' : _input,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 26,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        _result,
                        style: const TextStyle(
                          color: AppTheme.goldLight,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // কিপ্যাড পার্ট
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: buttons.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.15,
                  ),
                  itemBuilder: (context, index) {
                    final btn = buttons[index];

                    bool isOperator = ['÷', '×', '-', '+', '%'].contains(btn);
                    bool isEqual = btn == '=';
                    bool isClear = ['C', '⌫'].contains(btn);

                    Color btnBg = AppTheme.cardLight;
                    Color textColor = AppTheme.textDark;

                    if (isEqual) {
                      btnBg = AppTheme.gold;
                      textColor = Colors.black;
                    } else if (isOperator) {
                      btnBg = AppTheme.primaryLight;
                      textColor = AppTheme.goldLight;
                    } else if (isClear) {
                      btnBg = AppTheme.danger.withValues(alpha: 0.85);
                      textColor = Colors.white;
                    }

                    return Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: () => _onButtonPressed(btn),
                        borderRadius: BorderRadius.circular(16),
                        splashColor: AppTheme.gold.withValues(alpha: 0.25),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: btnBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isOperator || isEqual
                                  ? AppTheme.gold
                                  : AppTheme.gold.withValues(alpha: 0.25),
                              width: isOperator || isEqual ? 1 : 0.6,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              btn,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
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
