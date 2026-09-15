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

    // ==========================================================
    // DATE অনুযায়ী SORT
    // নতুন তারিখ আগে
    // একই তারিখ হলে নতুন ID আগে
    // ==========================================================

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

                    // AMOUNT

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

                    // INCOME / EXPENSE

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

                    // TRANSFER

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

                    // DATE

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

                    // NOTE

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
                : AppTheme.textMuted
                    .withValues(
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
              : ListView.builder(
                  padding:
                      const EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    90,
                  ),
                  itemCount:
                      transactions.length,
                  itemBuilder:
                      (context, index) {
                    return _transactionCard(
                      transactions[index],
                    );
                  },
                ),
        ),
      ],
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
  // TRANSACTION CARD
  // ============================================================

  Widget _transactionCard(
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

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 5,
        ),

        leading: CircleAvatar(
          backgroundColor:
              color.withValues(
            alpha: 0.13,
          ),
          child: Icon(
            icon,
            color: color,
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
              transaction.date,
              style: TextStyle(
                color:
                    AppTheme.textMuted,
              ),
            ),

            Text(
              transaction.account,
              style: TextStyle(
                color: isTransfer
                    ? Colors.orange
                    : AppTheme
                        .textMuted,
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
                isIncome
                    ? '+'
                    : '-',
                style: TextStyle(
                  color: color,
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 15,
                ),
              ),

            Text(
              '৳ ${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: color,
                fontWeight:
                    FontWeight.bold,
                fontSize: 12,
              ),
            ),

            PopupMenuButton<String>(
              onSelected:
                  (value) {
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
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons
                              .delete_outline,
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
  // PIE CHART
  // ============================================================

  Widget _buildPieChart(
    Map<String, double> data,
    double total,
    String type,
  ) {
    final entries =
        data.entries.toList();

    return Container(
      height: 310,
      padding:
          const EdgeInsets.all(16),
      decoration:
          BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 190,
            child: PieChart(
              PieChartData(
                centerSpaceRadius:
                    48,
                sectionsSpace: 3,
                sections:
                    List.generate(
                  entries.length,
                  (index) {
                    final value =
                        entries[index]
                            .value;

                    final percent =
                        total == 0
                            ? 0
                            : value /
                                total *
                                100;

                    return PieChartSectionData(
                      value: value,
                      title:
                          '${percent.toStringAsFixed(0)}%',
                      radius: 72,
                      titleStyle:
                          const TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight
                                .bold,
                        color:
                            Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Expanded(
            child:
                SingleChildScrollView(
              child: Wrap(
                spacing: 10,
                runSpacing: 7,
                children:
                    entries.map(
                  (entry) {
                    return InkWell(
                      onTap: () {
                        _openCategoryTransactions(
                          entry.key,
                          type,
                        );
                      },
                      borderRadius:
                          BorderRadius.circular(
                        8,
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 3,
                          vertical: 2,
                        ),
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration:
                                  BoxDecoration(
                                shape:
                                    BoxShape
                                        .circle,
                                color:
                                    AppTheme
                                        .gold,
                              ),
                            ),

                            const SizedBox(
                              width: 5,
                            ),

                            Text(
                              entry.key,
                              style:
                                  TextStyle(
                                color:
                                    AppTheme
                                        .textMuted,
                                fontSize:
                                    12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
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
                  shape:
                      BoxShape.circle,
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

  const CategoryTransactionsScreen({
    super.key,
    required this.category,
    required this.type,
    required this.transactions,
    required this.onDeleted,
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

    // Category screen-এও
    // নতুন তারিখ আগে
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

  String _money(
    double value,
  ) {
    return '৳ ${value.toStringAsFixed(2)}';
  }

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
                        trailing:
                            IconButton(
                          onPressed:
                              () {
                            _deleteTransaction(
                              transaction,
                            );
                          },
                          icon:
                              const Icon(
                            Icons
                                .delete_outline_rounded,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
