import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class DateCalculatorScreen extends StatefulWidget {
  const DateCalculatorScreen({super.key});

  @override
  State<DateCalculatorScreen> createState() => _DateCalculatorScreenState();
}

class _DateCalculatorScreenState extends State<DateCalculatorScreen> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _daysController = TextEditingController();

  DateTime? _resultDate;

  final List<String> _monthNames = const [
    'জানুয়ারি',
    'ফেব্রুয়ারি',
    'মার্চ',
    'এপ্রিল',
    'মে',
    'জুন',
    'জুলাই',
    'আগস্ট',
    'সেপ্টেম্বর',
    'অক্টোবর',
    'নভেম্বর',
    'ডিসেম্বর',
  ];

  String _formatBanglaDate(DateTime date) {
    return '${date.day} ${_monthNames[date.month - 1]} ${date.year}';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.gold,
              onPrimary: Colors.black,
              surface: AppTheme.cardColor,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _resultDate = null;
      });
    }
  }

  void _calculateDate() {
    final int? days = int.tryParse(_daysController.text.trim());

    if (days == null || days < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('সঠিক সংখ্যক দিন লিখুন'),
        ),
      );
      return;
    }

    setState(() {
      _resultDate = _selectedDate.subtract(
        Duration(days: days),
      );
    });
  }

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('তারিখ হিসাব'),
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
                      Icons.calendar_month_rounded,
                      color: AppTheme.gold,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'তারিখ থেকে দিন বাদ দিন',
                      style: TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'একটি তারিখ নির্বাচন করে কত দিন বাদ দিতে চান তা লিখুন।',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
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
                      'নির্বাচিত তারিখ',
                      style: TextStyle(
                        color: AppTheme.goldLight,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    InkWell(
                      onTap: _selectDate,
                      borderRadius: BorderRadius.circular(17),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 17,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.cardLight,
                          borderRadius: BorderRadius.circular(17),
                          border: Border.all(
                            color: AppTheme.gold.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.event_rounded,
                              color: AppTheme.gold,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _formatBanglaDate(_selectedDate),
                                style: const TextStyle(
                                  color: AppTheme.textDark,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down_rounded,
                              color: AppTheme.gold,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    TextField(
                      controller: _daysController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'কত দিন বাদ দেবেন?',
                        hintText: 'যেমন: 30',
                        prefixIcon: Icon(
                          Icons.numbers_rounded,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    ElevatedButton.icon(
                      onPressed: _calculateDate,
                      icon: const Icon(Icons.calculate_rounded),
                      label: const Text('হিসাব করুন'),
                    ),
                  ],
                ),
              ),
            ),

            if (_resultDate != null) ...[
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
                      const SizedBox(height: 12),
                      const Text(
                        'হিসাবের ফলাফল',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatBanglaDate(_resultDate!),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.goldLight,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
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
