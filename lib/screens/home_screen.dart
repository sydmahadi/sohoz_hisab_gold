import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'money_manager_screen.dart';
import 'entry_screen.dart';
import 'info_screen.dart';
import 'note_screen.dart';
import 'calculator_screen.dart';
import 'calendar_screen.dart';
import 'date_calculator_screen.dart';
import 'time_sum_screen.dart';
import 'daily_average_screen.dart';
import 'monthly_average_screen.dart';
import 'browser_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, themeMode, child) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: AppTheme.backgroundSecondary,
            elevation: 0,
            centerTitle: true,
            title: Column(
              children: [
                Text(
                  'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                  style: TextStyle(
                    color: AppTheme.gold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'সহজ হিসাব গোল্ড',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'থিম পরিবর্তন',
                onPressed: () {
                  AppTheme.themeNotifier.value =
                      themeMode == ThemeMode.dark
                          ? ThemeMode.light
                          : ThemeMode.dark;
                },
                icon: Icon(
                  themeMode == ThemeMode.dark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  color: AppTheme.gold,
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: GridView.count(
                    padding: const EdgeInsets.all(16),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.05,
                    children: [
                      _MenuCard(
                        title: 'মানি ম্যানেজার',
                        icon: Icons.account_balance_wallet_outlined,
                        color: AppTheme.gold,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const MoneyManagerScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuCard(
                        title: 'এন্ট্রি করুন',
                        icon: Icons.edit_note_outlined,
                        color: AppTheme.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EntryScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuCard(
                        title: 'তথ্য দেখুন',
                        icon: Icons.info_outline,
                        color: AppTheme.gold,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const InfoScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuCard(
                        title: 'নোট',
                        icon: Icons.note_alt_outlined,
                        color: AppTheme.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NoteScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuCard(
                        title: 'ক্যালকুলেটর',
                        icon: Icons.calculate_outlined,
                        color: AppTheme.gold,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const CalculatorScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuCard(
                        title: 'ক্যালেন্ডার',
                        icon: Icons.calendar_month_outlined,
                        color: AppTheme.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const CalendarScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuCard(
                        title: 'তারিখ হিসাব',
                        icon: Icons.date_range_outlined,
                        color: AppTheme.gold,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const DateCalculatorScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuCard(
                        title: 'সময় যোগ',
                        icon: Icons.access_time_outlined,
                        color: AppTheme.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const TimeSumScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuCard(
                        title: 'দৈনিক গড়',
                        icon: Icons.today_outlined,
                        color: AppTheme.gold,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const DailyAverageScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuCard(
                        title: 'মাসিক গড়',
                        icon: Icons.calendar_view_month_outlined,
                        color: AppTheme.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const MonthlyAverageScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuCard(
                        title: 'ব্রাউজার',
                        icon: Icons.language_outlined,
                        color: AppTheme.gold,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BrowserScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 12,
                  ),
                  child: Text(
                    'Developed by Talpatar Sepai',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// MENU CARD
// ============================================================

class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
