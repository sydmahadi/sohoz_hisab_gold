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
import 'about_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, themeMode, child) {
        final isDark = themeMode == ThemeMode.dark;

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: Stack(
            children: [
              // =================================================
              // ISLAMIC BACKGROUND
              // =================================================

              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: IslamicHomePainter(
                      isDark: isDark,
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(
                      context,
                      themeMode,
                    ),

                    const SizedBox(height: 5),

                    // =================================================
                    // MENU
                    // =================================================

                    Expanded(
                      child: GridView.count(
                        padding: const EdgeInsets.fromLTRB(
                          12,
                          8,
                          12,
                          10,
                        ),
                        crossAxisCount: 3,
                        crossAxisSpacing: 9,
                        mainAxisSpacing: 9,
                        childAspectRatio: 0.95,
                        children: [
                          // 1
                          _MenuCard(
                            title: 'মানি ম্যানেজার',
                            icon: Icons.account_balance_wallet_rounded,
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

                          // 2
                          _MenuCard(
                            title: 'এন্ট্রি করুন',
                            icon: Icons.edit_note_rounded,
                            color: AppTheme.green,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const EntryScreen(),
                                ),
                              );
                            },
                          ),

                          // 3
                          _MenuCard(
                            title: 'তথ্য দেখুন',
                            icon: Icons.info_rounded,
                            color: AppTheme.gold,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const InfoScreen(),
                                ),
                              );
                            },
                          ),

                          // 4
                          _MenuCard(
                            title: 'নোট',
                            icon: Icons.note_alt_rounded,
                            color: AppTheme.green,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const NoteScreen(),
                                ),
                              );
                            },
                          ),

                          // 5
                          _MenuCard(
                            title: 'ক্যালকুলেটর',
                            icon: Icons.calculate_rounded,
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

                          // 6
                          _MenuCard(
                            title: 'ক্যালেন্ডার',
                            icon: Icons.calendar_month_rounded,
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

                          // 7
                          _MenuCard(
                            title: 'তারিখ হিসাব',
                            icon: Icons.date_range_rounded,
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

                          // 8
                          _MenuCard(
                            title: 'সময় যোগ',
                            icon: Icons.access_time_filled_rounded,
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

                          // 9
                          _MenuCard(
                            title: 'দৈনিক গড়',
                            icon: Icons.today_rounded,
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

                          // 10
                          _MenuCard(
                            title: 'মাসিক গড়',
                            icon: Icons.calendar_view_month_rounded,
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

                          // 11
                          _MenuCard(
                            title: 'ব্রাউজার',
                            icon: Icons.language_rounded,
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

                          // 12
                          _MenuCard(
                            title: 'অ্যাপ সম্পর্কে',
                            icon: Icons.auto_awesome_rounded,
                            color: AppTheme.gold,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const AboutScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // =================================================
                    // FOOTER
                    // =================================================

                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        12,
                        2,
                        12,
                        9,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 65,
                            height: 1,
                            color: AppTheme.gold.withValues(
                              alpha: 0.45,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Developed by Talpatar Sepai',
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
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

  // =============================================================
  // PREMIUM HEADER
  // =============================================================

  Widget _buildHeader(
    BuildContext context,
    ThemeMode themeMode,
  ) {
    final isDark = themeMode == ThemeMode.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        12,
        10,
        12,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          14,
          12,
          6,
          12,
        ),
        decoration: BoxDecoration(
          color: AppTheme.cardColor.withValues(
            alpha: isDark ? 0.94 : 0.97,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppTheme.gold.withValues(
              alpha: 0.38,
            ),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: isDark ? 0.20 : 0.07,
              ),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // =================================================
            // ISLAMIC EMBLEM
            // =================================================

            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.gold.withValues(
                  alpha: 0.08,
                ),
                border: Border.all(
                  color: AppTheme.gold.withValues(
                    alpha: 0.50,
                  ),
                  width: 1,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: math.pi / 4,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.gold.withValues(
                            alpha: 0.75,
                          ),
                          width: 1.1,
                        ),
                      ),
                    ),
                  ),
                  Transform.rotate(
                    angle: -math.pi / 4,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.gold.withValues(
                            alpha: 0.35,
                          ),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppTheme.gold,
                    size: 21,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 11),

            // =================================================
            // TITLE
            // =================================================

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                    style: TextStyle(
                      color: AppTheme.goldLight,
                      fontSize: 11.5,
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
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    'প্রয়োজনীয় সব হিসাব এক জায়গায়',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 9.5,
                    ),
                  ),
                ],
              ),
            ),

            // =================================================
            // THEME BUTTON
            // =================================================

            Container(
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(
                  alpha: 0.08,
                ),
                borderRadius:
                    BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.gold.withValues(
                    alpha: 0.15,
                  ),
                ),
              ),
              child: IconButton(
                tooltip: 'থিম পরিবর্তন',
                onPressed: () {
                  AppTheme.themeNotifier.value =
                      isDark
                          ? ThemeMode.light
                          : ThemeMode.dark;
                },
                icon: AnimatedSwitcher(
                  duration:
                      const Duration(milliseconds: 250),
                  child: Icon(
                    isDark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    key: ValueKey(isDark),
                    color: AppTheme.gold,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// MENU CARD
// =================================================================

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
        borderRadius:
            BorderRadius.circular(18),
        splashColor:
            color.withValues(alpha: 0.12),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor.withValues(
              alpha: AppTheme.isDark
                  ? 0.91
                  : 0.97,
            ),
            borderRadius:
                BorderRadius.circular(18),
            border: Border.all(
              color: color.withValues(
                alpha: 0.28,
              ),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: AppTheme.isDark
                      ? 0.14
                      : 0.045,
                ),
                blurRadius: 9,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              // =================================================
              // CORNER GEOMETRY
              // =================================================

              Positioned(
                top: -10,
                right: -10,
                child: Transform.rotate(
                  angle: math.pi / 4,
                  child: Container(
                    width: 31,
                    height: 31,
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

              Positioned(
                bottom: -10,
                left: -10,
                child: Transform.rotate(
                  angle: math.pi / 4,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: color.withValues(
                          alpha: 0.07,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // =================================================
              // ICON + TITLE
              // =================================================

              Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      // ICON FRAME
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withValues(
                            alpha: 0.09,
                          ),
                          border: Border.all(
                            color: color.withValues(
                              alpha: 0.35,
                            ),
                            width: 1,
                          ),
                        ),
                        child: Stack(
                          alignment:
                              Alignment.center,
                          children: [
                            Transform.rotate(
                              angle: math.pi / 4,
                              child: Container(
                                width: 25,
                                height: 25,
                                decoration:
                                    BoxDecoration(
                                  border: Border.all(
                                    color: color
                                        .withValues(
                                      alpha: 0.16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Icon(
                              icon,
                              color: color,
                              size: 23,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 7),

                      Text(
                        title,
                        textAlign:
                            TextAlign.center,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              AppTheme.textPrimary,
                          fontSize: 11.5,
                          height: 1.15,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =================================================================
// ISLAMIC GEOMETRIC BACKGROUND
// =================================================================

class IslamicHomePainter
    extends CustomPainter {
  final bool isDark;

  IslamicHomePainter({
    required this.isDark,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    // ===========================================================
    // BASE GLOW
    // ===========================================================

    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(
          -0.7,
          -0.8,
        ),
        radius: 1.2,
        colors: [
          AppTheme.gold.withValues(
            alpha: isDark ? 0.055 : 0.035,
          ),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
      );

    canvas.drawRect(
      Offset.zero & size,
      glowPaint,
    );

    // ===========================================================
    // ISLAMIC STAR PATTERN
    // ===========================================================

    final starPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75
      ..color = AppTheme.gold.withValues(
        alpha: isDark ? 0.075 : 0.085,
      );

    const spacing = 78.0;

    for (double x = -spacing;
        x < size.width + spacing;
        x += spacing) {
      for (double y = -spacing;
          y < size.height + spacing;
          y += spacing) {
        _drawStar(
          canvas,
          Offset(x, y),
          30,
          starPaint,
        );
      }
    }

    // ===========================================================
    // DIAGONAL ARABESQUE LINES
    // ===========================================================

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = AppTheme.gold.withValues(
        alpha: isDark ? 0.035 : 0.045,
      );

    for (double i = -size.height;
        i < size.width + size.height;
        i += 110) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(
          i + size.height,
          size.height,
        ),
        linePaint,
      );

      canvas.drawLine(
        Offset(i, size.height),
        Offset(
          i + size.height,
          0,
        ),
        linePaint,
      );
    }

    // ===========================================================
    // TOP DECORATIVE BORDER
    // ===========================================================

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppTheme.gold.withValues(
        alpha: isDark ? 0.12 : 0.10,
      );

    const borderY = 4.0;

    canvas.drawLine(
      Offset(0, borderY),
      Offset(size.width, borderY),
      borderPaint,
    );

    for (double x = 15;
        x < size.width;
        x += 28) {
      canvas.drawCircle(
        Offset(x, borderY),
        1.5,
        borderPaint,
      );
    }
  }

  void _drawStar(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    const points = 8;

    final path = Path();

    for (int i = 0;
        i < points * 2;
        i++) {
      final angle =
          -math.pi / 2 +
          (math.pi / points) * i;

      final r = i.isEven
          ? radius
          : radius * 0.46;

      final point = Offset(
        center.dx +
            math.cos(angle) * r,
        center.dy +
            math.sin(angle) * r,
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

    // Inner octagon
    final innerPath = Path();

    for (int i = 0; i < points; i++) {
      final angle =
          -math.pi / 2 +
          (2 * math.pi / points) * i;

      final point = Offset(
        center.dx +
            math.cos(angle) *
                radius *
                0.38,
        center.dy +
            math.sin(angle) *
                radius *
                0.38,
      );

      if (i == 0) {
        innerPath.moveTo(
          point.dx,
          point.dy,
        );
      } else {
        innerPath.lineTo(
          point.dx,
          point.dy,
        );
      }
    }

    innerPath.close();

    canvas.drawPath(
      innerPath,
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant IslamicHomePainter oldDelegate,
  ) {
    return oldDelegate.isDark !=
        isDark;
  }
}
