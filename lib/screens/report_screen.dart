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
  State<ReportScreen> createState() =>
      _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTime _selectedMonth = DateTime.now();

  List<MoneyTransaction> _transactions = [];

  bool _loading = true;
  bool _savingImage = false;
  bool _savingPdf = false;

  final ScreenshotController _screenshotController =
      ScreenshotController();

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

    final data =
        await MoneyDbHelper.instance.getAllTransactions();

    if (!mounted) return;

    setState(() {
      _transactions = data;
      _loading = false;
    });
  }

  DateTime? _parseDate(String date) {
    try {
      return DateFormat('dd/MM/yyyy').parse(date);
    } catch (_) {
      return null;
    }
  }

  List<MoneyTransaction> get _monthlyTransactions {
    return _transactions.where((item) {
      final date = _parseDate(item.date);

      if (date == null) return false;

      return date.year == _selectedMonth.year &&
          date.month == _selectedMonth.month;
    }).toList();
  }

  // ============================================================
  // INCOME / EXPENSE / TRANSFER
  // ============================================================

  List<MoneyTransaction> get _incomeTransactions {
    return _monthlyTransactions
        .where((e) => e.type == 'Income')
        .toList();
  }

  List<MoneyTransaction> get _expenseTransactions {
    return _monthlyTransactions
        .where((e) => e.type == 'Expense')
        .toList();
  }

  List<MoneyTransaction> get _transferTransactions {
    return _monthlyTransactions
        .where((e) => e.type == 'Transfer')
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
  // CATEGORY TOTAL
  // ============================================================

  Map<String, double> _categoryTotals(
    List<MoneyTransaction> transactions,
  ) {
    final Map<String, double> result = {};

    for (final item in transactions) {
      result[item.category] =
          (result[item.category] ?? 0) + item.amount;
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
  // MONTH
  // ============================================================

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
      );
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
    });
  }

  // ============================================================
  // MONEY FORMAT
  // ============================================================

  String _money(double amount) {
    return '৳ ${amount.toStringAsFixed(2)}';
  }

  // ============================================================
  // A4 REPORT WIDGET
  // ============================================================

  Widget _buildA4Report() {
    final income = _incomeCategories.entries.toList();
    final expense = _expenseCategories.entries.toList();

    final int maxRows =
        income.length > expense.length
            ? income.length
            : expense.length;

    return Container(
      width: 794,
      color: Colors.white,
      padding: const EdgeInsets.all(35),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Colors.black,
          fontFamily: 'Arial',
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            // ------------------------------------------------
            // HEADER
            // ------------------------------------------------

            const Text(
              'সহজ হিসাব গোল্ড',
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
              DateFormat(
                'MMMM yyyy',
              ).format(_selectedMonth),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 25),

            // ------------------------------------------------
            // LEFT INCOME + RIGHT EXPENSE
            // ------------------------------------------------

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
                  // ==============================
                  // LEFT - INCOME
                  // ==============================

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

                  // ==============================
                  // RIGHT - EXPENSE
                  // ==============================

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

            // ------------------------------------------------
            // BALANCE
            // ------------------------------------------------

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
                      fontWeight:
                          FontWeight.w900,
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
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // ------------------------------------------------
            // TRANSACTION COUNT
            // ------------------------------------------------

            Text(
              'মোট লেনদেন: ${_monthlyTransactions.length} টি',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildA4Side({
    required String title,
    required List<
            MapEntry<String, double>>
        items,
    required double total,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: [
        // Header
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

        // Empty
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

        // Rows
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

        // Total
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
                style: const TextStyle(
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
  // CAPTURE A4 IMAGE
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
      constraints: const BoxConstraints(
        maxWidth: 794,
      ),
    );

    return image;
  }

  // ============================================================
  // SAVE IMAGE TO GALLERY
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
          DateFormat('MM-yyyy')
              .format(_selectedMonth);

      await Gal.putImageBytes(
        image,
        album: 'সহজ হিসাব গোল্ড',
        name:
            'Shohoj_Hisab_Report_$month',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'রিপোর্টটি Gallery-তে Save হয়েছে',
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
          DateFormat('MM-yyyy')
              .format(_selectedMonth);

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
  // MAIN UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = AppTheme.isDark;

    return Scaffold(
      backgroundColor:
          AppTheme.background,

      appBar: AppBar(
        title: Text(
          'মাসিক রিপোর্ট',
          style: TextStyle(
            color: dark
                ? AppTheme.gold
                : AppTheme.darkGreen,
            fontWeight:
                FontWeight.w800,
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
                  30,
                ),
                child: Column(
                  children: [
                    // ========================================
                    // MONTH SELECTOR
                    // ========================================

                    _buildMonthSelector(
                      theme,
                      dark,
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // ========================================
                    // LIVE PREVIEW
                    // ========================================

                    Container(
                      width:
                          double.infinity,
                      padding:
                          const EdgeInsets
                              .all(8),
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.grey.shade200,
                        borderRadius:
                            BorderRadius
                                .circular(12),
                      ),
                      child:
                          FittedBox(
                        fit:
                            BoxFit.fitWidth,
                        alignment:
                            Alignment.topCenter,
                        child: Screenshot(
                          controller:
                              _screenshotController,
                          child:
                              _buildA4Report(),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    // ========================================
                    // SAVE BUTTONS
                    // ========================================

                    Row(
                      children: [
                        Expanded(
                          child:
                              ElevatedButton.icon(
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
                                      strokeWidth:
                                          2,
                                    ),
                                  )
                                : const Icon(
                                    Icons
                                        .image_outlined,
                                  ),
                            label:
                                const Text(
                              'Save as Image',
                            ),
                            style:
                                ElevatedButton
                                    .styleFrom(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                vertical: 15,
                              ),
                              backgroundColor:
                                  dark
                                      ? AppTheme
                                          .gold
                                      : AppTheme
                                          .darkGreen,
                              foregroundColor:
                                  dark
                                      ? Colors
                                          .black
                                      : Colors
                                          .white,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  14,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Expanded(
                          child:
                              ElevatedButton.icon(
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
                                      strokeWidth:
                                          2,
                                    ),
                                  )
                                : const Icon(
                                    Icons
                                        .picture_as_pdf_outlined,
                                  ),
                            label:
                                const Text(
                              'Save as PDF',
                            ),
                            style:
                                ElevatedButton
                                    .styleFrom(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                vertical: 15,
                              ),
                              backgroundColor:
                                  Colors
                                      .redAccent,
                              foregroundColor:
                                  Colors.white,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      'Image: A4 • Gallery-তে Save হবে',
                      style: TextStyle(
                        color:
                            AppTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
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
            alpha:
                dark ? 0.35 : 0.25,
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
                  BorderRadius.circular(
                12,
              ),
              onTap: _selectMonth,
              child: Padding(
                padding:
                    const EdgeInsets
                        .symmetric(
                  vertical: 5,
                ),
                child: Column(
                  children: [
                    Text(
                      'রিপোর্টের মাস',
                      style: TextStyle(
                        color:
                            AppTheme
                                .textMuted,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

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
                            AppTheme
                                .textPrimary,
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height: 2,
                    ),

                    Text(
                      'মাস পরিবর্তন করতে চাপ দিন',
                      style: TextStyle(
                        color:
                            AppTheme
                                .textMuted,
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
