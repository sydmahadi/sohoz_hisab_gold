import 'package:flutter/material.dart';

import '../logic/calculator_logic.dart';
import '../models/calculator_model.dart';
import '../theme/app_theme.dart';

class MonthlyAverageScreen extends StatefulWidget {
  const MonthlyAverageScreen({super.key});

  @override
  State<MonthlyAverageScreen> createState() => _MonthlyAverageScreenState();
}

class _MonthlyAverageScreenState extends State<MonthlyAverageScreen> {
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  AverageType _type = AverageType.count;
  String? _result;

  void _calculate() {
    final days = double.tryParse(_daysController.text.trim());

    if (days == null || days <= 0) {
      setState(() {
        _result = 'সঠিক দিন ইনপুট দিন';
      });
      return;
    }

    if (_type == AverageType.count) {
      final value = double.tryParse(_valueController.text.trim());

      if (value == null || value < 0) {
        setState(() {
          _result = 'সঠিক সংখ্যা ইনপুট দিন';
        });
        return;
      }

      setState(() {
        _result = CalculatorLogic.monthlyCount(
          days: days,
          value: value,
        );
      });
    } else {
      setState(() {
        _result = CalculatorLogic.monthlyTime(
          days: days,
          time: _valueController.text,
        );
      });
    }
  }

  void _clear() {
    _daysController.clear();
    _valueController.clear();

    setState(() {
      _result = null;
    });
  }

  @override
  void dispose() {
    _daysController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isTime = _type == AverageType.time;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('মাসিক গড়'),
        actions: [
          IconButton(
            onPressed: _clear,
            tooltip: 'মুছে ফেলুন',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.calendar_view_month_rounded,
                      color: AppTheme.gold,
                      size: 46,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'মাসিক গড় হিসাব',
                      style: TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'আপনার দেওয়া দিনের হিসাব থেকে ৩০ দিনের মাসিক গড় বের করুন',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'হিসাবের ধরন',
                      style: TextStyle(
                        color: AppTheme.goldLight,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    SegmentedButton<AverageType>(
                      segments: const [
                        ButtonSegment<AverageType>(
                          value: AverageType.count,
                          icon: Icon(Icons.numbers_rounded),
                          label: Text('সংখ্যা'),
                        ),
                        ButtonSegment<AverageType>(
                          value: AverageType.time,
                          icon: Icon(Icons.access_time_rounded),
                          label: Text('সময়'),
                        ),
                      ],
                      selected: {_type},
                      onSelectionChanged: (selection) {
                        setState(() {
                          _type = selection.first;
                          _result = null;
                          _valueController.clear();
                        });
                      },
                      style: ButtonStyle(
                        foregroundColor:
                            WidgetStateProperty.resolveWith<Color?>(
                          (states) {
                            if (states.contains(WidgetState.selected)) {
                              return Colors.black;
                            }
                            return AppTheme.textDark;
                          },
                        ),
                        backgroundColor:
                            WidgetStateProperty.resolveWith<Color?>(
                          (states) {
                            if (states.contains(WidgetState.selected)) {
                              return AppTheme.gold;
                            }
                            return AppTheme.cardLight;
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    TextField(
                      controller: _daysController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'মোট দিন',
                        hintText: 'যেমন: 15',
                        prefixIcon: Icon(
                          Icons.calendar_today_rounded,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: _valueController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: isTime ? 'মোট সময়' : 'মোট সংখ্যা',
                        hintText: isTime ? 'যেমন: 45.30' : 'যেমন: 150',
                        prefixIcon: Icon(
                          isTime
                              ? Icons.schedule_rounded
                              : Icons.numbers_rounded,
                        ),
                      ),
                    ),

                    if (isTime) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'সময় ঘণ্টা.মিনিট ফরম্যাটে লিখুন। যেমন: 45.30',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),

                    ElevatedButton.icon(
                      onPressed: _calculate,
                      icon: const Icon(Icons.calculate_rounded),
                      label: const Text('হিসাব করুন'),
                    ),
                  ],
                ),
              ),
            ),

            if (_result != null) ...[
              const SizedBox(height: 18),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.gold,
                        size: 46,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'মাসিক গড়',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _result!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.goldLight,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '৩০ দিনের ভিত্তিতে',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
