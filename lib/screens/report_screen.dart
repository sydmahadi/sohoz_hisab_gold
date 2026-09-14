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
    _loadTransactions();
  }

  // =========================================================
  // LOAD DATA
  // =========================================================

  Future<void> _loadTransactions() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    try {
      final all =
          await MoneyDbHelper.instance.getAllTransactions();

      final filtered = all.where((transaction) {
        final date = DateTime.tryParse(transaction.date);

        if (date == null) {
          return false;
        }

        return date.year == _selectedMonth.year &&
            date.month == _selectedMonth.month;
      }).toList();

      if (!mounted) return;

      setState(() {
        _transactions = filtered;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _transactions = [];
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'রিপোর্ট লোড করতে সমস্যা হয়েছে: $e',
          ),
        ),
      );
    }
  }

  // =========================================================
  // MONTH
  // =========================================================

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
        1,
      );
    });

    _loadTransactions();
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        1,
      );
    });

    _loadTransactions();
  }

  String _monthName() {
    return DateFormat(
      'MMMM yyyy',
      'en',
    ).format(_selectedMonth);
  }

  String _money(double value) {
    return '৳ ${value.toStringAsFixed(2)}';
  }

  // =========================================================
  // TOTALS
  // =========================================================

  double get _totalIncome {
    return _transactions
        .where((e) => e.type == 'Income')
        .fold(
          0.0,
          (sum, e) => sum + e.amount,
        );
  }

  double get _totalExpense {
    return _transactions
        .where((e) => e.type == 'Expense')
        .fold(
          0.0,
          (sum, e) => sum + e.amount,
        );
  }

  double get _totalTransfer {
    return _transactions
        .where((e) => e.type == 'Transfer')
        .fold(
          0.0,
          (sum, e) => sum + e.amount,
        );
  }

  double get _balance {
    return _totalIncome - _totalExpense;
  }

  Map<String, double> get _incomeCategories {
    final Map<String, double> result = {};

    for (final transaction in _transactions) {
      if (transaction.type != 'Income') {
        continue;
      }

      result[transaction.category] =
          (result[transaction.category] ?? 0) +
              transaction.amount;
    }

    return result;
  }

  Map<String, double> get _expenseCategories {
    final Map<String, double> result = {};

    for (final transaction in _transactions) {
      if (transaction.type != 'Expense') {
        continue;
      }

      result[transaction.category] =
          (result[transaction.category] ?? 0) +
              transaction.amount;
    }

    return result;
  }

  // =========================================================
  // DARK SCREEN REPORT
  // =========================================================

  Widget _summaryCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            _money(amount),
            style: TextStyle(
              color: color,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _balanceCard() {
    final positive = _balance >= 0;

    final color = positive
        ? Colors.greenAccent
        : Colors.redAccent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: color.withOpacity(0.22),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              positive
                  ? Icons.account_balance_wallet_rounded
                  : Icons.warning_amber_rounded,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  positive
                      ? 'বর্তমান ব্যালেন্স'
                      : 'বর্তমান ঘাটতি',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _money(_balance.abs()),
                  style: TextStyle(
                    color: color,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryCard({
    required String title,
    required double amount,
    required Map<String, double> categories,
    required bool income,
  }) {
    final color = income
        ? Colors.greenAccent
        : Colors.redAccent;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: color.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          Text(
            _money(amount),
            style: TextStyle(
              color: color,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 13),

          if (categories.isEmpty)
            Text(
              'কোনো তথ্য নেই',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
              ),
            )
          else
            ...categories.entries.map(
              (entry) {
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            color:
                                AppTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _money(entry.value),
                        style: TextStyle(
                          color:
                              AppTheme.textPrimary,
                          fontSize: 11,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _infoRow(
    String title,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 12,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color:
                valueColor ?? AppTheme.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _darkReport() {
    final positive = _balance >= 0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 4,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.gold.withOpacity(0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'সহজ হিসাব গোল্ড',
            style: TextStyle(
              color: AppTheme.goldLight,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'মাসিক আয়-ব্যয়ের রিপোর্ট',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            _monthName(),
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 19),

          Container(
            height: 1,
            color: AppTheme.gold.withOpacity(0.14),
          ),

          const SizedBox(height: 17),

          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  title: 'মোট আয়',
                  amount: _totalIncome,
                  icon:
                      Icons.arrow_downward_rounded,
                  color: Colors.greenAccent,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _summaryCard(
                  title: 'মোট ব্যয়',
                  amount: _totalExpense,
                  icon:
                      Icons.arrow_upward_rounded,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          _balanceCard(),

          const SizedBox(height: 15),

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _categoryCard(
                  title: 'আয়',
                  amount: _totalIncome,
                  categories:
                      _incomeCategories,
                  income: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _categoryCard(
                  title: 'ব্যয়',
                  amount: _totalExpense,
                  categories:
                      _expenseCategories,
                  income: false,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _infoRow(
                  'মোট লেনদেন',
                  '${_transactions.length} টি',
                ),
                const SizedBox(height: 10),
                _infoRow(
                  'মোট ট্রান্সফার',
                  _money(_totalTransfer),
                ),
                const SizedBox(height: 10),
                _infoRow(
                  'ফলাফল',
                  positive ? 'উদ্বৃত্ত' : 'ঘাটতি',
                  valueColor: positive
                      ? Colors.greenAccent
                      : Colors.redAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // WHITE A4 REPORT FOR IMAGE
  // =========================================================

  Widget _a4Summary(
    String title,
    double amount,
    Color color,
    Color background,
  ) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            _money(amount),
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _a4CategoryCard({
    required String title,
    required double amount,
    required Map<String, double> categories,
    required bool income,
  }) {
    final color = income
        ? Colors.green.shade800
        : Colors.red.shade800;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            _money(amount),
            style: TextStyle(
              color: color,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 16),

          if (categories.isEmpty)
            const Text(
              'কোনো তথ্য নেই',
              style: TextStyle(
                color: Colors.black45,
                fontSize: 12,
              ),
            )
          else
            ...categories.entries.map(
              (entry) {
                return Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style:
                              const TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        _money(entry.value),
                        style:
                            const TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _a4InfoRow(
    String title,
    String value,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildA4Report() {
    final positive = _balance >= 0;

    return Container(
      width: 794,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        42,
        38,
        42,
        30,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Column(
              children: [
                const Text(
                  'সহজ হিসাব গোল্ড',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'মাসিক আয়-ব্যয়ের রিপোর্ট',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  _monthName(),
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Container(
            height: 1,
            color: Colors.black12,
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                child: _a4Summary(
                  'মোট আয়',
                  _totalIncome,
                  Colors.green.shade800,
                  const Color(0xFFEAF7EE),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _a4Summary(
                  'মোট ব্যয়',
                  _totalExpense,
                  Colors.red.shade800,
                  const Color(0xFFFFEEEE),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _a4Summary(
                  'ব্যালেন্স',
                  _balance,
                  positive
                      ? Colors.green.shade800
                      : Colors.red.shade800,
                  const Color(0xFFFFF8E8),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _a4CategoryCard(
                  title: 'আয়ের বিবরণ',
                  amount: _totalIncome,
                  categories:
                      _incomeCategories,
                  income: true,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _a4CategoryCard(
                  title: 'ব্যয়ের বিবরণ',
                  amount: _totalExpense,
                  categories:
                      _expenseCategories,
                  income: false,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius:
                  BorderRadius.circular(13),
              border: Border.all(
                color: Colors.black12,
              ),
            ),
            child: Column(
              children: [
                _a4InfoRow(
                  'মোট লেনদেন',
                  '${_transactions.length} টি',
                ),
                const SizedBox(height: 10),
                _a4InfoRow(
                  'মোট ট্রান্সফার',
                  _money(_totalTransfer),
                ),
                const SizedBox(height: 10),
                _a4InfoRow(
                  'ফলাফল',
                  positive
                      ? 'উদ্বৃত্ত'
                      : 'ঘাটতি',
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // FOOTER IS ONLY INSIDE SAVED IMAGE/PDF
          Container(
            padding: const EdgeInsets.only(
              top: 10,
            ),
            decoration:
                const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.black26,
                  width: 0.7,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                const Text(
                  'সহজ হিসাব গোল্ড',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Develop by Sayeed Mahadi',
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 8,
                  ),
                ),
                const SizedBox(height: 1),
                const Text(
                  'mahadisayeed@gmail.com',
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // CREATE IMAGE
  // =========================================================

  Future<Uint8List?> _captureA4Image() async {
    try {
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
        delay: const Duration(
          milliseconds: 400,
        ),
        context: context,
        pixelRatio: 2,
        constraints:
            const BoxConstraints(
          maxWidth: 794,
        ),
      );

      return image;
    } catch (e) {
      if (!mounted) return null;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'রিপোর্ট তৈরি করতে সমস্যা হয়েছে: $e',
          ),
        ),
      );

      return null;
    }
  }

  // =========================================================
  // SAVE IMAGE
  // =========================================================

  Future<void> _saveAsImage() async {
    if (_savingImage) return;

    setState(() {
      _savingImage = true;
    });

    try {
      final image =
          await _captureA4Image();

      if (image == null) return;

      bool access =
          await Gal.hasAccess();

      if (!access) {
        access =
            await Gal.requestAccess();
      }

      if (!access) {
        throw Exception(
          'Gallery permission দেওয়া হয়নি',
        );
      }

      await Gal.putImageBytes(
        image,
        album: 'সহজ হিসাব গোল্ড',
        name:
            'Shohoj_Hisab_Report_${DateFormat('yyyy_MM').format(_selectedMonth)}',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'রিপোর্ট ছবি হিসেবে সংরক্ষণ হয়েছে',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'ছবি সংরক্ষণ করা যায়নি: $e',
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

  // =========================================================
  // CREATE REAL PDF
  // =========================================================

  Future<Uint8List> _createPdfBytes() async {
    final pdf = pw.Document();

    final incomeCategories =
        _incomeCategories;
    final expenseCategories =
        _expenseCategories;

    final positive = _balance >= 0;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Container(
            color: PdfColors.white,
            child: pw.Column(
              crossAxisAlignment:
                  pw.CrossAxisAlignment
                      .stretch,
              children: [
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'Shohoj Hisab Gold',
                        style: pw.TextStyle(
                          fontSize: 25,
                          fontWeight:
                              pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Monthly Income & Expense Report',
                        style:
                            const pw.TextStyle(
                          fontSize: 13,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        _monthName(),
                        style:
                            const pw.TextStyle(
                          fontSize: 11,
                          color:
                              PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                pw.Divider(),

                pw.SizedBox(height: 15),

                pw.Row(
                  children: [
                    pw.Expanded(
                      child: _pdfSummary(
                        'Total Income',
                        _totalIncome,
                        PdfColors.green800,
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Expanded(
                      child: _pdfSummary(
                        'Total Expense',
                        _totalExpense,
                        PdfColors.red800,
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Expanded(
                      child: _pdfSummary(
                        'Balance',
                        _balance,
                        positive
                            ? PdfColors.green800
                            : PdfColors.red800,
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 18),

                pw.Row(
                  crossAxisAlignment:
                      pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child:
                          _pdfCategoryBox(
                        title:
                            'Income Details',
                        amount:
                            _totalIncome,
                        categories:
                            incomeCategories,
                        color:
                            PdfColors.green800,
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child:
                          _pdfCategoryBox(
                        title:
                            'Expense Details',
                        amount:
                            _totalExpense,
                        categories:
                            expenseCategories,
                        color:
                            PdfColors.red800,
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 18),

                pw.Container(
                  padding:
                      const pw.EdgeInsets.all(
                    14,
                  ),
                  decoration:
                      pw.BoxDecoration(
                    color:
                        PdfColors.grey100,
                    borderRadius:
                        pw.BorderRadius
                            .circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      _pdfInfoRow(
                        'Total Transactions',
                        '${_transactions.length}',
                      ),
                      pw.SizedBox(height: 8),
                      _pdfInfoRow(
                        'Total Transfer',
                        _money(_totalTransfer),
                      ),
                      pw.SizedBox(height: 8),
                      _pdfInfoRow(
                        'Result',
                        positive
                            ? 'Surplus'
                            : 'Deficit',
                      ),
                    ],
                  ),
                ),

                pw.Spacer(),

                pw.Divider(),

                pw.SizedBox(height: 6),

                pw.Align(
                  alignment:
                      pw.Alignment.centerRight,
                  child: pw.Column(
                    crossAxisAlignment:
                        pw.CrossAxisAlignment
                            .end,
                    children: [
                      pw.Text(
                        'সহজ হিসাব গোল্ড',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight:
                              pw.FontWeight.bold,
                          color:
                              PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        'Develop by Sayeed Mahadi',
                        style:
                            const pw.TextStyle(
                          fontSize: 8,
                          color:
                              PdfColors.grey600,
                        ),
                      ),
                      pw.Text(
                        'mahadisayeed@gmail.com',
                        style:
                            const pw.TextStyle(
                          fontSize: 8,
                          color:
                              PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _pdfSummary(
    String title,
    double amount,
    PdfColor color,
  ) {
    return pw.Container(
      padding:
          const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius:
            pw.BorderRadius.circular(7),
      ),
      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style:
                const pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            _money(amount),
            style: pw.TextStyle(
              fontSize: 15,
              fontWeight:
                  pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfCategoryBox({
    required String title,
    required double amount,
    required Map<String, double>
        categories,
    required PdfColor color,
  }) {
    return pw.Container(
      padding:
          const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.grey300,
        ),
        borderRadius:
            pw.BorderRadius.circular(7),
      ),
      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight:
                  pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 7),
          pw.Text(
            _money(amount),
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight:
                  pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 10),
          if (categories.isEmpty)
            pw.Text(
              'No data',
              style:
                  const pw.TextStyle(
                fontSize: 9,
                color:
                    PdfColors.grey600,
              ),
            )
          else
            ...categories.entries.map(
              (entry) {
                return pw.Padding(
                  padding:
                      const pw.EdgeInsets
                          .only(
                    bottom: 6,
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          entry.key,
                          style:
                              const pw.TextStyle(
                            fontSize: 9,
                          ),
                        ),
                      ),
                      pw.Text(
                        _money(entry.value),
                        style:
                            pw.TextStyle(
                          fontSize: 9,
                          fontWeight:
                              pw.FontWeight
                                  .bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  pw.Widget _pdfInfoRow(
    String title,
    String value,
  ) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.Text(
            title,
            style:
                const pw.TextStyle(
              fontSize: 9,
              color:
                  PdfColors.grey700,
            ),
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight:
                pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // SAVE PDF
  // =========================================================

  Future<void> _saveAsPdf() async {
    if (_savingPdf) return;

    setState(() {
      _savingPdf = true;
    });

    try {
      final pdfBytes =
          await _createPdfBytes();

      final fileName =
          'Shohoj_Hisab_Report_${DateFormat('yyyy_MM').format(_selectedMonth)}.pdf';

      // Opens Android's PDF share/save/print
      // system with a REAL PDF file.
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: fileName,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'PDF তৈরি করা যায়নি: $e',
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

  // =========================================================
  // ACTION BUTTON
  // =========================================================

  Widget _actionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool loading,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed:
            loading ? null : onTap,
        icon: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : Icon(icon),
        label: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              AppTheme.gold,
          foregroundColor:
              Colors.black,
          padding:
              const EdgeInsets.symmetric(
            vertical: 13,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppTheme.background,

      appBar: AppBar(
        backgroundColor:
            AppTheme.background,
        foregroundColor:
            AppTheme.textPrimary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'মাসিক রিপোর্ট',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed:
                _loading
                    ? null
                    : _loadTransactions,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),

      body: _loading
          ? Center(
              child:
                  CircularProgressIndicator(
                color: AppTheme.gold,
              ),
            )
          : Column(
              children: [
                // MONTH SELECTOR
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    14,
                    5,
                    14,
                    9,
                  ),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 4,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          AppTheme.cardColor,
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                      border: Border.all(
                        color: AppTheme.gold
                            .withOpacity(0.18),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed:
                              _previousMonth,
                          icon: const Icon(
                            Icons
                                .chevron_left_rounded,
                          ),
                          color:
                              AppTheme.gold,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'রিপোর্ট মাস',
                                style:
                                    TextStyle(
                                  color: AppTheme
                                      .textMuted,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                _monthName(),
                                style:
                                    TextStyle(
                                  color: AppTheme
                                      .textPrimary,
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight
                                          .w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed:
                              _nextMonth,
                          icon: const Icon(
                            Icons
                                .chevron_right_rounded,
                          ),
                          color:
                              AppTheme.gold,
                        ),
                      ],
                    ),
                  ),
                ),

                // DARK SCREEN REPORT
                Expanded(
                  child:
                      SingleChildScrollView(
                    padding:
                        const EdgeInsets.only(
                      bottom: 8,
                    ),
                    child: _darkReport(),
                  ),
                ),

                // IMAGE / PDF BUTTONS
                SafeArea(
                  top: false,
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      12,
                      6,
                      12,
                      10,
                    ),
                    child: Row(
                      children: [
                        _actionButton(
                          icon: Icons
                              .image_rounded,
                          title: 'ছবি',
                          onTap:
                              _saveAsImage,
                          loading:
                              _savingImage,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        _actionButton(
                          icon: Icons
                              .picture_as_pdf_rounded,
                          title: 'PDF',
                          onTap:
                              _saveAsPdf,
                          loading:
                              _savingPdf,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
