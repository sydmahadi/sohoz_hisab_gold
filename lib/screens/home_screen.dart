import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'money_manager_screen.dart';
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
      builder: (context, themeMode, _) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          body: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: IslamicBackgroundPainter(
                    color: AppTheme.gold.withValues(alpha: 0.055),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // HEADER
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        14,
                        12,
                        14,
                        4,
                      ),
                      child: Row(
                        children: [
                          const Spacer(),

                          Column(
                            children: [
                              Text(
                                'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppTheme.goldLight,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                  letterSpacing: 0.2,
                                ),
                              ),

                              const SizedBox(height: 7),

                              Text(
                                'সহজ হিসাব গোল্ড',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 27,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                'প্রয়োজনীয় সব হিসাব ও ইউটিলিটি এক জায়গায়',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          // THEME BUTTON
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.gold.withValues(
                                  alpha: 0.40,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: AppTheme.isDark ? 0.20 : 0.06,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 20,
                              onPressed: () {
                                AppTheme.toggleTheme();
                              },
                              icon: Icon(
                                AppTheme.isDark
                                    ? Icons.light_mode_rounded
                                    : Icons.dark_mode_rounded,
                                color: AppTheme.gold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // DECORATIVE DIVIDER
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 35,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppTheme.gold.withValues(
                                alpha: 0.22,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            child: Icon(
                              Icons.diamond_outlined,
                              size: 13,
                              color: AppTheme.gold.withValues(
                                alpha: 0.70,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppTheme.gold.withValues(
                                alpha: 0.22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // BUTTON GRID
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(
                            12,
                            18,
                            12,
                            12,
                          ),
                          child: GridView.count(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.92,
                            children: [
                              // 1 — মানি ম্যানেজার
                              _MenuCard(
                                icon:
                                    Icons.account_balance_wallet_rounded,
                                title: 'মানি ম্যানেজার',
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

                              // 2 — নোট
                              _MenuCard(
                                icon: Icons.note_alt_rounded,
                                title: 'নোট',
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

                              // 3 — ক্যালকুলেটর
                              _MenuCard(
                                icon: Icons.calculate_rounded,
                                title: 'ক্যালকুলেটর',
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

                              // 4 — ক্যালেন্ডার
                              _MenuCard(
                                icon: Icons.calendar_month_rounded,
                                title: 'ক্যালেন্ডার',
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

                              // 5 — তারিখ হিসাব
                              _MenuCard(
                                icon: Icons.event_available_rounded,
                                title: 'তারিখ হিসাব',
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

                              // 6 — সময় যোগ
                              _MenuCard(
                                icon: Icons.access_time_filled_rounded,
                                title: 'সময় যোগ',
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

                              // 7 — দৈনিক গড়
                              _MenuCard(
                                icon: Icons.speed_rounded,
                                title: 'দৈনিক গড়',
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

                              // 8 — মাসিক গড়
                              _MenuCard(
                                icon: Icons.date_range_rounded,
                                title: 'মাসিক গড়',
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

                              // 9 — ব্রাউজার
                              _MenuCard(
                                icon: Icons.language_rounded,
                                title: 'ব্রাউজার',
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

                              // 10 — অ্যাপ সম্পর্কে
                              _MenuCard(
                                icon: Icons.info_outline_rounded,
                                title: 'অ্যাপ সম্পর্কে',
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
}

// ═══════════════════════════════════════════════════════════════
// PREMIUM MENU CARD
// ═══════════════════════════════════════════════════════════════

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool dark = AppTheme.isDark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: AppTheme.gold.withValues(
          alpha: 0.12,
        ),
        highlightColor: AppTheme.gold.withValues(
          alpha: 0.05,
        ),
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppTheme.gold.withValues(
                alpha: dark ? 0.40 : 0.28,
              ),
              width: 0.9,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: dark ? 0.30 : 0.07,
                ),
                blurRadius: dark ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 9,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: dark
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.green,
                              AppTheme.darkGreen,
                            ],
                          )
                        : null,
                    color: dark
                        ? null
                        : AppTheme.darkGreen.withValues(
                            alpha: 0.10,
                          ),
                    border: Border.all(
                      color: AppTheme.gold.withValues(
                        alpha: dark ? 0.70 : 0.40,
                      ),
                      width: 1.1,
                    ),
                    boxShadow: dark
                        ? [
                            BoxShadow(
                              color: AppTheme.gold.withValues(
                                alpha: 0.13,
                              ),
                              blurRadius: 9,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: dark
                            ? AppTheme.cardLightDark
                            : AppTheme.darkGreen,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.gold.withValues(
                            alpha: dark ? 0.60 : 0.45,
                          ),
                          width: 0.8,
                        ),
                        boxShadow: dark
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: 0.20,
                                  ),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: dark
                            ? AppTheme.goldLight
                            : AppTheme.gold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
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

// ═══════════════════════════════════════════════════════════════
// ISLAMIC GEOMETRIC BACKGROUND
// ═══════════════════════════════════════════════════════════════

class IslamicBackgroundPainter extends CustomPainter {
  final Color color;

  IslamicBackgroundPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    const double spacing = 82;

    for (
      double x = -spacing;
      x < size.width + spacing;
      x += spacing
    ) {
      for (
        double y = -spacing;
        y < size.height + spacing;
        y += spacing
      ) {
        _drawPattern(
          canvas,
          Offset(x, y),
          35,
          paint,
        );
      }
    }

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.gold.withValues(alpha: 0.035),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width / 2,
            size.height / 2,
          ),
          radius: size.width * 0.65,
        ),
      );

    canvas.drawCircle(
      Offset(
        size.width / 2,
        size.height / 2,
      ),
      size.width * 0.65,
      glowPaint,
    );
  }

  void _drawPattern(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    final path = Path();

    for (int i = 0; i <= 8; i++) {
      final angle =
          (math.pi * 2 / 8) * i + math.pi / 8;

      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
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

    canvas.drawPath(
      path,
      paint,
    );

    final inner = Path();

    for (int i = 0; i <= 4; i++) {
      final angle =
          (math.pi * 2 / 4) * i + math.pi / 4;

      final point = Offset(
        center.dx +
            math.cos(angle) *
                radius *
                0.58,
        center.dy +
            math.sin(angle) *
                radius *
                0.58,
      );

      if (i == 0) {
        inner.moveTo(
          point.dx,
          point.dy,
        );
      } else {
        inner.lineTo(
          point.dx,
          point.dy,
        );
      }
    }

    canvas.drawPath(
      inner,
      paint,
    );

    for (int i = 0; i < 8; i++) {
      final angle =
          (math.pi * 2 / 8) * i + math.pi / 8;

      final outerPoint = Offset(
        center.dx +
            math.cos(angle) *
                radius,
        center.dy +
            math.sin(angle) *
                radius,
      );

      final innerPoint = Offset(
        center.dx +
            math.cos(angle) *
                radius *
                0.58,
        center.dy +
            math.sin(angle) *
                radius *
                0.58,
      );

      canvas.drawLine(
        outerPoint,
        innerPoint,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant IslamicBackgroundPainter oldDelegate,
  ) {
    return oldDelegate.color != color;
  }
}
