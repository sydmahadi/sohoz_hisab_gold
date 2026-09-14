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

  List<String> _accounts = ['Cash', 'Bkash', 'Bank Account', 'Nagad', 'Card'];

  @override
  void initState() {
    super.initState();
    _loadData();
    // অ্যাপ চালু হওয়ামাত্র গুগল অ্যাকাউন্ট চেক ও সাইন-ইন করবে
    MoneyDbHelper.signInWithGoogle();
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
        final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return itemDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
            itemDate.isBefore(endOfWeek.add(const Duration(days: 1)));
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildTransView(),
      _buildStatsView(),
      _buildAccountsView(),
      _buildMoreView(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'সহজ হিসাব',
          style: TextStyle(
            color: AppTheme.gold,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_rounded, color: AppTheme.gold),
            onPressed: () async {
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
              backgroundColor: AppTheme.gold,
              child: const Icon(Icons.add, color: Colors.black, size: 30),
              onPressed: () => _showAddTransactionModal(context),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: AppTheme.cardColor,
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
  Widget _buildTransView() {
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
          color: AppTheme.cardLight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _summaryItem('Income', totalIncome, Colors.blue),
              _summaryItem('Expenses', totalExpense, Colors.redAccent),
              _summaryItem('Total', balance, Colors.white),
            ],
          ),
        ),
        Expanded(
          child: _transactions.isEmpty
              ? const Center(
                  child: Text("কোনো লেনদেন পাওয়া যায়নি",
                      style: TextStyle(color: Colors.white54)))
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
                          color: AppTheme.cardLight.withOpacity(0.5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                dateStr,
                                style: const TextStyle(
                                  color: Colors.white,
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
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: Colors.white12, width: 0.5),
                              ),
                            ),
                            child: ListTile(
                              dense: true,
                              title: Text(item.category,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15)),
                              subtitle: Text(
                                (item.note ?? '').isNotEmpty
                                    ? '${item.account} • ${item.note}'
                                    : item.account,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
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
                        }).toList(),
                      ],
                    );
                  },
                ),
        )
      ],
    );
  }

  Widget _summaryItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 4),
        Text('৳ ${amount.toStringAsFixed(2)}',
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  // --- 2. Stats View ---
  Widget _buildStatsView() {
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

    double currentTotal =
        currentList.fold(0, (sum, item) => sum + item.amount);

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
                    icon: const Icon(Icons.chevron_left, color: Colors.white),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
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
                  color: AppTheme.cardLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _filterType,
                    dropdownColor: AppTheme.cardColor,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: Colors.white),
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
                        color: _statsTab == 0 ? Colors.white : Colors.grey,
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
                        color: _statsTab == 1 ? Colors.white : Colors.grey,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 3,
                      color:
                          _statsTab == 1 ? Colors.redAccent : Colors.transparent,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        const Divider(color: Colors.white12, height: 1),
        Expanded(
          child: sortedEntries.isEmpty
              ? const Center(
                  child: Text("এই সময়সীমার কোনো তথ্য পাওয়া যায়নি",
                      style: TextStyle(color: Colors.white54)),
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
                        color: AppTheme.cardColor,
                        child: ListView.separated(
                          itemCount: sortedEntries.length,
                          separatorBuilder: (c, i) =>
                              const Divider(color: Colors.white12, height: 1),
                          itemBuilder: (context, index) {
                            var item = sortedEntries[index];
                            final percentage = (item.value / currentTotal) * 100;
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
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '৳ ${item.value.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.white,
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
  Widget _buildAccountsView() {
    return ListView.builder(
      itemCount: _accounts.length,
      itemBuilder: (context, index) {
        final acc = _accounts[index];
        final double currentBalance = _calculateAccountBalance(acc);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading:
                const Icon(Icons.account_balance_wallet, color: AppTheme.gold),
            title: Text(acc,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(
              'ব্যালেন্স: ৳ ${currentBalance.toStringAsFixed(2)}',
              style: TextStyle(
                color: currentBalance >= 0 ? Colors.greenAccent : Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit, color: Colors.grey),
              onPressed: () => _showEditAccountDialog(index),
            ),
          ),
        );
      },
    );
  }

  void _showEditAccountDialog(int index) {
    TextEditingController controller =
        TextEditingController(text: _accounts[index]);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text("অ্যাকাউন্টের নাম পরিবর্তন",
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
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
  Widget _buildMoreView() {
    return Center(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.gold),
        icon: const Icon(Icons.backup, color: Colors.black),
        label: const Text('Google Drive-এ ব্যাকআপ নিন',
            style: TextStyle(color: Colors.black)),
        onPressed: () async {
          bool ok = await MoneyDbHelper.autoBackupToDrive();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(ok
                    ? "গুগল ড্রাইভে ব্যাকআপ সফল হয়েছে!"
                    : "ব্যাকআপ নেওয়া সম্ভব হয়নি"),
              ),
            );
          }
        },
      ),
    );
  }

  // --- Add Transaction Modal ---
  void _showAddTransactionModal(BuildContext context) {
    String type = 'Expense';
    String selectedCategory = _expenseCategories.first;
    String selectedAccount = _accounts.first;
    String targetAccount = _accounts.length > 1 ? _accounts[1] : _accounts.first;
    double amount = 0;
    String note = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardColor,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            List<String> currentCategories = type == 'Expense'
                ? _expenseCategories
                : (type == 'Income' ? _incomeCategories : _accounts);

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
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'পরিমাণ (Amount)',
                        labelStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => amount = double.tryParse(val) ?? 0,
                    ),
                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      value: selectedAccount,
                      dropdownColor: AppTheme.cardColor,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: type == 'Transfer'
                            ? 'কোথা থেকে (From Account)'
                            : 'অ্যাকাউন্ট (Account)',
                        labelStyle: const TextStyle(color: Colors.grey),
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
                        dropdownColor: AppTheme.cardColor,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'কোথায় (To Account)',
                          labelStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(),
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
                          const Text(
                            "ক্যাটাগরি নির্ধারণ করুন:",
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.add,
                                size: 16, color: AppTheme.gold),
                            label: const Text("Add New",
                                style: TextStyle(
                                    color: AppTheme.gold, fontSize: 12)),
                            onPressed: () {
                              _showAddCategoryDialog(type, () {
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
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.redAccent
                                    : AppTheme.cardLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                cat,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 11.5),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 15),
                    ],

                    TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'নোট (ঐচ্ছিক)',
                        labelStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => note = val,
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      child: const Text('Save Transaction',
                          style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        if (amount <= 0) return;

                        final newTrans = MoneyTransaction(
                          type: type,
                          amount: amount,
                          date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
                          category: type == 'Transfer' ? 'Transfer' : selectedCategory,
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

  void _showAddCategoryDialog(String type, VoidCallback onAdded) {
    TextEditingController newCatController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text("নতুন ক্যাটাগরি যোগ করুন",
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: newCatController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "ক্যাটাগরির নাম",
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(),
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
