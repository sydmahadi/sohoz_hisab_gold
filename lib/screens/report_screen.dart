import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gal/gal.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:screenshot/screenshot.dart';

import '../theme/app_theme.dart';
import '../logic/money_db_helper.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  // ============================================================
  // MONTHLY REPORT
  // ============================================================

  DateTime _selectedMonth = DateTime.now();

  // ============================================================
  // CATEGORY REPORT
  // ============================================================

  String _categoryReportType = 'Income';

  String? _selectedCategory;

  List<MoneyTransaction> _transactions = [];

  // ============================================================
  // STATES
  // ============================================================

  bool _loading = true;
  bool _savingImage = false;
  bool _savingPdf = false;
  bool _savingCategoryImage = false;

  // ============================================================
  // SCREENSHOT CONTROLLERS
  // ============================================================

  final ScreenshotController _screenshotController =
      ScreenshotController();

  final ScreenshotController _categoryScreenshotController =
      ScreenshotController();

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> _loadReport() async {
    setState(() {
      _loading = true;
    });

    try {
      final data =
          await MoneyDbHelper.instance.getAllTransactions();

      if (!mounted) return;

      setState(() {
        _transactions = data;
        _loading = false;

        _updateSelectedCategory();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _transactions = [];
        _loading = false;
        _selectedCategory = null;
      });
    }
  }

  // ============================================================
  // DATE PARSER
  // Supports common database formats
  // ============================================================

  DateTime? _parseDate(String date) {
    final value = date.trim();

    final formats = [
      'dd/MM/yyyy',
      'dd-MM-yyyy',
      'dd.MM.yyyy',
      'yyyy/MM/dd',
      'yyyy-MM-dd',
      'yyyy.MM.dd',
      'dd/MM/yyyy HH:mm',
      'dd-MM-yyyy HH:mm',
      'dd.MM.yyyy HH:mm',
      'yyyy-MM-dd HH:mm:ss',
      'yyyy-MM-dd HH:mm',
      'yyyy/MM/dd HH:mm:ss',
      'yyyy/MM/dd HH:mm',
    ];

    for (final format in formats) {
      try {
        return DateFormat(format).parseStrict(value);
      } catch (_) {}
    }

    try {
      return DateTime.tryParse(value);
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // MONTHLY TRANSACTIONS
  // ============================================================

  List<MoneyTransaction> get _monthlyTransactions {
    final result = _transactions.where((item) {
      final date = _parseDate(item.date);

      if (date == null) return false;

      return date.year == _selectedMonth.year &&
          date.month == _selectedMonth.month;
    }).toList();

    return result;
  }

  // ============================================================
  // INCOME / EXPENSE / TRANSFER
  // ============================================================

  List<MoneyTransaction> get _incomeTransactions {
    return _monthlyTransactions
        .where(
          (e) => e.type.toLowerCase() == 'income',
        )
        .toList();
  }

  List<MoneyTransaction> get _expenseTransactions {
    return _monthlyTransactions
        .where(
          (e) => e.type.toLowerCase() == 'expense',
        )
        .toList();
  }

  List<MoneyTransaction> get _transferTransactions {
    return _monthlyTransactions
        .where(
          (e) => e.type.toLowerCase() == 'transfer',
        )
        .toList();
  }

  // ============================================================
  // TOTALS
  // ============================================================

  double get _totalIncome {
    return _incomeTransactions.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );
  }

  double get _totalExpense {
    return _expenseTransactions.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );
  }

  double get _balance {
    return _totalIncome - _totalExpense;
  }

  // ============================================================
  // CATEGORY TOTAL
  // ============================================================

  Map<String, double> _categoryTotals(
    List<MoneyTransaction> transactions,
  ) {
    final Map<String, double> result = {};

    for (final item in transactions) {
      final category =
          item.category.trim().isEmpty
              ? 'অন্যান্য'
              : item.category.trim();

      result[category] =
          (result[category] ?? 0) + item.amount;
    }

    return result;
  }

  Map<String, double> get _incomeCategories {
    final result =
        _categoryTotals(_incomeTransactions);

    final entries = result.entries.toList()
      ..sort(
        (a, b) => b.value.compareTo(a.value),
      );

    return Map.fromEntries(entries);
  }

  Map<String, double> get _expenseCategories {
    final result =
        _categoryTotals(_expenseTransactions);

    final entries = result.entries.toList()
      ..sort(
        (a, b) => b.value.compareTo(a.value),
      );

    return Map.fromEntries(entries);
  }

  // ============================================================
  // CATEGORY REPORT AVAILABLE CATEGORIES
  // ============================================================

  List<String> get _availableCategories {
    final List<MoneyTransaction> source =
        _categoryReportType == 'Income'
            ? _incomeTransactions
            : _expenseTransactions;

    final categories = source
        .map(
          (e) => e.category.trim().isEmpty
              ? 'অন্যান্য'
              : e.category.trim(),
        )
        .toSet()
        .toList();

    categories.sort(
      (a, b) => a.compareTo(b),
    );

    return categories;
  }

  // ============================================================
  // UPDATE SELECTED CATEGORY
  // ============================================================

  void _updateSelectedCategory() {
    final categories = _availableCategories;

    if (categories.isEmpty) {
      _selectedCategory = null;
      return;
    }

    if (_selectedCategory == null ||
        !categories.contains(_selectedCategory)) {
      _selectedCategory = categories.first;
    }
  }

  // ============================================================
  // CATEGORY REPORT TRANSACTIONS
  //
  // Selected month:
  // - Current month = 1st day -> today
  // - Previous month = full selected month
  // ============================================================

  List<MoneyTransaction>
      get _categoryReportTransactions {
    if (_selectedCategory == null) {
      return [];
    }

    final now = DateTime.now();

    final firstDay = DateTime(
      _selectedMonth.year,
      _selectedMonth.month,
      1,
    );

    DateTime lastDay;

    final isCurrentMonth =
        _selectedMonth.year == now.year &&
        _selectedMonth.month == now.month;

    if (isCurrentMonth) {
      lastDay = DateTime(
        now.year,
        now.month,
        now.day,
        23,
        59,
        59,
      );
    } else {
      lastDay = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        0,
        23,
        59,
        59,
      );
    }

    final result = _transactions.where((item) {
      final date = _parseDate(item.date);

      if (date == null) return false;

      final typeMatches =
          item.type.toLowerCase() ==
          _categoryReportType.toLowerCase();

      final itemCategory =
          item.category.trim().isEmpty
              ? 'অন্যান্য'
              : item.category.trim();

      final categoryMatches =
          itemCategory == _selectedCategory;

      final dateMatches =
          !date.isBefore(firstDay) &&
          !date.isAfter(lastDay);

      return typeMatches &&
          categoryMatches &&
          dateMatches;
    }).toList();

    // Latest date first.
    result.sort((a, b) {
      final dateA = _parseDate(a.date);
      final dateB = _parseDate(b.date);

      if (dateA == null && dateB == null) {
        return 0;
      }

      if (dateA == null) {
        return 1;
      }

      if (dateB == null) {
        return -1;
      }

      return dateB.compareTo(dateA);
    });

    return result;
  }

  // ============================================================
  // CATEGORY REPORT TOTAL
  // ============================================================

  double get _categoryReportTotal {
    return _categoryReportTransactions.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );
  }

  // ============================================================
  // MONTH
  // ============================================================

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
      );

      _updateSelectedCategory();
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
      );

      _updateSelectedCategory();
    });
  }

  Future<void> _selectMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'রিপোর্টের মাস নির্বাচন করুন',
    );

    if (picked == null) return;

    setState(() {
      _selectedMonth = DateTime(
        picked.year,
        picked.month,
      );

      _updateSelectedCategory();
    });
  }

  // ============================================================
  // MONEY FORMAT
  // ============================================================

  String _money(double amount) {
    return '৳ ${amount.toStringAsFixed(2)}';
  }

  // ============================================================
  // DATE DISPLAY
  // ============================================================

  String _displayDate(String value) {
    final date = _parseDate(value);

    if (date == null) {
      return value;
    }

    return DateFormat(
      'dd/MM/yyyy',
    ).format(date);
  }

  // ============================================================
  // MONTHLY A4 REPORT
  // ============================================================

  Widget _buildA4Report() {
    final income = _incomeCategories.entries.toList();
    final expense = _expenseCategories.entries.toList();

    return Container(
      width: 794,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        35,
        35,
        35,
        28,
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Colors.black,
          fontFamily: 'Arial',
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            const Text(
              'সহজ হিসাব',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'মাসিক আয়-ব্যয়ের রিপোর্ট',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              DateFormat('MMMM yyyy').format(
                _selectedMonth,
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 25),

            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black54,
                  width: 1,
                ),
                borderRadius:
                    BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildA4Side(
                      title: 'আয়',
                      items: income,
                      total: _totalIncome,
                    ),
                  ),
                  Container(
                    width: 1,
                    color: Colors.black54,
                  ),
                  Expanded(
                    child: _buildA4Side(
                      title: 'ব্যয়',
                      items: expense,
                      total: _totalExpense,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 20,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _balance >= 0
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                  width: 1.2,
                ),
                borderRadius:
                    BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    _balance >= 0
                        ? 'উদ্বৃত্ত'
                        : 'ঘাটতি',
                    style: TextStyle(
                      color: _balance >= 0
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    _money(_balance.abs()),
                    style: TextStyle(
                      color: _balance >= 0
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            Text(
              'মোট লেনদেন: '
              '${_monthlyTransactions.length} টি',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            if (_transferTransactions.isNotEmpty)
              Text(
                'মোট ট্রান্সফার: '
                '${_transferTransactions.length} টি',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),

            const SizedBox(height: 22),

            // ==================================================
            // WATERMARK
            // ==================================================

            Align(
              alignment: Alignment.bottomRight,
              child: Opacity(
                opacity: 0.38,
                child: SizedBox(
                  width: 190,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.center,
                    children: const [
                      Text(
                        'সহজ হিসাব অ্যাপ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF777777),
                          fontSize: 10,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // A4 SIDE
  // ============================================================

  Widget _buildA4Side({
    required String title,
    required List<MapEntry<String, double>> items,
    required double total,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(
            vertical: 11,
          ),
          color: const Color(0xFFEFEFEF),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),

        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'কোনো তথ্য নেই',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ),

        ...items.asMap().entries.map(
          (entry) {
            final index = entry.key;
            final item = entry.value;

            return Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 9,
              ),
              decoration:
                  const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black12,
                  ),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 22,
                    child: Text(
                      '${index + 1}.',
                      style:
                          const TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),

                  Expanded(
                    child: Text(
                      item.key,
                      style:
                          const TextStyle(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(width: 5),

                  Text(
                    _money(item.value),
                    textAlign:
                        TextAlign.right,
                    style:
                        const TextStyle(
                      fontSize: 11.5,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 12,
          ),
          color: const Color(0xFFF5F5F5),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'মোট',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),
              Text(
                _money(total),
                style:
                    const TextStyle(
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CATEGORY A4 REPORT
  // ============================================================

  Widget _buildCategoryA4Report() {
    final transactions =
        _categoryReportTransactions;

    final isIncome =
        _categoryReportType == 'Income';

    final reportTitle =
        isIncome
            ? 'খাতভিত্তিক আয় রিপোর্ট'
            : 'খাতভিত্তিক ব্যয় রিপোর্ট';

    final typeTitle =
        isIncome ? 'আয়' : 'ব্যয়';

    final category =
        _selectedCategory ?? 'কোনো খাত নির্বাচন করা হয়নি';

    final now = DateTime.now();

    final isCurrentMonth =
        _selectedMonth.year == now.year &&
        _selectedMonth.month == now.month;

    String periodText;

    if (isCurrentMonth) {
      periodText =
          '১ ${DateFormat('MMMM').format(_selectedMonth)} '
          'থেকে ${DateFormat('dd/MM/yyyy').format(now)}';
    } else {
      final lastDate = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        0,
      );

      periodText =
          '০১/${DateFormat('MM').format(_selectedMonth)}/'
          '${_selectedMonth.year} থেকে '
          '${DateFormat('dd/MM/yyyy').format(lastDate)}';
    }

    return Container(
      width: 794,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        35,
        35,
        35,
        28,
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Colors.black,
          fontFamily: 'Arial',
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            const Text(
              'সহজ হিসাব',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              reportTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              DateFormat('MMMM yyyy').format(
                _selectedMonth,
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              periodText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 22),

            Container(
              padding:
                  const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black54,
                ),
                borderRadius:
                    BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    'রিপোর্টের ধরন',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    typeTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 9),

                  const Text(
                    'খাত',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    category,
                    textAlign:
                        TextAlign.center,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ==================================================
            // TABLE HEADER
            // ==================================================

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 11,
              ),
              color: const Color(0xFFEFEFEF),
              child: Row(
                children: const [
                  SizedBox(
                    width: 45,
                    child: Text(
                      'নং',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 95,
                    child: Text(
                      'তারিখ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'বিবরণ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: Text(
                      'পরিমাণ',
                      textAlign:
                          TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (transactions.isEmpty)
              Container(
                padding:
                    const EdgeInsets.all(30),
                decoration:
                    const BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Colors.black12,
                    ),
                    right: BorderSide(
                      color: Colors.black12,
                    ),
                    bottom: BorderSide(
                      color: Colors.black12,
                    ),
                  ),
                ),
                child: const Text(
                  'এই খাতে কোনো লেনদেন পাওয়া যায়নি',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
              ),

            ...transactions
                .asMap()
                .entries
                .map(
              (entry) {
                final index = entry.key;
                final item = entry.value;

                final description =
                    item.note?.trim() ?? '';

                return Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration:
                      const BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Colors.black12,
                      ),
                      right: BorderSide(
                        color: Colors.black12,
                      ),
                      bottom: BorderSide(
                        color: Colors.black12,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 45,
                        child: Text(
                          '${index + 1}',
                          style:
                              const TextStyle(
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ),

                      SizedBox(
                        width: 95,
                        child: Text(
                          _displayDate(
                            item.date,
                          ),
                          style:
                              const TextStyle(
                            fontSize: 11,
                          ),
                        ),
                      ),

                      Expanded(
                        child: Text(
                          description.isEmpty
                              ? '—'
                              : description,
                          style:
                              const TextStyle(
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),

                      SizedBox(
                        width: 120,
                        child: Text(
                          _money(item.amount),
                          textAlign:
                              TextAlign.right,
                          style:
                              const TextStyle(
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // ==================================================
            // TOTAL
            // ==================================================

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 15,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isIncome
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                  width: 1.2,
                ),
                borderRadius:
                    BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'মোট',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    _money(
                      _categoryReportTotal,
                    ),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w900,
                      color: isIncome
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'মোট লেনদেন: ${transactions.length} টি',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(height: 22),

            // ==================================================
            // WATERMARK
            // ==================================================

            Align(
              alignment: Alignment.bottomRight,
              child: Opacity(
                opacity: 0.38,
                child: SizedBox(
                  width: 190,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.center,
                    children: const [
                      Text(
                        'সহজ হিসাব অ্যাপ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF777777),
                          fontSize: 10,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CAPTURE MONTHLY A4 IMAGE
  // ============================================================

  Future<Uint8List> _captureA4Image() async {
    final image =
        await _screenshotController
            .captureFromLongWidget(
      InheritedTheme.captureAll(
        context,
        Material(
          color: Colors.white,
          child: _buildA4Report(),
        ),
      ),
      delay:
          const Duration(milliseconds: 500),
      context: context,
      pixelRatio: 2,
      constraints:
          const BoxConstraints(
        maxWidth: 794,
      ),
    );

    return image;
  }

  // ============================================================
  // CAPTURE CATEGORY IMAGE
  // ============================================================

  Future<Uint8List>
      _captureCategoryImage() async {
    final image =
        await _categoryScreenshotController
            .captureFromLongWidget(
      InheritedTheme.captureAll(
        context,
        Material(
          color: Colors.white,
          child: _buildCategoryA4Report(),
        ),
      ),
      delay:
          const Duration(milliseconds: 500),
      context: context,
      pixelRatio: 2,
      constraints:
          const BoxConstraints(
        maxWidth: 794,
      ),
    );

    return image;
  }

  // ============================================================
  // SAVE MONTHLY IMAGE
  // ============================================================

  Future<void> _saveAsImage() async {
    if (_savingImage) return;

    setState(() {
      _savingImage = true;
    });

    try {
      final Uint8List image =
          await _captureA4Image();

      final permission =
          await Gal.requestAccess(
        toAlbum: true,
      );

      if (!permission) {
        throw Exception(
          'Gallery permission পাওয়া যায়নি',
        );
      }

      final month =
          DateFormat('MM-yyyy').format(
        _selectedMonth,
      );

      await Gal.putImageBytes(
        image,
        album: 'সহজ হিসাব',
        name:
            'Shohoj_Hisab_Report_$month',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'মাসিক রিপোর্টটি Gallery-তে Save হয়েছে',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Image Save করা যায়নি\n$e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _savingImage = false;
        });
      }
    }
  }

  // ============================================================
  // SAVE MONTHLY PDF
  // ============================================================

  Future<void> _saveAsPdf() async {
    if (_savingPdf) return;

    setState(() {
      _savingPdf = true;
    });

    try {
      final Uint8List image =
          await _captureA4Image();

      final pdf = pw.Document();

      final pdfImage =
          pw.MemoryImage(image);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (context) {
            return pw.Image(
              pdfImage,
              fit: pw.BoxFit.contain,
            );
          },
        ),
      );

      final month =
          DateFormat('MM-yyyy').format(
        _selectedMonth,
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename:
            'Shohoj_Hisab_Report_$month.pdf',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'A4 PDF তৈরি হয়েছে',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'PDF তৈরি করা যায়নি\n$e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _savingPdf = false;
        });
      }
    }
  }

  // ============================================================
  // SAVE CATEGORY REPORT IMAGE
  // ============================================================

  Future<void>
      _saveCategoryReportImage() async {
    if (_savingCategoryImage) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'প্রথমে একটি খাত নির্বাচন করুন',
          ),
        ),
      );
      return;
    }

    setState(() {
      _savingCategoryImage = true;
    });

    try {
      final Uint8List image =
          await _captureCategoryImage();

      final permission =
          await Gal.requestAccess(
        toAlbum: true,
      );

      if (!permission) {
        throw Exception(
          'Gallery permission পাওয়া যায়নি',
        );
      }

      final month =
          DateFormat('MM-yyyy').format(
        _selectedMonth,
      );

      final type =
          _categoryReportType == 'Income'
              ? 'Income'
              : 'Expense';

      final safeCategory =
          _selectedCategory!
              .replaceAll(
                RegExp(r'[\\/:*?"<>|]'),
                '_',
              )
              .replaceAll(' ', '_');

      await Gal.putImageBytes(
        image,
        album: 'সহজ হিসাব',
        name:
            'Shohoj_Hisab_${type}_${safeCategory}_$month',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'খাতভিত্তিক রিপোর্টটি Gallery-তে Save হয়েছে',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'রিপোর্ট Save করা যায়নি\n$e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _savingCategoryImage = false;
        });
      }
    }
  }

  // ============================================================
  // MAIN UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final dark = AppTheme.isDark;

    return Scaffold(
      backgroundColor:
          AppTheme.background,

      appBar: AppBar(
        title: Text(
          'রিপোর্ট',
          style: TextStyle(
            color: dark
                ? AppTheme.gold
                : AppTheme.darkGreen,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadReport,
            icon: Icon(
              Icons.refresh_rounded,
              color: dark
                  ? AppTheme.gold
                  : AppTheme.darkGreen,
            ),
          ),
        ],
      ),

      body: _loading
          ? Center(
              child:
                  CircularProgressIndicator(
                color: dark
                    ? AppTheme.gold
                    : AppTheme.darkGreen,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadReport,
              color: dark
                  ? AppTheme.gold
                  : AppTheme.darkGreen,
              child:
                  SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.fromLTRB(
                  14,
                  10,
                  14,
                  20,
                ),
                child: Column(
                  children: [
                    // ==================================================
                    // REPORT TYPE SWITCH
                    // ==================================================

                    _buildReportTypeSelector(
                      dark,
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // MONTHLY REPORT
                    // ==================================================

                    if (_selectedReportMode ==
                        'monthly')
                      _buildMonthlyReportSection(
                        dark,
                      ),

                    // ==================================================
                    // CATEGORY REPORT
                    // ==================================================

                    if (_selectedReportMode ==
                        'category')
                      _buildCategoryReportSection(
                        dark,
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  // ============================================================
  // REPORT MODE
  // ============================================================

  String _selectedReportMode = 'monthly';

  // ============================================================
  // REPORT TYPE SELECTOR
  // ============================================================

  Widget _buildReportTypeSelector(
    bool dark,
  ) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.gold.withValues(
            alpha: dark ? 0.35 : 0.25,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildReportModeButton(
              title: 'মাসিক রিপোর্ট',
              icon: Icons
                  .calendar_month_rounded,
              selected:
                  _selectedReportMode ==
                      'monthly',
              dark: dark,
              onTap: () {
                setState(() {
                  _selectedReportMode =
                      'monthly';
                });
              },
            ),
          ),

          const SizedBox(width: 5),

          Expanded(
            child: _buildReportModeButton(
              title: 'খাতভিত্তিক রিপোর্ট',
              icon: Icons
                  .category_rounded,
              selected:
                  _selectedReportMode ==
                      'category',
              dark: dark,
              onTap: () {
                setState(() {
                  _selectedReportMode =
                      'category';

                  _updateSelectedCategory();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REPORT MODE BUTTON
  // ============================================================

  Widget _buildReportModeButton({
    required String title,
    required IconData icon,
    required bool selected,
    required bool dark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(12),
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? (dark
                  ? AppTheme.gold
                  : AppTheme.darkGreen)
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 19,
              color: selected
                  ? (dark
                      ? Colors.black
                      : Colors.white)
                  : AppTheme.textMuted,
            ),

            const SizedBox(width: 6),

            Flexible(
              child: Text(
                title,
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color: selected
                      ? (dark
                          ? Colors.black
                          : Colors.white)
                      : AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MONTHLY REPORT SECTION
  // ============================================================

  Widget _buildMonthlyReportSection(
    bool dark,
  ) {
    return Column(
      children: [
        _buildMonthSelector(
          Theme.of(context),
          dark,
        ),

        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: FittedBox(
            fit: BoxFit.fitWidth,
            alignment:
                Alignment.topCenter,
            child: Screenshot(
              controller:
                  _screenshotController,
              child: _buildA4Report(),
            ),
          ),
        ),

        const SizedBox(height: 18),

        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed:
                    _savingImage
                        ? null
                        : _saveAsImage,
                icon: _savingImage
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.image_outlined,
                      ),
                label: const Text(
                  'Save as Image',
                ),
                style:
                    ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 15,
                  ),
                  backgroundColor: dark
                      ? AppTheme.gold
                      : AppTheme.darkGreen,
                  foregroundColor: dark
                      ? Colors.black
                      : Colors.white,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: ElevatedButton.icon(
                onPressed:
                    _savingPdf
                        ? null
                        : _saveAsPdf,
                icon: _savingPdf
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons
                            .picture_as_pdf_outlined,
                      ),
                label: const Text(
                  'Save as PDF',
                ),
                style:
                    ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 15,
                  ),
                  backgroundColor:
                      Colors.redAccent,
                  foregroundColor:
                      Colors.white,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        Text(
          'Image: A4 • Gallery-তে Save হবে',
          style: TextStyle(
            color: AppTheme.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CATEGORY REPORT SECTION
  // ============================================================

  Widget _buildCategoryReportSection(
    bool dark,
  ) {
    final categories =
        _availableCategories;

    return Column(
      children: [
        // ========================================================
        // MONTH SELECTOR
        // ========================================================

        _buildMonthSelector(
          Theme.of(context),
          dark,
        ),

        const SizedBox(height: 14),

        // ========================================================
        // INCOME / EXPENSE
        // ========================================================

        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius:
                BorderRadius.circular(16),
            border: Border.all(
              color:
                  AppTheme.gold.withValues(
                alpha: dark ? 0.35 : 0.25,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child:
                    _buildIncomeExpenseButton(
                  title: 'আয়',
                  icon: Icons
                      .arrow_downward_rounded,
                  selected:
                      _categoryReportType ==
                          'Income',
                  dark: dark,
                  onTap: () {
                    setState(() {
                      _categoryReportType =
                          'Income';

                      _updateSelectedCategory();
                    });
                  },
                ),
              ),

              const SizedBox(width: 5),

              Expanded(
                child:
                    _buildIncomeExpenseButton(
                  title: 'ব্যয়',
                  icon: Icons
                      .arrow_upward_rounded,
                  selected:
                      _categoryReportType ==
                          'Expense',
                  dark: dark,
                  onTap: () {
                    setState(() {
                      _categoryReportType =
                          'Expense';

                      _updateSelectedCategory();
                    });
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ========================================================
        // CATEGORY DROPDOWN
        // ========================================================

        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius:
                BorderRadius.circular(16),
            border: Border.all(
              color:
                  AppTheme.gold.withValues(
                alpha: dark ? 0.35 : 0.25,
              ),
            ),
          ),
          child: categories.isEmpty
              ? Padding(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 17,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons
                            .category_outlined,
                        color:
                            AppTheme.textMuted,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          _categoryReportType ==
                                  'Income'
                              ? 'এই মাসে কোনো আয়ের খাত নেই'
                              : 'এই মাসে কোনো ব্যয়ের খাত নেই',
                          style: TextStyle(
                            color:
                                AppTheme.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : DropdownButtonHideUnderline(
                  child:
                      DropdownButton<String>(
                    value:
                        categories.contains(
                      _selectedCategory,
                    )
                            ? _selectedCategory
                            : categories
                                .first,
                    isExpanded: true,
                    dropdownColor:
                        AppTheme.cardColor,
                    icon: Icon(
                      Icons
                          .keyboard_arrow_down_rounded,
                      color: dark
                          ? AppTheme.gold
                          : AppTheme.darkGreen,
                    ),
                    style: TextStyle(
                      color:
                          AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w700,
                    ),
                    items: categories
                        .map(
                          (category) =>
                              DropdownMenuItem<
                                  String>(
                            value: category,
                            child: Text(
                              category,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        _selectedCategory =
                            value;
                      });
                    },
                  ),
                ),
        ),

        const SizedBox(height: 16),

        // ========================================================
        // CATEGORY REPORT PREVIEW
        // ========================================================

        if (_selectedCategory != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: FittedBox(
              fit: BoxFit.fitWidth,
              alignment:
                  Alignment.topCenter,
              child: Screenshot(
                controller:
                    _categoryScreenshotController,
                child:
                    _buildCategoryA4Report(),
              ),
            ),
          ),

        const SizedBox(height: 18),

        // ========================================================
        // SAVE BUTTON
        // ========================================================

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed:
                (_selectedCategory == null ||
                        _savingCategoryImage)
                    ? null
                    : _saveCategoryReportImage,
            icon: _savingCategoryImage
                ? const SizedBox(
                    width: 19,
                    height: 19,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons
                        .save_alt_rounded,
                  ),
            label: const Text(
              'Gallery-তে রিপোর্ট Save করুন',
            ),
            style:
                ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(
                vertical: 15,
              ),
              backgroundColor: dark
                  ? AppTheme.gold
                  : AppTheme.darkGreen,
              foregroundColor: dark
                  ? Colors.black
                  : Colors.white,
              disabledBackgroundColor:
                  Colors.grey.shade400,
              disabledForegroundColor:
                  Colors.white,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(14),
              ),
            ),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'নির্বাচিত মাসের ১ তারিখ থেকে আজ পর্যন্ত লেনদেন দেখাবে',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INCOME / EXPENSE BUTTON
  // ============================================================

  Widget _buildIncomeExpenseButton({
    required String title,
    required IconData icon,
    required bool selected,
    required bool dark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(12),
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: selected
              ? (dark
                  ? AppTheme.gold
                  : AppTheme.darkGreen)
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected
                  ? (dark
                      ? Colors.black
                      : Colors.white)
                  : AppTheme.textMuted,
            ),

            const SizedBox(width: 6),

            Text(
              title,
              style: TextStyle(
                color: selected
                    ? (dark
                        ? Colors.black
                        : Colors.white)
                    : AppTheme.textPrimary,
                fontSize: 13,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MONTH SELECTOR
  // ============================================================

  Widget _buildMonthSelector(
    ThemeData theme,
    bool dark,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.gold.withValues(
            alpha: dark ? 0.35 : 0.25,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _previousMonth,
            icon: Icon(
              Icons.chevron_left_rounded,
              color: dark
                  ? AppTheme.gold
                  : AppTheme.darkGreen,
              size: 30,
            ),
          ),

          Expanded(
            child: InkWell(
              borderRadius:
                  BorderRadius.circular(12),
              onTap: _selectMonth,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 5,
                ),
                child: Column(
                  children: [
                    Text(
                      'রিপোর্টের মাস',
                      style: TextStyle(
                        color:
                            AppTheme.textMuted,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      DateFormat(
                        'MMMM yyyy',
                      ).format(
                        _selectedMonth,
                      ),
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        color:
                            AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      'মাস পরিবর্তন করতে চাপ দিন',
                      style: TextStyle(
                        color:
                            AppTheme.textMuted,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          IconButton(
            onPressed: _nextMonth,
            icon: Icon(
              Icons.chevron_right_rounded,
              color: dark
                  ? AppTheme.gold
                  : AppTheme.darkGreen,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}
