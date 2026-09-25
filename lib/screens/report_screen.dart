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

enum _ReportMode {
  monthly,
  category,
}

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTime _selectedMonth = DateTime.now();

  List<MoneyTransaction> _transactions = [];

  bool _loading = true;
  bool _savingImage = false;
  bool _savingPdf = false;

  _ReportMode _reportMode = _ReportMode.monthly;

  String _categoryType = 'Expense';
  String? _selectedCategory;

  int _categoryPage = 0;

  final ScreenshotController _screenshotController =
      ScreenshotController();

  static const int _transactionsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> _loadReport() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    try {
      final data =
          await MoneyDbHelper.instance.getAllTransactions();

      if (!mounted) return;

      setState(() {
        _transactions = data;
        _loading = false;
      });

      _prepareCategory();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _transactions = [];
        _loading = false;
      });
    }
  }

  // ============================================================
  // DATE PARSER
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
      'yyyy/MM/dd HH:mm',
    ];

    for (final format in formats) {
      try {
        return DateFormat(format).parseStrict(value);
      } catch (_) {}
    }

    return DateTime.tryParse(value);
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

    result.sort((a, b) {
      final da = _parseDate(a.date);
      final db = _parseDate(b.date);

      if (da == null && db == null) {
        return (a.id ?? 0).compareTo(b.id ?? 0);
      }

      if (da == null) return 1;
      if (db == null) return -1;

      final dateResult = da.compareTo(db);

      if (dateResult != 0) {
        return dateResult;
      }

      return (a.id ?? 0).compareTo(b.id ?? 0);
    });

    return result;
  }

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
  // CATEGORY TOTALS
  // ============================================================

  Map<String, double> _categoryTotals(
    List<MoneyTransaction> transactions,
  ) {
    final Map<String, double> result = {};

    for (final item in transactions) {
      final category = item.category.trim().isEmpty
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
  // CATEGORY REPORT
  // ============================================================

  List<String> get _availableCategories {
    final source = _categoryType == 'Income'
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
      (a, b) => a.toLowerCase().compareTo(
            b.toLowerCase(),
          ),
    );

    return categories;
  }

  void _prepareCategory() {
    final categories = _availableCategories;

    if (categories.isEmpty) {
      if (mounted) {
        setState(() {
          _selectedCategory = null;
          _categoryPage = 0;
        });
      }
      return;
    }

    if (_selectedCategory == null ||
        !categories.contains(_selectedCategory)) {
      if (mounted) {
        setState(() {
          _selectedCategory = categories.first;
          _categoryPage = 0;
        });
      }
    }
  }

  List<MoneyTransaction> get _categoryTransactions {
    if (_selectedCategory == null) {
      return [];
    }

    final selected =
        _selectedCategory!.trim();

    final result = _monthlyTransactions.where((item) {
      final sameType =
          item.type.toLowerCase() ==
              _categoryType.toLowerCase();

      final itemCategory =
          item.category.trim().isEmpty
              ? 'অন্যান্য'
              : item.category.trim();

      return sameType &&
          itemCategory.toLowerCase() ==
              selected.toLowerCase();
    }).toList();

    result.sort((a, b) {
      final da = _parseDate(a.date);
      final db = _parseDate(b.date);

      if (da == null && db == null) {
        return (a.id ?? 0).compareTo(b.id ?? 0);
      }

      if (da == null) return 1;
      if (db == null) return -1;

      final dateResult = da.compareTo(db);

      if (dateResult != 0) {
        return dateResult;
      }

      return (a.id ?? 0).compareTo(b.id ?? 0);
    });

    return result;
  }

  int get _categoryPageCount {
    final count = _categoryTransactions.length;

    if (count == 0) {
      return 1;
    }

    return (count + _transactionsPerPage - 1) ~/
        _transactionsPerPage;
  }

  List<MoneyTransaction>
      get _currentCategoryPageTransactions {
    final all = _categoryTransactions;

    if (all.isEmpty) {
      return [];
    }

    final maxPage = _categoryPageCount - 1;

    if (_categoryPage > maxPage) {
      _categoryPage = maxPage;
    }

    final start =
        _categoryPage * _transactionsPerPage;

    return all
        .skip(start)
        .take(_transactionsPerPage)
        .toList();
  }

  double get _categoryGrandTotal {
    return _categoryTransactions.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );
  }

  // ============================================================
  // MONTH NAVIGATION
  // ============================================================

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
      );

      _categoryPage = 0;
    });

    _prepareCategory();
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
      );

      _categoryPage = 0;
    });

    _prepareCategory();
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

      _categoryPage = 0;
    });

    _prepareCategory();
  }

  // ============================================================
  // CATEGORY TYPE / CATEGORY CHANGE
  // ============================================================

  void _changeCategoryType(String type) {
    setState(() {
      _categoryType = type;
      _selectedCategory = null;
      _categoryPage = 0;
    });

    _prepareCategory();
  }

  void _changeCategory(String? category) {
    setState(() {
      _selectedCategory = category;
      _categoryPage = 0;
    });
  }

  // ============================================================
  // MONEY / DISPLAY
  // ============================================================

  String _money(double amount) {
    return '৳ ${amount.toStringAsFixed(2)}';
  }

  String _displayDate(String value) {
    final date = _parseDate(value);

    if (date == null) {
      return value;
    }

    return DateFormat(
      'dd/MM/yyyy',
    ).format(date);
  }

  String _safeFileName(String value) {
    return value
        .replaceAll(
          RegExp(r'[\\/:*?"<>|]'),
          '_',
        )
        .replaceAll(' ', '_');
  }

  // ============================================================
  // MONTHLY A4 REPORT
  // ============================================================

  Widget _buildA4Report() {
    final income =
        _incomeCategories.entries.toList();

    final expense =
        _expenseCategories.entries.toList();

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

            Align(
              alignment: Alignment.bottomRight,
              child: Opacity(
                opacity: 0.38,
                child: SizedBox(
                  width: 150,
                  child: const Text(
                    'সহজ হিসাব',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF777777),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
  // CATEGORY VOUCHER
  // ============================================================

  Widget _buildCategoryVoucher({
    required List<MoneyTransaction> transactions,
    required int pageIndex,
    required int totalPages,
  }) {
    final isIncome =
        _categoryType == 'Income';

    final pageTotal =
        transactions.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );

    return Container(
      width: 794,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        32,
        30,
        32,
        28,
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Colors.black,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            const Text(
              'সহজ হিসাব',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              isIncome
                  ? 'খাতভিত্তিক আয় রিপোর্ট'
                  : 'খাতভিত্তিক ব্যয় রিপোর্ট',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              DateFormat('MMMM yyyy').format(
                _selectedMonth,
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 18),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black54,
                ),
                borderRadius:
                    BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Text(
                    'খাত:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      _selectedCategory ??
                          'কোনো খাত নেই',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),

                  Text(
                    isIncome ? 'আয়' : 'ব্যয়',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isIncome
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (transactions.isEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 45,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black26,
                  ),
                  borderRadius:
                      BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 45,
                      color: Colors.black45,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'এই খাতে কোনো Transaction নেই',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black54,
                  ),
                  borderRadius:
                      BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildCategoryTableHeader(),

                    ...transactions
                        .asMap()
                        .entries
                        .map(
                      (entry) {
                        final index = entry.key;
                        final item = entry.value;

                        return _buildCategoryTableRow(
                          index + 1,
                          item,
                        );
                      },
                    ),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 13,
                      ),
                      color: const Color(
                        0xFFF2F2F2,
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'এই পৃষ্ঠার মোট',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                          ),
                          Text(
                            _money(pageTotal),
                            style:
                                const TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 14),

            Container(
              padding:
                  const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black26,
                ),
                borderRadius:
                    BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'সব পৃষ্ঠার মোট',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    _money(_categoryGrandTotal),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'মোট Transaction: '
                  '${_categoryTransactions.length} টি',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                Text(
                  'পৃষ্ঠা ${pageIndex + 1} / $totalPages',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Align(
              alignment: Alignment.bottomRight,
              child: Opacity(
                opacity: 0.35,
                child: const Text(
                  'সহজ হিসাব',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTableHeader() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 11,
      ),
      color: const Color(0xFFEFEFEF),
      child: Row(
        children: [
          const SizedBox(
            width: 38,
            child: Text(
              'নং',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(
            width: 95,
            child: Text(
              'তারিখ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const Expanded(
            flex: 2,
            child: Text(
              'বিবরণ / নোট',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const Expanded(
            flex: 1,
            child: Text(
              'অ্যাকাউন্ট',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(
            width: 105,
            child: Text(
              'পরিমাণ',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTableRow(
    int number,
    MoneyTransaction item,
  ) {
    final note =
        item.note?.trim() ?? '';

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 11,
      ),
      decoration:
          const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.black12,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 38,
            child: Text(
              '$number',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          SizedBox(
            width: 95,
            child: Text(
              _displayDate(item.date),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            flex: 2,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 5,
              ),
              child: Text(
                note.isEmpty ? '—' : note,
                maxLines: 3,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          Expanded(
            flex: 1,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 4,
              ),
              child: Text(
                item.account,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(
            width: 105,
            child: Text(
              _money(item.amount),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SCREENSHOT
  // ============================================================

  Future<Uint8List> _captureWidget(
    Widget widget,
  ) async {
    final image =
        await _screenshotController
            .captureFromLongWidget(
      InheritedTheme.captureAll(
        context,
        Material(
          color: Colors.white,
          child: widget,
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

  Future<Uint8List> _captureMonthlyImage() async {
    return await _captureWidget(
      _buildA4Report(),
    );
  }

  Future<Uint8List> _captureCategoryPageImage(
    int page,
  ) async {
    final transactions =
        _categoryTransactions
            .skip(
              page * _transactionsPerPage,
            )
            .take(_transactionsPerPage)
            .toList();

    return await _captureWidget(
      _buildCategoryVoucher(
        transactions: transactions,
        pageIndex: page,
        totalPages: _categoryPageCount,
      ),
    );
  }

  // ============================================================
  // SAVE IMAGE
  // ============================================================

  Future<void> _saveAsImage() async {
    if (_savingImage) return;

    setState(() {
      _savingImage = true;
    });

    try {
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

      if (_reportMode ==
          _ReportMode.monthly) {
        final image =
            await _captureMonthlyImage();

        await Gal.putImageBytes(
          image,
          album: 'সহজ হিসাব',
          name:
              'Shohoj_Hisab_Report_$month',
        );
      } else {
        if (_categoryTransactions.isEmpty) {
          throw Exception(
            'এই খাতে কোনো Transaction নেই',
          );
        }

        final totalPages =
            _categoryPageCount;

        final category =
            _safeFileName(
          _selectedCategory ??
              'Category',
        );

        for (int page = 0;
            page < totalPages;
            page++) {
          final image =
              await _captureCategoryPageImage(
            page,
          );

          await Gal.putImageBytes(
            image,
            album: 'সহজ হিসাব',
            name:
                'Shohoj_Hisab_${_categoryType}_'
                '${category}_$month'
                '_Page_${page + 1}',
          );
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            _reportMode ==
                    _ReportMode.monthly
                ? 'রিপোর্টটি Gallery-তে Save হয়েছে'
                : '${_categoryPageCount}টি Page Gallery-তে Save হয়েছে',
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
  // SAVE PDF
  // ============================================================

  Future<void> _saveAsPdf() async {
    if (_savingPdf) return;

    setState(() {
      _savingPdf = true;
    });

    try {
      final pdf = pw.Document();

      final month =
          DateFormat('MM-yyyy').format(
        _selectedMonth,
      );

      if (_reportMode ==
          _ReportMode.monthly) {
        final image =
            await _captureMonthlyImage();

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

        await Printing.sharePdf(
          bytes: await pdf.save(),
          filename:
              'Shohoj_Hisab_Report_$month.pdf',
        );
      } else {
        if (_categoryTransactions.isEmpty) {
          throw Exception(
            'এই খাতে কোনো Transaction নেই',
          );
        }

        final totalPages =
            _categoryPageCount;

        final category =
            _safeFileName(
          _selectedCategory ??
              'Category',
        );

        for (int page = 0;
            page < totalPages;
            page++) {
          final image =
              await _captureCategoryPageImage(
            page,
          );

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
        }

        await Printing.sharePdf(
          bytes: await pdf.save(),
          filename:
              'Shohoj_Hisab_${_categoryType}_'
              '${category}_$month.pdf',
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            _reportMode ==
                    _ReportMode.monthly
                ? 'A4 PDF তৈরি হয়েছে'
                : '${_categoryPageCount} পৃষ্ঠার PDF তৈরি হয়েছে',
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
      decoration:
          BoxDecoration(
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

  // ============================================================
  // REPORT MODE SELECTOR
  // ============================================================

  Widget _buildReportModeSelector(
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
            alpha: dark ? 0.30 : 0.20,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _modeButton(
              title: 'মাসিক সারাংশ',
              icon:
                  Icons.analytics_outlined,
              selected:
                  _reportMode ==
                      _ReportMode.monthly,
              dark: dark,
              onTap: () {
                setState(() {
                  _reportMode =
                      _ReportMode.monthly;
                });
              },
            ),
          ),

          const SizedBox(width: 5),

          Expanded(
            child: _modeButton(
              title: 'খাতভিত্তিক রিপোর্ট',
              icon:
                  Icons.receipt_long_outlined,
              selected:
                  _reportMode ==
                      _ReportMode.category,
              dark: dark,
              onTap: () {
                setState(() {
                  _reportMode =
                      _ReportMode.category;
                  _categoryPage = 0;
                });

                _prepareCategory();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeButton({
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
                textAlign: TextAlign.center,
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
  // CATEGORY CONTROLS
  // ============================================================

  Widget _buildCategoryControls(
    bool dark,
  ) {
    final categories =
        _availableCategories;

    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius:
                BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Expanded(
                child: _typeButton(
                  title: 'আয়',
                  selected:
                      _categoryType ==
                          'Income',
                  icon:
                      Icons.arrow_downward_rounded,
                  dark: dark,
                  onTap: () {
                    _changeCategoryType(
                      'Income',
                    );
                  },
                ),
              ),

              const SizedBox(width: 5),

              Expanded(
                child: _typeButton(
                  title: 'ব্যয়',
                  selected:
                      _categoryType ==
                          'Expense',
                  icon:
                      Icons.arrow_upward_rounded,
                  dark: dark,
                  onTap: () {
                    _changeCategoryType(
                      'Expense',
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius:
                BorderRadius.circular(15),
            border: Border.all(
              color:
                  AppTheme.gold.withValues(
                alpha: dark ? 0.30 : 0.20,
              ),
            ),
          ),
          child: categories.isEmpty
              ? Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 17,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        color:
                            AppTheme.textMuted,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'এই মাসে কোনো খাত পাওয়া যায়নি',
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
                    value: categories.contains(
                      _selectedCategory,
                    )
                        ? _selectedCategory
                        : categories.first,
                    isExpanded: true,
                    icon: Icon(
                      Icons
                          .keyboard_arrow_down_rounded,
                      color: dark
                          ? AppTheme.gold
                          : AppTheme.darkGreen,
                    ),
                    dropdownColor:
                        AppTheme.cardColor,
                    items: categories.map(
                      (category) {
                        return DropdownMenuItem<
                            String>(
                          value: category,
                          child: Text(
                            category,
                            overflow:
                                TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppTheme
                                  .textPrimary,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        );
                      },
                    ).toList(),
                    onChanged:
                        _changeCategory,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _typeButton({
    required String title,
    required bool selected,
    required IconData icon,
    required bool dark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(11),
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: selected
              ? (title == 'আয়'
                  ? Colors.green.shade700
                  : Colors.red.shade700)
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(11),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected
                  ? Colors.white
                  : AppTheme.textMuted,
            ),

            const SizedBox(width: 5),

            Text(
              title,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PAGE NAVIGATION
  // ============================================================

  Widget _buildPageNavigation(
    bool dark,
  ) {
    if (_categoryTransactions.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalPages =
        _categoryPageCount;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              AppTheme.gold.withValues(
            alpha: dark ? 0.30 : 0.20,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _categoryPage > 0
                ? () {
                    setState(() {
                      _categoryPage--;
                    });
                  }
                : null,
            icon: const Icon(
              Icons.chevron_left_rounded,
            ),
          ),

          Expanded(
            child: Column(
              children: [
                Text(
                  'Voucher / Page',
                  style: TextStyle(
                    color:
                        AppTheme.textMuted,
                    fontSize: 10,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  'পৃষ্ঠা ${_categoryPage + 1} / $totalPages',
                  style: TextStyle(
                    color:
                        AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  '${_categoryTransactions.length}টি Transaction • প্রতি পৃষ্ঠায় সর্বোচ্চ ১০টি',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color:
                        AppTheme.textMuted,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed:
                _categoryPage <
                        totalPages - 1
                    ? () {
                        setState(() {
                          _categoryPage++;
                        });
                      }
                    : null,
            icon: const Icon(
              Icons.chevron_right_rounded,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SAVE BUTTONS
  // ============================================================

  Widget _buildSaveButtons(
    bool dark,
  ) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed:
                _savingImage || _savingPdf
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
            label: Text(
              _reportMode ==
                      _ReportMode.category
                  ? 'সব Page Image'
                  : 'Save as Image',
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
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(14),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: ElevatedButton.icon(
            onPressed:
                _savingImage || _savingPdf
                    ? null
                    : _saveAsPdf,
            icon: _savingPdf
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons
                        .picture_as_pdf_outlined,
                  ),
            label: Text(
              _reportMode ==
                      _ReportMode.category
                  ? 'সব Page PDF'
                  : 'Save as PDF',
            ),
            style:
                ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(
                vertical: 15,
              ),
              backgroundColor:
                  Colors.redAccent,
              foregroundColor:
                  Colors.white,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BUILD
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
                    _buildMonthSelector(
                      Theme.of(context),
                      dark,
                    ),

                    const SizedBox(height: 14),

                    _buildReportModeSelector(
                      dark,
                    ),

                    const SizedBox(height: 14),

                    if (_reportMode ==
                        _ReportMode.monthly)
                      _buildMonthlyReportBody(
                        dark,
                      )
                    else
                      _buildCategoryReportBody(
                        dark,
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  // ============================================================
  // MONTHLY BODY
  // ============================================================

  Widget _buildMonthlyReportBody(
    bool dark,
  ) {
    return Column(
      children: [
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
            alignment: Alignment.topCenter,
            child: Screenshot(
              controller:
                  _screenshotController,
              child:
                  _buildA4Report(),
            ),
          ),
        ),

        const SizedBox(height: 18),

        _buildSaveButtons(dark),

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
  // CATEGORY BODY
  // ============================================================

  Widget _buildCategoryReportBody(
    bool dark,
  ) {
    return Column(
      children: [
        _buildCategoryControls(dark),

        const SizedBox(height: 14),

        if (_categoryTransactions.isEmpty)
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(
              vertical: 25,
              horizontal: 15,
            ),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons
                      .receipt_long_outlined,
                  size: 42,
                  color:
                      AppTheme.textMuted,
                ),

                const SizedBox(height: 8),

                Text(
                  'এই মাসে এই খাতে কোনো Transaction নেই',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color:
                        AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ],
            ),
          )
        else ...[
          _buildPageNavigation(dark),

          const SizedBox(height: 14),

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
                child: _buildCategoryVoucher(
                  transactions:
                      _currentCategoryPageTransactions,
                  pageIndex:
                      _categoryPage,
                  totalPages:
                      _categoryPageCount,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          _buildSaveButtons(dark),

          const SizedBox(height: 6),

          Text(
            'প্রতি Page-এ সর্বোচ্চ ১০টি Transaction • '
            'সব Page আলাদা Image হিসেবে Gallery-তে Save হবে',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }
}
