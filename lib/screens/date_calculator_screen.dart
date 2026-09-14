import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class DateCalculatorScreen extends StatefulWidget {
  const DateCalculatorScreen({super.key});

  @override
  State<DateCalculatorScreen> createState() => _DateCalculatorScreenState();
}

class _DateCalculatorScreenState extends State<DateCalculatorScreen> {
  // ============================================================
  // GENERAL
  // ============================================================

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

  final List<String> _weekDays = const [
    'সোমবার',
    'মঙ্গলবার',
    'বুধবার',
    'বৃহস্পতিবার',
    'শুক্রবার',
    'শনিবার',
    'রবিবার',
  ];

  String _formatDate(DateTime date) {
    return '${date.day} ${_monthNames[date.month - 1]} ${date.year}';
  }

  String _getWeekDay(DateTime date) {
    return _weekDays[date.weekday - 1];
  }

  // ============================================================
  // 1. AGE CALCULATOR
  // ============================================================

  DateTime? _birthDate;
  DateTime? _ageAtDate;

  int _ageYears = 0;
  int _ageMonths = 0;
  int _ageDays = 0;
  bool _ageCalculated = false;

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return _datePickerTheme(child!);
      },
    );

    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _ageCalculated = false;
      });
    }
  }

  Future<void> _selectAgeAtDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _ageAtDate ?? now,
      firstDate: _birthDate ?? DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return _datePickerTheme(child!);
      },
    );

    if (picked != null) {
      setState(() {
        _ageAtDate = picked;
        _ageCalculated = false;
      });
    }
  }

  void _calculateAge() {
    if (_birthDate == null) {
      _showMessage('প্রথমে জন্মতারিখ নির্বাচন করুন');
      return;
    }

    final endDate = _ageAtDate ?? DateTime.now();

    if (endDate.isBefore(_birthDate!)) {
      _showMessage('হিসাবের তারিখ জন্মতারিখের আগে হতে পারবে না');
      return;
    }

    int years = endDate.year - _birthDate!.year;
    int months = endDate.month - _birthDate!.month;
    int days = endDate.day - _birthDate!.day;

    if (days < 0) {
      months--;

      final previousMonth = DateTime(
        endDate.year,
        endDate.month,
        0,
      );

      days += previousMonth.day;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    setState(() {
      _ageYears = years;
      _ageMonths = months;
      _ageDays = days;
      _ageCalculated = true;
    });
  }

  // ============================================================
  // 2. DATE ADD / SUBTRACT
  // ============================================================

  DateTime _calculationDate = DateTime.now();
  final TextEditingController _daysController =
      TextEditingController();

  bool _isAdding = true;
  DateTime? _dateCalculationResult;

  Future<void> _selectCalculationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _calculationDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return _datePickerTheme(child!);
      },
    );

    if (picked != null) {
      setState(() {
        _calculationDate = picked;
        _dateCalculationResult = null;
      });
    }
  }

  void _calculateDateAddSubtract() {
    final days = int.tryParse(
      _daysController.text.trim(),
    );

    if (days == null || days < 0) {
      _showMessage('সঠিক সংখ্যক দিন লিখুন');
      return;
    }

    final result = _isAdding
        ? _calculationDate.add(Duration(days: days))
        : _calculationDate.subtract(Duration(days: days));

    setState(() {
      _dateCalculationResult = result;
    });
  }

  // ============================================================
  // 3. DIFFERENCE BETWEEN TWO DATES
  // ============================================================

  DateTime _firstDate = DateTime.now();
  DateTime _secondDate =
      DateTime.now().add(const Duration(days: 1));

  int _differenceDays = 0;
  int _differenceYears = 0;
  int _differenceMonths = 0;
  int _differenceRemainingDays = 0;

  bool _differenceCalculated = false;

  Future<void> _selectFirstDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _firstDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return _datePickerTheme(child!);
      },
    );

    if (picked != null) {
      setState(() {
        _firstDate = picked;
        _differenceCalculated = false;
      });
    }
  }

  Future<void> _selectSecondDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _secondDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return _datePickerTheme(child!);
      },
    );

    if (picked != null) {
      setState(() {
        _secondDate = picked;
        _differenceCalculated = false;
      });
    }
  }

  void _calculateDateDifference() {
    DateTime start = _firstDate;
    DateTime end = _secondDate;

    if (start.isAfter(end)) {
      final temp = start;
      start = end;
      end = temp;
    }

    final difference = end.difference(start).inDays;

    int years = end.year - start.year;
    int months = end.month - start.month;
    int days = end.day - start.day;

    if (days < 0) {
      months--;

      final previousMonth = DateTime(
        end.year,
        end.month,
        0,
      );

      days += previousMonth.day;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    setState(() {
      _differenceDays = difference;
      _differenceYears = years;
      _differenceMonths = months;
      _differenceRemainingDays = days;
      _differenceCalculated = true;
    });
  }

  // ============================================================
  // 4. DATE → DAY + HIJRI
  // ============================================================

  DateTime _dayCheckDate = DateTime.now();
  bool _dayChecked = false;

  Future<void> _selectDayCheckDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dayCheckDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return _datePickerTheme(child!);
      },
    );

    if (picked != null) {
      setState(() {
        _dayCheckDate = picked;
        _dayChecked = true;
      });
    }
  }

  // ============================================================
  // HIJRI CONVERSION
  // ============================================================

  String _getHijriDate(DateTime date) {
    final jd = _gregorianToJulianDay(
      date.year,
      date.month,
      date.day,
    );

    final islamic = _julianDayToIslamic(jd);

    final day = islamic[0];
    final month = islamic[1];
    final year = islamic[2];

    const hijriMonths = [
      'মুহররম',
      'সফর',
      'রবিউল আউয়াল',
      'রবিউস সানি',
      'জমাদিউল আউয়াল',
      'জমাদিউস সানি',
      'রজব',
      'শাবান',
      'রমজান',
      'শাওয়াল',
      'জিলকদ',
      'জিলহজ',
    ];

    return '$day ${hijriMonths[month - 1]} $year হিজরি';
  }

  int _gregorianToJulianDay(
    int year,
    int month,
    int day,
  ) {
    int a = ((14 - month) ~/ 12);
    int y = year + 4800 - a;
    int m = month + (12 * a) - 3;

    return day +
        ((153 * m + 2) ~/ 5) +
        (365 * y) +
        (y ~/ 4) -
        (y ~/ 100) +
        (y ~/ 400) -
        32045;
  }

  List<int> _julianDayToIslamic(int jd) {
    final l = jd - 1948440 + 10632;
    final n = ((l - 1) ~/ 10631);
    final l2 = l - 10631 * n + 354;

    final j =
        (((10985 - l2) ~/ 5316) *
                ((50 * l2) ~/ 17719)) +
            ((l2 ~/ 5670) *
                ((43 * l2) ~/ 15238));

    final l3 =
        l2 -
        ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) -
        (j ~/ 16) * ((15238 * j) ~/ 43) +
        29;

    final month = ((24 * l3) ~/ 709);
    final day = l3 - ((709 * month) ~/ 24);
    final year = 30 * n + j - 30;

    return [day, month, year];
  }

  // ============================================================
  // DATE PICKER THEME
  // ============================================================

  Theme _datePickerTheme(Widget child) {
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: AppTheme.gold,
          onPrimary: Colors.black,
          surface: AppTheme.cardColor,
          onSurface: AppTheme.textPrimary,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppTheme.cardColor,
        ),
      ),
      child: child,
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // DATE SELECT BOX
  // ============================================================

  Widget _dateBox({
    required String title,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.goldLight,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: AppTheme.cardLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.gold.withValues(alpha: 0.45),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  color: AppTheme.gold,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _formatDate(date),
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
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
      ],
    );
  }

  // ============================================================
  // RESULT INFO ROW
  // ============================================================

  Widget _infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.gold,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 14,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppTheme.goldLight,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.gold,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppTheme.goldLight,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ...children,
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        title: const Text('তারিখ হিসাব'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ==================================================
            // 1. AGE CALCULATOR
            // ==================================================

            _sectionCard(
              icon: Icons.cake_rounded,
              title: 'বয়স হিসাব',
              subtitle:
                  'জন্মতারিখ দিয়ে বয়স নির্ণয় করুন',
              children: [
                _dateBox(
                  title: 'জন্মতারিখ',
                  date: _birthDate ?? DateTime(2000, 1, 1),
                  onTap: _selectBirthDate,
                ),

                const SizedBox(height: 14),

                _dateBox(
                  title: 'যে তারিখ পর্যন্ত বয়স',
                  date: _ageAtDate ?? DateTime.now(),
                  onTap: _selectAgeAtDate,
                ),

                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: _calculateAge,
                  icon: const Icon(
                    Icons.calculate_rounded,
                  ),
                  label: const Text('বয়স হিসাব করুন'),
                ),

                if (_ageCalculated) ...[
                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.green.withValues(
                        alpha: 0.12,
                      ),
                      borderRadius:
                          BorderRadius.circular(18),
                      border: Border.all(
                        color: AppTheme.gold.withValues(
                          alpha: 0.35,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.person_rounded,
                          color: AppTheme.gold,
                          size: 42,
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'আপনার বয়স',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          '$_ageYears বছর $_ageMonths মাস $_ageDays দিন',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.goldLight,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 15),

                        _infoRow(
                          Icons.event_rounded,
                          'জন্মবার',
                          _getWeekDay(_birthDate!),
                        ),

                        _infoRow(
                          Icons.calendar_today_rounded,
                          'জন্মতারিখ',
                          _formatDate(_birthDate!),
                        ),

                        _infoRow(
                          Icons.mosque_rounded,
                          'হিজরি জন্মতারিখ',
                          _getHijriDate(_birthDate!),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // ==================================================
            // 2. DATE ADD / SUBTRACT
            // ==================================================

            _sectionCard(
              icon: Icons.add_circle_outline_rounded,
              title: 'তারিখ যোগ / বিয়োগ',
              subtitle:
                  'একটি তারিখের সাথে দিন যোগ বা বিয়োগ করুন',
              children: [
                _dateBox(
                  title: 'তারিখ',
                  date: _calculationDate,
                  onTap: _selectCalculationDate,
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('যোগ'),
                        selected: _isAdding,
                        onSelected: (value) {
                          if (value) {
                            setState(() {
                              _isAdding = true;
                              _dateCalculationResult = null;
                            });
                          }
                        },
                        selectedColor:
                            AppTheme.gold,
                        labelStyle: TextStyle(
                          color: _isAdding
                              ? Colors.black
                              : AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: ChoiceChip(
                        label: const Text('বিয়োগ'),
                        selected: !_isAdding,
                        onSelected: (value) {
                          if (value) {
                            setState(() {
                              _isAdding = false;
                              _dateCalculationResult = null;
                            });
                          }
                        },
                        selectedColor:
                            AppTheme.gold,
                        labelStyle: TextStyle(
                          color: !_isAdding
                              ? Colors.black
                              : AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: _daysController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'কত দিন?',
                    hintText: 'যেমন: 30',
                    prefixIcon: Icon(
                      Icons.numbers_rounded,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: _calculateDateAddSubtract,
                  icon: const Icon(
                    Icons.calculate_rounded,
                  ),
                  label: const Text('হিসাব করুন'),
                ),

                if (_dateCalculationResult != null) ...[
                  const SizedBox(height: 18),

                  _infoRow(
                    Icons.event_available_rounded,
                    'ফলাফল',
                    _formatDate(
                      _dateCalculationResult!,
                    ),
                  ),

                  _infoRow(
                    Icons.today_rounded,
                    'বার',
                    _getWeekDay(
                      _dateCalculationResult!,
                    ),
                  ),

                  _infoRow(
                    Icons.mosque_rounded,
                    'হিজরি',
                    _getHijriDate(
                      _dateCalculationResult!,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // ==================================================
            // 3. DIFFERENCE BETWEEN TWO DATES
            // ==================================================

            _sectionCard(
              icon: Icons.date_range_rounded,
              title: 'দুই তারিখের হিসাব',
              subtitle:
                  'দুইটি তারিখের মধ্যে সময়ের ব্যবধান জানুন',
              children: [
                _dateBox(
                  title: 'প্রথম তারিখ',
                  date: _firstDate,
                  onTap: _selectFirstDate,
                ),

                const SizedBox(height: 14),

                _dateBox(
                  title: 'দ্বিতীয় তারিখ',
                  date: _secondDate,
                  onTap: _selectSecondDate,
                ),

                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: _calculateDateDifference,
                  icon: const Icon(
                    Icons.compare_arrows_rounded,
                  ),
                  label: const Text('ব্যবধান হিসাব করুন'),
                ),

                if (_differenceCalculated) ...[
                  const SizedBox(height: 18),

                  _infoRow(
                    Icons.numbers_rounded,
                    'মোট দিন',
                    '$_differenceDays দিন',
                  ),

                  _infoRow(
                    Icons.calendar_view_month_rounded,
                    'বছর / মাস / দিন',
                    '$_differenceYears বছর '
                        '$_differenceMonths মাস '
                        '$_differenceRemainingDays দিন',
                  ),

                  _infoRow(
                    Icons.today_rounded,
                    'প্রথম তারিখের বার',
                    _getWeekDay(_firstDate),
                  ),

                  _infoRow(
                    Icons.today_rounded,
                    'দ্বিতীয় তারিখের বার',
                    _getWeekDay(_secondDate),
                  ),

                  _infoRow(
                    Icons.mosque_rounded,
                    'প্রথম তারিখের হিজরি',
                    _getHijriDate(_firstDate),
                  ),

                  _infoRow(
                    Icons.mosque_rounded,
                    'দ্বিতীয় তারিখের হিজরি',
                    _getHijriDate(_secondDate),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // ==================================================
            // 4. DATE → DAY + HIJRI
            // ==================================================

            _sectionCard(
              icon: Icons.event_note_rounded,
              title: 'তারিখ থেকে বার ও হিজরি',
              subtitle:
                  'যেকোনো তারিখের বার ও হিজরি তারিখ দেখুন',
              children: [
                _dateBox(
                  title: 'তারিখ নির্বাচন করুন',
                  date: _dayCheckDate,
                  onTap: _selectDayCheckDate,
                ),

                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _dayChecked = true;
                    });
                  },
                  icon: const Icon(
                    Icons.search_rounded,
                  ),
                  label: const Text('তারিখ দেখুন'),
                ),

                if (_dayChecked) ...[
                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.green.withValues(
                        alpha: 0.12,
                      ),
                      borderRadius:
                          BorderRadius.circular(18),
                      border: Border.all(
                        color: AppTheme.gold.withValues(
                          alpha: 0.35,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          color: AppTheme.gold,
                          size: 42,
                        ),

                        const SizedBox(height: 10),

                        Text(
                          _formatDate(_dayCheckDate),
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          _getWeekDay(_dayCheckDate),
                          style: const TextStyle(
                            color: AppTheme.goldLight,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          _getHijriDate(_dayCheckDate),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }
}
