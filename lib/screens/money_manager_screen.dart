import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import '../logic/money_db_helper.dart';
import 'report_screen.dart';

class MoneyManagerScreen extends StatefulWidget {
  const MoneyManagerScreen({super.key});

  @override
  State<MoneyManagerScreen> createState() =>
      _MoneyManagerScreenState();
}

class _MoneyManagerScreenState
    extends State<MoneyManagerScreen> {
  int _currentIndex = 0;
  int _statsTab = 1;
  String _filterType = 'Monthly';

  List<MoneyTransaction> _transactions = [];

  static const String _incomeCategoryKey =
      'money_manager_custom_income_categories';

  static const String _expenseCategoryKey =
      'money_manager_custom_expense_categories';

  final List<String> _defaultExpenseCategories = [
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

  final List<String> _defaultIncomeCategories = [
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

  late List<String> _incomeCategories;
  late List<String> _expenseCategories;

  final List<String> _accounts = [
    'Cash',
    'Bkash',
    'Bank Account',
    'Nagad',
    'Card',
  ];

  @override
  void initState() {
    super.initState();

    _incomeCategories =
        List<String>.from(_defaultIncomeCategories);

    _expenseCategories =
        List<String>.from(_defaultExpenseCategories);

    _loadCategories();
    _loadTransactions();
  }

  // ============================================================
  // LOAD TRANSACTIONS
  // ============================================================

  Future<void> _loadTransactions() async {
    try {
      final data =
          await MoneyDbHelper.instance.getAllTransactions();

      if (!mounted) return;

      setState(() {
        _transactions = data;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _transactions = [];
      });
    }
  }

  // ============================================================
  // LOAD CATEGORIES
  // ============================================================

  Future<void> _loadCategories() async {
    try {
      final prefs =
          await SharedPreferences.getInstance();

      final savedIncome =
          prefs.getStringList(_incomeCategoryKey) ?? [];

      final savedExpense =
          prefs.getStringList(_expenseCategoryKey) ?? [];

      final income = <String>{
        ..._defaultIncomeCategories,
        ...savedIncome,
      }.toList();

      final expense = <String>{
        ..._defaultExpenseCategories,
        ...savedExpense,
      }.toList();

      if (!mounted) return;

      setState(() {
        _incomeCategories = income;
        _expenseCategories = expense;
      });
    } catch (_) {
      // Default categories remain available.
    }
  }

  // ============================================================
  // DATE PARSER
  // ============================================================

  DateTime? _parseDate(String value) {
    try {
      return DateFormat('dd/MM/yyyy').parseStrict(value);
    } catch (_) {
      return null;
    }
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

    return _transactions.where((transaction) {
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
        return transactionDate.year == today.year &&
            transactionDate.month == today.month;
      }

      if (_filterType == 'Yearly') {
        return transactionDate.year == today.year;
      }

      return false;
    }).toList();
  }

  // ============================================================
  // TOTALS
  // ============================================================

  double _totalByType(String type) {
    return _filteredTransactions
        .where((item) => item.type == type)
        .fold<double>(
          0,
          (sum, item) => sum + item.amount,
        );
  }

  double get _totalIncome => _totalByType('Income');

  double get _totalExpense => _totalByType('Expense');

  double get _balance => _totalIncome - _totalExpense;

  // ============================================================
  // CATEGORY TOTALS
  // ============================================================

  Map<String, double> _categoryTotals(String type) {
    final result = <String, double>{};

    for (final transaction in _filteredTransactions) {
      if (transaction.type != type) continue;

      result[transaction.category] =
          (result[transaction.category] ?? 0) +
              transaction.amount;
    }

    return result;
  }

  // ============================================================
  // ACCOUNT BALANCE
  // ============================================================

  double _accountBalance(String accountName) {
    double balance = 0;

    for (final transaction in _transactions) {
      if (transaction.type == 'Income') {
        if (transaction.account == accountName) {
          balance += transaction.amount;
        }
      }

      if (transaction.type == 'Expense') {
        if (transaction.account == accountName) {
          balance -= transaction.amount;
        }
      }

      if (transaction.type == 'Transfer') {
        final parts = transaction.account.split('➔');

        if (parts.length == 2) {
          final from = parts[0].trim();
          final to = parts[1].trim();

          if (from == accountName) {
            balance -= transaction.amount;
          }

          if (to == accountName) {
            balance += transaction.amount;
          }
        }
      }
    }

    return balance;
  }

  // ============================================================
  // OPEN ADD TRANSACTION
  // ============================================================

  Future<void> _openAddTransaction() async {
    await _loadCategories();

    if (!mounted) return;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (_) {
        return _TransactionSheet(
          incomeCategories: _incomeCategories,
          expenseCategories: _expenseCategories,
          accounts: _accounts,
        );
      },
    );

    if (!mounted) return;

    if (saved == true) {
      await _loadCategories();
      await _loadTransactions();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'লেনদেন সফলভাবে সংরক্ষণ হয়েছে',
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // ============================================================
  // DELETE TRANSACTION
  // ============================================================

  Future<void> _confirmDeleteTransaction(
    MoneyTransaction transaction,
  ) async {
    if (transaction.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: Text(
            'লেনদেন মুছে ফেলবেন?',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'এই লেনদেনটি স্থায়ীভাবে মুছে যাবে।',
            style: TextStyle(
              color: AppTheme.textMuted,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('বাতিল'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('মুছে ফেলুন'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await MoneyDbHelper.instance.deleteTransaction(
        transaction.id!,
      );

      await _loadTransactions();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('লেনদেন মুছে ফেলা হয়েছে'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'লেনদেন মুছতে সমস্যা হয়েছে',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildTransactionView(),
      _buildStatsView(),
      _buildAccountsView(),
      const ReportScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'মানি ম্যানেজার',
          style: TextStyle(
            color: AppTheme.isDark
                ? AppTheme.gold
                : AppTheme.darkGreen,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await _loadCategories();
              await _loadTransactions();
            },
            icon: Icon(
              Icons.refresh_rounded,
              color: AppTheme.isDark
                  ? AppTheme.gold
                  : AppTheme.darkGreen,
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: AppTheme.gold,
              foregroundColor: AppTheme.darkGreen,
              onPressed: _openAddTransaction,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'লেনদেন যোগ',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.cardColor,
        selectedItemColor: AppTheme.gold,
        unselectedItemColor: AppTheme.textMuted,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book_rounded),
            label: 'লেনদেন',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart_rounded),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_balance_wallet_outlined,
            ),
            activeIcon: Icon(
              Icons.account_balance_wallet_rounded,
            ),
            label: 'Accounts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment_outlined),
            activeIcon: Icon(Icons.assessment_rounded),
            label: 'Report',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TRANSACTION VIEW
  // ============================================================

  Widget _buildTransactionView() {
    final transactions = [..._filteredTransactions];

    transactions.sort((a, b) {
      final dateA = _parseDate(a.date);
      final dateB = _parseDate(b.date);

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;

      final dateCompare = dateB.compareTo(dateA);

      if (dateCompare != 0) {
        return dateCompare;
      }

      return (b.id ?? 0).compareTo(a.id ?? 0);
    });

    final grouped =
        <String, List<MoneyTransaction>>{};

    for (final transaction in transactions) {
      grouped.putIfAbsent(
        transaction.date,
        () => [],
      );

      grouped[transaction.date]!.add(transaction);
    }

    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: grouped.isEmpty
              ? _emptyState(
                  Icons.receipt_long_outlined,
                  _emptyFilterMessage(),
                )
              : RefreshIndicator(
                  onRefresh: _loadTransactions,
                  color: AppTheme.gold,
                  child: ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      12,
                      8,
                      12,
                      100,
                    ),
                    children: grouped.entries
                        .map(
                          (entry) {
                            final date =
                                _parseDate(entry.key);

                            return _buildDateGroup(
                              entry.key,
                              date,
                              entry.value,
                            );
                          },
                        )
                        .toList(),
                  ),
                ),
        ),
      ],
    );
  }

  String _emptyFilterMessage() {
    if (_filterType == 'Daily') {
      return 'আজ কোনো লেনদেন নেই';
    }

    if (_filterType == 'Weekly') {
      return 'এই সপ্তাহে কোনো লেনদেন নেই';
    }

    if (_filterType == 'Monthly') {
      return 'এই মাসে কোনো লেনদেন নেই';
    }

    return 'এই বছরে কোনো লেনদেন নেই';
  }

  // ============================================================
  // FILTER BAR
  // ============================================================

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        12,
        10,
        12,
        5,
      ),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: AppTheme.gold.withValues(
              alpha: 0.15,
            ),
          ),
        ),
        child: Row(
          children: [
            _filterButton('Daily', 'দৈনিক'),
            _filterButton('Weekly', 'সাপ্তাহিক'),
            _filterButton('Monthly', 'মাসিক'),
            _filterButton('Yearly', 'বার্ষিক'),
          ],
        ),
      ),
    );
  }

  Widget _filterButton(
    String value,
    String title,
  ) {
    final selected = _filterType == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _filterType = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 180,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 3,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.gold
                : Colors.transparent,
            borderRadius:
                BorderRadius.circular(11),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected
                  ? AppTheme.darkGreen
                  : AppTheme.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DATE GROUP
  // ============================================================

  Widget _buildDateGroup(
    String dateText,
    DateTime? date,
    List<MoneyTransaction> transactions,
  ) {
    final formattedDate = date == null
        ? dateText
        : DateFormat(
            'dd MMMM yyyy',
            'bn',
          ).format(date);

    final dayName = date == null
        ? ''
        : DateFormat(
            'EEEE',
            'bn',
          ).format(date);

    final dayIncome = transactions
        .where(
          (item) => item.type == 'Income',
        )
        .fold<double>(
          0,
          (sum, item) => sum + item.amount,
        );

    final dayExpense = transactions
        .where(
          (item) => item.type == 'Expense',
        )
        .fold<double>(
          0,
          (sum, item) => sum + item.amount,
        );

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            5,
            12,
            5,
            9,
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Container(
                width: 5,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.gold,
                  borderRadius:
                      BorderRadius.circular(5),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: TextStyle(
                        color:
                            AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    if (dayName.isNotEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.only(
                          top: 2,
                        ),
                        child: Text(
                          dayName,
                          style: TextStyle(
                            color:
                                AppTheme.textMuted,
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (dayIncome > 0 ||
                  dayExpense > 0)
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  children: [
                    if (dayIncome > 0)
                      Text(
                        '+৳ ${dayIncome.toStringAsFixed(0)}',
                        style:
                            const TextStyle(
                          color: Colors.blue,
                          fontSize: 10,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    if (dayExpense > 0)
                      Text(
                        '-৳ ${dayExpense.toStringAsFixed(0)}',
                        style:
                            const TextStyle(
                          color:
                              Colors.redAccent,
                          fontSize: 10,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
        ...transactions.map(
          (transaction) =>
              _transactionCard(transaction),
        ),
      ],
    );
  }

  // ============================================================
  // TRANSACTION CARD
  // ============================================================

  Widget _transactionCard(
    MoneyTransaction transaction,
  ) {
    final income =
        transaction.type == 'Income';

    final expense =
        transaction.type == 'Expense';

    final transfer =
        transaction.type == 'Transfer';

    final color = income
        ? Colors.blue
        : expense
            ? Colors.redAccent
            : AppTheme.gold;

    final icon = income
        ? Icons.arrow_downward_rounded
        : expense
            ? Icons.arrow_upward_rounded
            : Icons.swap_horiz_rounded;

    return Container(
      margin:
          const EdgeInsets.only(bottom: 8),
      padding:
          const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius:
            BorderRadius.circular(17),
        border: Border.all(
          color: color.withValues(
            alpha: 0.22,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.12,
              ),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  transfer
                      ? 'ট্রান্সফার'
                      : transaction.category,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    color:
                        AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.account,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    color:
                        AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
                if ((transaction.note ?? '')
                    .trim()
                    .isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.only(
                      top: 4,
                    ),
                    child: Text(
                      transaction.note!,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        color:
                            AppTheme.textMuted,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                '${income ? '+' : expense ? '-' : ''}৳ ${transaction.amount.toStringAsFixed(2)}',
                textAlign:
                    TextAlign.end,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  _confirmDeleteTransaction(
                    transaction,
                  );
                },
                borderRadius:
                    BorderRadius.circular(20),
                child: const Padding(
                  padding:
                      EdgeInsets.all(4),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color:
                        Colors.redAccent,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATS VIEW
  // ============================================================

  Widget _buildStatsView() {
    final income = _totalIncome;
    final expense = _totalExpense;

    final type =
        _statsTab == 0
            ? 'Income'
            : 'Expense';

    final categories =
        _categoryTotals(type);

    final total =
        categories.values.fold<double>(
      0,
      (sum, value) => sum + value,
    );

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      color: AppTheme.gold,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          14,
          12,
          14,
          30,
        ),
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: AppTheme.gold.withValues(
                alpha: 0.08,
              ),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.filter_alt_outlined,
                  color: AppTheme.gold,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  _filterBanglaName(),
                  style: TextStyle(
                    color:
                        AppTheme.goldLight,
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _statCard(
                  'মোট আয়',
                  income,
                  Colors.blue,
                  Icons.trending_up_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCard(
                  'মোট খরচ',
                  expense,
                  Colors.redAccent,
                  Icons.trending_down_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _statCard(
            _balance >= 0
                ? 'উদ্বৃত্ত'
                : 'ঘাটতি',
            _balance.abs(),
            _balance >= 0
                ? Colors.green
                : Colors.redAccent,
            _balance >= 0
                ? Icons.account_balance_rounded
                : Icons.warning_amber_rounded,
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _statsTabButton(
                    'আয়',
                    0,
                  ),
                ),
                Expanded(
                  child: _statsTabButton(
                    'খরচ',
                    1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          if (categories.isEmpty)
            _emptyState(
              Icons.bar_chart_rounded,
              'এই সময়ে কোনো তথ্য নেই',
            )
          else ...[
            _buildPieChart(
              categories,
              total,
            ),
            const SizedBox(height: 16),
            _buildCategoryStats(
              categories,
            ),
          ],
        ],
      ),
    );
  }

  String _filterBanglaName() {
    if (_filterType == 'Daily') {
      return 'দৈনিক হিসাব';
    }

    if (_filterType == 'Weekly') {
      return 'সাপ্তাহিক হিসাব';
    }

    if (_filterType == 'Monthly') {
      return 'মাসিক হিসাব';
    }

    return 'বার্ষিক হিসাব';
  }

  // ============================================================
  // PIE CHART
  // ============================================================

  Widget _buildPieChart(
    Map<String, double> data,
    double total,
  ) {
    final entries = data.entries.toList()
      ..sort(
        (a, b) => b.value.compareTo(a.value),
      );

    final chartEntries =
        entries.take(8).toList();

    final otherTotal =
        entries.skip(8).fold<double>(
              0,
              (sum, item) =>
                  sum + item.value,
            );

    if (otherTotal > 0) {
      chartEntries.add(
        MapEntry(
          'অন্যান্য',
          otherTotal,
        ),
      );
    }

    final colors = [
      const Color(0xFF4FC3F7),
      const Color(0xFF81C784),
      const Color(0xFFFFB74D),
      const Color(0xFFE57373),
      const Color(0xFFBA68C8),
      const Color(0xFF64B5F6),
      const Color(0xFFFFD54F),
      const Color(0xFF4DB6AC),
      const Color(0xFF90A4AE),
    ];

    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        12,
        16,
        12,
        14,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.gold.withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart_rounded,
                color: AppTheme.gold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _statsTab == 0
                    ? 'আয়ের বিশ্লেষণ'
                    : 'খরচের বিশ্লেষণ',
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
          const SizedBox(height: 12),
          SizedBox(
            height: 230,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 58,
                sections: List.generate(
                  chartEntries.length,
                  (index) {
                    final entry =
                        chartEntries[index];

                    final percentage =
                        total == 0
                            ? 0.0
                            : entry.value /
                                total *
                                100;

                    return PieChartSectionData(
                      value: entry.value,
                      color: colors[
                          index %
                              colors.length],
                      radius: 72,
                      title: percentage >= 4
                          ? '${percentage.toStringAsFixed(0)}%'
                          : '',
                      titleStyle:
                          const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'মোট ৳ ${total.toStringAsFixed(2)}',
            style: TextStyle(
              color: AppTheme.gold,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: List.generate(
              chartEntries.length,
              (index) {
                final entry =
                    chartEntries[index];

                return Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration:
                          BoxDecoration(
                        color: colors[
                            index %
                                colors.length],
                        shape:
                            BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      entry.key,
                      style: TextStyle(
                        color:
                            AppTheme.textMuted,
                        fontSize: 10.5,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATS TAB
  // ============================================================

  Widget _statsTabButton(
    String title,
    int index,
  ) {
    final selected =
        _statsTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _statsTab = index;
        });
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.gold
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(10),
        ),
        child: Text(
          title,
          textAlign:
              TextAlign.center,
          style: TextStyle(
            color: selected
                ? AppTheme.darkGreen
                : AppTheme.textMuted,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY STATS
  // ============================================================

  Widget _buildCategoryStats(
    Map<String, double> data,
  ) {
    final entries = data.entries.toList()
      ..sort(
        (a, b) => b.value.compareTo(a.value),
      );

    final total =
        data.values.fold<double>(
      0,
      (sum, value) => sum + value,
    );

    return Column(
      children: entries.map((entry) {
        final percentage =
            total == 0
                ? 0.0
                : entry.value / total;

        return Container(
          margin:
              const EdgeInsets.only(
            bottom: 9,
          ),
          padding:
              const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius:
                BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        color:
                            AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '৳ ${entry.value.toStringAsFixed(2)}',
                    style: TextStyle(
                      color:
                          AppTheme.gold,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(8),
                child:
                    LinearProgressIndicator(
                  value: percentage,
                  minHeight: 6,
                  backgroundColor:
                      AppTheme.gold
                          .withValues(
                    alpha: 0.10,
                  ),
                  valueColor:
                      AlwaysStoppedAnimation<
                          Color>(
                    AppTheme.gold,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget _statCard(
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              color.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color:
                  color.withValues(
                alpha: 0.12,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 21,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color:
                        AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                FittedBox(
                  child: Text(
                    '৳ ${amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w900,
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
  // ACCOUNTS
  // ============================================================

  Widget _buildAccountsView() {
    return RefreshIndicator(
      onRefresh: _loadTransactions,
      color: AppTheme.gold,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.fromLTRB(
          14,
          14,
          14,
          30,
        ),
        children: [
          Text(
            'অ্যাকাউন্টসমূহ',
            style: TextStyle(
              color:
                  AppTheme.textPrimary,
              fontSize: 19,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ..._accounts.map((account) {
            final balance =
                _accountBalance(account);

            return Container(
              margin:
                  const EdgeInsets.only(
                bottom: 10,
              ),
              padding:
                  const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    AppTheme.cardColor,
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
                border: Border.all(
                  color: AppTheme.gold
                      .withValues(
                    alpha: 0.25,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration:
                        BoxDecoration(
                      color: AppTheme.gold
                          .withValues(
                        alpha: 0.12,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        13,
                      ),
                    ),
                    child: Icon(
                      Icons
                          .account_balance_wallet_rounded,
                      color:
                          AppTheme.gold,
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Text(
                      account,
                      style: TextStyle(
                        color:
                            AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    '৳ ${balance.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: balance >= 0
                          ? Colors.green
                          : Colors.redAccent,
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState(
    IconData icon,
    String text,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(50),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 55,
              color:
                  AppTheme.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    AppTheme.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TRANSACTION SHEET
// ============================================================================

class _TransactionSheet
    extends StatefulWidget {
  final List<String> incomeCategories;
  final List<String> expenseCategories;
  final List<String> accounts;

  const _TransactionSheet({
    required this.incomeCategories,
    required this.expenseCategories,
    required this.accounts,
  });

  @override
  State<_TransactionSheet> createState() =>
      _TransactionSheetState();
}

class _TransactionSheetState
    extends State<_TransactionSheet> {
  String _type = 'Expense';

  late List<String> _incomeCategories;
  late List<String> _expenseCategories;

  String? _selectedCategory;
  String? _selectedAccount;
  String? _targetAccount;

  DateTime _selectedDate =
      DateTime.now();

  bool _saving = false;

  final TextEditingController
      _amountController =
      TextEditingController();

  final TextEditingController
      _noteController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    _incomeCategories =
        List<String>.from(
      widget.incomeCategories,
    );

    _expenseCategories =
        List<String>.from(
      widget.expenseCategories,
    );

    _selectedCategory =
        _expenseCategories.isNotEmpty
            ? _expenseCategories.first
            : null;

    _selectedAccount =
        widget.accounts.isNotEmpty
            ? widget.accounts.first
            : null;

    _targetAccount =
        widget.accounts.length > 1
            ? widget.accounts[1]
            : widget.accounts.isNotEmpty
                ? widget.accounts.first
                : null;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  List<String> get _currentCategories {
    if (_type == 'Income') {
      return _incomeCategories;
    }

    return _expenseCategories;
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectTransactionDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText:
          'লেনদেনের তারিখ নির্বাচন করুন',
      cancelText: 'বাতিল',
      confirmText: 'নির্বাচন',
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDate = picked;
    });
  }

  // ============================================================
  // ADD CATEGORY
  // ============================================================

  Future<void> _addCategory() async {
    final controller =
        TextEditingController();

    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: Text(
            _type == 'Income'
                ? 'নতুন আয় খাত যোগ করুন'
                : 'নতুন খরচের খাত যোগ করুন',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: TextStyle(
              color: AppTheme.textPrimary,
            ),
            decoration: const InputDecoration(
              hintText: 'খাতের নাম লিখুন',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('বাতিল'),
            ),
            ElevatedButton(
              onPressed: () {
                final text =
                    controller.text.trim();

                if (text.isEmpty) return;

                Navigator.of(dialogContext)
                    .pop(text);
              },
              child: const Text('যোগ করুন'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (value == null ||
        value.trim().isEmpty ||
        !mounted) {
      return;
    }

    final category = value.trim();

    final current =
        _type == 'Income'
            ? _incomeCategories
            : _expenseCategories;

    final exists = current.any(
      (item) =>
          item.trim().toLowerCase() ==
          category.toLowerCase(),
    );

    if (exists) {
      _showMessage(
        'এই খাতটি আগে থেকেই আছে',
      );
      return;
    }

    setState(() {
      if (_type == 'Income') {
        _incomeCategories.add(category);
      } else {
        _expenseCategories.add(category);
      }

      _selectedCategory = category;
    });

    try {
      final prefs =
          await SharedPreferences.getInstance();

      if (_type == 'Income') {
        final customIncome =
            _incomeCategories
                .where(
                  (item) =>
                      !widget
                          .incomeCategories
                          .contains(item),
                )
                .toList();

        await prefs.setStringList(
          'money_manager_custom_income_categories',
          customIncome,
        );
      } else {
        final customExpense =
            _expenseCategories
                .where(
                  (item) =>
                      !widget
                          .expenseCategories
                          .contains(item),
                )
                .toList();

        await prefs.setStringList(
          'money_manager_custom_expense_categories',
          customExpense,
        );
      }
    } catch (_) {}

    if (!mounted) return;

    _showMessage(
      '“$category” খাত যোগ হয়েছে',
    );
  }

  // ============================================================
  // SAVE TRANSACTION
  // ============================================================

  Future<void> _save() async {
    if (_saving) return;

    final amount = double.tryParse(
      _amountController.text
          .trim()
          .replaceAll(',', ''),
    );

    if (amount == null || amount <= 0) {
      _showMessage('সঠিক পরিমাণ লিখুন');
      return;
    }

    if (_selectedAccount == null) {
      _showMessage(
        'অ্যাকাউন্ট নির্বাচন করুন',
      );
      return;
    }

    if (_type != 'Transfer' &&
        _selectedCategory == null) {
      _showMessage(
        'খাত নির্বাচন করুন',
      );
      return;
    }

    if (_type == 'Transfer' &&
        (_targetAccount == null ||
            _targetAccount ==
                _selectedAccount)) {
      _showMessage(
        'ভিন্ন অ্যাকাউন্ট নির্বাচন করুন',
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final transaction = MoneyTransaction(
        type: _type,
        amount: amount,
        date: DateFormat(
          'dd/MM/yyyy',
        ).format(
          _selectedDate,
        ),
        category: _type == 'Transfer'
            ? 'Transfer'
            : _selectedCategory!,
        account: _type == 'Transfer'
            ? '$_selectedAccount ➔ $_targetAccount'
            : _selectedAccount!,
        note: _noteController.text.trim(),
      );

      await MoneyDbHelper.instance
          .insertTransaction(
        transaction,
      );

      if (!mounted) return;

      // IMPORTANT:
      // এখানে আর parent screen update করা হচ্ছে না।
      // শুধু true দিয়ে BottomSheet বন্ধ করা হচ্ছে।
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      _showMessage(
        'লেনদেন সংরক্ষণ করতে সমস্যা হয়েছে',
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // BUILD SHEET
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 10,
          bottom:
              MediaQuery.of(context)
                      .viewInsets
                      .bottom +
                  16,
        ),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius:
              const BorderRadius.vertical(
            top: Radius.circular(26),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textMuted,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Text(
                'নতুন লেনদেন',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: _typeButton(
                      'Income',
                      'আয়',
                      Icons
                          .arrow_downward_rounded,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _typeButton(
                      'Expense',
                      'খরচ',
                      Icons
                          .arrow_upward_rounded,
                      Colors.redAccent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _typeButton(
                      'Transfer',
                      'ট্রান্সফার',
                      Icons.swap_horiz_rounded,
                      AppTheme.gold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _label('পরিমাণ'),

              const SizedBox(height: 6),

              TextField(
                controller:
                    _amountController,
                enabled: !_saving,
                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),
                style: TextStyle(
                  color:
                      AppTheme.textPrimary,
                ),
                decoration:
                    const InputDecoration(
                  hintText:
                      'যেমন: 5000',
                  prefixText: '৳ ',
                ),
              ),

              const SizedBox(height: 13),

              _label(
                'লেনদেনের তারিখ',
              ),

              const SizedBox(height: 6),

              GestureDetector(
                onTap: _saving
                    ? null
                    : _selectTransactionDate,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 15,
                  ),
                  decoration:
                      BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius:
                        BorderRadius.circular(
                      13,
                    ),
                    border: Border.all(
                      color:
                          AppTheme.gold
                              .withValues(
                        alpha: 0.25,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons
                            .calendar_month_rounded,
                        color: AppTheme.gold,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          DateFormat(
                            'dd/MM/yyyy',
                          ).format(
                            _selectedDate,
                          ),
                          style: TextStyle(
                            color:
                                AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ),
                      Icon(
                        Icons
                            .arrow_drop_down_rounded,
                        color:
                            AppTheme.textMuted,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 13),

              _label(
                _type == 'Transfer'
                    ? 'যে অ্যাকাউন্ট থেকে'
                    : 'অ্যাকাউন্ট',
              ),

              const SizedBox(height: 6),

              DropdownButtonFormField<String>(
                value: _selectedAccount,
                isExpanded: true,
                decoration:
                    const InputDecoration(),
                items: widget.accounts
                    .map(
                      (account) {
                        return DropdownMenuItem<
                            String>(
                          value: account,
                          child: Text(account),
                        );
                      },
                    )
                    .toList(),
                onChanged: _saving
                    ? null
                    : (value) {
                        setState(() {
                          _selectedAccount =
                              value;
                        });
                      },
              ),

              if (_type == 'Transfer') ...[
                const SizedBox(height: 13),

                _label('যে অ্যাকাউন্টে'),

                const SizedBox(height: 6),

                DropdownButtonFormField<String>(
                  value: _targetAccount,
                  isExpanded: true,
                  decoration:
                      const InputDecoration(),
                  items: widget.accounts
                      .map(
                        (account) {
                          return DropdownMenuItem<
                              String>(
                            value: account,
                            child:
                                Text(account),
                          );
                        },
                      )
                      .toList(),
                  onChanged: _saving
                      ? null
                      : (value) {
                          setState(() {
                            _targetAccount =
                                value;
                          });
                        },
                ),
              ],

              if (_type != 'Transfer') ...[
                const SizedBox(height: 13),

                Row(
                  children: [
                    Expanded(
                      child: _label('খাত'),
                    ),
                    TextButton.icon(
                      onPressed: _saving
                          ? null
                          : _addCategory,
                      icon: const Icon(
                        Icons.add_rounded,
                        size: 17,
                      ),
                      label: const Text(
                        'নতুন খাত',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 2),

                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  decoration:
                      const InputDecoration(),
                  items:
                      _currentCategories.map(
                    (category) {
                      return DropdownMenuItem<
                          String>(
                        value: category,
                        child:
                            Text(category),
                      );
                    },
                  ).toList(),
                  onChanged: _saving
                      ? null
                      : (value) {
                          setState(() {
                            _selectedCategory =
                                value;
                          });
                        },
                ),
              ],

              const SizedBox(height: 13),

              _label('নোট'),

              const SizedBox(height: 6),

              TextField(
                controller:
                    _noteController,
                enabled: !_saving,
                maxLines: 3,
                style: TextStyle(
                  color:
                      AppTheme.textPrimary,
                ),
                decoration:
                    const InputDecoration(
                  hintText:
                      'প্রয়োজনে নোট লিখুন',
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed:
                      _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 19,
                          height: 19,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color:
                                AppTheme.darkGreen,
                          ),
                        )
                      : const Icon(
                          Icons.save_rounded,
                        ),
                  label: Text(
                    _saving
                        ? 'সংরক্ষণ হচ্ছে...'
                        : 'সংরক্ষণ করুন',
                    style:
                        const TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // ============================================================
  // TYPE BUTTON
  // ============================================================

  Widget _typeButton(
    String type,
    String title,
    IconData icon,
    Color color,
  ) {
    final selected = _type == type;

    return GestureDetector(
      onTap: _saving
          ? null
          : () {
              setState(() {
                _type = type;

                if (type == 'Income') {
                  _selectedCategory =
                      _incomeCategories
                              .isNotEmpty
                          ? _incomeCategories
                              .first
                          : null;
                } else if (type ==
                    'Expense') {
                  _selectedCategory =
                      _expenseCategories
                              .isNotEmpty
                          ? _expenseCategories
                              .first
                          : null;
                } else {
                  _selectedCategory = null;
                }
              });
            },
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 11,
          horizontal: 5,
        ),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(
                  alpha: 0.16,
                )
              : AppTheme.cardColor,
          borderRadius:
              BorderRadius.circular(13),
          border: Border.all(
            color: selected
                ? color
                : AppTheme.textMuted
                    .withValues(
              alpha: 0.18,
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
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: selected
                    ? color
                    : AppTheme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
