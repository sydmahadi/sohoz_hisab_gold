import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../logic/money_db_helper.dart';
import 'report_screen.dart';

class MoneyManagerScreen extends StatefulWidget {
  const MoneyManagerScreen({super.key});

  @override
  State<MoneyManagerScreen> createState() =>
      _MoneyManagerScreenState();
}

class _MoneyManagerScreenState extends State<MoneyManagerScreen> {
  // ============================================================
  // BASIC STATE
  // ============================================================

  int _currentIndex = 0;

  int _statsTab = 1;

  String _filterType = 'Monthly';

  DateTime _selectedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );

  List<MoneyTransaction> _transactions = [];

  List<String> _accounts = [];

  int _touchedPieIndex = -1;

  // ============================================================
  // PIE CHART COLORS
  // ============================================================

  static const List<Color> _pieColors = [
    Color(0xFF2E86DE),
    Color(0xFF00B894),
    Color(0xFFFF7675),
    Color(0xFFFDCB6E),
    Color(0xFF6C5CE7),
    Color(0xFF00CEC9),
    Color(0xFFE17055),
    Color(0xFFA29BFE),
    Color(0xFF55EFC4),
    Color(0xFFFF9FF3),
    Color(0xFF5F27CD),
    Color(0xFF10AC84),
    Color(0xFFFF9F43),
    Color(0xFFEE5253),
    Color(0xFF48DBFB),
    Color(0xFF1DD1A1),
    Color(0xFFC8D6E5),
    Color(0xFF576574),
    Color(0xFF341F97),
  ];

  // ============================================================
  // EXPENSE CATEGORIES
  // ============================================================

  List<String> _expenseCategories = [
    'উর্ধ্বতন এয়ানত',
    'যাতায়াত',
    'অফিস স্টেশনারী',
    'আপ্যায়ন',
    'প্রচার',
    'অফিস ভাড়া',
    'সফর',
    'ডাক ও তার',
    'ছাত্রকল্যাণ',
    'পাঠাগার',
    'প্রোগ্রাম বাস্তবায়ন',
    'প্রকাশনা',
    'সাহিত্য',
    'দাওয়াতী কার্যক্রম',
    'প্রশিক্ষণ',
    'চিকিৎসা',
    'যানবাহন মেরামত',
    'সৌজন্য',
    'ঋণ পরিশোধ',
    'সদস্য সম্মেলন',
    'আসবাবপত্র/ সম্পদ',
    'শহীদ পরিবার',
    'ফাউন্ডেশন',
  ];

  // ============================================================
  // INCOME CATEGORIES
  // ============================================================

  List<String> _incomeCategories = [
    'জনশক্তি',
    'শুভাকাঙ্খী এয়ানত',
    'শাখা এয়ানত',
    'এককালীন',
    'বিশেষ',
    'সফর',
    'প্রকাশনা মুনাফা',
    'সাহিত্য মুনাফা',
    'ছাত্রকল্যাণ',
    'প্রোগ্রাম বাস্তবায়ন',
    'ঋণ গ্রহণ',
    'সদস্য সম্মেলন',
    'ঋন ফেরত',
    'শহীদ ফান্ড',
    'জাকাত',
    'এ + সংবর্ধনা',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> _loadData() async {
    final transactions =
        await MoneyDbHelper.instance.getAllTransactions();

    final accounts =
        await MoneyDbHelper.instance.getAccounts();

    if (!mounted) return;

    setState(() {
      _transactions = transactions;
      _accounts = accounts;
    });
  }

  // ============================================================
  // DATE PARSER
  // ============================================================

  DateTime? _parseDate(String value) {
    final formats = [
      'dd/MM/yyyy',
      'dd-MM-yyyy',
      'dd.MM.yyyy',
      'yyyy/MM/dd',
      'yyyy-MM-dd',
      'yyyy.MM.dd',
    ];

    for (final format in formats) {
      try {
        return DateFormat(format).parseStrict(value);
      } catch (_) {}
    }

    return DateTime.tryParse(value);
  }

  // ============================================================
  // FILTERED TRANSACTIONS
  // ============================================================

  List<MoneyTransaction> get _filteredTransactions {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final result = _transactions.where((transaction) {
      final parsed = _parseDate(transaction.date);

      if (parsed == null) return false;

      final transactionDate = DateTime(
        parsed.year,
        parsed.month,
        parsed.day,
      );

      if (_filterType == 'Daily') {
        return transactionDate == today;
      }

      if (_filterType == 'Weekly') {
        final startOfWeek = today.subtract(
          Duration(days: today.weekday - 1),
        );

        final endOfWeek = startOfWeek.add(
          const Duration(days: 6),
        );

        return !transactionDate.isBefore(startOfWeek) &&
            !transactionDate.isAfter(endOfWeek);
      }

      if (_filterType == 'Monthly') {
        return transactionDate.year == _selectedMonth.year &&
            transactionDate.month == _selectedMonth.month;
      }

      if (_filterType == 'Yearly') {
        return transactionDate.year == _selectedMonth.year;
      }

      return false;
    }).toList();

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

      final dateCompare = dateB.compareTo(dateA);

      if (dateCompare != 0) {
        return dateCompare;
      }

      return (b.id ?? 0).compareTo(
        a.id ?? 0,
      );
    });

    return result;
  }

  // ============================================================
  // MONTH NAME
  // ============================================================

  String _banglaMonthYear(DateTime date) {
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

    return '${months[date.month - 1]} ${date.year}';
  }

  // ============================================================
  // DATE TITLE
  // ============================================================

  String _banglaFullDate(String value) {
    final parsed = _parseDate(value);

    if (parsed == null) {
      return value;
    }

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

    return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
  }

  // ============================================================
  // PREVIOUS MONTH
  // ============================================================

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
        1,
      );
    });
  }

  // ============================================================
  // NEXT MONTH
  // ============================================================

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        1,
      );
    });
  }

  // ============================================================
  // TOTAL BY TYPE
  // ============================================================

  double _totalByType(String type) {
    return _filteredTransactions
        .where((item) => item.type == type)
        .fold(
          0,
          (sum, item) => sum + item.amount,
        );
  }

  double get _incomeTotal {
    return _totalByType('Income');
  }

  double get _expenseTotal {
    return _totalByType('Expense');
  }

  double get _balance {
    return _incomeTotal - _expenseTotal;
  }

  // ============================================================
  // CATEGORY TOTALS
  // ============================================================

  Map<String, double> _categoryTotals(String type) {
    final Map<String, double> result = {};

    for (final transaction in _filteredTransactions) {
      if (transaction.type != type) {
        continue;
      }

      result[transaction.category] =
          (result[transaction.category] ?? 0) +
              transaction.amount;
    }

    final entries = result.entries.toList();

    entries.sort(
      (a, b) => b.value.compareTo(a.value),
    );

    return {
      for (final entry in entries)
        entry.key: entry.value,
    };
  }

  // ============================================================
  // PIE COLOR
  // ============================================================

  Color _pieColor(
    String category,
    int index,
  ) {
    final allCategories = [
      ..._incomeCategories,
      ..._expenseCategories,
    ];

    final categoryIndex =
        allCategories.indexOf(category);

    if (categoryIndex >= 0) {
      return _pieColors[
          categoryIndex % _pieColors.length];
    }

    return _pieColors[
        index % _pieColors.length];
  }

  // ============================================================
  // MONEY FORMAT
  // ============================================================

  String _money(double value) {
    return '৳ ${value.toStringAsFixed(2)}';
  }

  // ============================================================
  // ADD TRANSACTION
  // ============================================================

  Future<void> _showTransactionSheet() async {
    String type = 'Income';

    String? category;

    String? account;

    String? fromAccount;

    String? toAccount;

    final amountController = TextEditingController();

    final noteController = TextEditingController();

    DateTime selectedDate = DateTime.now();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final categories = type == 'Income'
                ? _incomeCategories
                : _expenseCategories;

            return Container(
              height:
                  MediaQuery.of(context).size.height * 0.90,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom +
                        20,
              ),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius:
                    const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 45,
                        height: 5,
                        decoration: BoxDecoration(
                          color:
                              AppTheme.textMuted.withValues(
                            alpha: 0.35,
                          ),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'নতুন লেনদেন',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'লেনদেনের ধরন',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: _typeButton(
                            title: 'আয়',
                            icon:
                                Icons.arrow_downward_rounded,
                            selected:
                                type == 'Income',
                            color: Colors.blue,
                            onTap: () {
                              setSheetState(() {
                                type = 'Income';
                                category = null;
                                fromAccount = null;
                                toAccount = null;
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: _typeButton(
                            title: 'ব্যয়',
                            icon:
                                Icons.arrow_upward_rounded,
                            selected:
                                type == 'Expense',
                            color: Colors.redAccent,
                            onTap: () {
                              setSheetState(() {
                                type = 'Expense';
                                category = null;
                                fromAccount = null;
                                toAccount = null;
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: _typeButton(
                            title: 'Transfer',
                            icon:
                                Icons.swap_horiz_rounded,
                            selected:
                                type == 'Transfer',
                            color: Colors.orange,
                            onTap: () {
                              setSheetState(() {
                                type = 'Transfer';
                                category = null;
                                account = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                      ),
                      decoration:
                          const InputDecoration(
                        labelText: 'পরিমাণ',
                        prefixText: '৳ ',
                        border:
                            OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (type != 'Transfer') ...[
                      DropdownButtonFormField<String>(
                        value: category,
                        isExpanded: true,
                        decoration:
                            const InputDecoration(
                          labelText: 'খাত / Category',
                          border:
                              OutlineInputBorder(),
                        ),
                        items: [
                          ...categories.map(
                            (item) {
                              return DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              );
                            },
                          ),
                          const DropdownMenuItem(
                            value: '__add__',
                            child: Text(
                              '+ নতুন খাত যোগ করুন',
                            ),
                          ),
                        ],
                        onChanged: (value) async {
                          if (value == '__add__') {
                            final newCategory =
                                await _addCategory(
                              type,
                            );

                            if (newCategory != null) {
                              setSheetState(() {
                                category =
                                    newCategory;
                              });
                            }
                          } else {
                            setSheetState(() {
                              category = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: account,
                        isExpanded: true,
                        decoration:
                            const InputDecoration(
                          labelText: 'Account',
                          border:
                              OutlineInputBorder(),
                        ),
                        items: _accounts.map(
                          (item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            );
                          },
                        ).toList(),
                        onChanged: (value) {
                          setSheetState(() {
                            account = value;
                          });
                        },
                      ),
                    ],

                    if (type == 'Transfer') ...[
                      DropdownButtonFormField<String>(
                        value: fromAccount,
                        isExpanded: true,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'কোন Account থেকে',
                          border:
                              OutlineInputBorder(),
                        ),
                        items: _accounts.map(
                          (item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            );
                          },
                        ).toList(),
                        onChanged: (value) {
                          setSheetState(() {
                            fromAccount = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: toAccount,
                        isExpanded: true,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'কোন Account-এ',
                          border:
                              OutlineInputBorder(),
                        ),
                        items: _accounts.map(
                          (item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            );
                          },
                        ).toList(),
                        onChanged: (value) {
                          setSheetState(() {
                            toAccount = value;
                          });
                        },
                      ),
                    ],

                    const SizedBox(height: 16),

                    InkWell(
                      onTap: () async {
                        final picked =
                            await showDatePicker(
                          context: context,
                          initialDate:
                              selectedDate,
                          firstDate:
                              DateTime(2000),
                          lastDate:
                              DateTime(2100),
                        );

                        if (picked != null) {
                          setSheetState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration:
                            const InputDecoration(
                          labelText: 'তারিখ',
                          border:
                              OutlineInputBorder(),
                        ),
                        child: Text(
                          DateFormat(
                            'dd/MM/yyyy',
                          ).format(
                            selectedDate,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: noteController,
                      maxLines: 2,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                      ),
                      decoration:
                          const InputDecoration(
                        labelText: 'নোট',
                        border:
                            OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final amount =
                              double.tryParse(
                            amountController.text
                                .trim()
                                .replaceAll(
                                  ',',
                                  '',
                                ),
                          );

                          if (amount == null ||
                              amount <= 0) {
                            _showMessage(
                              'সঠিক পরিমাণ লিখুন',
                            );
                            return;
                          }

                          if (type != 'Transfer' &&
                              category == null) {
                            _showMessage(
                              'একটি খাত নির্বাচন করুন',
                            );
                            return;
                          }

                          if (type != 'Transfer' &&
                              account == null) {
                            _showMessage(
                              'একটি Account নির্বাচন করুন',
                            );
                            return;
                          }

                          if (type == 'Transfer') {
                            if (fromAccount == null ||
                                toAccount == null) {
                              _showMessage(
                                'উভয় Account নির্বাচন করুন',
                              );
                              return;
                            }

                            if (fromAccount ==
                                toAccount) {
                              _showMessage(
                                'একই Account-এ Transfer করা যাবে না',
                              );
                              return;
                            }
                          }

                          String finalAccount;

                          if (type ==
                              'Transfer') {
                            finalAccount =
                                '$fromAccount➔$toAccount';
                          } else {
                            finalAccount =
                                account!;
                          }

                          final transaction =
                              MoneyTransaction(
                            type: type,
                            amount: amount,
                            date: DateFormat(
                              'dd/MM/yyyy',
                            ).format(
                              selectedDate,
                            ),
                            category:
                                type == 'Transfer'
                                    ? 'Transfer'
                                    : category!,
                            account:
                                finalAccount,
                            note: noteController.text
                                    .trim()
                                    .isEmpty
                                ? null
                                : noteController.text
                                    .trim(),
                          );

                          await MoneyDbHelper
                              .instance
                              .insertTransaction(
                            transaction,
                          );

                          if (!mounted) return;

                          Navigator.pop(
                            sheetContext,
                          );

                          await _loadData();

                          _showMessage(
                            'লেনদেন সংরক্ষণ হয়েছে',
                          );
                        },
                        icon: const Icon(
                          Icons.save_rounded,
                        ),
                        label: const Text(
                          'সংরক্ষণ করুন',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    amountController.dispose();
    noteController.dispose();
  }

  // ============================================================
  // EDIT TRANSACTION
  // ============================================================

  Future<void> _showEditTransactionSheet(
    MoneyTransaction transaction,
  ) async {
    String type = transaction.type;

    String? category;
    String? account;
    String? fromAccount;
    String? toAccount;

    // ------------------------------------------------------------
    // LOAD OLD DATA
    // ------------------------------------------------------------

    if (type == 'Transfer') {
      final parts = transaction.account.split('➔');

      if (parts.length == 2) {
        fromAccount = parts[0];
        toAccount = parts[1];
      }
    } else {
      category = transaction.category;
      account = transaction.account;
    }

    final amountController = TextEditingController(
      text: transaction.amount.toStringAsFixed(2),
    );

    final noteController = TextEditingController(
      text: transaction.note ?? '',
    );

    DateTime selectedDate =
        _parseDate(transaction.date) ?? DateTime.now();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final categories = type == 'Income'
                ? List<String>.from(_incomeCategories)
                : List<String>.from(_expenseCategories);

            // Custom category হলে সেটিও dropdown-এ দেখাবে
            if (type != 'Transfer' &&
                category != null &&
                !categories.contains(category)) {
              categories.add(category!);
            }

            // Custom account হলে সেটিও dropdown-এ দেখাবে
            final editAccounts =
                List<String>.from(_accounts);

            if (type != 'Transfer' &&
                account != null &&
                !editAccounts.contains(account)) {
              editAccounts.add(account!);
            }

            if (type == 'Transfer') {
              if (fromAccount != null &&
                  !editAccounts.contains(fromAccount)) {
                editAccounts.add(fromAccount!);
              }

              if (toAccount != null &&
                  !editAccounts.contains(toAccount)) {
                editAccounts.add(toAccount!);
              }
            }

            return Container(
              height:
                  MediaQuery.of(context).size.height * 0.90,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom +
                        20,
              ),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius:
                    const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // ------------------------------------------------
                    // HANDLE
                    // ------------------------------------------------

                    Center(
                      child: Container(
                        width: 45,
                        height: 5,
                        decoration: BoxDecoration(
                          color:
                              AppTheme.textMuted.withValues(
                            alpha: 0.35,
                          ),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ------------------------------------------------
                    // TITLE
                    // ------------------------------------------------

                    Text(
                      'লেনদেন সম্পাদনা',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ------------------------------------------------
                    // TYPE
                    // ------------------------------------------------

                    Text(
                      'লেনদেনের ধরন',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: _typeButton(
                            title: 'আয়',
                            icon:
                                Icons.arrow_downward_rounded,
                            selected:
                                type == 'Income',
                            color: Colors.blue,
                            onTap: () {
                              setSheetState(() {
                                type = 'Income';
                                category = null;
                                account = null;
                                fromAccount = null;
                                toAccount = null;
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: _typeButton(
                            title: 'ব্যয়',
                            icon:
                                Icons.arrow_upward_rounded,
                            selected:
                                type == 'Expense',
                            color: Colors.redAccent,
                            onTap: () {
                              setSheetState(() {
                                type = 'Expense';
                                category = null;
                                account = null;
                                fromAccount = null;
                                toAccount = null;
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: _typeButton(
                            title: 'Transfer',
                            icon:
                                Icons.swap_horiz_rounded,
                            selected:
                                type == 'Transfer',
                            color: Colors.orange,
                            onTap: () {
                              setSheetState(() {
                                type = 'Transfer';
                                category = null;
                                account = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ------------------------------------------------
                    // AMOUNT
                    // ------------------------------------------------

                    TextField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                      ),
                      decoration:
                          const InputDecoration(
                        labelText: 'পরিমাণ',
                        prefixText: '৳ ',
                        border:
                            OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ------------------------------------------------
                    // INCOME / EXPENSE
                    // ------------------------------------------------

                    if (type != 'Transfer') ...[
                      DropdownButtonFormField<String>(
                        value: category,
                        isExpanded: true,
                        decoration:
                            const InputDecoration(
                          labelText: 'খাত / Category',
                          border:
                              OutlineInputBorder(),
                        ),
                        items: [
                          ...categories.map(
                            (item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Text(item),
                              );
                            },
                          ),
                          const DropdownMenuItem<String>(
                            value: '__add__',
                            child: Text(
                              '+ নতুন খাত যোগ করুন',
                            ),
                          ),
                        ],
                        onChanged: (value) async {
                          if (value == '__add__') {
                            final newCategory =
                                await _addCategory(type);

                            if (newCategory != null) {
                              setSheetState(() {
                                category =
                                    newCategory;
                              });
                            }
                          } else {
                            setSheetState(() {
                              category = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: account,
                        isExpanded: true,
                        decoration:
                            const InputDecoration(
                          labelText: 'Account',
                          border:
                              OutlineInputBorder(),
                        ),
                        items: editAccounts.map(
                          (item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          },
                        ).toList(),
                        onChanged: (value) {
                          setSheetState(() {
                            account = value;
                          });
                        },
                      ),
                    ],

                    // ------------------------------------------------
                    // TRANSFER
                    // ------------------------------------------------

                    if (type == 'Transfer') ...[
                      DropdownButtonFormField<String>(
                        value: fromAccount,
                        isExpanded: true,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'কোন Account থেকে',
                          border:
                              OutlineInputBorder(),
                        ),
                        items: editAccounts.map(
                          (item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          },
                        ).toList(),
                        onChanged: (value) {
                          setSheetState(() {
                            fromAccount = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: toAccount,
                        isExpanded: true,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'কোন Account-এ',
                          border:
                              OutlineInputBorder(),
                        ),
                        items: editAccounts.map(
                          (item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          },
                        ).toList(),
                        onChanged: (value) {
                          setSheetState(() {
                            toAccount = value;
                          });
                        },
                      ),
                    ],

                    const SizedBox(height: 16),

                    // ------------------------------------------------
                    // DATE
                    // ------------------------------------------------

                    InkWell(
                      onTap: () async {
                        final picked =
                            await showDatePicker(
                          context: context,
                          initialDate:
                              selectedDate,
                          firstDate:
                              DateTime(2000),
                          lastDate:
                              DateTime(2100),
                        );

                        if (picked != null) {
                          setSheetState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration:
                            const InputDecoration(
                          labelText: 'তারিখ',
                          border:
                              OutlineInputBorder(),
                        ),
                        child: Text(
                          DateFormat(
                            'dd/MM/yyyy',
                          ).format(
                            selectedDate,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ------------------------------------------------
                    // NOTE
                    // ------------------------------------------------

                    TextField(
                      controller: noteController,
                      maxLines: 2,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                      ),
                      decoration:
                          const InputDecoration(
                        labelText: 'নোট',
                        border:
                            OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ------------------------------------------------
                    // UPDATE BUTTON
                    // ------------------------------------------------

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final amount =
                              double.tryParse(
                            amountController.text
                                .trim()
                                .replaceAll(',', ''),
                          );

                          if (amount == null ||
                              amount <= 0) {
                            _showMessage(
                              'সঠিক পরিমাণ লিখুন',
                            );
                            return;
                          }

                          if (type != 'Transfer' &&
                              category == null) {
                            _showMessage(
                              'একটি খাত নির্বাচন করুন',
                            );
                            return;
                          }

                          if (type != 'Transfer' &&
                              account == null) {
                            _showMessage(
                              'একটি Account নির্বাচন করুন',
                            );
                            return;
                          }

                          if (type == 'Transfer') {
                            if (fromAccount == null ||
                                toAccount == null) {
                              _showMessage(
                                'উভয় Account নির্বাচন করুন',
                              );
                              return;
                            }

                            if (fromAccount ==
                                toAccount) {
                              _showMessage(
                                'একই Account-এ Transfer করা যাবে না',
                              );
                              return;
                            }
                          }

                          final finalAccount =
                              type == 'Transfer'
                                  ? '$fromAccount➔$toAccount'
                                  : account!;

                          final updatedTransaction =
                              MoneyTransaction(
                            id: transaction.id,
                            type: type,
                            amount: amount,
                            date: DateFormat(
                              'dd/MM/yyyy',
                            ).format(
                              selectedDate,
                            ),
                            category:
                                type == 'Transfer'
                                    ? 'Transfer'
                                    : category!,
                            account: finalAccount,
                            note: noteController.text
                                    .trim()
                                    .isEmpty
                                ? null
                                : noteController.text
                                    .trim(),
                          );

                          final updated =
                              await MoneyDbHelper
                                  .instance
                                  .updateTransaction(
                            updatedTransaction,
                          );

                          if (!mounted) return;

                          if (updated > 0) {
                            Navigator.pop(
                              sheetContext,
                            );

                            await _loadData();

                            _showMessage(
                              'লেনদেন আপডেট হয়েছে',
                            );
                          } else {
                            _showMessage(
                              'লেনদেন আপডেট করা যায়নি',
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.edit_rounded,
                        ),
                        label: const Text(
                          'আপডেট করুন',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    amountController.dispose();
    noteController.dispose();
  }

  // ============================================================
  // TYPE BUTTON
  // ============================================================

  Widget _typeButton({
    required String title,
    required IconData icon,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(14),
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 5,
        ),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(
                  alpha: 0.12,
                )
              : AppTheme.cardColor,
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? color
                : AppTheme.textMuted.withValues(
                    alpha: 0.15,
                  ),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected
                  ? color
                  : AppTheme.textMuted,
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: selected
                    ? color
                    : AppTheme.textMuted,
                fontWeight: selected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ADD CATEGORY
  // ============================================================

  Future<String?> _addCategory(
    String type,
  ) async {
    final controller =
        TextEditingController();

    final result =
        await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'নতুন খাত',
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration:
                const InputDecoration(
              hintText:
                  'খাতের নাম',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child: const Text(
                'বাতিল',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final value =
                    controller.text
                        .trim();

                if (value.isNotEmpty) {
                  Navigator.pop(
                    context,
                    value,
                  );
                }
              },
              child: const Text(
                'যোগ করুন',
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null ||
        result.trim().isEmpty) {
      return null;
    }

    final list = type == 'Income'
        ? _incomeCategories
        : _expenseCategories;

    if (!list.contains(result)) {
      setState(() {
        list.add(result);
      });
    }

    return result;
  }

  // ============================================================
  // DELETE TRANSACTION
  // ============================================================

  Future<void> _deleteTransaction(
    MoneyTransaction transaction,
  ) async {
    if (transaction.id == null) {
      return;
    }

    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'লেনদেন মুছে ফেলবেন?',
          ),
          content: const Text(
            'এই transaction মুছে দিলে হিসাব থেকে এটি বাদ যাবে।',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'বাতিল',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'মুছে ফেলুন',
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    await MoneyDbHelper.instance
        .deleteTransaction(
      transaction.id!,
    );

    await _loadData();

    _showMessage(
      'Transaction মুছে ফেলা হয়েছে',
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // ADD ACCOUNT
  // ============================================================

  Future<void> _addAccount() async {
    final controller =
        TextEditingController();

    final accountName =
        await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'নতুন Account',
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration:
                const InputDecoration(
              labelText:
                  'Account-এর নাম',
              hintText:
                  'যেমন: Rocket',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child: const Text(
                'বাতিল',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final value =
                    controller.text
                        .trim();

                if (value.isNotEmpty) {
                  Navigator.pop(
                    context,
                    value,
                  );
                }
              },
              child: const Text(
                'যোগ করুন',
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (accountName == null ||
        accountName.trim().isEmpty) {
      return;
    }

    final success =
        await MoneyDbHelper.instance
            .addAccount(
      accountName,
    );

    if (!mounted) return;

    if (success) {
      await _loadData();

      _showMessage(
        'Account যোগ হয়েছে',
      );
    } else {
      _showMessage(
        'এই Account আগে থেকেই আছে',
      );
    }
  }

  // ============================================================
  // DELETE ACCOUNT
  // ============================================================

  Future<void> _deleteAccount(
    String account,
  ) async {
    final used = _transactions.any(
      (transaction) {
        if (transaction.type ==
            'Transfer') {
          final parts =
              transaction.account
                  .split('➔');

          return parts.contains(
            account,
          );
        }

        return transaction.account ==
            account;
      },
    );

    if (used) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Account মুছে ফেলা যাবে না',
            ),
            content: Text(
              '$account Account-এ পুরোনো transaction আছে। তাই Accountটি মুছে ফেলা যাবে না।',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },
                child: const Text(
                  'ঠিক আছে',
                ),
              ),
            ],
          );
        },
      );

      return;
    }

    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Account মুছে ফেলবেন?',
          ),
          content: Text(
            'আপনি কি "$account" Accountটি মুছে ফেলতে চান?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'না',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'মুছে ফেলুন',
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    final success =
        await MoneyDbHelper.instance
            .deleteAccount(
      account,
    );

    if (!mounted) return;

    if (success) {
      await _loadData();

      _showMessage(
        'Account মুছে ফেলা হয়েছে',
      );
    } else {
      _showMessage(
        'এই Account মুছে ফেলা যাবে না',
      );
    }
  }

  // ============================================================
  // ACCOUNT BALANCE
  // ============================================================

  double _accountBalance(
    String accountName,
  ) {
    double balance = 0;

    for (final transaction
        in _transactions) {
      if (transaction.type ==
          'Income') {
        if (transaction.account ==
            accountName) {
          balance += transaction.amount;
        }
      }

      if (transaction.type ==
          'Expense') {
        if (transaction.account ==
            accountName) {
          balance -= transaction.amount;
        }
      }

      if (transaction.type ==
          'Transfer') {
        final parts =
            transaction.account
                .split('➔');

        if (parts.length == 2) {
          final from = parts[0];
          final to = parts[1];

          if (from == accountName) {
            balance -=
                transaction.amount;
          }

          if (to == accountName) {
            balance +=
                transaction.amount;
          }
        }
      }
    }

    return balance;
  }

  // ============================================================
  // OPEN CATEGORY TRANSACTIONS
  // ============================================================

  void _openCategoryTransactions(
    String category,
    String type,
  ) {
    final transactions =
        _filteredTransactions.where(
      (transaction) {
        return transaction.type ==
                type &&
            transaction.category ==
                category;
      },
    ).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CategoryTransactionsScreen(
          category: category,
          type: type,
          transactions: transactions,
          onDeleted: _loadData,
          onEdited: (transaction) async {
            await _showEditTransactionSheet(
              transaction,
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // TRANSACTIONS VIEW
  // ============================================================

  Widget _buildTransactionsView() {
    final transactions =
        _filteredTransactions;

    final groups =
        <String, List<MoneyTransaction>>{};

    for (final transaction in transactions) {
      final parsed =
          _parseDate(transaction.date);

      final key = parsed == null
          ? transaction.date
          : DateFormat('dd/MM/yyyy')
              .format(parsed);

      groups.putIfAbsent(
        key,
        () => [],
      );

      groups[key]!.add(transaction);
    }

    return Column(
      children: [
        _buildFilterHeader(),

        _buildSummaryCards(),

        Expanded(
          child: transactions.isEmpty
              ? _emptyState(
                  icon: Icons
                      .receipt_long_outlined,
                  text:
                      'এই সময়ের কোনো হিসাব নেই',
                )
              : ListView(
                  padding:
                      const EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    90,
                  ),
                  children:
                      groups.entries.map(
                    (entry) {
                      return _buildDateGroup(
                        entry.key,
                        entry.value,
                      );
                    },
                  ).toList(),
                ),
        ),
      ],
    );
  }

  // ============================================================
  // DATE GROUP
  // ============================================================

  Widget _buildDateGroup(
    String date,
    List<MoneyTransaction> transactions,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),
      decoration:
          BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
        border: Border.all(
          color:
              AppTheme.gold.withValues(
            alpha: 0.14,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 13,
            ),
            decoration:
                BoxDecoration(
              color:
                  AppTheme.gold.withValues(
                alpha: 0.08,
              ),
              borderRadius:
                  const BorderRadius.vertical(
                top: Radius.circular(
                  20,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.all(
                    8,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        AppTheme.gold.withValues(
                      alpha: 0.14,
                    ),
                    shape:
                        BoxShape.circle,
                  ),
                  child: Icon(
                    Icons
                        .calendar_month_rounded,
                    size: 18,
                    color:
                        AppTheme.gold,
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: Text(
                    _banglaFullDate(
                      date,
                    ),
                    style: TextStyle(
                      color:
                          AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        AppTheme.gold.withValues(
                      alpha: 0.12,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Text(
                    '${transactions.length}টি লেনদেন',
                    style: TextStyle(
                      color:
                          AppTheme.gold,
                      fontSize: 11,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          ...List.generate(
            transactions.length,
            (index) {
              final transaction =
                  transactions[index];

              return Column(
                children: [
                  _transactionRow(
                    transaction,
                  ),

                  if (index !=
                      transactions.length -
                          1)
                    Divider(
                      height: 1,
                      indent: 70,
                      endIndent: 12,
                      color:
                          AppTheme.textMuted
                              .withValues(
                        alpha: 0.10,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TRANSACTION ROW
  // ============================================================

  Widget _transactionRow(
    MoneyTransaction transaction,
  ) {
    final isIncome =
        transaction.type == 'Income';

    final isTransfer =
        transaction.type ==
            'Transfer';

    Color color;

    IconData icon;

    if (isTransfer) {
      color = Colors.orange;
      icon =
          Icons.swap_horiz_rounded;
    } else if (isIncome) {
      color = Colors.blue;
      icon =
          Icons.arrow_downward_rounded;
    } else {
      color = Colors.redAccent;
      icon =
          Icons.arrow_upward_rounded;
    }

    final accountText =
        transaction.account.replaceAll(
      '➔',
      ' → ',
    );

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 4,
      ),

      leading: CircleAvatar(
        radius: 21,
        backgroundColor:
            color.withValues(
          alpha: 0.13,
        ),
        child: Icon(
          icon,
          color: color,
          size: 21,
        ),
      ),

      title: Text(
        isTransfer
            ? 'Transfer'
            : transaction.category,
        style: TextStyle(
          color:
              AppTheme.textPrimary,
          fontWeight:
              FontWeight.bold,
          fontSize: 14,
        ),
      ),

      subtitle: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 3,
          ),

          Text(
            accountText,
            style: TextStyle(
              color: isTransfer
                  ? Colors.orange
                  : AppTheme.textMuted,
              fontSize: 12,
            ),
          ),

          if (transaction.note !=
                  null &&
              transaction.note!
                  .trim()
                  .isNotEmpty)
            Text(
              transaction.note!,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: TextStyle(
                color:
                    AppTheme.textMuted,
                fontSize: 11,
              ),
            ),
        ],
      ),

      trailing: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          if (!isTransfer)
            Text(
              isIncome ? '+' : '-',
              style: TextStyle(
                color: color,
                fontWeight:
                    FontWeight.bold,
                fontSize: 14,
              ),
            ),

          Text(
            '৳ ${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontWeight:
                  FontWeight.bold,
              fontSize: 11,
            ),
          ),

          // ========================================================
          // EDIT + DELETE MENU
          // ========================================================

          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _showEditTransactionSheet(
                  transaction,
                );
              }

              if (value == 'delete') {
                _deleteTransaction(
                  transaction,
                );
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        'সম্পাদনা করুন',
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        'মুছে ফেলুন',
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTER HEADER
  // ============================================================

  Widget _buildFilterHeader() {
    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        6,
      ),
      child: Column(
        children: [
          if (_filterType ==
              'Monthly')
            Row(
              children: [
                IconButton(
                  onPressed:
                      _previousMonth,
                  icon: const Icon(
                    Icons
                        .chevron_left_rounded,
                  ),
                ),

                Expanded(
                  child: Center(
                    child: Text(
                      _banglaMonthYear(
                        _selectedMonth,
                      ),
                      style:
                          TextStyle(
                        color:
                            AppTheme
                                .textPrimary,
                        fontSize: 16,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                  ),
                ),

                IconButton(
                  onPressed:
                      _nextMonth,
                  icon: const Icon(
                    Icons
                        .chevron_right_rounded,
                  ),
                ),
              ],
            ),

          SingleChildScrollView(
            scrollDirection:
                Axis.horizontal,
            child: Row(
              children: [
                'Daily',
                'Weekly',
                'Monthly',
                'Yearly',
              ].map(
                (filter) {
                  final selected =
                      _filterType ==
                          filter;

                  return Padding(
                    padding:
                        const EdgeInsets
                            .only(
                      right: 8,
                    ),
                    child:
                        ChoiceChip(
                      label: Text(
                        _filterBangla(
                          filter,
                        ),
                      ),
                      selected:
                          selected,
                      onSelected:
                          (_) {
                        setState(
                          () {
                            _filterType =
                                filter;
                          },
                        );
                      },
                    ),
                  );
                },
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _filterBangla(
    String value,
  ) {
    switch (value) {
      case 'Daily':
        return 'দৈনিক';
      case 'Weekly':
        return 'সাপ্তাহিক';
      case 'Monthly':
        return 'মাসিক';
      case 'Yearly':
        return 'বার্ষিক';
      default:
        return value;
    }
  }

  // ============================================================
  // SUMMARY CARDS
  // ============================================================

  Widget _buildSummaryCards() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        10,
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryCard(
              title: 'আয়',
              amount: _incomeTotal,
              icon:
                  Icons.arrow_downward_rounded,
              color: Colors.blue,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: _summaryCard(
              title: 'ব্যয়',
              amount: _expenseTotal,
              icon:
                  Icons.arrow_upward_rounded,
              color: Colors.redAccent,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: _summaryCard(
              title: _balance >= 0
                  ? 'উদ্বৃত্ত'
                  : 'ঘাটতি',
              amount:
                  _balance.abs(),
              icon: _balance >= 0
                  ? Icons
                      .trending_up_rounded
                  : Icons
                      .trending_down_rounded,
              color: _balance >= 0
                  ? Colors.green
                  : Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      constraints:
          const BoxConstraints(
        minHeight: 108,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 11,
      ),
      decoration:
          BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius:
            BorderRadius.circular(17),
        border: Border.all(
          color:
              color.withValues(
            alpha: 0.20,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 21,
            color: color,
          ),

          const SizedBox(
            height: 5,
          ),

          FittedBox(
            fit:
                BoxFit.scaleDown,
            child: Text(
              title,
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          FittedBox(
            fit:
                BoxFit.scaleDown,
            child: Text(
              '৳ ${amount.toStringAsFixed(2)}',
              maxLines: 1,
              style: TextStyle(
                color:
                    AppTheme.textPrimary,
                fontSize: 12,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATS VIEW
  // ============================================================

  Widget _buildStatsView() {
    final type =
        _statsTab == 0
            ? 'Income'
            : 'Expense';

    final data =
        _categoryTotals(type);

    final total =
        data.values.fold<double>(
      0,
      (sum, value) =>
          sum + value,
    );

    return Column(
      children: [
        _buildFilterHeader(),

        Padding(
          padding:
              const EdgeInsets
                  .symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Row(
            children: [
              Expanded(
                child:
                    _statsTabButton(
                  title: 'আয়',
                  selected:
                      _statsTab == 0,
                  onTap: () {
                    setState(() {
                      _statsTab = 0;
                      _touchedPieIndex =
                          -1;
                    });
                  },
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child:
                    _statsTabButton(
                  title: 'ব্যয়',
                  selected:
                      _statsTab == 1,
                  onTap: () {
                    setState(() {
                      _statsTab = 1;
                      _touchedPieIndex =
                          -1;
                    });
                  },
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: data.isEmpty
              ? _emptyState(
                  icon: Icons
                      .bar_chart_rounded,
                  text:
                      'এই সময়ের কোনো তথ্য নেই',
                )
              : ListView(
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    16,
                    8,
                    16,
                    90,
                  ),
                  children: [
                    _buildPieChart(
                      data,
                      total,
                      type,
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    Text(
                      'খাত অনুযায়ী হিসাব',
                      style: TextStyle(
                        color:
                            AppTheme
                                .textPrimary,
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    ...data.entries.map(
                      (entry) {
                        return _categoryTile(
                          category:
                              entry.key,
                          amount:
                              entry.value,
                          total: total,
                          type: type,
                        );
                      },
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  // ============================================================
  // STATS BUTTON
  // ============================================================

  Widget _statsTabButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(14),
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 13,
        ),
        decoration:
            BoxDecoration(
          color: selected
              ? AppTheme.gold
                  .withValues(
                  alpha: 0.16,
                )
              : AppTheme.cardColor,
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          border: Border.all(
            color: selected
                ? AppTheme.gold
                : AppTheme.textMuted
                    .withValues(
                    alpha: 0.15,
                  ),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: selected
                  ? AppTheme.gold
                  : AppTheme.textMuted,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PREMIUM PIE CHART
  // ============================================================

  Widget _buildPieChart(
    Map<String, double> data,
    double total,
    String type,
  ) {
    final entries =
        data.entries.toList();

    final activeIndex =
        _touchedPieIndex >= 0 &&
                _touchedPieIndex <
                    entries.length
            ? _touchedPieIndex
            : -1;

    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        16,
      ),
      decoration:
          BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color:
              AppTheme.gold.withValues(
            alpha: 0.15,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: 0.08,
            ),
            blurRadius: 18,
            offset:
                const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.all(
                  9,
                ),
                decoration:
                    BoxDecoration(
                  color: AppTheme
                      .gold
                      .withValues(
                    alpha: 0.12,
                  ),
                  shape:
                      BoxShape.circle,
                ),
                child: Icon(
                  Icons
                      .pie_chart_rounded,
                  color:
                      AppTheme.gold,
                  size: 20,
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      type == 'Income'
                          ? 'আয়ের বিশ্লেষণ'
                          : 'ব্যয়ের বিশ্লেষণ',
                      style: TextStyle(
                        color:
                            AppTheme
                                .textPrimary,
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      '${entries.length}টি খাত',
                      style: TextStyle(
                        color:
                            AppTheme
                                .textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                _money(total),
                style: TextStyle(
                  color: type ==
                          'Income'
                      ? Colors.blue
                      : Colors.redAccent,
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          SizedBox(
            height: 250,
            child: Stack(
              alignment:
                  Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    centerSpaceRadius:
                        58,
                    sectionsSpace: 3,
                    startDegreeOffset:
                        -90,
                    borderData:
                        FlBorderData(
                      show: false,
                    ),
                    pieTouchData:
                        PieTouchData(
                      touchCallback:
                          (event,
                              response) {
                        final index =
                            response
                                    ?.touchedSection
                                    ?.touchedSectionIndex ??
                                -1;

                        if (index !=
                            _touchedPieIndex) {
                          setState(() {
                            _touchedPieIndex =
                                index;
                          });
                        }
                      },
                    ),
                    sections:
                        List.generate(
                      entries.length,
                      (index) {
                        final value =
                            entries[index]
                                .value;

                        final percentage =
                            total == 0
                                ? 0
                                : value /
                                    total *
                                    100;

                        final selected =
                            activeIndex ==
                                index;

                        return PieChartSectionData(
                          value:
                              value,
                          color:
                              _pieColor(
                            entries[index]
                                .key,
                            index,
                          ),
                          radius:
                              selected
                                  ? 86
                                  : 72,
                          title: percentage >=
                                  4
                              ? '${percentage.toStringAsFixed(0)}%'
                              : '',
                          titleStyle:
                              const TextStyle(
                            fontSize:
                                11,
                            fontWeight:
                                FontWeight
                                    .bold,
                            color:
                                Colors
                                    .white,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                IgnorePointer(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize
                            .min,
                    children: [
                      Text(
                        'মোট',
                        style:
                            TextStyle(
                          color:
                              AppTheme
                                  .textMuted,
                          fontSize:
                              11,
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        _money(total),
                        style:
                            TextStyle(
                          color:
                              AppTheme
                                  .textPrimary,
                          fontSize:
                              14,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          Divider(
            color:
                AppTheme.textMuted
                    .withValues(
              alpha: 0.12,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          ...List.generate(
            entries.length,
            (index) {
              final entry =
                  entries[index];

              final percentage =
                  total == 0
                      ? 0.0
                      : entry.value /
                          total *
                          100;

              final color =
                  _pieColor(
                entry.key,
                index,
              );

              return InkWell(
                onTap: () {
                  _openCategoryTransactions(
                    entry.key,
                    type,
                  );
                },
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
                child: Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 8,
                    vertical: 9,
                  ),
                  margin:
                      const EdgeInsets
                          .only(
                    bottom: 4,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        activeIndex ==
                                index
                            ? color
                                .withValues(
                                alpha:
                                    0.08,
                              )
                            : Colors
                                .transparent,
                    borderRadius:
                        BorderRadius
                            .circular(
                      12,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration:
                            BoxDecoration(
                          color: color,
                          shape:
                              BoxShape
                                  .circle,
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: Text(
                          entry.key,
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              TextStyle(
                            color:
                                AppTheme
                                    .textPrimary,
                            fontSize: 12,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
                      ),

                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style:
                            TextStyle(
                          color:
                              color,
                          fontSize:
                              11,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Text(
                        _money(
                          entry.value,
                        ),
                        style:
                            TextStyle(
                          color:
                              AppTheme
                                  .textPrimary,
                          fontSize: 11,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),

                      const SizedBox(
                        width: 3,
                      ),

                      Icon(
                        Icons
                            .chevron_right_rounded,
                        color:
                            AppTheme
                                .textMuted,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORY TILE
  // ============================================================

  Widget _categoryTile({
    required String category,
    required double amount,
    required double total,
    required String type,
  }) {
    final percentage =
        total == 0
            ? 0.0
            : amount / total;

    final color =
        type == 'Income'
            ? Colors.blue
            : Colors.redAccent;

    return InkWell(
      onTap: () {
        _openCategoryTransactions(
          category,
          type,
        );
      },
      borderRadius:
          BorderRadius.circular(16),
      child: Container(
        margin:
            const EdgeInsets.only(
          bottom: 10,
        ),
        padding:
            const EdgeInsets.all(15),
        decoration:
            BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(
              alpha: 0.14,
            ),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration:
                      BoxDecoration(
                    color: _pieColor(
                      category,
                      0,
                    ),
                    shape:
                        BoxShape.circle,
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                Expanded(
                  child: Text(
                    category,
                    style: TextStyle(
                      color:
                          AppTheme
                              .textPrimary,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),

                Text(
                  _money(amount),
                  style: TextStyle(
                    color: color,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  width: 6,
                ),

                Icon(
                  Icons
                      .chevron_right_rounded,
                  color:
                      AppTheme.textMuted,
                  size: 20,
                ),
              ],
            ),

            const SizedBox(
              height: 10,
            ),

            LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
              backgroundColor:
                  AppTheme.textMuted
                      .withValues(
                alpha: 0.10,
              ),
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ACCOUNTS VIEW
  // ============================================================

  Widget _buildAccountsView() {
    final totalBalance =
        _accounts.fold<double>(
      0,
      (sum, account) =>
          sum + _accountBalance(account),
    );

    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            8,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Accounts',
                  style: TextStyle(
                    color:
                        AppTheme
                            .textPrimary,
                    fontSize: 21,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              IconButton(
                onPressed:
                    _addAccount,
                tooltip:
                    'Account যোগ করুন',
                icon: Icon(
                  Icons
                      .add_circle_outline_rounded,
                  color:
                      AppTheme.gold,
                ),
              ),
            ],
          ),
        ),

        Container(
          margin:
              const EdgeInsets
                  .symmetric(
            horizontal: 16,
          ),
          padding:
              const EdgeInsets.all(
            18,
          ),
          decoration:
              BoxDecoration(
            color:
                AppTheme.cardColor,
            borderRadius:
                BorderRadius.circular(
              20,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets
                        .all(12),
                decoration:
                    BoxDecoration(
                  color: AppTheme
                      .gold
                      .withValues(
                    alpha: 0.14,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons
                      .account_balance_wallet_rounded,
                  color:
                      AppTheme.gold,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    'মোট ব্যালেন্স',
                    style: TextStyle(
                      color:
                          AppTheme
                              .textMuted,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    _money(
                      totalBalance,
                    ),
                    style: TextStyle(
                      color:
                          AppTheme
                              .textPrimary,
                      fontSize: 21,
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 10,
        ),

        Expanded(
          child: _accounts.isEmpty
              ? _emptyState(
                  icon: Icons
                      .account_balance_outlined,
                  text:
                      'কোনো Account নেই',
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    16,
                    8,
                    16,
                    90,
                  ),
                  itemCount:
                      _accounts.length,
                  itemBuilder:
                      (context, index) {
                    final account =
                        _accounts[index];

                    final balance =
                        _accountBalance(
                      account,
                    );

                    final isDefault =
                        MoneyDbHelper
                            .defaultAccounts
                            .contains(
                      account,
                    );

                    return Card(
                      margin:
                          const EdgeInsets
                              .only(
                        bottom: 10,
                      ),
                      child:
                          ListTile(
                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 16,
                          vertical: 5,
                        ),
                        leading:
                            CircleAvatar(
                          backgroundColor:
                              AppTheme
                                  .gold
                                  .withValues(
                            alpha:
                                0.14,
                          ),
                          child: Icon(
                            Icons
                                .account_balance_wallet_outlined,
                            color:
                                AppTheme
                                    .gold,
                          ),
                        ),
                        title: Text(
                          account,
                          style:
                              TextStyle(
                            color:
                                AppTheme
                                    .textPrimary,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                        subtitle:
                            isDefault
                                ? const Text(
                                    'Default Account',
                                  )
                                : null,
                        trailing:
                            Row(
                          mainAxisSize:
                              MainAxisSize
                                  .min,
                          children: [
                            Text(
                              _money(
                                balance,
                              ),
                              style:
                                  TextStyle(
                                color: balance >=
                                        0
                                    ? AppTheme
                                        .gold
                                    : Colors
                                        .redAccent,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),

                            if (!isDefault)
                              IconButton(
                                onPressed:
                                    () {
                                  _deleteAccount(
                                    account,
                                  );
                                },
                                icon:
                                    const Icon(
                                  Icons
                                      .delete_outline_rounded,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState({
    required IconData icon,
    required String text,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppTheme
                .textMuted
                .withValues(
              alpha: 0.4,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          Text(
            text,
            style: TextStyle(
              color:
                  AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          AppTheme.background,

      appBar: AppBar(
        title: const Text(
          'মানি ম্যানেজার',
        ),
        centerTitle: false,
      ),

      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildTransactionsView(),
          _buildStatsView(),
          _buildAccountsView(),
          const ReportScreen(),
        ],
      ),

      floatingActionButton:
          _currentIndex == 0
              ? FloatingActionButton.extended(
                  onPressed:
                      _showTransactionSheet,
                  icon: const Icon(
                    Icons.add_rounded,
                  ),
                  label: const Text(
                    'লেনদেন',
                  ),
                )
              : _currentIndex == 2
                  ? FloatingActionButton(
                      onPressed:
                          _addAccount,
                      child:
                          const Icon(
                        Icons.add_rounded,
                      ),
                    )
                  : null,

      bottomNavigationBar:
          NavigationBar(
        selectedIndex:
            _currentIndex,
        onDestinationSelected:
            (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons
                  .receipt_long_outlined,
            ),
            selectedIcon: Icon(
              Icons
                  .receipt_long_rounded,
            ),
            label: 'লেনদেন',
          ),
          NavigationDestination(
            icon: Icon(
              Icons
                  .bar_chart_outlined,
            ),
            selectedIcon: Icon(
              Icons
                  .bar_chart_rounded,
            ),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(
              Icons
                  .account_balance_wallet_outlined,
            ),
            selectedIcon: Icon(
              Icons
                  .account_balance_wallet_rounded,
            ),
            label: 'Accounts',
          ),
          NavigationDestination(
            icon: Icon(
              Icons
                  .assessment_outlined,
            ),
            selectedIcon: Icon(
              Icons
                  .assessment_rounded,
            ),
            label: 'Report',
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// CATEGORY TRANSACTIONS SCREEN
// ==================================================================

class CategoryTransactionsScreen
    extends StatefulWidget {
  final String category;

  final String type;

  final List<MoneyTransaction>
      transactions;

  final Future<void> Function()
      onDeleted;

  final Future<void> Function(
    MoneyTransaction transaction,
  ) onEdited;

  const CategoryTransactionsScreen({
    super.key,
    required this.category,
    required this.type,
    required this.transactions,
    required this.onDeleted,
    required this.onEdited,
  });

  @override
  State<CategoryTransactionsScreen>
      createState() =>
          _CategoryTransactionsScreenState();
}

class _CategoryTransactionsScreenState
    extends State<CategoryTransactionsScreen> {
  late List<MoneyTransaction>
      _transactions;

  @override
  void initState() {
    super.initState();

    _transactions =
        List<MoneyTransaction>.from(
      widget.transactions,
    );

    _sortTransactions();
  }

  // ============================================================
  // SORT
  // ============================================================

  void _sortTransactions() {
    _transactions.sort(
      (a, b) {
        DateTime? dateA =
            _parseDate(a.date);

        DateTime? dateB =
            _parseDate(b.date);

        if (dateA == null &&
            dateB == null) {
          return 0;
        }

        if (dateA == null) {
          return 1;
        }

        if (dateB == null) {
          return -1;
        }

        final result =
            dateB.compareTo(dateA);

        if (result != 0) {
          return result;
        }

        return (b.id ?? 0)
            .compareTo(
          a.id ?? 0,
        );
      },
    );
  }

  // ============================================================
  // DATE PARSER
  // ============================================================

  DateTime? _parseDate(
    String value,
  ) {
    final formats = [
      'dd/MM/yyyy',
      'dd-MM-yyyy',
      'dd.MM.yyyy',
      'yyyy/MM/dd',
      'yyyy-MM-dd',
      'yyyy.MM.dd',
    ];

    for (final format in formats) {
      try {
        return DateFormat(
          format,
        ).parseStrict(value);
      } catch (_) {}
    }

    return DateTime.tryParse(
      value,
    );
  }

  // ============================================================
  // MONEY
  // ============================================================

  String _money(
    double value,
  ) {
    return '৳ ${value.toStringAsFixed(2)}';
  }

  // ============================================================
  // EDIT TRANSACTION
  // ============================================================

  Future<void> _editTransaction(
    MoneyTransaction transaction,
  ) async {
    await widget.onEdited(
      transaction,
    );

    if (!mounted) return;

    // Main database থেকে আবার সব transaction নিয়ে আসবে
    final updated =
        await MoneyDbHelper
            .instance
            .getAllTransactions();

    final filtered =
        updated.where((item) {
      return item.type ==
              widget.type &&
          item.category ==
              widget.category;
    }).toList();

    setState(() {
      _transactions = filtered;
      _sortTransactions();
    });
  }

  // ============================================================
  // DELETE TRANSACTION
  // ============================================================

  Future<void> _deleteTransaction(
    MoneyTransaction transaction,
  ) async {
    if (transaction.id ==
        null) {
      return;
    }

    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'লেনদেন মুছে ফেলবেন?',
          ),
          content: const Text(
            'এই transaction মুছে দিলে হিসাব থেকে এটি বাদ যাবে।',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'বাতিল',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'মুছে ফেলুন',
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    await MoneyDbHelper.instance
        .deleteTransaction(
      transaction.id!,
    );

    await widget.onDeleted();

    if (!mounted) {
      return;
    }

    setState(() {
      _transactions.removeWhere(
        (item) =>
            item.id ==
            transaction.id,
      );
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      const SnackBar(
        content: Text(
          'Transaction মুছে ফেলা হয়েছে',
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final total =
        _transactions.fold<double>(
      0,
      (sum, item) =>
          sum + item.amount,
    );

    final isIncome =
        widget.type == 'Income';

    final color = isIncome
        ? Colors.blue
        : Colors.redAccent;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category,
        ),
        actions: [
          Padding(
            padding:
                const EdgeInsets.only(
              right: 16,
            ),
            child: Center(
              child: Text(
                _money(total),
                style:
                    TextStyle(
                  color: color,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),

      body:
          _transactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    children: [
                      Icon(
                        Icons
                            .receipt_long_outlined,
                        size: 64,
                        color: AppTheme
                            .textMuted
                            .withValues(
                          alpha:
                              0.5,
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      const Text(
                        'এই খাতে কোনো transaction নেই',
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets
                          .all(16),
                  itemCount:
                      _transactions
                          .length,
                  itemBuilder:
                      (
                    context,
                    index,
                  ) {
                    final transaction =
                        _transactions[
                            index];

                    return Card(
                      margin:
                          const EdgeInsets
                              .only(
                        bottom: 10,
                      ),
                      child:
                          ListTile(
                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal:
                              14,
                          vertical:
                              5,
                        ),

                        leading:
                            CircleAvatar(
                          backgroundColor:
                              color.withValues(
                            alpha:
                                0.13,
                          ),
                          child: Icon(
                            isIncome
                                ? Icons
                                    .arrow_downward_rounded
                                : Icons
                                    .arrow_upward_rounded,
                            color:
                                color,
                          ),
                        ),

                        title: Text(
                          _money(
                            transaction
                                .amount,
                          ),
                          style:
                              TextStyle(
                            color:
                                color,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        subtitle:
                            Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            const SizedBox(
                              height:
                                  4,
                            ),

                            Text(
                              transaction
                                  .date,
                            ),

                            Text(
                              transaction
                                  .account,
                            ),

                            if (transaction
                                        .note !=
                                    null &&
                                transaction
                                    .note!
                                    .trim()
                                    .isNotEmpty)
                              Text(
                                transaction
                                    .note!,
                                maxLines:
                                    2,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                              ),
                          ],
                        ),

                        // ==================================================
                        // EDIT + DELETE
                        // ==================================================

                        trailing:
                            PopupMenuButton<String>(
                          onSelected:
                              (value) {
                            if (value ==
                                'edit') {
                              _editTransaction(
                                transaction,
                              );
                            }

                            if (value ==
                                'delete') {
                              _deleteTransaction(
                                transaction,
                              );
                            }
                          },
                          itemBuilder:
                              (context) {
                            return const [
                              PopupMenuItem(
                                value:
                                    'edit',
                                child:
                                    Row(
                                  children: [
                                    Icon(
                                      Icons
                                          .edit_outlined,
                                    ),
                                    SizedBox(
                                      width:
                                          8,
                                    ),
                                    Text(
                                      'সম্পাদনা করুন',
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value:
                                    'delete',
                                child:
                                    Row(
                                  children: [
                                    Icon(
                                      Icons
                                          .delete_outline_rounded,
                                    ),
                                    SizedBox(
                                      width:
                                          8,
                                    ),
                                    Text(
                                      'মুছে ফেলুন',
                                    ),
                                  ],
                                ),
                              ),
                            ];
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
