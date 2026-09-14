import 'dart:math' as math;

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
          body: Stack(
            children: [
              // ============================================================
              // ISLAMIC GEOMETRIC BACKGROUND
              // ============================================================

              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: IslamicGeometryPainter(
                      isDark: themeMode == ThemeMode.dark,
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // ======================================================
                    // PREMIUM HEADER
                    // ======================================================

                    _buildHeader(
                      context,
                      themeMode,
                    ),

                    // ======================================================
                    // MENU
                    // ======================================================

                    Expanded(
                      child: GridView.count(
                        padding: const EdgeInsets.fromLTRB(
                          14,
                          8,
                          14,
                          12,
                        ),
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.35,
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
                            icon: Icons.info_outline_rounded,
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
                                  builder: (_) =>
                                      const BrowserScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // ======================================================
                    // FOOTER
                    // ======================================================

                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        12,
                        2,
                        12,
                        10,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 70,
                            height: 1,
                            color: AppTheme.gold.withValues(
                              alpha: 0.45,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Developed by Talpatar Sepai',
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'mail : m.talpatarsepai@gmail.com',
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(
    BuildContext context,
    ThemeMode themeMode,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        14,
        10,
        14,
        4,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          16,
          12,
          8,
          12,
        ),
        decoration: BoxDecoration(
          color: AppTheme.cardColor.withValues(
            alpha: AppTheme.isDark ? 0.94 : 0.96,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.gold.withValues(
              alpha: 0.32,
            ),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: AppTheme.isDark ? 0.20 : 0.07,
              ),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Islamic emblem
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.gold.withValues(
                  alpha: 0.10,
                ),
                border: Border.all(
                  color: AppTheme.gold.withValues(
                    alpha: 0.45,
                  ),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: math.pi / 4,
                    child: Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.gold.withValues(
                            alpha: 0.75,
                          ),
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.auto_awesome,
                    size: 18,
                    color: AppTheme.gold,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                    style: TextStyle(
                      color: AppTheme.goldLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'সহজ হিসাব গোল্ড',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'প্রয়োজনীয় সব হিসাব এক জায়গায়',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            // Theme button
            Container(
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(
                  alpha: 0.09,
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: IconButton(
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
                  size: 21,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// PREMIUM MENU CARD
// ============================================================================

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
        borderRadius: BorderRadius.circular(16),
        splashColor: color.withValues(alpha: 0.12),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor.withValues(
              alpha: AppTheme.isDark ? 0.90 : 0.94,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: AppTheme.isDark ? 0.15 : 0.05,
                ),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Small geometric decoration
              Positioned(
                right: -9,
                top: -9,
                child: Transform.rotate(
                  angle: math.pi / 4,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: color.withValues(
                          alpha: 0.10,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: color.withValues(
                          alpha: 0.10,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: color.withValues(
                            alpha: 0.22,
                          ),
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 22,
                        color: color,
                      ),
                    ),

                    const SizedBox(width: 9),

                    Flexible(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ISLAMIC GEOMETRIC BACKGROUND PAINTER
// ============================================================================

class IslamicGeometryPainter extends CustomPainter {
  final bool isDark;

  IslamicGeometryPainter({
    required this.isDark,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = AppTheme.gold.withValues(
        alpha: isDark ? 0.045 : 0.055,
      );

    const double spacing = 72;

    for (double x = -spacing;
        x < size.width + spacing;
        x += spacing) {
      for (double y = -spacing;
          y < size.height + spacing;
          y += spacing) {
        _drawIslamicStar(
          canvas,
          Offset(x, y),
          28,
          paint,
        );
      }
    }

    // Additional diagonal lines for geometric depth
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = AppTheme.gold.withValues(
        alpha: isDark ? 0.025 : 0.035,
      );

    for (double i = -size.height;
        i < size.width;
        i += 100) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        linePaint,
      );

      canvas.drawLine(
        Offset(i, size.height),
        Offset(i + size.height, 0),
        linePaint,
      );
    }
  }

  void _drawIslamicStar(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    final path = Path();

    const int points = 8;

    for (int i = 0; i < points * 2; i++) {
      final angle =
          -math.pi / 2 +
          (math.pi / points) * i;

      final currentRadius =
          i.isEven ? radius : radius * 0.48;

      final point = Offset(
        center.dx +
            math.cos(angle) * currentRadius,
        center.dy +
            math.sin(angle) * currentRadius,
      );

      if (i == 0) {
        path.moveTo(
          point.dx,
          point.dy,
        );
      } else {
        path.lineTo(
          point.dx,
          point.dy,
        );
      }
    }

    path.close();

    canvas.drawPath(
      path,
      paint,
    );

    // Inner diamond
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..color = AppTheme.gold.withValues(
        alpha: isDark ? 0.025 : 0.035,
      );

    final diamond = Path()
      ..moveTo(
        center.dx,
        center.dy - radius * 0.38,
      )
      ..lineTo(
        center.dx + radius * 0.38,
        center.dy,
      )
      ..lineTo(
        center.dx,
        center.dy + radius * 0.38,
      )
      ..lineTo(
        center.dx - radius * 0.38,
        center.dy,
      )
      ..close();

    canvas.drawPath(
      diamond,
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant IslamicGeometryPainter oldDelegate,
  ) {
    return oldDelegate.isDark != isDark;
  }
}
