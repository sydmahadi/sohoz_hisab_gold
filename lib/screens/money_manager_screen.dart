import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../logic/money_db_helper.dart';

class MoneyManagerScreen extends StatefulWidget {
  const MoneyManagerScreen({super.key});

  @override
  State<MoneyManagerScreen> createState() => _MoneyManagerScreenState();
}

class _MoneyManagerScreenState extends State<MoneyManagerScreen> {
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
    final data = await MoneyDbHelper.instance.getAllTransactions();

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

  double _calculateAccountBalance(String accountName) {
    double balance = 0.0;

    for (final item in _transactions) {
      if (item.type == 'Income' && item.account == accountName) {
        balance += item.amount;
      } else if (item.type == 'Expense' && item.account == accountName) {
        balance -= item.amount;
      } else if (item.type == 'Transfer') {
        if (item.account.startsWith('$accountName ➔')) {
          balance -= item.amount;
        } else if (item.account.endsWith('➔ $accountName')) {
          balance += item.amount;
        }
      }
    }

    return balance;
  }

  List<MoneyTransaction> _getFilteredTransactions() {
    return _transactions.where((item) {
      final itemDate = _parseDate(item.date);

      if (itemDate == null) {
        return false;
      }

      if (_filterType == 'Monthly') {
        return itemDate.year == _selectedDate.year &&
            itemDate.month == _selectedDate.month;
      }

      if (_filterType == 'Yearly') {
        return itemDate.year == _selectedDate.year;
      }

      if (_filterType == 'Daily') {
        return itemDate.year == _selectedDate.year &&
            itemDate.month == _selectedDate.month &&
            itemDate.day == _selectedDate.day;
      }

      if (_filterType == 'Weekly') {
        final startOfWeek = _selectedDate.subtract(
          Duration(days: _selectedDate.weekday - 1),
        );

        final endOfWeek = startOfWeek.add(
          const Duration(days: 6),
        );

        return itemDate.isAfter(
              startOfWeek.subtract(const Duration(days: 1)),
            ) &&
            itemDate.isBefore(
              endOfWeek.add(const Duration(days: 1)),
            );
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final pages = [
      _buildTransView(theme, isDark),
      _buildStatsView(theme, isDark),
      _buildAccountsView(theme, isDark),
      _buildMoreView(theme, isDark),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'সহজ হিসাব',
          style: TextStyle(
            color: isDark
                ? AppTheme.gold
                : theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Google Drive',
            icon: Icon(
              Icons.cloud_upload_rounded,
              color: isDark ? AppTheme.gold : AppTheme.darkGreen,
            ),
            onPressed: () async {
              final success = await MoneyDbHelper.signInWithGoogle();

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'গুগল ড্রাইভ কানেক্ট সম্পন্ন হয়েছে!'
                        : 'সাইন-ইন করতে সমস্যা হয়েছে',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: pages[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              backgroundColor:
                  isDark ? AppTheme.gold : AppTheme.darkGreen,
              onPressed: () {
                _showAddTransactionModal(
                  context,
                  theme,
                  isDark,
                );
              },
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 30,
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
        selectedItemColor:
            isDark ? AppTheme.gold : AppTheme.darkGreen,
        unselectedItemColor:
            isDark ? Colors.grey : Colors.black45,
        backgroundColor:
            theme.cardTheme.color ?? AppTheme.cardColor,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: 'Trans.',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Accounts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz_rounded),
            label: 'More',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TRANSACTIONS
  // ============================================================

  Widget _buildTransView(
    ThemeData theme,
    bool isDark,
  ) {
    final totalIncome = _transactions
        .where((e) => e.type == 'Income')
        .fold<double>(
          0,
          (sum, item) => sum + item.amount,
        );

    final totalExpense = _transactions
        .where((e) => e.type == 'Expense')
        .fold<double>(
          0,
          (sum, item) => sum + item.amount,
        );

    final balance = totalIncome - totalExpense;

    final Map<String, List<MoneyTransaction>> groupedTrans = {};

    for (final trans in _transactions) {
      groupedTrans.putIfAbsent(
        trans.date,
        () => [],
      ).add(trans);
    }

    final dates = groupedTrans.keys.toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          color: isDark
              ? AppTheme.cardLightDark
              : Colors.white,
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround,
            children: [
              _summaryItem(
                'Income',
                totalIncome,
                Colors.blue,
                theme,
              ),
              _summaryItem(
                'Expenses',
                totalExpense,
                Colors.redAccent,
                theme,
              ),
              _summaryItem(
                'Total',
                balance,
                theme.textTheme.bodyLarge?.color ??
                    Colors.black,
                theme,
              ),
            ],
          ),
        ),
        Expanded(
          child: _transactions.isEmpty
              ? Center(
                  child: Text(
                    'কোনো লেনদেন পাওয়া যায়নি',
                    style: TextStyle(
                      color:
                          theme.textTheme.bodySmall?.color ??
                              Colors.grey,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: dates.length,
                  itemBuilder: (context, index) {
                    final dateStr = dates[index];
                    final dayTrans =
                        groupedTrans[dateStr]!;

                    final dayIncome = dayTrans
                        .where((e) => e.type == 'Income')
                        .fold<double>(
                          0,
                          (sum, item) => sum + item.amount,
                        );

                    final dayExpense = dayTrans
                        .where((e) => e.type == 'Expense')
                        .fold<double>(
                          0,
                          (sum, item) => sum + item.amount,
                        );

                    return Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          color: isDark
                              ? AppTheme.cardLightDark
                                  .withValues(alpha: 0.5)
                              : const Color(0xFFEFEFEF),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                dateStr,
                                style: TextStyle(
                                  color: theme.textTheme
                                      .titleMedium
                                      ?.color,
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Row(
                                children: [
                                  if (dayIncome > 0)
                                    Text(
                                      '৳ ${dayIncome.toStringAsFixed(2)}  ',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 13,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  if (dayExpense > 0)
                                    Text(
                                      '৳ ${dayExpense.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color:
                                            Colors.redAccent,
                                        fontSize: 13,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ...dayTrans.map(
                          (item) {
                            final isIncome =
                                item.type == 'Income';
                            final isTransfer =
                                item.type == 'Transfer';

                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color:
                                        theme.dividerColor,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  item.category,
                                  style: TextStyle(
                                    color: theme.textTheme
                                        .bodyLarge
                                        ?.color,
                                    fontWeight:
                                        FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                subtitle: Text(
                                  (item.note ?? '').isNotEmpty
                                      ? '${item.account} • ${item.note}'
                                      : item.account,
                                  style: TextStyle(
                                    color: theme.textTheme
                                        .bodySmall
                                        ?.color,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: Text(
                                  '৳ ${item.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: isIncome
                                        ? Colors.blue
                                        : isTransfer
                                            ? Colors.orange
                                            : Colors.redAccent,
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _summaryItem(
    String label,
    double amount,
    Color color,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color:
                theme.textTheme.bodySmall?.color ??
                    Colors.grey,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '৳ ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _buildStatsView(
    ThemeData theme,
    bool isDark,
  ) {
    final filteredTrans =
        _getFilteredTransactions();

    final totalIncome = filteredTrans
        .where((e) => e.type == 'Income')
        .fold<double>(
          0,
          (sum, item) => sum + item.amount,
        );

    final totalExpense = filteredTrans
        .where((e) => e.type == 'Expense')
        .fold<double>(
          0,
          (sum, item) => sum + item.amount,
        );

    final currentList = filteredTrans
        .where(
          (e) => e.type ==
              (_statsTab == 0
                  ? 'Income'
                  : 'Expense'),
        )
        .toList();

    final currentTotal = currentList.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );

    final Map<String, double> categoryMap = {};

    for (final e in currentList) {
      categoryMap[e.category] =
          (categoryMap[e.category] ?? 0) + e.amount;
    }

    final sortedEntries =
        categoryMap.entries.toList()
          ..sort(
            (a, b) => b.value.compareTo(a.value),
          );

    final List<Color> pieColors = [
      const Color(0xFFFF6B6B),
      const Color(0xFFFF9F43),
      const Color(0xFFFFD93D),
      const Color(0xFF6BCB77),
      const Color(0xFF4D96FF),
      const Color(0xFF9B59B6),
      const Color(0xFF1ABC9C),
      const Color(0xFFE67E22),
    ];

    final textColor =
        theme.textTheme.bodyLarge?.color;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      color: textColor,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_filterType == 'Yearly') {
                          _selectedDate = DateTime(
                            _selectedDate.year - 1,
                          );
                        } else {
                          _selectedDate = DateTime(
                            _selectedDate.year,
                            _selectedDate.month - 1,
                            _selectedDate.day,
                          );
                        }
                      });
                    },
                  ),
                  Text(
                    _filterType == 'Yearly'
                        ? DateFormat('yyyy')
                            .format(_selectedDate)
                        : DateFormat('MMM yyyy')
                            .format(_selectedDate),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      color: textColor,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_filterType == 'Yearly') {
                          _selectedDate = DateTime(
                            _selectedDate.year + 1,
                          );
                        } else {
                          _selectedDate = DateTime(
                            _selectedDate.year,
                            _selectedDate.month + 1,
                            _selectedDate.day,
                          );
                        }
                      });
                    },
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.cardLightDark
                      : Colors.white,
                  borderRadius:
                      BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.dividerColor,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _filterType,
                    dropdownColor: isDark
                        ? AppTheme.cardColorDark
                        : Colors.white,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: textColor,
                    ),
                    items: const [
                      'Daily',
                      'Weekly',
                      'Monthly',
                      'Yearly',
                    ].map(
                      (value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      },
                    ).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _filterType = value;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _statsTab = 0;
                  });
                },
                child: Column(
                  children: [
                    Text(
                      'Income  ৳ ${totalIncome.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: _statsTab == 0
                            ? Colors.blue
                            : theme.textTheme.bodySmall
                                ?.color,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 3,
                      color: _statsTab == 0
                          ? Colors.blue
                          : Colors.transparent,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _statsTab = 1;
                  });
                },
                child: Column(
                  children: [
                    Text(
                      'Expenses  ৳ ${totalExpense.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: _statsTab == 1
                            ? Colors.redAccent
                            : theme.textTheme.bodySmall
                                ?.color,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 3,
                      color: _statsTab == 1
                          ? Colors.redAccent
                          : Colors.transparent,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Divider(
          color: theme.dividerColor,
          height: 1,
        ),
        Expanded(
          child: sortedEntries.isEmpty
              ? Center(
                  child: Text(
                    'এই সময়সীমার কোনো তথ্য পাওয়া যায়নি',
                    style: TextStyle(
                      color: theme.textTheme
                          .bodySmall
                          ?.color,
                    ),
                  ),
                )
              : Column(
                  children: [
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 0,
                          sections:
                              sortedEntries.asMap().entries.map(
                            (entry) {
                              final idx = entry.key;
                              final item = entry.value;

                              final percentage =
                                  currentTotal == 0
                                      ? 0
                                      : (item.value /
                                              currentTotal) *
                                          100;

                              final color =
                                  pieColors[
                                      idx %
                                          pieColors.length];

                              return PieChartSectionData(
                                color: color,
                                value: item.value,
                                title:
                                    '${item.key}\n${percentage.toStringAsFixed(1)}%',
                                radius: 95,
                                titleStyle:
                                    const TextStyle(
                                  color: Colors.white,
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize: 11,
                                ),
                              );
                            },
                          ).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: Container(
                        color: theme.cardColor,
                        child: ListView.separated(
                          itemCount:
                              sortedEntries.length,
                          separatorBuilder:
                              (context, index) {
                            return Divider(
                              color:
                                  theme.dividerColor,
                              height: 1,
                            );
                          },
                          itemBuilder:
                              (context, index) {
                            final item =
                                sortedEntries[index];

                            final percentage =
                                currentTotal == 0
                                    ? 0
                                    : (item.value /
                                            currentTotal) *
                                        100;

                            final color =
                                pieColors[
                                    index %
                                        pieColors.length];

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 45,
                                    height: 26,
                                    alignment:
                                        Alignment.center,
                                    decoration:
                                        BoxDecoration(
                                      color: color,
                                      borderRadius:
                                          BorderRadius
                                              .circular(6),
                                    ),
                                    child: Text(
                                      '${percentage.toStringAsFixed(0)}%',
                                      style:
                                          const TextStyle(
                                        color: Colors.white,
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      item.key,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 15,
                                        fontWeight:
                                            FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '৳ ${item.value.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 15,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  // ============================================================
  // ACCOUNTS
  // ============================================================

  Widget _buildAccountsView(
    ThemeData theme,
    bool isDark,
  ) {
    return ListView.builder(
      itemCount: _accounts.length,
      itemBuilder: (context, index) {
        final acc = _accounts[index];
        final currentBalance =
            _calculateAccountBalance(acc);

        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: theme.dividerColor,
              width: 0.5,
            ),
          ),
          child: ListTile(
            leading: Icon(
              Icons.account_balance_wallet,
              color: isDark
                  ? AppTheme.gold
                  : AppTheme.darkGreen,
            ),
            title: Text(
              acc,
              style: TextStyle(
                color:
                    theme.textTheme.titleMedium?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'ব্যালেন্স: ৳ ${currentBalance.toStringAsFixed(2)}',
              style: TextStyle(
                color: currentBalance >= 0
                    ? Colors.green
                    : Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.edit,
                color:
                    theme.textTheme.bodySmall?.color,
              ),
              onPressed: () {
                _showEditAccountDialog(
                  index,
                  theme,
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showEditAccountDialog(
    int index,
    ThemeData theme,
  ) {
    final controller = TextEditingController(
      text: _accounts[index],
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text(
            'অ্যাকাউন্টের নাম পরিবর্তন',
            style: TextStyle(
              color:
                  theme.textTheme.titleLarge?.color,
            ),
          ),
          content: TextField(
            controller: controller,
            style: TextStyle(
              color:
                  theme.textTheme.bodyLarge?.color,
            ),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newName =
                    controller.text.trim();

                if (newName.isNotEmpty) {
                  setState(() {
                    _accounts[index] = newName;
                  });
                }

                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // MORE
  // ============================================================

  Widget _buildMoreView(
    ThemeData theme,
    bool isDark,
  ) {
    return Center(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark
              ? AppTheme.gold
              : AppTheme.darkGreen,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
        ),
        icon: const Icon(
          Icons.backup,
          color: Colors.white,
        ),
        label: const Text(
          'Google Drive-এ ব্যাকআপ নিন',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () async {
          final ok =
              await MoneyDbHelper.autoBackupToDrive();

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                ok
                    ? 'গুগল ড্রাইভে ব্যাকআপ সফল হয়েছে!'
                    : 'ব্যাকআপ নেওয়া সম্ভব হয়নি',
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // ADD TRANSACTION
  // ============================================================

  void _showAddTransactionModal(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    String type = 'Expense';
    String selectedCategory =
        _expenseCategories.first;
    String selectedAccount = _accounts.first;

    String targetAccount = _accounts.length > 1
        ? _accounts[1]
        : _accounts.first;

    double amount = 0;
    String note = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardColor,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final List<String> currentCategories =
                type == 'Expense'
                    ? _expenseCategories
                    : type == 'Income'
                        ? _incomeCategories
                        : _accounts;

            final textColor =
                theme.textTheme.bodyLarge?.color;

            return Padding(
              padding: EdgeInsets.only(
                bottom:
                    MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        'Income',
                        'Expense',
                        'Transfer',
                      ].map((t) {
                        final isSelected = type == t;

                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          child: ChoiceChip(
                            label: Text(t),
                            selected: isSelected,
                            selectedColor:
                                isDark
                                    ? AppTheme.gold
                                    : AppTheme.darkGreen,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : textColor,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                            onSelected: (value) {
                              if (!value) return;

                              setModalState(() {
                                type = t;

                                if (type == 'Expense') {
                                  selectedCategory =
                                      _expenseCategories
                                          .first;
                                } else if (type ==
                                    'Income') {
                                  selectedCategory =
                                      _incomeCategories
                                          .first;
                                } else {
                                  selectedCategory =
                                      _accounts.first;
                                }
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: TextStyle(
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        labelText: 'পরিমাণ (Amount)',
                        labelStyle: TextStyle(
                          color: theme.textTheme
                              .bodySmall
                              ?.color,
                        ),
                        border:
                            const OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        amount =
                            double.tryParse(value) ?? 0;
                      },
                    ),

                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      initialValue: selectedAccount,
                      dropdownColor:
                          theme.cardColor,
                      style: TextStyle(
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        labelText: type == 'Transfer'
                            ? 'কোথা থেকে (From Account)'
                            : 'অ্যাকাউন্ট (Account)',
                        labelStyle: TextStyle(
                          color: theme.textTheme
                              .bodySmall
                              ?.color,
                        ),
                        border:
                            const OutlineInputBorder(),
                      ),
                      items: _accounts.map((acc) {
                        return DropdownMenuItem<String>(
                          value: acc,
                          child: Text(acc),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() {
                            selectedAccount = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 15),

                    if (type == 'Transfer') ...[
                      DropdownButtonFormField<String>(
                        initialValue: targetAccount,
                        dropdownColor:
                            theme.cardColor,
                        style: TextStyle(
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          labelText:
                              'কোথায় (To Account)',
                          labelStyle: TextStyle(
                            color: theme.textTheme
                                .bodySmall
                                ?.color,
                          ),
                          border:
                              const OutlineInputBorder(),
                        ),
                        items: _accounts.map((acc) {
                          return DropdownMenuItem<String>(
                            value: acc,
                            child: Text(acc),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() {
                              targetAccount = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 15),
                    ] else ...[
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ক্যাটাগরি নির্ধারণ করুন:',
                            style: TextStyle(
                              color: textColor,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            icon: Icon(
                              Icons.add,
                              size: 16,
                              color: isDark
                                  ? AppTheme.gold
                                  : AppTheme.darkGreen,
                            ),
                            label: Text(
                              'Add New',
                              style: TextStyle(
                                color: isDark
                                    ? AppTheme.gold
                                    : AppTheme.darkGreen,
                                fontSize: 12,
                              ),
                            ),
                            onPressed: () {
                              _showAddCategoryDialog(
                                type,
                                theme,
                                () {
                                  setModalState(() {});
                                },
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      GridView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2.3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount:
                            currentCategories.length,
                        itemBuilder: (c, i) {
                          final cat =
                              currentCategories[i];

                          final isSelected =
                              selectedCategory == cat;

                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                selectedCategory = cat;
                              });
                            },
                            child: Container(
                              alignment:
                                  Alignment.center,
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: isSelected
                                    ? (isDark
                                        ? AppTheme.gold
                                        : AppTheme.darkGreen)
                                    : (isDark
                                        ? AppTheme.cardLightDark
                                        : const Color(
                                            0xFFEFEFEF,
                                          )),
                                borderRadius:
                                    BorderRadius.circular(
                                  8,
                                ),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : textColor,
                                  fontSize: 11.5,
                                ),
                                textAlign:
                                    TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 15),
                    ],

                    TextField(
                      style: TextStyle(
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        labelText: 'নোট (ঐচ্ছিক)',
                        labelStyle: TextStyle(
                          color: theme.textTheme
                              .bodySmall
                              ?.color,
                        ),
                        border:
                            const OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        note = value;
                      },
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? AppTheme.gold
                            : AppTheme.darkGreen,
                        foregroundColor: Colors.white,
                        minimumSize:
                            const Size(double.infinity, 45),
                      ),
                      onPressed: () async {
                        if (amount <= 0) return;

                        final newTrans =
                            MoneyTransaction(
                          type: type,
                          amount: amount,
                          date: DateFormat(
                            'dd/MM/yyyy',
                          ).format(DateTime.now()),
                          category: type == 'Transfer'
                              ? 'Transfer'
                              : selectedCategory,
                          account: type == 'Transfer'
                              ? '$selectedAccount ➔ $targetAccount'
                              : selectedAccount,
                          note: note,
                        );

                        await MoneyDbHelper.instance
                            .insertTransaction(
                          newTrans,
                        );

                        if (!context.mounted) return;

                        Navigator.pop(ctx);
                        _loadData();
                      },
                      child: const Text(
                        'Save Transaction',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // ADD CATEGORY
  // ============================================================

  void _showAddCategoryDialog(
    String type,
    ThemeData theme,
    VoidCallback onAdded,
  ) {
    final newCatController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text(
            'নতুন ক্যাটাগরি যোগ করুন',
            style: TextStyle(
              color:
                  theme.textTheme.titleLarge?.color,
            ),
          ),
          content: TextField(
            controller: newCatController,
            style: TextStyle(
              color:
                  theme.textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              hintText: 'ক্যাটাগরির নাম',
              hintStyle: TextStyle(
                color: theme.textTheme.bodySmall?.color,
              ),
              border:
                  const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name =
                    newCatController.text.trim();

                if (name.isNotEmpty) {
                  setState(() {
                    if (type == 'Expense') {
                      _expenseCategories.add(name);
                    } else if (type == 'Income') {
                      _incomeCategories.add(name);
                    }
                  });

                  onAdded();
                }

                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
