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
  int _statsTab = 1; // 0 = Income, 1 = Expenses
  DateTime _selectedDate = DateTime.now();
  String _filterType = 'Monthly';

  List<MoneyTransaction> _transactions = [];

  // Expense ক্যাটাগরি তালিকা
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

  // Income ক্যাটাগরি তালিকা
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

  final List<String> _accounts = ['Cash', 'Bkash', 'Bank Account', 'Nagad', 'Card'];

  @override
  void initState() {
    super.initState();
    _loadData();
    // অটো ব্যাকগ্রাউন্ড গুগল সাইন ইন সরিয়ে দেওয়া হয়েছে যা স্পর্শ ব্লক করে রাখত
  }

  Future<void> _loadData() async {
    final data = await MoneyDbHelper.instance.getAllTransactions();
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
    for (var item in _transactions) {
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
      DateTime? itemDate = _parseDate(item.date);
      if (itemDate == null) return false;

      if (_filterType == 'Monthly') {
        return itemDate.year == _selectedDate.year &&
            itemDate.month == _selectedDate.month;
      } else if (_filterType == 'Yearly') {
        return itemDate.year == _selectedDate.year;
      } else if (_filterType == 'Daily') {
        return itemDate.year == _selectedDate.year &&
            itemDate.month == _selectedDate.month &&
            itemDate.day == _selectedDate.day;
      } else if (_filterType == 'Weekly') {
        final startOfWeek =
            _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return itemDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
            itemDate.isBefore(endOfWeek.add(const Duration(days: 1)));
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
            color: isDark ? AppTheme.gold : theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.cloud_upload_rounded,
              color: isDark ? AppTheme.gold : AppTheme.darkGreen,
            ),
            onPressed: () async {
              // টাচ সেশন ফ্রি করার জন্য ম্যানুয়াল সাইন ইন কল
              bool success = await MoneyDbHelper.signInWithGoogle();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? "গুগল ড্রাইভ কানেক্ট সম্পন্ন হয়েছে!"
                          : "সাইন-ইন করতে সমস্যা হয়েছে",
                    ),
                  ),
                );
              }
            },
          )
        ],
      ),
      body: pages[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              backgroundColor: isDark ? AppTheme.gold : AppTheme.darkGreen,
              child: const Icon(Icons.add, color: Colors.white, size: 30),
              onPressed: () => _showAddTransactionModal(context, theme, isDark),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: isDark ? AppTheme.gold : AppTheme.darkGreen,
        unselectedItemColor: isDark ? Colors.grey : Colors.black45,
        backgroundColor: theme.cardTheme.color ?? AppTheme.cardColor,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined), label: 'Trans.'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded), label: 'Stats'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              label: 'Accounts'),
          BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz_rounded), label: 'More'),
        ],
      ),
    );
  }

  // --- 1. Transactions View ---
  Widget _buildTransView(ThemeData theme, bool isDark) {
    double totalIncome = _transactions
        .where((e) => e.type == 'Income')
        .fold(0, (sum, item) => sum + item.amount);
    double totalExpense = _transactions
        .where((e) => e.type == 'Expense')
        .fold(0, (sum, item) => sum + item.amount);
    double balance = totalIncome - totalExpense;

    Map<String, List<MoneyTransaction>> groupedTrans = {};
    for (var trans in _transactions) {
      if (!groupedTrans.containsKey(trans.date)) {
        groupedTrans[trans.date] = [];
      }
      groupedTrans[trans.date]!.add(trans);
    }

    final dates = groupedTrans.keys.toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          color: isDark ? AppTheme.cardLightDark : Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _summaryItem('Income', totalIncome, Colors.blue, theme),
              _summaryItem('Expenses', totalExpense, Colors.redAccent, theme),
              _summaryItem('Total', balance,
                  theme.textTheme.bodyLarge?.color ?? Colors.black, theme),
            ],
          ),
        ),
        Expanded(
          child: _transactions.isEmpty
              ? Center(
                  child: Text(
                    "কোনো লেনদেন পাওয়া যায়নি",
                    style: TextStyle(
                        color: theme.textTheme.bodySmall?.color ?? Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: dates.length,
                  itemBuilder: (context, index) {
                    String dateStr = dates[index];
                    List<MoneyTransaction> dayTrans = groupedTrans[dateStr]!;

                    double dayIncome = dayTrans
                        .where((e) => e.type == 'Income')
                        .fold(0, (sum, item) => sum + item.amount);
                    double dayExpense = dayTrans
                        .where((e) => e.type == 'Expense')
                        .fold(0, (sum, item) => sum + item.amount);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          color: isDark
                              ? AppTheme.cardLightDark.withValues(alpha: 0.5)
                              : const Color(0xFFEFEFEF),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                dateStr,
                                style: TextStyle(
                                  color: theme.textTheme.titleMedium?.color,
                                  fontWeight: FontWeight.bold,
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
                                          fontWeight: FontWeight.bold),
                                    ),
                                  if (dayExpense > 0)
                                    Text(
                                      '৳ ${dayExpense.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold),
                                    ),
                                ],
                              )
                            ],
                          ),
                        ),
                        ...dayTrans.map((item) {
                          bool isIncome = item.type == 'Income';
                          bool isTransfer = item.type == 'Transfer';
                          return Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: theme.dividerColor,
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: ListTile(
                              dense: true,
                              title: Text(
                                item.category,
                                style: TextStyle(
                                  color: theme.textTheme.bodyLarge?.color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Text(
                                (item.note ?? '').isNotEmpty
                                    ? '${item.account} • ${item.note}'
                                    : item.account,
                                style: TextStyle(
                                  color: theme.textTheme.bodySmall?.color,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Text(
                                '৳ ${item.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: isIncome
                                      ? Colors.blue
                                      : (isTransfer
                                          ? Colors.orange
                                          : Colors.redAccent),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
        )
      ],
    );
  }

  Widget _summaryItem(
      String label, double amount, Color color, ThemeData theme) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: theme.textTheme.bodySmall?.color ?? Colors.grey,
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

  // --- 2. Stats View ---
  Widget _buildStatsView(ThemeData theme, bool isDark) {
    List<MoneyTransaction> filteredTrans = _getFilteredTransactions();

    double totalIncome = filteredTrans
        .where((e) => e.type == 'Income')
        .fold(0, (sum, item) => sum + item.amount);
    double totalExpense = filteredTrans
        .where((e) => e.type == 'Expense')
        .fold(0, (sum, item) => sum + item.amount);

    final currentList = filteredTrans
        .where((e) => e.type == (_statsTab == 0 ? 'Income' : 'Expense'))
        .toList();

    double currentTotal = currentList.fold(0, (sum, item) => sum + item.amount);

    Map<String, double> categoryMap = {};
    for (var e in currentList) {
      categoryMap[e.category] = (categoryMap[e.category] ?? 0) + e.amount;
    }

    var sortedEntries = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    List<Color> pieColors = [
      const Color(0xFFFF6B6B),
      const Color(0xFFFF9F43),
      const Color(0xFFFFD93D),
      const Color(0xFF6BCB77),
      const Color(0xFF4D96FF),
      const Color(0xFF9B59B6),
      const Color(0xFF1ABC9C),
      const Color(0xFFE67E22),
    ];

    final textColor = theme.textTheme.bodyLarge?.color;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: textColor),
                    onPressed: () {
                      setState(() {
                        if (_filterType == 'Yearly') {
                          _selectedDate = DateTime(_selectedDate.year - 1);
                        } else {
                          _selectedDate = DateTime(_selectedDate.year,
                              _selectedDate.month - 1, _selectedDate.day);
                        }
                      });
                    },
                  ),
                  Text(
                    _filterType == 'Yearly'
                        ? DateFormat('yyyy').format(_selectedDate)
                        : DateFormat('MMM yyyy').format(_selectedDate),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right, color: textColor),
                    onPressed: () {
                      setState(() {
                        if (_filterType == 'Yearly') {
                          _selectedDate = DateTime(_selectedDate.year + 1);
                        } else {
                          _selectedDate = DateTime(_selectedDate.year,
                              _selectedDate.month + 1, _selectedDate.day);
                        }
                      });
                    },
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardLightDark : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _filterType,
                    dropdownColor:
                        isDark ? AppTheme.cardColorDark : Colors.white,
                    style: TextStyle(color: textColor, fontSize: 13),
                    icon: Icon(Icons.keyboard_arrow_down, color: textColor),
                    items: ['Daily', 'Weekly', 'Monthly', 'Yearly']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _filterType = val);
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
                onTap: () => setState(() => _statsTab = 0),
                child: Column(
                  children: [
                    Text(
                      'Income  ৳ ${totalIncome.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: _statsTab == 0
                            ? Colors.blue
                            : theme.textTheme.bodySmall?.color,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 3,
                      color:
                          _statsTab == 0 ? Colors.blue : Colors.transparent,
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _statsTab = 1),
                child: Column(
                  children: [
                    Text(
                      'Expenses  ৳ ${totalExpense.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: _statsTab == 1
                            ? Colors.redAccent
                            : theme.textTheme.bodySmall?.color,
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
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        Divider(color: theme.dividerColor, height: 1),
        Expanded(
          child: sortedEntries.isEmpty
              ? Center(
                  child: Text(
                    "এই সময়সীমার কোনো তথ্য পাওয়া যায়নি",
                    style: TextStyle(color: theme.textTheme.bodySmall?.color),
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
                          sections: sortedEntries.asMap().entries.map((entry) {
                            int idx = entry.key;
                            var item = entry.value;
                            final percentage =
                                (item.value / currentTotal) * 100;
                            final color = pieColors[idx % pieColors.length];

                            return PieChartSectionData(
                              color: color,
                              value: item.value,
                              title:
                                  '${item.key}\n${percentage.toStringAsFixed(1)}%',
                              radius: 95,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: Container(
                        color: theme.cardColor,
                        child: ListView.separated(
                          itemCount: sortedEntries.length,
                          separatorBuilder: (c, i) =>
                              Divider(color: theme.dividerColor, height: 1),
                          itemBuilder: (context, index) {
                            var item = sortedEntries[index];
                            final percentage =
                                (item.value / currentTotal) * 100;
                            final color = pieColors[index % pieColors.length];

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 45,
                                    height: 26,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${percentage.toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
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
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '৳ ${item.value.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
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
        )
      ],
    );
  }

  // --- 3. Accounts View ---
  Widget _buildAccountsView(ThemeData theme, bool isDark) {
    return ListView.builder(
      itemCount: _accounts.length,
      itemBuilder: (context, index) {
        final acc = _accounts[index];
        final double currentBalance = _calculateAccountBalance(acc);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.dividerColor, width: 0.5),
          ),
          child: ListTile(
            leading: Icon(
              Icons.account_balance_wallet,
              color: isDark ? AppTheme.gold : AppTheme.darkGreen,
            ),
            title: Text(
              acc,
              style: TextStyle(
                color: theme.textTheme.titleMedium?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'ব্যালেন্স: ৳ ${currentBalance.toStringAsFixed(2)}',
              style: TextStyle(
                color:
                    currentBalance >= 0 ? Colors.green : Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.edit, color: theme.textTheme.bodySmall?.color),
              onPressed: () => _showEditAccountDialog(index, theme),
            ),
          ),
        );
      },
    );
  }

  void _showEditAccountDialog(int index, ThemeData theme) {
    TextEditingController controller =
        TextEditingController(text: _accounts[index]);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text(
          "অ্যাকাউন্টের নাম পরিবর্তন",
          style: TextStyle(color: theme.textTheme.titleLarge?.color),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            child: const Text("Save"),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _accounts[index] = controller.text.trim();
                });
              }
              Navigator.pop(ctx);
            },
          )
        ],
      ),
    );
  }

  // --- 4. More View ---
  Widget _buildMoreView(ThemeData theme, bool isDark) {
    return Center(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppTheme.gold : AppTheme.darkGreen,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        icon: const Icon(Icons.backup, color: Colors.white),
        label: const Text(
          'Google Drive-এ ব্যাকআপ নিন',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          bool ok = await MoneyDbHelper.autoBackupToDrive();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  ok
                      ? "গুগল ড্রাইভে ব্যাকআপ সফল হয়েছে!"
                      : "ব্যাকআপ নেওয়া সম্ভব হয়নি",
                ),
              ),
            );
          }
        },
      ),
    );
  }

  // --- Add Transaction Modal ---
  void _showAddTransactionModal(
      BuildContext context, ThemeData theme, bool isDark) {
    String type = 'Expense';
    String selectedCategory = _expenseCategories.first;
    String selectedAccount = _accounts.first;
    String targetAccount =
        _accounts.length > 1 ? _accounts[1] : _accounts.first;
    double amount = 0;
    String note = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardColor,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            List<String> currentCategories = type == 'Expense'
                ? _expenseCategories
                : (type == 'Income' ? _incomeCategories : _accounts);

            final textColor = theme.textTheme.bodyLarge?.color;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: ['Income', 'Expense', 'Transfer'].map((t) {
                        bool isSel = type == t;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(t),
                            selected: isSel,
                            selectedColor: Colors.redAccent,
                            onSelected: (val) {
                              setModalState(() {
                                type = t;
                                if (type == 'Expense') {
                                  selectedCategory = _expenseCategories.first;
                                } else if (type == 'Income') {
                                  selectedCategory = _incomeCategories.first;
                                } else {
                                  selectedCategory = _accounts.first;
                                }
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 15),

                    TextField(
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: 'পরিমাণ (Amount)',
                        labelStyle:
                            TextStyle(color: theme.textTheme.bodySmall?.color),
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (val) => amount = double.tryParse(val) ?? 0,
                    ),
                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      value: selectedAccount,
                      dropdownColor: theme.cardColor,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: type == 'Transfer'
                            ? 'কোথা থেকে (From Account)'
                            : 'অ্যাকাউন্ট (Account)',
                        labelStyle:
                            TextStyle(color: theme.textTheme.bodySmall?.color),
                        border: const OutlineInputBorder(),
                      ),
                      items: _accounts.map((acc) {
                        return DropdownMenuItem<String>(
                          value: acc,
                          child: Text(acc),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedAccount = val);
                        }
                      },
                    ),
                    const SizedBox(height: 15),

                    if (type == 'Transfer') ...[
                      DropdownButtonFormField<String>(
                        value: targetAccount,
                        dropdownColor: theme.cardColor,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: 'কোথায় (To Account)',
                          labelStyle: TextStyle(
                              color: theme.textTheme.bodySmall?.color),
                          border: const OutlineInputBorder(),
                        ),
                        items: _accounts.map((acc) {
                          return DropdownMenuItem<String>(
                            value: acc,
                            child: Text(acc),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => targetAccount = val);
                          }
                        },
                      ),
                      const SizedBox(height: 15),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "ক্যাটাগরি নির্ধারণ করুন:",
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            icon: Icon(
                              Icons.add,
                              size: 16,
                              color:
                                  isDark ? AppTheme.gold : AppTheme.darkGreen,
                            ),
                            label: Text(
                              "Add New",
                              style: TextStyle(
                                color:
                                    isDark ? AppTheme.gold : AppTheme.darkGreen,
                                fontSize: 12,
                              ),
                            ),
                            onPressed: () {
                              _showAddCategoryDialog(type, theme, () {
                                setModalState(() {});
                              });
                            },
                          )
                        ],
                      ),
                      const SizedBox(height: 8),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2.3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: currentCategories.length,
                        itemBuilder: (c, i) {
                          String cat = currentCategories[i];
                          bool isSelected = selectedCategory == cat;
                          return GestureDetector(
                            onTap: () =>
                                setModalState(() => selectedCategory = cat),
                            child: Container(
                              alignment: Alignment.center,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.redAccent
                                    : (isDark
                                        ? AppTheme.cardLightDark
                                        : const Color(0xFFEFEFEF)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : textColor,
                                  fontSize: 11.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 15),
                    ],

                    TextField(
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: 'নোট (ঐচ্ছিক)',
                        labelStyle:
                            TextStyle(color: theme.textTheme.bodySmall?.color),
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (val) => note = val,
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      child: const Text(
                        'Save Transaction',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        if (amount <= 0) return;

                        final newTrans = MoneyTransaction(
                          type: type,
                          amount: amount,
                          date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
                          category: type == 'Transfer'
                              ? 'Transfer'
                              : selectedCategory,
                          account: type == 'Transfer'
                              ? '$selectedAccount ➔ $targetAccount'
                              : selectedAccount,
                          note: note,
                        );

                        await MoneyDbHelper.instance.insertTransaction(newTrans);
                        Navigator.pop(ctx);
                        _loadData();
                      },
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

  void _showAddCategoryDialog(
      String type, ThemeData theme, VoidCallback onAdded) {
    TextEditingController newCatController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text(
          "নতুন ক্যাটাগরি যোগ করুন",
          style: TextStyle(color: theme.textTheme.titleLarge?.color),
        ),
        content: TextField(
          controller: newCatController,
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            hintText: "ক্যাটাগরির নাম",
            hintStyle: TextStyle(color: theme.textTheme.bodySmall?.color),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            child: const Text("Add"),
            onPressed: () {
              if (newCatController.text.trim().isNotEmpty) {
                setState(() {
                  if (type == 'Expense') {
                    _expenseCategories.add(newCatController.text.trim());
                  } else if (type == 'Income') {
                    _incomeCategories.add(newCatController.text.trim());
                  }
                });
                onAdded();
              }
              Navigator.pop(ctx);
            },
          )
        ],
      ),
    );
  }
}
