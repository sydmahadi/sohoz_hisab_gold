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

class _MoneyManagerScreenState
    extends State<MoneyManagerScreen> {
  int _currentIndex = 0;
  int _statsTab = 1;

  DateTime _selectedDate = DateTime.now();
  String _filterType = 'Monthly';

  List<MoneyTransaction> _transactions = [];

  final List<String> _expenseCategories = [
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

  final List<String> _incomeCategories = [
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
    _loadData();
  }

  Future<void> _loadData() async {
    final data =
        await MoneyDbHelper.instance.getAllTransactions();

    if (!mounted) return;

    setState(() {
      _transactions = data;
    });
  }

  DateTime? _parseDate(String dateStr) {
    try {
      return DateFormat('dd/MM/yyyy').parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  List<MoneyTransaction> get _filteredTransactions {
    return _transactions.where((transaction) {
      final date = _parseDate(transaction.date);

      if (date == null) return false;

      if (_filterType == 'Daily') {
        return date.year == _selectedDate.year &&
            date.month == _selectedDate.month &&
            date.day == _selectedDate.day;
      }

      if (_filterType == 'Weekly') {
        final start = _selectedDate.subtract(
          Duration(days: _selectedDate.weekday - 1),
        );

        final end = start.add(
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

        return !d.isBefore(s) && !d.isAfter(e);
      }

      if (_filterType == 'Yearly') {
        return date.year == _selectedDate.year;
      }

      return date.year == _selectedDate.year &&
          date.month == _selectedDate.month;
    }).toList();
  }

  double get _totalIncome {
    return _filteredTransactions
        .where((e) => e.type == 'Income')
        .fold<double>(
          0,
          (sum, item) => sum + item.amount,
        );
  }

  double get _totalExpense {
    return _filteredTransactions
        .where((e) => e.type == 'Expense')
        .fold<double>(
          0,
          (sum, item) => sum + item.amount,
        );
  }

  double get _balance {
    return _totalIncome - _totalExpense;
  }

  double _accountBalance(String accountName) {
    double balance = 0;

    for (final transaction in _transactions) {
      if (transaction.type == 'Income') {
        if (transaction.account == accountName) {
          balance += transaction.amount;
        }
      } else if (transaction.type == 'Expense') {
        if (transaction.account == accountName) {
          balance -= transaction.amount;
        }
      } else if (transaction.type == 'Transfer') {
        final account = transaction.account;

        if (account.contains('➔')) {
          final parts = account.split('➔');

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
    }

    return balance;
  }

  Future<void> _openReport() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ReportScreen(),
      ),
    );

    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = AppTheme.isDark;

    final pages = [
      _buildTransView(theme, isDark),
      _buildStatsView(theme, isDark),
      _buildAccountsView(theme, isDark),
      _buildReportView(theme, isDark),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        title: Text(
          'মানি ম্যানেজার',
          style: TextStyle(
            color: isDark
                ? AppTheme.gold
                : AppTheme.darkGreen,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),

      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              backgroundColor: isDark
                  ? AppTheme.gold
                  : AppTheme.darkGreen,
              foregroundColor: isDark
                  ? Colors.black
                  : Colors.white,
              onPressed: _showAddTransaction,
              child: const Icon(
                Icons.add_rounded,
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
        selectedItemColor: isDark
            ? AppTheme.gold
            : AppTheme.darkGreen,
        unselectedItemColor: AppTheme.textMuted,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book_rounded),
            label: 'Trans.',
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

  Widget _buildTransView(
    ThemeData theme,
    bool isDark,
  ) {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: isDark
          ? AppTheme.gold
          : AppTheme.darkGreen,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          14,
          14,
          14,
          90,
        ),
        children: [
          _buildFilterCard(theme, isDark),
          const SizedBox(height: 14),
          _buildTotalCard(theme, isDark),
          const SizedBox(height: 14),

          if (_filteredTransactions.isEmpty)
            _buildEmptyState()
          else
            ..._filteredTransactions.reversed.map(
              (transaction) =>
                  _buildTransactionCard(
                transaction,
                theme,
                isDark,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterCard(
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.gold.withValues(
            alpha: isDark ? 0.30 : 0.20,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _filterType,
                  decoration: InputDecoration(
                    labelText: 'সময়',
                    prefixIcon: Icon(
                      Icons.filter_alt_outlined,
                      color: isDark
                          ? AppTheme.gold
                          : AppTheme.darkGreen,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Daily',
                      child: Text('দৈনিক'),
                    ),
                    DropdownMenuItem(
                      value: 'Weekly',
                      child: Text('সাপ্তাহিক'),
                    ),
                    DropdownMenuItem(
                      value: 'Monthly',
                      child: Text('মাসিক'),
                    ),
                    DropdownMenuItem(
                      value: 'Yearly',
                      child: Text('বার্ষিক'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _filterType = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: _pickDate,
                icon: Icon(
                  Icons.calendar_month_rounded,
                  color: isDark
                      ? AppTheme.gold
                      : AppTheme.darkGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _filterType == 'Daily'
                ? DateFormat(
                    'dd MMMM yyyy',
                  ).format(_selectedDate)
                : _filterType == 'Yearly'
                    ? DateFormat(
                        'yyyy',
                      ).format(_selectedDate)
                    : DateFormat(
                        'MMMM yyyy',
                      ).format(_selectedDate),
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      _selectedDate = picked;
    });
  }

  Widget _buildTotalCard(
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppTheme.cardLightDark,
                  AppTheme.cardColorDark,
                ]
              : [
                  Colors.white,
                  AppTheme.backgroundSecondaryLight,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.gold.withValues(
            alpha: isDark ? 0.35 : 0.25,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _miniAmount(
              'আয়',
              _totalIncome,
              Colors.blue,
              Icons.arrow_downward_rounded,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: theme.dividerColor,
          ),
          Expanded(
            child: _miniAmount(
              'খরচ',
              _totalExpense,
              Colors.redAccent,
              Icons.arrow_upward_rounded,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: theme.dividerColor,
          ),
          Expanded(
            child: _miniAmount(
              'ব্যালেন্স',
              _balance,
              _balance >= 0
                  ? Colors.green
                  : Colors.redAccent,
              Icons.account_balance_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniAmount(
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(
            color: AppTheme.textMuted,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 3),
        FittedBox(
          child: Text(
            '৳ ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 50,
            color: AppTheme.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            'এই সময়ের কোনো লেনদেন নেই',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(
    MoneyTransaction transaction,
    ThemeData theme,
    bool isDark,
  ) {
    final isIncome = transaction.type == 'Income';
    final isExpense = transaction.type == 'Expense';

    final Color color = isIncome
        ? Colors.blue
        : isExpense
            ? Colors.redAccent
            : AppTheme.gold;

    final IconData icon = isIncome
        ? Icons.arrow_downward_rounded
        : isExpense
            ? Icons.arrow_upward_rounded
            : Icons.swap_horiz_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.account,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
                if (transaction.note.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 3,
                    ),
                    child: Text(
                      transaction.note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.textMuted,
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
                '৳ ${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                transaction.date,
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 9.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _buildStatsView(
    ThemeData theme,
    bool isDark,
  ) {
    final income = _filteredTransactions
        .where((e) => e.type == 'Income')
        .toList();

    final expense = _filteredTransactions
        .where((e) => e.type == 'Expense')
        .toList();

    final selected =
        _statsTab == 0 ? income : expense;

    final color =
        _statsTab == 0 ? Colors.blue : Colors.redAccent;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        14,
        14,
        14,
        30,
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: _statsTabButton(
                'আয়',
                _statsTab == 0,
                Colors.blue,
                () {
                  setState(() {
                    _statsTab = 0;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statsTabButton(
                'খরচ',
                _statsTab == 1,
                Colors.redAccent,
                () {
                  setState(() {
                    _statsTab = 1;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildPieChartCard(
          selected,
          color,
        ),
        const SizedBox(height: 16),
        _buildCategoryStats(
          selected,
          color,
          theme,
        ),
      ],
    );
  }

  Widget _statsTabButton(
    String title,
    bool selected,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.12)
              : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.45)
                : AppTheme.gold.withValues(
                    alpha: 0.20,
                  ),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: selected
                  ? color
                  : AppTheme.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChartCard(
    List<MoneyTransaction> transactions,
    Color color,
  ) {
    final Map<String, double> categoryMap = {};

    for (final item in transactions) {
      categoryMap[item.category] =
          (categoryMap[item.category] ?? 0) +
              item.amount;
    }

    if (categoryMap.isEmpty) {
      return _buildEmptyState();
    }

    final entries = categoryMap.entries.toList()
      ..sort(
        (a, b) => b.value.compareTo(a.value),
      );

    final topEntries = entries.take(6).toList();

    return Container(
      height: 290,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.gold.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Column(
        children: [
          Text(
            'ক্যাটাগরি অনুযায়ী পরিসংখ্যান',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 42,
                sectionsSpace: 3,
                sections: List.generate(
                  topEntries.length,
                  (index) {
                    return PieChartSectionData(
                      value: topEntries[index].value,
                      title: '',
                      radius: 58,
                      color: _chartColor(
                        index,
                        color,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _chartColor(
    int index,
    Color base,
  ) {
    final colors = [
      base,
      Colors.green,
      AppTheme.gold,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    return colors[index % colors.length];
  }

  Widget _buildCategoryStats(
    List<MoneyTransaction> transactions,
    Color accent,
    ThemeData theme,
  ) {
    if (transactions.isEmpty) {
      return const SizedBox.shrink();
    }

    final Map<String, double> categoryMap = {};

    for (final item in transactions) {
      categoryMap[item.category] =
          (categoryMap[item.category] ?? 0) +
              item.amount;
    }

    final entries = categoryMap.entries.toList()
      ..sort(
        (a, b) => b.value.compareTo(a.value),
      );

    final total = entries.fold<double>(
      0,
      (sum, item) => sum + item.value,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.gold.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Column(
        children: entries.map((entry) {
          final percentage = total == 0
              ? 0.0
              : entry.value / total;

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '৳ ${entry.value.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: accent,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: percentage,
                  minHeight: 5,
                  borderRadius:
                      BorderRadius.circular(10),
                  backgroundColor:
                      accent.withValues(alpha: 0.08),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(
                    accent,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // ACCOUNTS
  // ============================================================

  Widget _buildAccountsView(
    ThemeData theme,
    bool isDark,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        14,
        14,
        14,
        30,
      ),
      children: [
        Text(
          'অ্যাকাউন্টসমূহ',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'প্রতিটি অ্যাকাউন্টের বর্তমান ব্যালেন্স',
          style: TextStyle(
            color: AppTheme.textMuted,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        ..._accounts.map(
          (account) => _buildAccountCard(
            account,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountCard(
    String account,
    bool isDark,
  ) {
    final balance =
        _accountBalance(account);

    final color = balance >= 0
        ? (isDark
            ? AppTheme.gold
            : AppTheme.darkGreen)
        : Colors.redAccent;

    IconData icon;

    switch (account) {
      case 'Cash':
        icon = Icons.payments_rounded;
        break;
      case 'Bkash':
        icon = Icons.phone_android_rounded;
        break;
      case 'Bank Account':
        icon = Icons.account_balance_rounded;
        break;
      case 'Nagad':
        icon =
            Icons.account_balance_wallet_rounded;
        break;
      case 'Card':
        icon = Icons.credit_card_rounded;
        break;
      default:
        icon = Icons.wallet_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              account,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            '৳ ${balance.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REPORT
  // ============================================================

  Widget _buildReportView(
    ThemeData theme,
    bool isDark,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: (isDark
                        ? AppTheme.gold
                        : AppTheme.darkGreen)
                    .withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assessment_rounded,
                size: 48,
                color: isDark
                    ? AppTheme.gold
                    : AppTheme.darkGreen,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'মাসিক রিপোর্ট',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'আয়, খরচ ও ক্যাটাগরি অনুযায়ী বিস্তারিত মাসিক রিপোর্ট দেখুন',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 12.5,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? AppTheme.gold
                      : AppTheme.darkGreen,
                  foregroundColor: isDark
                      ? Colors.black
                      : Colors.white,
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),
                icon: const Icon(
                  Icons.bar_chart_rounded,
                ),
                label: const Text(
                  'রিপোর্ট দেখুন',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
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
  // ADD TRANSACTION
  // ============================================================

  void _showAddTransaction() {
    String type = 'Expense';

    String selectedCategory =
        _expenseCategories.first;

    String selectedAccount =
        _accounts.first;

    String targetAccount =
        _accounts.length > 1
            ? _accounts[1]
            : _accounts.first;

    final amountController =
        TextEditingController();

    final noteController =
        TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (
            context,
            setModalState,
          ) {
            final categories = type == 'Income'
                ? _incomeCategories
                : _expenseCategories;

            if (!categories
                .contains(selectedCategory)) {
              selectedCategory =
                  categories.first;
            }

            return Container(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom: MediaQuery.of(
                      context,
                    ).viewInsets.bottom +
                    18,
              ),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius:
                    const BorderRadius.vertical(
                  top: Radius.circular(25),
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
                          color: AppTheme.textMuted
                              .withValues(alpha: 0.35),
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'নতুন লেনদেন',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // TYPE
                    Row(
                      children: [
                        Expanded(
                          child: _typeButton(
                            'আয়',
                            Icons
                                .arrow_downward_rounded,
                            Colors.blue,
                            type == 'Income',
                            () {
                              setModalState(() {
                                type = 'Income';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _typeButton(
                            'খরচ',
                            Icons
                                .arrow_upward_rounded,
                            Colors.redAccent,
                            type == 'Expense',
                            () {
                              setModalState(() {
                                type = 'Expense';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _typeButton(
                            'Transfer',
                            Icons.swap_horiz_rounded,
                            AppTheme.gold,
                            type == 'Transfer',
                            () {
                              setModalState(() {
                                type = 'Transfer';
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal: true,
                      ),
                      decoration:
                          const InputDecoration(
                        labelText: 'পরিমাণ',
                        prefixText: '৳ ',
                        prefixIcon: Icon(
                          Icons.payments_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      initialValue: selectedAccount,
                      decoration:
                          const InputDecoration(
                        labelText: 'অ্যাকাউন্ট',
                        prefixIcon: Icon(
                          Icons
                              .account_balance_wallet_outlined,
                        ),
                      ),
                      items: _accounts
                          .map(
                            (account) =>
                                DropdownMenuItem(
                              value: account,
                              child:
                                  Text(account),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setModalState(() {
                          selectedAccount =
                              value;
                        });
                      },
                    ),

                    if (type == 'Transfer') ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: targetAccount,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'যে অ্যাকাউন্টে যাবে',
                          prefixIcon: Icon(
                            Icons
                                .arrow_forward_rounded,
                          ),
                        ),
                        items: _accounts
                            .map(
                              (account) =>
                                  DropdownMenuItem(
                                value: account,
                                child:
                                    Text(account),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }

                          setModalState(() {
                            targetAccount =
                                value;
                          });
                        },
                      ),
                    ],

                    if (type != 'Transfer') ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue:
                            selectedCategory,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'ক্যাটাগরি',
                          prefixIcon: Icon(
                            Icons
                                .category_outlined,
                          ),
                        ),
                        items: [
                          ...categories.map(
                            (category) =>
                                DropdownMenuItem(
                              value: category,
                              child:
                                  Text(category),
                            ),
                          ),
                          const DropdownMenuItem(
                            value: '__add__',
                            child: Text(
                              '+ নতুন ক্যাটাগরি যোগ করুন',
                            ),
                          ),
                        ],
                        onChanged: (value) async {
                          if (value == null) {
                            return;
                          }

                          if (value == '__add__') {
                            final newCategory =
                                await _addCategory(
                              type,
                            );

                            if (newCategory !=
                                null) {
                              setModalState(() {
                                selectedCategory =
                                    newCategory;
                              });
                            }
                          } else {
                            setModalState(() {
                              selectedCategory =
                                  value;
                            });
                          }
                        },
                      ),
                    ],

                    const SizedBox(height: 12),

                    TextField(
                      controller: noteController,
                      maxLines: 2,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'নোট (ঐচ্ছিক)',
                        prefixIcon: Icon(
                          Icons.notes_rounded,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final amount =
                              double.tryParse(
                            amountController.text
                                .trim(),
                          );

                          if (amount == null ||
                              amount <= 0) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'সঠিক পরিমাণ লিখুন',
                                ),
                              ),
                            );
                            return;
                          }

                          if (type ==
                                  'Transfer' &&
                              selectedAccount ==
                                  targetAccount) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'একই অ্যাকাউন্টে Transfer করা যাবে না',
                                ),
                              ),
                            );
                            return;
                          }

                          final newTrans =
                              MoneyTransaction(
                            type: type,
                            amount: amount,
                            date: DateFormat(
                              'dd/MM/yyyy',
                            ).format(
                              DateTime.now(),
                            ),
                            category:
                                type == 'Transfer'
                                    ? 'Transfer'
                                    : selectedCategory,
                            account:
                                type == 'Transfer'
                                    ? '$selectedAccount ➔ $targetAccount'
                                    : selectedAccount,
                            note:
                                noteController.text
                                    .trim(),
                          );

                          await MoneyDbHelper
                              .instance
                              .insertTransaction(
                            newTrans,
                          );

                          if (!mounted) return;

                          Navigator.pop(
                            sheetContext,
                          );

                          await _loadData();

                          if (!mounted) return;

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'লেনদেন সফলভাবে সংরক্ষণ হয়েছে',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.save_rounded,
                        ),
                        label: const Text(
                          'সংরক্ষণ করুন',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              AppTheme.gold,
                          foregroundColor:
                              Colors.black,
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 15,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              15,
                            ),
                          ),
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
  }

  Widget _typeButton(
    String title,
    IconData icon,
    Color color,
    bool selected,
    VoidCallback onTap,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(13),
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.13)
              : AppTheme.cardColor,
          borderRadius:
              BorderRadius.circular(13),
          border: Border.all(
            color: selected
                ? color
                : AppTheme.textMuted.withValues(
                    alpha: 0.20,
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
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          backgroundColor:
              AppTheme.cardColor,
          title: Text(
            'নতুন ক্যাটাগরি',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration:
                const InputDecoration(
              hintText:
                  'ক্যাটাগরির নাম লিখুন',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('বাতিল'),
            ),
            ElevatedButton(
              onPressed: () {
                final value =
                    controller.text.trim();

                if (value.isEmpty) return;

                Navigator.pop(
                  context,
                  value,
                );
              },
              child: const Text('যোগ করুন'),
            ),
          ],
        );
      },
    );

    if (result == null || result.isEmpty) {
      return null;
    }

    setState(() {
      if (type == 'Income') {
        if (!_incomeCategories
            .contains(result)) {
          _incomeCategories.add(result);
        }
      } else {
        if (!_expenseCategories
            .contains(result)) {
          _expenseCategories.add(result);
        }
      }
    });

    return result;
  }
}
