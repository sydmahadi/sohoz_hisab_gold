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

  DateTime _selectedDate = DateTime.now();
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
    'প্রোগ্রাম বান্তবায়ন',
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

  late List<String> _expenseCategories;
  late List<String> _incomeCategories;

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

    _expenseCategories =
        List<String>.from(_defaultExpenseCategories);

    _incomeCategories =
        List<String>.from(_defaultIncomeCategories);

    _loadCategories();
    _loadTransactions();
  }

  // ═══════════════════════════════════════════════════════════════
  // LOAD TRANSACTIONS
  // ═══════════════════════════════════════════════════════════════

  Future<void> _loadTransactions() async {
    final data =
        await MoneyDbHelper.instance.getAllTransactions();

    if (!mounted) return;

    setState(() {
      _transactions = data;
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // LOAD SAVED CUSTOM CATEGORIES
  // ═══════════════════════════════════════════════════════════════

  Future<void> _loadCategories() async {
    final prefs =
        await SharedPreferences.getInstance();

    final savedIncome =
        prefs.getStringList(
              _incomeCategoryKey,
            ) ??
            [];

    final savedExpense =
        prefs.getStringList(
              _expenseCategoryKey,
            ) ??
            [];

    final income =
        <String>{
          ..._defaultIncomeCategories,
          ...savedIncome,
        }.toList();

    final expense =
        <String>{
          ..._defaultExpenseCategories,
          ...savedExpense,
        }.toList();

    if (!mounted) return;

    setState(() {
      _incomeCategories = income;
      _expenseCategories = expense;
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // SAVE CUSTOM CATEGORIES
  // ═══════════════════════════════════════════════════════════════

  Future<void> _saveCustomCategories() async {
    final prefs =
        await SharedPreferences.getInstance();

    final customIncome =
        _incomeCategories
            .where(
              (category) =>
                  !_defaultIncomeCategories
                      .contains(category),
            )
            .toList();

    final customExpense =
        _expenseCategories
            .where(
              (category) =>
                  !_defaultExpenseCategories
                      .contains(category),
            )
            .toList();

    await prefs.setStringList(
      _incomeCategoryKey,
      customIncome,
    );

    await prefs.setStringList(
      _expenseCategoryKey,
      customExpense,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DATE PARSER
  // ═══════════════════════════════════════════════════════════════

  DateTime? _parseDate(String dateStr) {
    try {
      return DateFormat('dd/MM/yyyy')
          .parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // FILTER
  // ═══════════════════════════════════════════════════════════════

  List<MoneyTransaction>
      get _filteredTransactions {
    return _transactions.where((transaction) {
      final date =
          _parseDate(transaction.date);

      if (date == null) return false;

      if (_filterType == 'Daily') {
        return date.year ==
                _selectedDate.year &&
            date.month ==
                _selectedDate.month &&
            date.day ==
                _selectedDate.day;
      }

      if (_filterType == 'Weekly') {
        final start =
            _selectedDate.subtract(
          Duration(
            days:
                _selectedDate.weekday - 1,
          ),
        );

        final end =
            start.add(
          const Duration(days: 6),
        );

        final d = DateTime(
          date.year,
          date.month,
          date.day,
        );

        final s = DateTime(
          start.year,
          start.month,
          start.day,
        );

        final e = DateTime(
          end.year,
          end.month,
          end.day,
        );

        return !d.isBefore(s) &&
            !d.isAfter(e);
      }

      if (_filterType == 'Yearly') {
        return date.year ==
            _selectedDate.year;
      }

      return date.year ==
              _selectedDate.year &&
          date.month ==
              _selectedDate.month;
    }).toList();
  }

  // ═══════════════════════════════════════════════════════════════
  // TOTALS
  // ═══════════════════════════════════════════════════════════════

  double _totalByType(String type) {
    return _filteredTransactions
        .where(
          (e) => e.type == type,
        )
        .fold<double>(
          0,
          (sum, item) =>
              sum + item.amount,
        );
  }

  double get _totalIncome =>
      _totalByType('Income');

  double get _totalExpense =>
      _totalByType('Expense');

  double get _balance =>
      _totalIncome - _totalExpense;

  // ═══════════════════════════════════════════════════════════════
  // ACCOUNT BALANCE
  // ═══════════════════════════════════════════════════════════════

  double _accountBalance(
    String accountName,
  ) {
    double balance = 0;

    for (final transaction
        in _transactions) {
      final amount =
          transaction.amount;

      if (transaction.type ==
          'Income') {
        if (transaction.account ==
            accountName) {
          balance += amount;
        }
      } else if (transaction.type ==
          'Expense') {
        if (transaction.account ==
            accountName) {
          balance -= amount;
        }
      } else if (transaction.type ==
          'Transfer') {
        final account =
            transaction.account;

        if (account.contains('➔')) {
          final parts =
              account.split('➔');

          if (parts.length == 2) {
            final from =
                parts[0].trim();

            final to =
                parts[1].trim();

            if (from ==
                accountName) {
              balance -= amount;
            }

            if (to ==
                accountName) {
              balance += amount;
            }
          }
        }
      }
    }

    return balance;
  }

  // ═══════════════════════════════════════════════════════════════
  // CATEGORY TOTAL
  // ═══════════════════════════════════════════════════════════════

  Map<String, double> _categoryTotals(
    String type,
  ) {
    final Map<String, double> result =
        {};

    for (final transaction
        in _filteredTransactions) {
      if (transaction.type != type) {
        continue;
      }

      result[transaction.category] =
          (result[
                  transaction.category] ??
              0) +
          transaction.amount;
    }

    return result;
  }

  // ═══════════════════════════════════════════════════════════════
  // OPEN TRANSACTION SHEET
  // ═══════════════════════════════════════════════════════════════

  Future<void> _openAddTransaction() async {
    await _loadCategories();

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent,
      builder: (_) =>
          _TransactionSheet(
        incomeCategories:
            _incomeCategories,
        expenseCategories:
            _expenseCategories,
        accounts: _accounts,
        onSaved:
            _loadTransactions,
      ),
    );

    await _loadCategories();
  }

  // ═══════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final dark = AppTheme.isDark;

    final pages = [
      _buildTransView(),
      _buildStatsView(),
      _buildAccountsView(),
      const ReportScreen(),
    ];

    return Scaffold(
      backgroundColor:
          AppTheme.background,

      appBar: AppBar(
        title: Text(
          'মানি ম্যানেজার',
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
            onPressed: () async {
              await _loadCategories();
              await _loadTransactions();
            },
            icon: Icon(
              Icons.refresh_rounded,
              color: dark
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

      floatingActionButton:
          _currentIndex == 0
              ? FloatingActionButton.extended(
                  backgroundColor:
                      AppTheme.gold,
                  foregroundColor:
                      AppTheme.darkGreen,
                  onPressed:
                      _openAddTransaction,
                  icon: const Icon(
                    Icons.add_rounded,
                  ),
                  label: const Text(
                    'লেনদেন যোগ',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                )
              : null,

      bottomNavigationBar:
          BottomNavigationBar(
        currentIndex:
            _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type:
            BottomNavigationBarType.fixed,
        backgroundColor:
            AppTheme.cardColor,
        selectedItemColor:
            AppTheme.gold,
        unselectedItemColor:
            AppTheme.textMuted,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.book_outlined,
            ),
            activeIcon: Icon(
              Icons.book_rounded,
            ),
            label: 'লেনদেন',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.bar_chart_outlined,
            ),
            activeIcon: Icon(
              Icons.bar_chart_rounded,
            ),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons
                  .account_balance_wallet_outlined,
            ),
            activeIcon: Icon(
              Icons
                  .account_balance_wallet_rounded,
            ),
            label: 'Accounts',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.assessment_outlined,
            ),
            activeIcon: Icon(
              Icons.assessment_rounded,
            ),
            label: 'Report',
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TRANSACTION VIEW
  // ═══════════════════════════════════════════════════════════════

  Widget _buildTransView() {
    final transactions =
        _filteredTransactions
            .reversed
            .toList();

    return Column(
      children: [
        _buildFilterBar(),

        Expanded(
          child:
              transactions.isEmpty
                  ? _emptyState(
                      Icons
                          .receipt_long_outlined,
                      'এই সময়ে কোনো লেনদেন নেই',
                    )
                  : RefreshIndicator(
                      onRefresh:
                          _loadTransactions,
                      color:
                          AppTheme.gold,
                      child:
                          ListView.builder(
                        padding:
                            const EdgeInsets
                                .fromLTRB(
                          12,
                          8,
                          12,
                          100,
                        ),
                        itemCount:
                            transactions
                                .length,
                        itemBuilder:
                            (context,
                                index) {
                          return _transactionCard(
                            transactions[
                                index],
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // FILTER BAR
  // ═══════════════════════════════════════════════════════════════

  Widget _buildFilterBar() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        12,
        10,
        12,
        4,
      ),
      child: Row(
        children: [
          Expanded(
            child:
                SingleChildScrollView(
              scrollDirection:
                  Axis.horizontal,
              child: Row(
                children: [
                  'Daily',
                  'Weekly',
                  'Monthly',
                  'Yearly',
                ].map((item) {
                  final selected =
                      _filterType ==
                          item;

                  return Padding(
                    padding:
                        const EdgeInsets
                            .only(
                      right: 7,
                    ),
                    child:
                        ChoiceChip(
                      label: Text(
                        item ==
                                'Daily'
                            ? 'দৈনিক'
                            : item ==
                                    'Weekly'
                                ? 'সাপ্তাহিক'
                                : item ==
                                        'Monthly'
                                    ? 'মাসিক'
                                    : 'বার্ষিক',
                      ),
                      selected:
                          selected,
                      onSelected:
                          (_) {
                        setState(() {
                          _filterType =
                              item;
                        });
                      },
                      selectedColor:
                          AppTheme.gold,
                      labelStyle:
                          TextStyle(
                        color: selected
                            ? AppTheme
                                .darkGreen
                            : AppTheme
                                .textPrimary,
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          IconButton(
            onPressed:
                _selectFilterDate,
            icon: Icon(
              Icons
                  .calendar_month_rounded,
              color:
                  AppTheme.gold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectFilterDate() async {
    final picked =
        await showDatePicker(
      context: context,
      initialDate:
          _selectedDate,
      firstDate:
          DateTime(2020),
      lastDate:
          DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      _selectedDate = picked;
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // TRANSACTION CARD
  // ═══════════════════════════════════════════════════════════════

  Widget _transactionCard(
    MoneyTransaction transaction,
  ) {
    final bool income =
        transaction.type == 'Income';

    final bool expense =
        transaction.type == 'Expense';

    final bool transfer =
        transaction.type == 'Transfer';

    final Color color = income
        ? Colors.blue
        : expense
            ? Colors.redAccent
            : AppTheme.gold;

    final IconData icon = income
        ? Icons.arrow_downward_rounded
        : expense
            ? Icons.arrow_upward_rounded
            : Icons.swap_horiz_rounded;

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 9,
      ),
      padding:
          const EdgeInsets.all(13),
      decoration:
          BoxDecoration(
        color:
            AppTheme.cardColor,
        borderRadius:
            BorderRadius.circular(17),
        border: Border.all(
          color: color.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration:
                BoxDecoration(
              color: color.withValues(
                alpha: 0.12,
              ),
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
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
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  transfer
                      ? 'ট্রান্সফার'
                      : transaction
                          .category,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style: TextStyle(
                    color: AppTheme
                        .textPrimary,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  transaction
                      .account,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style: TextStyle(
                    color: AppTheme
                        .textMuted,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                Text(
                  transaction.date,
                  style: TextStyle(
                    color: AppTheme
                        .textMuted,
                    fontSize: 10,
                  ),
                ),

                if ((transaction
                            .note ??
                        '')
                    .trim()
                    .isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets
                            .only(
                      top: 4,
                    ),
                    child: Text(
                      transaction
                              .note ??
                          '',
                      maxLines: 2,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style: TextStyle(
                        color: AppTheme
                            .textMuted,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Text(
            '${income ? '+' : expense ? '-' : ''}৳ ${transaction.amount.toStringAsFixed(2)}',
            textAlign:
                TextAlign.end,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STATS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildStatsView() {
    final income =
        _totalIncome;

    final expense =
        _totalExpense;

    final type =
        _statsTab == 0
            ? 'Income'
            : 'Expense';

    final categories =
        _categoryTotals(type);

    final total =
        categories.values
            .fold<double>(
      0,
      (sum, value) =>
          sum + value,
    );

    return RefreshIndicator(
      onRefresh:
          _loadTransactions,
      color: AppTheme.gold,
      child: ListView(
        padding:
            const EdgeInsets.fromLTRB(
          14,
          12,
          14,
          30,
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: _statCard(
                  'মোট আয়',
                  income,
                  Colors.blue,
                  Icons
                      .trending_up_rounded,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: _statCard(
                  'মোট খরচ',
                  expense,
                  Colors.redAccent,
                  Icons
                      .trending_down_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          _statCard(
            _balance >= 0
                ? 'উদ্বৃত্ত'
                : 'ঘাটতি',
            _balance.abs(),
            _balance >= 0
                ? Colors.green
                : Colors.redAccent,
            _balance >= 0
                ? Icons
                    .account_balance_rounded
                : Icons
                    .warning_amber_rounded,
          ),

          const SizedBox(
            height: 18,
          ),

          Container(
            padding:
                const EdgeInsets.all(5),
            decoration:
                BoxDecoration(
              color:
                  AppTheme.cardColor,
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child:
                      _statsTabButton(
                    'আয়',
                    0,
                  ),
                ),
                Expanded(
                  child:
                      _statsTabButton(
                    'খরচ',
                    1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          if (categories.isEmpty)
            _emptyState(
              Icons
                  .bar_chart_rounded,
              'কোনো তথ্য নেই',
            )
          else ...[
            _buildPieChart(
              categories,
              total,
            ),

            const SizedBox(
              height: 16,
            ),

            _buildCategoryStats(
              categories,
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PIE CHART
  // ═══════════════════════════════════════════════════════════════

  Widget _buildPieChart(
    Map<String, double> data,
    double total,
  ) {
    final entries =
        data.entries.toList()
          ..sort(
            (a, b) =>
                b.value.compareTo(
              a.value,
            ),
          );

    final chartEntries =
        entries.take(8).toList();

    final otherTotal =
        entries
            .skip(8)
            .fold<double>(
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
      decoration:
          BoxDecoration(
        color:
            AppTheme.cardColor,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              AppTheme.gold.withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons
                    .pie_chart_rounded,
                color:
                    AppTheme.gold,
                size: 20,
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                _statsTab == 0
                    ? 'আয়ের বিশ্লেষণ'
                    : 'খরচের বিশ্লেষণ',
                style: TextStyle(
                  color: AppTheme
                      .textPrimary,
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          SizedBox(
            height: 230,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 58,
                sections:
                    List.generate(
                  chartEntries.length,
                  (index) {
                    final entry =
                        chartEntries[
                            index];

                    final percentage =
                        total == 0
                            ? 0.0
                            : entry.value /
                                total *
                                100;

                    return PieChartSectionData(
                      value:
                          entry.value,
                      color: colors[
                          index %
                              colors.length],
                      radius: 72,
                      title:
                          percentage >=
                                  4
                              ? '${percentage.toStringAsFixed(0)}%'
                              : '',
                      titleStyle:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize: 11,
                        fontWeight:
                            FontWeight
                                .w900,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            'মোট ৳ ${total.toStringAsFixed(2)}',
            style: TextStyle(
              color:
                  AppTheme.gold,
              fontSize: 15,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          Wrap(
            spacing: 12,
            runSpacing: 8,
            children:
                List.generate(
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
                            BoxShape
                                .circle,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      entry.key,
                      style:
                          TextStyle(
                        color: AppTheme
                            .textMuted,
                        fontSize: 10.5,
                        fontWeight:
                            FontWeight
                                .w600,
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

  // ═══════════════════════════════════════════════════════════════
  // STATS TAB BUTTON
  // ═══════════════════════════════════════════════════════════════

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
        decoration:
            BoxDecoration(
          color: selected
              ? AppTheme.gold
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(
            10,
          ),
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

  // ═══════════════════════════════════════════════════════════════
  // CATEGORY DETAILS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildCategoryStats(
    Map<String, double> data,
  ) {
    final entries =
        data.entries.toList()
          ..sort(
            (a, b) =>
                b.value.compareTo(
              a.value,
            ),
          );

    final total =
        data.values.fold<double>(
      0,
      (sum, value) =>
          sum + value,
    );

    return Column(
      children:
          entries.map((entry) {
        final percentage =
            total == 0
                ? 0.0
                : entry.value /
                    total;

        return Container(
          margin:
              const EdgeInsets.only(
            bottom: 9,
          ),
          padding:
              const EdgeInsets.all(13),
          decoration:
              BoxDecoration(
            color:
                AppTheme.cardColor,
            borderRadius:
                BorderRadius.circular(
              15,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        color: AppTheme
                            .textPrimary,
                        fontSize: 13,
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),
                  ),
                  Text(
                    '৳ ${entry.value.toStringAsFixed(2)}',
                    style: TextStyle(
                      color:
                          AppTheme.gold,
                      fontWeight:
                          FontWeight
                              .w800,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 8,
              ),

              ClipRRect(
                borderRadius:
                    BorderRadius
                        .circular(8),
                child:
                    LinearProgressIndicator(
                  value:
                      percentage,
                  minHeight: 6,
                  backgroundColor:
                      AppTheme
                          .gold
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

  // ═══════════════════════════════════════════════════════════════
  // STAT CARD
  // ═══════════════════════════════════════════════════════════════

  Widget _statCard(
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(15),
      decoration:
          BoxDecoration(
        color:
            AppTheme.cardColor,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration:
                BoxDecoration(
              color: color.withValues(
                alpha: 0.12,
              ),
              shape:
                  BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 21,
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
                  title,
                  style: TextStyle(
                    color: AppTheme
                        .textMuted,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                FittedBox(
                  child: Text(
                    '৳ ${amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight:
                          FontWeight
                              .w900,
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

  // ═══════════════════════════════════════════════════════════════
  // ACCOUNTS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildAccountsView() {
    return RefreshIndicator(
      onRefresh:
          _loadTransactions,
      color: AppTheme.gold,
      child: ListView(
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

          const SizedBox(
            height: 12,
          ),

          ..._accounts.map(
            (account) {
              final balance =
                  _accountBalance(
                account,
              );

              return Container(
                margin:
                    const EdgeInsets
                        .only(
                  bottom: 10,
                ),
                padding:
                    const EdgeInsets
                        .all(16),
                decoration:
                    BoxDecoration(
                  color:
                      AppTheme.cardColor,
                  borderRadius:
                      BorderRadius
                          .circular(18),
                  border: Border.all(
                    color: AppTheme
                        .gold
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
                        color: AppTheme
                            .gold
                            .withValues(
                          alpha: 0.12,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          13,
                        ),
                      ),
                      child: Icon(
                        Icons
                            .account_balance_wallet_rounded,
                        color:
                            AppTheme
                                .gold,
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child: Text(
                        account,
                        style:
                            TextStyle(
                          color: AppTheme
                              .textPrimary,
                          fontSize: 14,
                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),
                    ),

                    Text(
                      '৳ ${balance.toStringAsFixed(2)}',
                      style:
                          TextStyle(
                        color: balance >=
                                0
                            ? Colors.green
                            : Colors
                                .redAccent,
                        fontSize: 15,
                        fontWeight:
                            FontWeight
                                .w900,
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

  // ═══════════════════════════════════════════════════════════════
  // EMPTY STATE
  // ═══════════════════════════════════════════════════════════════

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
            const SizedBox(
              height: 12,
            ),
            Text(
              text,
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: AppTheme
                    .textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TRANSACTION SHEET
// ═══════════════════════════════════════════════════════════════

class _TransactionSheet
    extends StatefulWidget {
  final List<String>
      incomeCategories;

  final List<String>
      expenseCategories;

  final List<String> accounts;

  final Future<void> Function()
      onSaved;

  const _TransactionSheet({
    required this.incomeCategories,
    required this.expenseCategories,
    required this.accounts,
    required this.onSaved,
  });

  @override
  State<_TransactionSheet>
      createState() =>
          _TransactionSheetState();
}

class _TransactionSheetState
    extends State<_TransactionSheet> {
  String _type = 'Expense';

  late List<String>
      _incomeCategories;

  late List<String>
      _expenseCategories;

  String? _selectedCategory;

  String? _selectedAccount;

  String? _targetAccount;

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
        widget.accounts.first;

    _targetAccount =
        widget.accounts.length > 1
            ? widget.accounts[1]
            : widget.accounts.first;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  List<String>
      get _currentCategories {
    return _type == 'Income'
        ? _incomeCategories
        : _expenseCategories;
  }

  // ═══════════════════════════════════════════════════════════════
  // ADD NEW CATEGORY
  // ═══════════════════════════════════════════════════════════════

  Future<void> _addCategory() async {
    final controller =
        TextEditingController();

    final value =
        await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              AppTheme.cardColor,
          title: Text(
            _type == 'Income'
                ? 'নতুন আয় খাত যোগ করুন'
                : 'নতুন খরচের খাত যোগ করুন',
            style: TextStyle(
              color:
                  AppTheme.textPrimary,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          content: TextField(
            controller:
                controller,
            autofocus: true,
            style: TextStyle(
              color:
                  AppTheme.textPrimary,
            ),
            decoration:
                const InputDecoration(
              hintText:
                  'খাতের নাম লিখুন',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
              ),
              child:
                  const Text('বাতিল'),
            ),
            ElevatedButton(
              onPressed: () {
                final text =
                    controller.text
                        .trim();

                if (text.isEmpty) {
                  return;
                }

                Navigator.pop(
                  context,
                  text,
                );
              },
              child:
                  const Text('যোগ করুন'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (value == null ||
        value.trim().isEmpty) {
      return;
    }

    final category =
        value.trim();

    final current =
        _type == 'Income'
            ? _incomeCategories
            : _expenseCategories;

    final alreadyExists =
        current.any(
      (item) =>
          item.trim().toLowerCase() ==
          category
              .toLowerCase(),
    );

    if (alreadyExists) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'এই খাতটি আগে থেকেই আছে',
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      if (_type == 'Income') {
        _incomeCategories
            .add(category);
      } else {
        _expenseCategories
            .add(category);
      }

      _selectedCategory =
          category;
    });

    // Save permanently
    final prefs =
        await SharedPreferences
            .getInstance();

    if (_type == 'Income') {
      await prefs.setStringList(
        'money_manager_custom_income_categories',
        _incomeCategories,
      );
    } else {
      await prefs.setStringList(
        'money_manager_custom_expense_categories',
        _expenseCategories,
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          '“$category” খাত যোগ হয়েছে',
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SAVE TRANSACTION
  // ═══════════════════════════════════════════════════════════════

  Future<void> _save() async {
    final amount =
        double.tryParse(
      _amountController.text
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

    if (_selectedAccount ==
        null) {
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
        _targetAccount ==
            _selectedAccount) {
      _showMessage(
        'একই অ্যাকাউন্টে ট্রান্সফার করা যাবে না',
      );
      return;
    }

    final transaction =
        MoneyTransaction(
      type: _type,
      amount: amount,
      date: DateFormat(
        'dd/MM/yyyy',
      ).format(
        DateTime.now(),
      ),
      category:
          _type == 'Transfer'
              ? 'Transfer'
              : _selectedCategory!,
      account:
          _type == 'Transfer'
              ? '$_selectedAccount ➔ $_targetAccount'
              : _selectedAccount!,
      note:
          _noteController.text
              .trim(),
    );

    await MoneyDbHelper.instance
        .insertTransaction(
      transaction,
    );

    await widget.onSaved();

    if (!mounted) return;

    Navigator.pop(context);

    _showSavedMessage();
  }

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content:
            Text(message),
      ),
    );
  }

  void _showSavedMessage() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      const SnackBar(
        content: Text(
          'লেনদেন সফলভাবে সংরক্ষণ হয়েছে',
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BUILD SHEET
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding:
            EdgeInsets.only(
          left: 16,
          right: 16,
          top: 10,
          bottom:
              MediaQuery.of(context)
                  .viewInsets
                  .bottom +
              16,
        ),
        decoration:
            BoxDecoration(
          color:
              AppTheme.background,
          borderRadius:
              const BorderRadius
                  .vertical(
            top:
                Radius.circular(26),
          ),
        ),
        child:
            SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration:
                      BoxDecoration(
                    color: AppTheme
                        .textMuted,
                    borderRadius:
                        BorderRadius
                            .circular(
                      10,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              Text(
                'নতুন লেনদেন',
                style: TextStyle(
                  color: AppTheme
                      .textPrimary,
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              Row(
                children: [
                  Expanded(
                    child:
                        _typeButton(
                      'Income',
                      'আয়',
                      Icons
                          .arrow_downward_rounded,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child:
                        _typeButton(
                      'Expense',
                      'খরচ',
                      Icons
                          .arrow_upward_rounded,
                      Colors.redAccent,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child:
                        _typeButton(
                      'Transfer',
                      'ট্রান্সফার',
                      Icons
                          .swap_horiz_rounded,
                      AppTheme.gold,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 16,
              ),

              _label('পরিমাণ'),

              const SizedBox(
                height: 6,
              ),

              TextField(
                controller:
                    _amountController,
                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),
                style: TextStyle(
                  color: AppTheme
                      .textPrimary,
                ),
                decoration:
                    const InputDecoration(
                  hintText:
                      'যেমন: 5000',
                  prefixText: '৳ ',
                ),
              ),

              const SizedBox(
                height: 13,
              ),

              _label(
                _type == 'Transfer'
                    ? 'যে অ্যাকাউন্ট থেকে'
                    : 'অ্যাকাউন্ট',
              ),

              const SizedBox(
                height: 6,
              ),

              DropdownButtonFormField<
                  String>(
                value:
                    _selectedAccount,
                isExpanded: true,
                decoration:
                    const InputDecoration(),
                items: widget.accounts
                    .map(
                      (account) =>
                          DropdownMenuItem<
                              String>(
                        value: account,
                        child:
                            Text(
                          account,
                        ),
                      ),
                    )
                    .toList(),
                onChanged:
                    (value) {
                  setState(() {
                    _selectedAccount =
                        value;
                  });
                },
              ),

              if (_type ==
                  'Transfer') ...[
                const SizedBox(
                  height: 13,
                ),

                _label(
                  'যে অ্যাকাউন্টে',
                ),

                const SizedBox(
                  height: 6,
                ),

                DropdownButtonFormField<
                    String>(
                  value:
                      _targetAccount,
                  isExpanded:
                      true,
                  decoration:
                      const InputDecoration(),
                  items: widget
                      .accounts
                      .map(
                        (account) =>
                            DropdownMenuItem<
                                String>(
                          value:
                              account,
                          child:
                              Text(
                            account,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged:
                      (value) {
                    setState(() {
                      _targetAccount =
                          value;
                    });
                  },
                ),
              ],

              if (_type !=
                  'Transfer') ...[
                const SizedBox(
                  height: 13,
                ),

                Row(
                  children: [
                    Expanded(
                      child:
                          _label(
                        'খাত',
                      ),
                    ),
                    TextButton.icon(
                      onPressed:
                          _addCategory,
                      icon:
                          const Icon(
                        Icons
                            .add_rounded,
                        size: 17,
                      ),
                      label:
                          const Text(
                        'নতুন খাত',
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 2,
                ),

                DropdownButtonFormField<
                    String>(
                  value:
                      _selectedCategory,
                  isExpanded:
                      true,
                  decoration:
                      const InputDecoration(),
                  items:
                      _currentCategories
                          .map(
                            (
                              category,
                            ) =>
                                DropdownMenuItem<
                                    String>(
                              value:
                                  category,
                              child:
                                  Text(
                                category,
                              ),
                            ),
                          )
                          .toList(),
                  onChanged:
                      (value) {
                    setState(() {
                      _selectedCategory =
                          value;
                    });
                  },
                ),
              ],

              const SizedBox(
                height: 13,
              ),

              _label('নোট'),

              const SizedBox(
                height: 6,
              ),

              TextField(
                controller:
                    _noteController,
                maxLines: 3,
                style: TextStyle(
                  color: AppTheme
                      .textPrimary,
                ),
                decoration:
                    const InputDecoration(
                  hintText:
                      'প্রয়োজনে নোট লিখুন',
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              SizedBox(
                width:
                    double.infinity,
                height: 52,
                child:
                    ElevatedButton
                        .icon(
                  onPressed:
                      _save,
                  icon:
                      const Icon(
                    Icons
                        .save_rounded,
                  ),
                  label:
                      const Text(
                    'সংরক্ষণ করুন',
                    style:
                        TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight
                              .w800,
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

  Widget _label(
    String text,
  ) {
    return Text(
      text,
      style: TextStyle(
        color:
            AppTheme.textPrimary,
        fontSize: 12.5,
        fontWeight:
            FontWeight.w700,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TYPE BUTTON
  // ═══════════════════════════════════════════════════════════════

  Widget _typeButton(
    String type,
    String title,
    IconData icon,
    Color color,
  ) {
    final selected =
        _type == type;

    return GestureDetector(
      onTap: () {
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
            _selectedCategory =
                null;
          }
        });
      },
      child: Container(
        padding:
            const EdgeInsets
                .symmetric(
          vertical: 11,
          horizontal: 5,
        ),
        decoration:
            BoxDecoration(
          color: selected
              ? color.withValues(
                  alpha: 0.16,
                )
              : AppTheme.cardColor,
          borderRadius:
              BorderRadius.circular(
            13,
          ),
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
                  : AppTheme
                      .textMuted,
              size: 20,
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              title,
              style: TextStyle(
                color: selected
                    ? color
                    : AppTheme
                        .textMuted,
                fontSize: 11,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
