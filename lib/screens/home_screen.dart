import 'dart:math';
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
    final List<_MenuItem> items = [
      _MenuItem(
        title: 'মানি ম্যানেজার',
        icon: Icons.account_balance_wallet_rounded,
        screen: const MoneyManagerScreen(),
      ),
      _MenuItem(
        title: 'এন্ট্রি করুন',
        icon: Icons.edit_note_rounded,
        screen: const EntryScreen(),
      ),
      _MenuItem(
        title: 'তথ্য দেখুন',
        icon: Icons.menu_book_rounded,
        screen: const InfoScreen(),
      ),
      _MenuItem(
        title: 'নোট করুন',
        icon: Icons.note_alt_rounded,
        screen: const NoteScreen(),
      ),
      _MenuItem(
        title: 'ক্যালকুলেটর',
        icon: Icons.calculate_rounded,
        screen: const CalculatorScreen(),
      ),
      _MenuItem(
        title: 'ক্যালেন্ডার',
        icon: Icons.calendar_month_rounded,
        screen: const CalendarScreen(),
      ),
      _MenuItem(
        title: 'তারিখ হিসাব',
        icon: Icons.event_rounded,
        screen: const DateCalculatorScreen(),
      ),
      _MenuItem(
        title: 'সময় যোগ',
        icon: Icons.access_time_rounded,
        screen: const TimeSumScreen(),
      ),
      _MenuItem(
        title: 'দৈনিক গড়',
        icon: Icons.bar_chart_rounded,
        screen: const DailyAverageScreen(),
      ),
      _MenuItem(
        title: 'মাসিক গড়',
        icon: Icons.analytics_rounded,
        screen: const MonthlyAverageScreen(),
      ),
      _MenuItem(
        title: 'ব্রাউজার',
        icon: Icons.language_rounded,
        screen: const BrowserScreen(),
      ),
    ];

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('সহজ হিসাব গোল্ড'),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: AppTheme.themeNotifier,
            builder: (_, ThemeMode mode, __) {
              final isDark = mode == ThemeMode.dark;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? AppTheme.gold.withValues(alpha: 0.15)
                        : AppTheme.darkGreen.withValues(alpha: 0.1),
                    border: Border.all(
                      color: isDark
                          ? AppTheme.gold.withValues(alpha: 0.5)
                          : AppTheme.darkGreen.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      color: isDark ? AppTheme.gold : AppTheme.darkGreen,
                      size: 22,
                    ),
                    tooltip: isDark ? 'Light Mode' : 'Dark Mode',
                    onPressed: () {
                      AppTheme.themeNotifier.value =
                          isDark ? ThemeMode.light : ThemeMode.dark;
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: _IslamicBackground(),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
              child: Column(
                children: [
                  const _HeaderCard(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 23,
                        decoration: BoxDecoration(
                          color: AppTheme.gold,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.gold.withValues(alpha: 0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'হিসাব ও প্রয়োজনীয় টুল',
                        style: TextStyle(
                          color: theme.textTheme.titleLarge?.color,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.88,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return _MenuCard(
                        item: item,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => item.screen,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  const _BottomInfo(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final Widget screen;

  const _MenuItem({
    required this.title,
    required this.icon,
    required this.screen,
  });
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  AppTheme.darkGreen,
                  AppTheme.backgroundSecondaryDark,
                ]
              : const [
                  AppTheme.darkGreen,
                  AppTheme.green,
                ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? AppTheme.gold.withValues(alpha: 0.65)
              : AppTheme.gold.withValues(alpha: 0.8),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : AppTheme.darkGreen.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? AppTheme.backgroundDark.withValues(alpha: 0.55)
                  : Colors.white.withValues(alpha: 0.15),
              border: Border.all(
                color: AppTheme.gold.withValues(alpha: 0.75),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.gold.withValues(alpha: 0.2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.calculate_rounded,
              color: AppTheme.goldLight,
              size: 29,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.goldLight,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 11),
          const Text(
            'সহজ হিসাব গোল্ড',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'সহজে হিসাব করুন',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 1,
            width: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppTheme.gold.withValues(alpha: 0.7),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'হিসাব, নোট, ক্যালেন্ডার ও প্রয়োজনীয় টুল এক জায়গায়',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final _MenuItem item;
  final VoidCallback onTap;

  const _MenuCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(21),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        splashColor: AppTheme.gold.withValues(alpha: 0.15),
        highlightColor: AppTheme.gold.withValues(alpha: 0.08),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [
                      AppTheme.cardLightDark,
                      AppTheme.cardColorDark,
                    ]
                  : const [
                      Colors.white,
                      Color(0xFFF7F9F8),
                    ],
            ),
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: isDark
                  ? AppTheme.gold.withValues(alpha: 0.38)
                  : const Color(0xFFD3DDD8),
              width: isDark ? 0.7 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.22)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 9,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 51,
                  height: 51,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.green,
                        AppTheme.darkGreen,
                      ],
                    ),
                    border: Border.all(
                      color: AppTheme.gold.withValues(alpha: 0.65),
                      width: 0.9,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.gold.withValues(alpha: 0.12),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    item.icon,
                    color: AppTheme.goldLight,
                    size: 25,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomInfo extends StatelessWidget {
  const _BottomInfo();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 45,
              height: 1,
              color: AppTheme.gold.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.auto_awesome_rounded,
              color: AppTheme.gold,
              size: 16,
            ),
            const SizedBox(width: 10),
            Container(
              width: 45,
              height: 1,
              color: AppTheme.gold.withValues(alpha: 0.5),
            ),
          ],
        ),
        const SizedBox(height: 13),
        Text(
          'Developed by Talpatar Sepai',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'm.talpatarsepai@gmail.com',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.textTheme.bodyMedium?.color,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'সহজ • সুন্দর • প্রয়োজনীয়',
          style: TextStyle(
            color: isDark
                ? AppTheme.gold.withValues(alpha: 0.7)
                : AppTheme.darkGreen,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _IslamicBackground extends StatelessWidget {
  const _IslamicBackground();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomPaint(
      painter: _IslamicPatternPainter(isDark: isDark),
      child: const SizedBox.expand(),
    );
  }
}

class _IslamicPatternPainter extends CustomPainter {
  final bool isDark;

  _IslamicPatternPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final goldPaint = Paint()
      ..color = isDark
          ? AppTheme.gold.withValues(alpha: 0.035)
          : AppTheme.gold.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    final greenPaint = Paint()
      ..color = isDark
          ? AppTheme.green.withValues(alpha: 0.05)
          : AppTheme.green.withValues(alpha: 0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    const spacing = 96.0;

    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      for (double y = -spacing; y < size.height + spacing; y += spacing) {
        final center = Offset(x, y);

        // Draw 8-pointed Rub el Hizb Star
        _drawEightPointStar(canvas, center, 28, goldPaint);
        _drawEightPointStar(canvas, center, 18, greenPaint);

        // Outer connecting geometric lines
        final diamondPath = Path();
        diamondPath.moveTo(center.dx, center.dy - 42);
        diamondPath.lineTo(center.dx + 42, center.dy);
        diamondPath.lineTo(center.dx, center.dy + 42);
        diamondPath.lineTo(center.dx - 42, center.dy);
        diamondPath.close();

        canvas.drawPath(diamondPath, goldPaint);
      }
    }
  }

  void _drawEightPointStar(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    final path = Path();
    final double innerRadius = radius * 0.5;

    for (int i = 0; i < 16; i++) {
      final double r = i.isEven ? radius : innerRadius;
      final double angle = (i * pi / 8);
      final double x = center.dx + r * cos(angle);
      final double y = center.dy + r * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _IslamicPatternPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
