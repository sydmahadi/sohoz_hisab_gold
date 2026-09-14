import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../logic/money_db_helper.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() =>
      _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTime _selectedMonth = DateTime.now();

  List<MoneyTransaction> _transactions = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _loading = true;
    });

    final data =
        await MoneyDbHelper.instance.getAllTransactions();

    if (!mounted) return;

    setState(() {
      _transactions = data;
      _loading = false;
    });
  }

  DateTime? _parseDate(String date) {
    try {
      return DateFormat('dd/MM/yyyy').parse(date);
    } catch (_) {
      return null;
    }
  }

  List<MoneyTransaction> get _monthlyTransactions {
    return _transactions.where((item) {
      final date = _parseDate(item.date);

      if (date == null) return false;

      return date.year == _selectedMonth.year &&
          date.month == _selectedMonth.month;
    }).toList();
  }

  List<MoneyTransaction> get _incomeTransactions {
    return _monthlyTransactions
        .where((e) => e.type == 'Income')
        .toList();
  }

  List<MoneyTransaction> get _expenseTransactions {
    return _monthlyTransactions
        .where((e) => e.type == 'Expense')
        .toList();
  }

  double get _totalIncome {
    return _incomeTransactions.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );
  }

  double get _totalExpense {
    return _expenseTransactions.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );
  }

  double get _balance {
    return _totalIncome - _totalExpense;
  }

  Map<String, double> _categoryTotals(
    List<MoneyTransaction> transactions,
  ) {
    final Map<String, double> result = {};

    for (final item in transactions) {
      result[item.category] =
          (result[item.category] ?? 0) +
              item.amount;
    }

    return result;
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
      );
    });
  }

  Future<void> _selectMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'রিপোর্টের মাস নির্বাচন করুন',
    );

    if (picked == null) return;

    setState(() {
      _selectedMonth = DateTime(
        picked.year,
        picked.month,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = AppTheme.isDark;

    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        title: Text(
          'মাসিক রিপোর্ট',
          style: TextStyle(
            color: dark
                ? AppTheme.gold
                : AppTheme.darkGreen,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadReport,
            icon: Icon(
              Icons.refresh_rounded,
              color: dark
                  ? AppTheme.gold
                  : AppTheme.darkGreen,
            ),
          ),
        ],
      ),

      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: dark
                    ? AppTheme.gold
                    : AppTheme.darkGreen,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadReport,
              color: dark
                  ? AppTheme.gold
                  : AppTheme.darkGreen,
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  14,
                  10,
                  14,
                  30,
                ),
                child: Column(
                  children: [
                    _buildMonthSelector(
                      theme,
                      dark,
                    ),

                    const SizedBox(height: 14),

                    _buildSummaryCard(
                      theme,
                      dark,
                    ),

                    const SizedBox(height: 14),

                    _buildBalanceCard(
                      theme,
                      dark,
                    ),

                    const SizedBox(height: 20),

                    _buildSectionTitle(
                      'আয়ের বিস্তারিত',
                      Icons.trending_up_rounded,
                      Colors.blue,
                    ),

                    const SizedBox(height: 10),

                    _buildCategoryCard(
                      theme: theme,
                      dark: dark,
                      transactions:
                          _incomeTransactions,
                      total: _totalIncome,
                      emptyText:
                          'এই মাসে কোনো আয় নেই',
                      accentColor: Colors.blue,
                    ),

                    const SizedBox(height: 20),

                    _buildSectionTitle(
                      'খরচের বিস্তারিত',
                      Icons.trending_down_rounded,
                      Colors.redAccent,
                    ),

                    const SizedBox(height: 10),

                    _buildCategoryCard(
                      theme: theme,
                      dark: dark,
                      transactions:
                          _expenseTransactions,
                      total: _totalExpense,
                      emptyText:
                          'এই মাসে কোনো খরচ নেই',
                      accentColor:
                          Colors.redAccent,
                    ),

                    const SizedBox(height: 20),

                    _buildTransactionInfo(
                      theme,
                      dark,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMonthSelector(
    ThemeData theme,
    bool dark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.gold.withValues(
            alpha: dark ? 0.35 : 0.25,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _previousMonth,
            icon: Icon(
              Icons.chevron_left_rounded,
              color: dark
                  ? AppTheme.gold
                  : AppTheme.darkGreen,
              size: 30,
            ),
          ),

          Expanded(
            child: InkWell(
              borderRadius:
                  BorderRadius.circular(12),
              onTap: _selectMonth,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 5,
                ),
                child: Column(
                  children: [
                    Text(
                      'রিপোর্টের মাস',
                      style: TextStyle(
                        color:
                            AppTheme.textMuted,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      DateFormat(
                        'MMMM yyyy',
                      ).format(_selectedMonth),
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        color:
                            AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'মাস পরিবর্তন করতে চাপ দিন',
                      style: TextStyle(
                        color:
                            AppTheme.textMuted,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          IconButton(
            onPressed: _nextMonth,
            icon: Icon(
              Icons.chevron_right_rounded,
              color: dark
                  ? AppTheme.gold
                  : AppTheme.darkGreen,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    ThemeData theme,
    bool dark,
  ) {
    return Row(
      children: [
        Expanded(
          child: _summaryBox(
            title: 'মোট আয়',
            amount: _totalIncome,
            icon: Icons.arrow_downward_rounded,
            color: Colors.blue,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _summaryBox(
            title: 'মোট খরচ',
            amount: _totalExpense,
            icon: Icons.arrow_upward_rounded,
            color: Colors.redAccent,
          ),
        ),
      ],
    );
  }

  Widget _summaryBox({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(
            alpha: 0.35,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: AppTheme.isDark
                  ? 0.18
                  : 0.05,
            ),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.12,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            title,
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          FittedBox(
            child: Text(
              '৳ ${amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: color,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(
    ThemeData theme,
    bool dark,
  ) {
    final surplus = _balance >= 0;

    final Color balanceColor =
        surplus ? Colors.green : Colors.redAccent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? [
                  AppTheme.cardLightDark,
                  AppTheme.cardColorDark,
                ]
              : [
                  Colors.white,
                  AppTheme.backgroundSecondaryLight,
                ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: balanceColor.withValues(
            alpha: 0.45,
          ),
        ),
      ),
      child: Column(
        children: [
          Icon(
            surplus
                ? Icons.account_balance_rounded
                : Icons.warning_amber_rounded,
            color: balanceColor,
            size: 35,
          ),

          const SizedBox(height: 8),

          Text(
            surplus ? 'উদ্বৃত্ত' : 'ঘাটতি',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            '৳ ${_balance.abs().toStringAsFixed(2)}',
            style: TextStyle(
              color: balanceColor,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            surplus
                ? 'এই মাসে আয় থেকে খরচ বাদ দিয়ে উদ্বৃত্ত আছে'
                : 'এই মাসে আয়ের তুলনায় খরচ বেশি হয়েছে',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(
              alpha: 0.12,
            ),
            borderRadius:
                BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 19,
          ),
        ),

        const SizedBox(width: 10),

        Text(
          title,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required ThemeData theme,
    required bool dark,
    required List<MoneyTransaction>
        transactions,
    required double total,
    required String emptyText,
    required Color accentColor,
  }) {
    if (transactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: AppTheme.gold.withValues(
              alpha: 0.25,
            ),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              color: AppTheme.textMuted,
              size: 35,
            ),

            const SizedBox(height: 8),

            Text(
              emptyText,
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    final categoryMap =
        _categoryTotals(transactions);

    final entries =
        categoryMap.entries.toList()
          ..sort(
            (a, b) =>
                b.value.compareTo(a.value),
          );

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.gold.withValues(
            alpha: dark ? 0.28 : 0.20,
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              14,
              16,
              12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'মোট',
                    style: TextStyle(
                      color:
                          AppTheme.textMuted,
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '৳ ${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: theme.dividerColor,
          ),

          ...entries.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final item = entry.value;

              final percentage =
                  total == 0
                      ? 0.0
                      : (item.value /
                              total) *
                          100;

              return Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          alignment:
                              Alignment.center,
                          decoration:
                              BoxDecoration(
                            color: accentColor
                                .withValues(
                              alpha: 0.10,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              9,
                            ),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color:
                                  accentColor,
                              fontSize: 12,
                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
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
                                item.key,
                                maxLines: 2,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style: TextStyle(
                                  color:
                                      AppTheme
                                          .textPrimary,
                                  fontSize:
                                      13.5,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                ),
                              ),

                              const SizedBox(
                                height: 5,
                              ),

                              ClipRRect(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  10,
                                ),
                                child:
                                    LinearProgressIndicator(
                                  value:
                                      percentage /
                                          100,
                                  minHeight: 5,
                                  backgroundColor:
                                      accentColor
                                          .withValues(
                                    alpha:
                                        0.08,
                                  ),
                                  valueColor:
                                      AlwaysStoppedAnimation<
                                          Color>(
                                    accentColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .end,
                          children: [
                            Text(
                              '৳ ${item.value.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: AppTheme
                                    .textPrimary,
                                fontSize: 13,
                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),

                            const SizedBox(
                              height: 3,
                            ),

                            Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color:
                                    accentColor,
                                fontSize: 10.5,
                                fontWeight:
                                    FontWeight
                                        .w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (index !=
                      entries.length - 1)
                    Divider(
                      height: 1,
                      color:
                          theme.dividerColor,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionInfo(
    ThemeData theme,
    bool dark,
  ) {
    final count =
        _monthlyTransactions.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.gold.withValues(
            alpha: dark ? 0.28 : 0.20,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.gold.withValues(
                alpha: 0.12,
              ),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: AppTheme.gold,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'মোট লেনদেন',
                  style: TextStyle(
                    color:
                        AppTheme.textMuted,
                    fontSize: 11.5,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '$count টি',
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

          Text(
            DateFormat(
              'MMMM yyyy',
            ).format(_selectedMonth),
            style: TextStyle(
              color: AppTheme.gold,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
