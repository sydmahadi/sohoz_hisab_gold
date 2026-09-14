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
  List<MoneyTransaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await MoneyDbHelper.instance.getAllTransactions();
    setState(() {
      _transactions = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildTransView(),
      _buildStatsView(),
      const Center(child: Text("অ্যাকাউন্টস স্ক্রিন", style: TextStyle(color: Colors.white))),
      _buildMoreView(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('মানি ম্যানেজার'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_rounded, color: AppTheme.gold),
            onPressed: () async {
              bool success = await MoneyDbHelper.signInWithGoogle();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? "গুগল ড্রাইভ সিঙ্ক চালু হয়েছে!" : "সিঙ্ক ব্যর্থ হয়েছে"),
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
              backgroundColor: Colors.redAccent,
              child: const Icon(Icons.add, color: Colors.white, size: 30),
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
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Trans.'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: 'Accounts'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }

  Widget _buildTransView() {
    double totalIncome = _transactions.where((e) => e.type == 'Income').fold(0, (sum, item) => sum + item.amount);
    double totalExpense = _transactions.where((e) => e.type == 'Expense').fold(0, (sum, item) => sum + item.amount);
    double balance = totalIncome - totalExpense;

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
              ? const Center(child: Text("কোনো লেনদেন পাওয়া যায়নি", style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final item = _transactions[index];
                    bool isIncome = item.type == 'Income';
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(item.category, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text('${item.account} • ${item.date}', style: const TextStyle(color: Colors.grey)),
                        trailing: Text(
                          '৳ ${item.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isIncome ? Colors.blue : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
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
        Text('৳ ${amount.toStringAsFixed(2)}', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  Widget _buildStatsView() {
    final expenses = _transactions.where((e) => e.type == 'Expense').toList();
    double totalExpense = expenses.fold(0, (sum, item) => sum + item.amount);

    if (expenses.isEmpty) {
      return const Center(child: Text("স্ট্যাটস দেখানোর মতো কোনো খরচ নেই", style: TextStyle(color: Colors.white54)));
    }

    Map<String, double> categoryMap = {};
    for (var e in expenses) {
      categoryMap[e.category] = (categoryMap[e.category] ?? 0) + e.amount;
    }

    List<PieChartSectionData> sections = [];
    List<Color> colors = [Colors.redAccent, Colors.orange, Colors.amber, Colors.green, Colors.purple, Colors.blue];
    int colorIdx = 0;

    categoryMap.forEach((category, amount) {
      final percentage = (amount / totalExpense) * 100;
      sections.add(PieChartSectionData(
        color: colors[colorIdx % colors.length],
        value: amount,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      ));
      colorIdx++;
    });

    return Column(
      children: [
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: PieChart(PieChartData(sections: sections, centerSpaceRadius: 40)),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView(
            children: categoryMap.entries.map((e) {
              return ListTile(
                title: Text(e.key, style: const TextStyle(color: Colors.white)),
                trailing: Text('৳ ${e.value.toStringAsFixed(2)}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMoreView() {
    return Center(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.gold),
        icon: const Icon(Icons.backup, color: Colors.black),
        label: const Text('Google Drive-এ ম্যানুয়াল ব্যাকআপ নিন', style: TextStyle(color: Colors.black)),
        onPressed: () async {
          await MoneyDbHelper.autoBackupToDrive();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("গুগল ড্রাইভে ব্যাকআপ সফল হয়েছে!")),
            );
          }
        },
      ),
    );
  }

  void _showAddTransactionModal(BuildContext context) {
    String type = 'Expense';
    String selectedCategory = 'Food';
    double amount = 0;
    String note = '';

    List<String> expenseCategories = ['Food', 'Transport', 'Social Life', 'Pets', 'Household', 'Apparel', 'Beauty', 'Health', 'Education', 'Gift', 'Other'];
    List<String> incomeCategories = ['Allowance', 'Salary', 'Petty cash', 'Bonus', 'Baitul Mal', 'Other'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardColor,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            List<String> currentCategories = type == 'Expense' ? expenseCategories : incomeCategories;

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
                                selectedCategory = currentCategories.first;
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
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("ক্যাটাগরি নির্ধারণ করুন:", style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: currentCategories.length,
                      itemBuilder: (c, i) {
                        String cat = currentCategories[i];
                        bool isSelected = selectedCategory == cat;
                        return GestureDetector(
                          onTap: () => setModalState(() => selectedCategory = cat),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.redAccent : AppTheme.cardLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(cat, style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'নোট (অচ্ছিক)',
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
                      child: const Text('Save Transaction', style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        if (amount <= 0) return;

                        final newTrans = MoneyTransaction(
                          type: type,
                          amount: amount,
                          date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
                          category: selectedCategory,
                          account: 'Cash',
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
}
