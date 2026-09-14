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

  String? _errorMessage;

  final ScreenshotController _screenshotController =
      ScreenshotController();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  // ============================================================
  // LOAD TRANSACTIONS
  // ============================================================

  Future<void> _loadTransactions() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final all =
          await MoneyDbHelper.instance.getAllTransactions();

      final List<MoneyTransaction> filtered = [];

      for (final transaction in all) {
        final date = DateTime.tryParse(transaction.date);

        if (date == null) continue;

        if (date.year == _selectedMonth.year &&
            date.month == _selectedMonth.month) {
          filtered.add(transaction);
        }
      }

      if (!mounted) return;

      setState(() {
        _transactions = filtered;
        _loading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _transactions = [];
        _loading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // ============================================================
  // MONTH
  // ============================================================

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

  // ============================================================
  // TOTALS
  // ============================================================

  double get _totalIncome {
    double total = 0;

    for (final e in _transactions) {
      if (_isType(e.type, 'income')) {
        total += e.amount;
      }
    }

    return total;
  }

  double get _totalExpense {
    double total = 0;

    for (final e in _transactions) {
      if (_isType(e.type, 'expense')) {
        total += e.amount;
      }
    }

    return total;
  }

  double get _totalTransfer {
    double total = 0;

    for (final e in _transactions) {
      if (_isType(e.type, 'transfer')) {
        total += e.amount;
      }
    }

    return total;
  }

  double get _balance {
    return _totalIncome - _totalExpense;
  }

  // Handles Income/income/INCOME etc.
  bool _isType(String value, String expected) {
    return value.trim().toLowerCase() ==
        expected.toLowerCase();
  }

  // ============================================================
  // CATEGORIES
  // ============================================================

  Map<String, double> get _incomeCategories {
    final Map<String, double> result = {};

    for (final transaction in _transactions) {
      if (!_isType(transaction.type, 'income')) {
        continue;
      }

      final category =
          transaction.category.trim().isEmpty
              ? 'অন্যান্য'
              : transaction.category;

      result[category] =
          (result[category] ?? 0) + transaction.amount;
    }

    return result;
  }

  Map<String, double> get _expenseCategories {
    final Map<String, double> result = {};

    for (final transaction in _transactions) {
      if (!_isType(transaction.type, 'expense')) {
        continue;
      }

      final category =
          transaction.category.trim().isEmpty
              ? 'অন্যান্য'
              : transaction.category;

      result[category] =
          (result[category] ?? 0) + transaction.amount;
    }

    return result;
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 40,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.gold.withOpacity(0.15),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.gold.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 36,
              color: AppTheme.gold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'এই মাসে কোনো লেনদেন নেই',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'অন্য মাস দেখতে উপরের মাস পরিবর্তন করুন।',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _errorState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 15),
            Text(
              'রিপোর্ট লোড করা যায়নি',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'অজানা সমস্যা হয়েছে',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadTransactions,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('আবার চেষ্টা করুন'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: color,
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
          const SizedBox(height: 8),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              _money(amount),
              style: TextStyle(
                color: color,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BALANCE
  // ============================================================

  Widget _balanceCard() {
    final positive = _balance >= 0;

    final color =
        positive ? Colors.greenAccent : Colors.redAccent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
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
                const SizedBox(height: 4),
                FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _money(_balance.abs()),
                    style: TextStyle(
                      color: color,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORY CARD
  // ============================================================

  Widget _categoryCard({
    required String title,
    required double amount,
    required Map<String, double> categories,
    required bool income,
  }) {
    final color =
        income ? Colors.greenAccent : Colors.redAccent;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.13),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              _money(amount),
              style: TextStyle(
                color: color,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
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
              (entry) => Padding(
                padding:
                    const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        _money(entry.value),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow(
    String title,
    String value, {
    Color? color,
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
            color: color ?? AppTheme.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MAIN REPORT
  // ============================================================

  Widget _reportContent() {
    final positive = _balance >= 0;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 4,
      ),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.gold.withOpacity(0.16),
        ),
      ),
      child: Column(
        children: [
          Text(
            'সহজ হিসাব',
            style: TextStyle(
              color: AppTheme.goldLight,
              fontSize: 24,
              fontWeight: FontWeight.w900,
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
          const SizedBox(height: 18),
          Divider(
            color: AppTheme.gold.withOpacity(0.14),
            height: 1,
          ),
          const SizedBox(height: 16),

          // SUMMARY
          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  title: 'মোট আয়',
                  amount: _totalIncome,
                  icon: Icons.south_rounded,
                  color: Colors.greenAccent,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _summaryCard(
                  title: 'মোট ব্যয়',
                  amount: _totalExpense,
                  icon: Icons.north_rounded,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          _balanceCard(),

          const SizedBox(height: 14),

          // CATEGORIES
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _categoryCard(
                  title: 'আয়',
                  amount: _totalIncome,
                  categories: _incomeCategories,
                  income: true,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _categoryCard(
                  title: 'ব্যয়',
                  amount: _totalExpense,
                  categories: _expenseCategories,
                  income: false,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // EXTRA INFO
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Column(
              children: [
                _infoRow(
                  'মোট লেনদেন',
                  '${_transactions.length} টি',
                ),
                const SizedBox(height: 11),
                _infoRow(
                  'মোট ট্রান্সফার',
                  _money(_totalTransfer),
                ),
                const SizedBox(height: 11),
                _infoRow(
                  'ফলাফল',
                  positive ? 'উদ্বৃত্ত' : 'ঘাটতি',
                  color: positive
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

  // ============================================================
  // A4 IMAGE REPORT
  // ============================================================

  Widget _buildA4Report() {
    final positive = _balance >= 0;

    return Material(
      color: Colors.white,
      child: Container(
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
                    'সহজ হিসাব',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'মাসিক আয়-ব্যয়ের রিপোর্ট',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
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

            const SizedBox(height: 22),

            const Divider(),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _imageSummary(
                    'মোট আয়',
                    _totalIncome,
                    Colors.green.shade800,
                    const Color(0xFFEAF7EE),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _imageSummary(
                    'মোট ব্যয়',
                    _totalExpense,
                    Colors.red.shade800,
                    const Color(0xFFFFEEEE),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _imageSummary(
                    'ব্যালেন্স',
                    _balance.abs(),
                    positive
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                    const Color(0xFFFFF8E8),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _imageCategory(
                    title: 'আয়ের বিবরণ',
                    amount: _totalIncome,
                    categories: _incomeCategories,
                    color: Colors.green.shade800,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _imageCategory(
                    title: 'ব্যয়ের বিবরণ',
                    amount: _totalExpense,
                    categories: _expenseCategories,
                    color: Colors.red.shade800,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.black12,
                ),
              ),
              child: Column(
                children: [
                  _imageInfo(
                    'মোট লেনদেন',
                    '${_transactions.length} টি',
                  ),
                  const SizedBox(height: 9),
                  _imageInfo(
                    'মোট ট্রান্সফার',
                    _money(_totalTransfer),
                  ),
                  const SizedBox(height: 9),
                  _imageInfo(
                    'ফলাফল',
                    positive ? 'উদ্বৃত্ত' : 'ঘাটতি',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Footer only in saved image
            Container(
              padding: const EdgeInsets.only(top: 9),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.black26,
                  ),
                ),
              ),
              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Text(
                    'সহজ হিসাব',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Develop by Sayeed Mahadi',
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 8,
                    ),
                  ),
                  Text(
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
      ),
    );
  }

  Widget _imageSummary(
    String title,
    double amount,
    Color color,
    Color background,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _money(amount),
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageCategory({
    required String title,
    required double amount,
    required Map<String, double> categories,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _money(amount),
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (categories.isEmpty)
            const Text(
              'কোনো তথ্য নেই',
              style: TextStyle(
                color: Colors.black45,
                fontSize: 11,
              ),
            )
          else
            ...categories.entries.map(
              (entry) => Padding(
                padding:
                    const EdgeInsets.only(bottom: 7),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    Text(
                      _money(entry.value),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _imageInfo(
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
              fontSize: 11,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CAPTURE IMAGE
  // ============================================================

  Future<Uint8List?> _captureImage() async {
    try {
      return await _screenshotController
          .captureFromLongWidget(
        _buildA4Report(),
        delay: const Duration(
          milliseconds: 300,
        ),
        context: context,
        pixelRatio: 2,
        constraints: const BoxConstraints(
          maxWidth: 794,
        ),
      );
    } catch (e) {
      if (!mounted) return null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'রিপোর্ট ছবি তৈরি করা যায়নি: $e',
          ),
        ),
      );

      return null;
    }
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
      final image = await _captureImage();

      if (image == null) return;

      bool access = await Gal.hasAccess();

      if (!access) {
        access = await Gal.requestAccess();
      }

      if (!access) {
        throw Exception(
          'Gallery permission দেওয়া হয়নি',
        );
      }

      await Gal.putImageBytes(
        image,
        album: 'সহজ হিসাব',
        name:
            'Shohoj_Hisab_Report_${DateFormat('yyyy_MM').format(_selectedMonth)}',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'রিপোর্ট ছবি হিসেবে সংরক্ষণ হয়েছে',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
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

  // ============================================================
  // PDF
  // ============================================================

  Future<Uint8List> _createPdfBytes() async {
    final pdf = pw.Document();

    final positive = _balance >= 0;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) {
          return pw.Column(
            crossAxisAlignment:
                pw.CrossAxisAlignment.stretch,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Shohoj Hisab',
                      style: pw.TextStyle(
                        fontSize: 25,
                        fontWeight:
                            pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Monthly Income & Expense Report',
                      style: const pw.TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      _monthName(),
                      style: const pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 18),

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
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: _pdfSummary(
                      'Total Expense',
                      _totalExpense,
                      PdfColors.red800,
                    ),
                  ),
                  pw.SizedBox(width: 8),
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

              pw.SizedBox(height: 17),

              pw.Row(
                crossAxisAlignment:
                    pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: _pdfCategory(
                      title: 'Income Details',
                      amount: _totalIncome,
                      categories:
                          _incomeCategories,
                      color:
                          PdfColors.green800,
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: _pdfCategory(
                      title: 'Expense Details',
                      amount: _totalExpense,
                      categories:
                          _expenseCategories,
                      color: PdfColors.red800,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 17),

              pw.Container(
                padding:
                    const pw.EdgeInsets.all(13),
                color: PdfColors.grey100,
                child: pw.Column(
                  children: [
                    _pdfInfo(
                      'Total Transactions',
                      '${_transactions.length}',
                    ),
                    pw.SizedBox(height: 7),
                    _pdfInfo(
                      'Total Transfer',
                      _money(_totalTransfer),
                    ),
                    pw.SizedBox(height: 7),
                    _pdfInfo(
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

              pw.SizedBox(height: 5),

              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment:
                      pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'সহজ হিসাব',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight:
                            pw.FontWeight.bold,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      'Develop by Sayeed Mahadi',
                      style: const pw.TextStyle(
                        fontSize: 8,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.Text(
                      'mahadisayeed@gmail.com',
                      style: const pw.TextStyle(
                        fontSize: 8,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
      padding: const pw.EdgeInsets.all(10),
      color: PdfColors.grey100,
      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: const pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            _money(amount),
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfCategory({
    required String title,
    required double amount,
    required Map<String, double> categories,
    required PdfColor color,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(11),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.grey300,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            _money(amount),
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 8),
          if (categories.isEmpty)
            pw.Text(
              'No data',
              style: const pw.TextStyle(
                fontSize: 8,
                color: PdfColors.grey600,
              ),
            )
          else
            ...categories.entries.map(
              (entry) => pw.Padding(
                padding:
                    const pw.EdgeInsets.only(
                  bottom: 5,
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        entry.key,
                        style: const pw.TextStyle(
                          fontSize: 8,
                        ),
                      ),
                    ),
                    pw.Text(
                      _money(entry.value),
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight:
                            pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  pw.Widget _pdfInfo(
    String title,
    String value,
  ) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.Text(
            title,
            style: const pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey700,
            ),
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
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
      final bytes = await _createPdfBytes();

      final fileName =
          'Shohoj_Hisab_Report_${DateFormat('yyyy_MM').format(_selectedMonth)}.pdf';

      await Printing.sharePdf(
        bytes: bytes,
        filename: fileName,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
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

  // ============================================================
  // ACTION BUTTON
  // ============================================================

  Widget _actionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool loading,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: loading ? null : onTap,
        icon: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : Icon(icon),
        label: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.gold,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(
            vertical: 13,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
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
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
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
                _loading ? null : _loadTransactions,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ====================================================
          // MONTH SELECTOR
          // ====================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              14,
              5,
              14,
              9,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius:
                    BorderRadius.circular(15),
                border: Border.all(
                  color:
                      AppTheme.gold.withOpacity(0.16),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed:
                        _loading
                            ? null
                            : _previousMonth,
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                    ),
                    color: AppTheme.gold,
                  ),

                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'রিপোর্ট মাস',
                          style: TextStyle(
                            color:
                                AppTheme.textMuted,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _monthName(),
                          style: TextStyle(
                            color:
                                AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed:
                        _loading
                            ? null
                            : _nextMonth,
                    icon: const Icon(
                      Icons.chevron_right_rounded,
                    ),
                    color: AppTheme.gold,
                  ),
                ],
              ),
            ),
          ),

          // ====================================================
          // BODY
          // ====================================================

          Expanded(
            child: _loading
                ? Center(
                    child:
                        CircularProgressIndicator(
                      color: AppTheme.gold,
                    ),
                  )
                : _errorMessage != null
                    ? _errorState()
                    : _transactions.isEmpty
                        ? SingleChildScrollView(
                            child: _emptyState(),
                          )
                        : SingleChildScrollView(
                            padding:
                                const EdgeInsets.only(
                              bottom: 8,
                            ),
                            child: _reportContent(),
                          ),
          ),

          // ====================================================
          // SAVE BUTTONS
          // ====================================================

          if (!_loading &&
              _errorMessage == null &&
              _transactions.isNotEmpty)
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
                      icon: Icons.image_rounded,
                      title: 'ছবি',
                      onTap: _saveAsImage,
                      loading: _savingImage,
                    ),
                    const SizedBox(width: 10),
                    _actionButton(
                      icon:
                          Icons.picture_as_pdf_rounded,
                      title: 'PDF',
                      onTap: _saveAsPdf,
                      loading: _savingPdf,
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

এখন যা করবে

1. পুরোনো "lib/screens/report_screen.dart" পুরো delete করো।
2. উপরের code পুরো paste করো।
3. GitHub-এ commit করো।
4. GitHub Actions থেকে আবার APK build করো।
5. নতুন APK install করে Money Manager → Report এ যাও।

একটা গুরুত্বপূর্ণ পরিবর্তন করেছি: তোমার database-এ "Income", "income", "EXPENSE", "expense"—যেভাবেই type save থাকুক, Report এখন case-insensitive ভাবে ধরবে। তাই আগের মতো data থাকার পরও আয়/ব্যয় "0" দেখানোর সম্ভাবনাও কমবে।

আর app-এর নামও report থেকে “সহজ হিসাব” করেছি—Gold শুধু design-এর color হিসেবে থাকবে।
