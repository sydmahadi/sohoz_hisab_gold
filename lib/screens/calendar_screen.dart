import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        title: const Text('ক্যালেন্ডার'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Selected date card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppTheme.darkGreen,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.gold.withOpacity(0.6),
                  width: 0.7,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.darkGreen.withOpacity(0.18),
                    blurRadius: 15,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: AppTheme.gold,
                    size: 32,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    '${selectedDate.day}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${monthName(selectedDate.month)} ${selectedDate.year}',
                    style: const TextStyle(
                      color: AppTheme.goldLight,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Calendar
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.gold.withOpacity(0.35),
                  ),
                ),
                child: CalendarDatePicker(
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  onDateChanged: (date) {
                    setState(() {
                      selectedDate = date;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Today button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    selectedDate = DateTime.now();
                  });
                },
                icon: const Icon(Icons.today_rounded),
                label: const Text(
                  'আজকের তারিখ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String monthName(int month) {
    const months = [
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

    return months[month - 1];
  }
}
