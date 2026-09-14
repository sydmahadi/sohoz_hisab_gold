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

  Future<void> _loadTransactions() async {
    setState(() {
      _loading = true;
    });

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

  String _money(double value) {
    return '৳ ${value.toStringAsFixed(2)}';
  }

  String _monthName() {
    return DateFormat(
      'MMMM yyyy',
      'en',
    ).format(_selectedMonth);
  }

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
      if (transaction.type != 'Income') continue;

      result[transaction.category] =
          (result[transaction.category] ?? 0) +
              transaction.amount;
    }

    return result;
  }

  Map<String, double> get _expenseCategories {
    final Map<String, double> result = {};

    for (final transaction in _transactions) {
      if (transaction.type != 'Expense') continue;

      result[transaction.category] =
          (result[transaction.category] ?? 0) +
              transaction.amount;
    }

    return result;
  }

  Widget _buildA4Side({
    required String title,
    required double amount,
    required Map<String, double> categories,
    required bool income,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: income
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            _money(amount),
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: income
                  ? Colors.green.shade800
                  : Colors.red.shade800,
            ),
          ),

          const SizedBox(height: 18),

          if (categories.isEmpty)
            const Text(
              'কোনো তথ্য নেই',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black45,
              ),
            )
          else
            ...categories.entries.map(
              (entry) {
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 9,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _money(entry.value),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
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

  Widget _buildA4Report({
    bool includeFooter = false,
  }) {
    final balancePositive = _balance >= 0;

    return Container(
      width: 794,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        45,
        40,
        45,
        35,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // HEADER
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
                const SizedBox(height: 7),
                const Text(
                  'মাসিক আয়-ব্যয়ের রিপোর্ট',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _monthName(),
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          Container(
            height: 1,
            color: Colors.black12,
          ),

          const SizedBox(height: 25),

          // SUMMARY
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF7EE),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'মোট আয়',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _money(_totalIncome),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEEE),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'মোট ব্যয়',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _money(_totalExpense),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.red.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ব্যালেন্স',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _money(_balance),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: balancePositive
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // INCOME + EXPENSE
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildA4Side(
                  title: 'আয়ের বিবরণ',
                  amount: _totalIncome,
                  categories: _incomeCategories,
                  income: true,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: _buildA4Side(
                  title: 'ব্যয়ের বিবরণ',
                  amount: _totalExpense,
                  categories: _expenseCategories,
                  income: false,
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // OTHER INFORMATION
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.black12,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'মোট লেনদেন',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Text(
                      '${_transactions.length} টি',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'মোট ট্রান্সফার',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Text(
                      _money(_totalTransfer),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'ফলাফল',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Text(
                      balancePositive
                          ? 'উদ্বৃত্ত'
                          : 'ঘাটতি',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: balancePositive
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // এই footer শুধু Image/PDF save করার সময় থাকবে।
          if (includeFooter) ...[
            const SizedBox(height: 35),

            Container(
              padding: const EdgeInsets.only(
                top: 12,
              ),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.black26,
                    width: 0.8,
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
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Develop by Sayeed Mahadi',
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 1),
                  const Text(
                    'mahadisayeed@gmail.com',
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<Uint8List?> _captureA4Image() async {
    try {
      final image =
          await _screenshotController.captureFromLongWidget(
        InheritedTheme.captureAll(
          context,
          Material(
            color: Colors.white,
            child: _buildA4Report(
              includeFooter: true,
            ),
          ),
        ),
        delay: const Duration(
          milliseconds: 500,
        ),
        context: context,
        pixelRatio: 2,
        constraints: const BoxConstraints(
          maxWidth: 794,
        ),
      );

      return image;
    } catch (e) {
      if (!mounted) return null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'রিপোর্ট তৈরি করতে সমস্যা হয়েছে: $e',
          ),
        ),
      );

      return null;
    }
  }

  Future<void> _saveAsImage() async {
    if (_savingImage) return;

    setState(() {
      _savingImage = true;
    });

    try {
      final image = await _captureA4Image();

      if (image == null) {
        return;
      }

      final hasAccess =
          await Gal.hasAccess();

      if (!hasAccess) {
        await Gal.requestAccess();
      }

      await Gal.putImageBytes(
        image,
        album: 'সহজ হিসাব গোল্ড',
        name:
            'Shohoj_Hisab_Report_${DateFormat('yyyy_MM').format(_selectedMonth)}',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'রিপোর্ট ছবিতে সংরক্ষণ হয়েছে',
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

  Future<void> _saveAsPdf() async {
    if (_savingPdf) return;

    setState(() {
      _savingPdf = true;
    });

    try {
      final image = await _captureA4Image();

      if (image == null) {
        return;
      }

      final pdf = pw.Document();

      final imageProvider =
          pw.MemoryImage(image);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (context) {
            return pw.Container(
              width: double.infinity,
              height: double.infinity,
              color: PdfColors.white,
              child: pw.Image(
                imageProvider,
                fit: pw.BoxFit.contain,
              ),
            );
          },
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename:
            'Shohoj_Hisab_Report_${DateFormat('yyyy_MM').format(_selectedMonth)}.pdf',
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

  Widget _actionButton({
    required IconData icon,
    required String title,
    required VoidCallback? onTap,
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
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.gold,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(
            vertical: 13,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = AppTheme.isDark;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        title: const Text(
          'মাসিক রিপোর্ট',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loading
                ? null
                : _loadTransactions,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            tooltip: 'রিফ্রেশ',
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: AppTheme.gold,
              ),
            )
          : Column(
              children: [
                // MONTH SELECTOR
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    5,
                    16,
                    12,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius:
                          BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.gold
                            .withOpacity(0.18),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _previousMonth,
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
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _monthName(),
                                textAlign:
                                    TextAlign.center,
                                style: TextStyle(
                                  color:
                                      AppTheme.textPrimary,
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          onPressed: _nextMonth,
                          icon: const Icon(
                            Icons.chevron_right_rounded,
                          ),
                          color: AppTheme.gold,
                        ),
                      ],
                    ),
                  ),
                ),

                // REPORT PREVIEW
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Center(
                      child: FittedBox(
                        alignment:
                            Alignment.topCenter,
                        child: Screenshot(
                          controller:
                              _screenshotController,
                          child: _buildA4Report(),
                        ),
                      ),
                    ),
                  ),
                ),

                // ACTION BUTTONS
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      12,
                      8,
                      12,
                      10,
                    ),
                    child: Row(
                      children: [
                        _actionButton(
                          icon:
                              Icons.image_rounded,
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
