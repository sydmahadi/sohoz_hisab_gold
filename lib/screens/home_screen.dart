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
        final bool dark = AppTheme.isDark;

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: Stack(
            children: [
              // Islamic geometric background
              Positioned.fill(
                child: CustomPaint(
                  painter: IslamicBackgroundPainter(
                    patternColor: AppTheme.gold.withValues(
                      alpha: dark ? 0.065 : 0.045,
                    ),
                  ),
                ),
              ),

              // Soft emerald glow
              Positioned(
                top: -120,
                left: -100,
                child: IgnorePointer(
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.darkGreen.withValues(
                            alpha: dark ? 0.30 : 0.10,
                          ),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: -140,
                right: -100,
                child: IgnorePointer(
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.green.withValues(
                            alpha: dark ? 0.18 : 0.07,
                          ),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(context, dark),

                    const SizedBox(height: 12),

                    _buildDivider(dark),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          14,
                          18,
                          14,
                          24,
                        ),
                        child: Column(
                          children: [
                            _buildMenuGrid(context, dark),
                            const SizedBox(height: 14),
                            _buildAboutCard(context, dark),
                          ],
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

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------

  Widget _buildHeader(
    BuildContext context,
    bool dark,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        14,
        10,
        14,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 44),

          Expanded(
            child: Column(
              children: [
                // Bismillah ornamental area
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.darkGreen.withValues(
                      alpha: dark ? 0.34 : 0.08,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppTheme.gold.withValues(
                        alpha: dark ? 0.42 : 0.28,
                      ),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: dark
                          ? AppTheme.goldLight
                          : AppTheme.darkGreen,
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      height: 1.45,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Main title
                Text(
                  'সহজ হিসাব',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 29,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'প্রয়োজনীয় সব হিসাব ও ইউটিলিটি এক জায়গায়',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12.2,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 4),

          // Theme button
          _ThemeButton(
            onTap: () {
              AppTheme.toggleTheme();
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DIVIDER
  // ---------------------------------------------------------------------------

  Widget _buildDivider(bool dark) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 32,
      ),
      child: Row(
        children: [
          Expanded(
            child: _dividerLine(dark),
          ),

          Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.symmetric(
              horizontal: 9,
            ),
            decoration: BoxDecoration(
              color: AppTheme.darkGreen.withValues(
                alpha: dark ? 0.45 : 0.08,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.gold.withValues(
                  alpha: 0.45,
                ),
              ),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 14,
              color: AppTheme.gold,
            ),
          ),

          Expanded(
            child: _dividerLine(dark),
          ),
        ],
      ),
    );
  }

  Widget _dividerLine(bool dark) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppTheme.gold.withValues(
              alpha: dark ? 0.40 : 0.25,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MENU GRID
  // ---------------------------------------------------------------------------

  Widget _buildMenuGrid(
    BuildContext context,
    bool dark,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 11,
      childAspectRatio: 0.84,
      children: [
        _MenuCard(
          icon: Icons.account_balance_wallet_rounded,
          title: 'মানি ম্যানেজার',
          number: '01',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MoneyManagerScreen(),
              ),
            );
          },
        ),

        _MenuCard(
          icon: Icons.note_alt_rounded,
          title: 'নোট',
          number: '02',
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
          icon: Icons.calculate_rounded,
          title: 'ক্যালকুলেটর',
          number: '03',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CalculatorScreen(),
              ),
            );
          },
        ),

        _MenuCard(
          icon: Icons.calendar_month_rounded,
          title: 'ক্যালেন্ডার',
          number: '04',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CalendarScreen(),
              ),
            );
          },
        ),

        _MenuCard(
          icon: Icons.event_available_rounded,
          title: 'তারিখ হিসাব',
          number: '05',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DateCalculatorScreen(),
              ),
            );
          },
        ),

        _MenuCard(
          icon: Icons.access_time_filled_rounded,
          title: 'সময় যোগ',
          number: '06',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TimeSumScreen(),
              ),
            );
          },
        ),

        _MenuCard(
          icon: Icons.speed_rounded,
          title: 'দৈনিক গড়',
          number: '07',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DailyAverageScreen(),
              ),
            );
          },
        ),

        _MenuCard(
          icon: Icons.date_range_rounded,
          title: 'মাসিক গড়',
          number: '08',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MonthlyAverageScreen(),
              ),
            );
          },
        ),

        _MenuCard(
          icon: Icons.language_rounded,
          title: 'ব্রাউজার',
          number: '09',
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
    );
  }

  // ---------------------------------------------------------------------------
  // ABOUT CARD
  // ---------------------------------------------------------------------------

  Widget _buildAboutCard(
    BuildContext context,
    bool dark,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AboutScreen(),
            ),
          );
        },
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppTheme.darkGreen.withValues(
                  alpha: dark ? 0.90 : 0.12,
                ),
                AppTheme.green.withValues(
                  alpha: dark ? 0.55 : 0.07,
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppTheme.gold.withValues(
                alpha: dark ? 0.48 : 0.32,
              ),
              width: 0.9,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: dark ? 0.25 : 0.06,
                ),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.cardColor.withValues(
                    alpha: dark ? 0.65 : 0.85,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.gold.withValues(
                      alpha: 0.55,
                    ),
                  ),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.goldLight,
                  size: 24,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'অ্যাপ সম্পর্কে',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'সহজ হিসাব সম্পর্কে আরও জানুন',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppTheme.gold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// THEME BUTTON
// =============================================================================

class _ThemeButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ThemeButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool dark = AppTheme.isDark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.gold.withValues(
                alpha: dark ? 0.50 : 0.32,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: dark ? 0.22 : 0.06,
                ),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            dark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            color: AppTheme.gold,
            size: 21,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// MENU CARD
// =============================================================================

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String number;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.number,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool dark = AppTheme.isDark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        splashColor: AppTheme.gold.withValues(
          alpha: 0.12,
        ),
        highlightColor: AppTheme.gold.withValues(
          alpha: 0.045,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dark
                  ? [
                      AppTheme.cardColor,
                      AppTheme.darkGreen.withValues(
                        alpha: 0.55,
                      ),
                    ]
                  : [
                      AppTheme.cardColor,
                      AppTheme.cardLight.withValues(
                        alpha: 0.90,
                      ),
                    ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppTheme.gold.withValues(
                alpha: dark ? 0.42 : 0.28,
              ),
              width: 0.85,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: dark ? 0.28 : 0.07,
                ),
                blurRadius: dark ? 12 : 8,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative corner
              Positioned(
                top: -16,
                right: -16,
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.gold.withValues(
                        alpha: 0.10,
                      ),
                    ),
                  ),
                ),
              ),

              // Small number
              Positioned(
                top: 8,
                right: 10,
                child: Text(
                  number,
                  style: TextStyle(
                    color: AppTheme.gold.withValues(
                      alpha: 0.55,
                    ),
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),

              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Outer geometric icon frame
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: AppTheme.darkGreen.withValues(
                            alpha: dark ? 0.42 : 0.08,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppTheme.gold.withValues(
                              alpha: dark ? 0.62 : 0.38,
                            ),
                            width: 1,
                          ),
                          boxShadow: dark
                              ? [
                                  BoxShadow(
                                    color: AppTheme.gold.withValues(
                                      alpha: 0.08,
                                    ),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: dark
                                  ? AppTheme.green.withValues(
                                      alpha: 0.70,
                                    )
                                  : AppTheme.darkGreen,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppTheme.gold.withValues(
                                  alpha: 0.45,
                                ),
                                width: 0.8,
                              ),
                            ),
                            child: Icon(
                              icon,
                              size: 22,
                              color: dark
                                  ? AppTheme.goldLight
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 11.3,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
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

// =============================================================================
// ISLAMIC GEOMETRIC BACKGROUND
// =============================================================================

class IslamicBackgroundPainter extends CustomPainter {
  final Color patternColor;

  IslamicBackgroundPainter({
    required this.patternColor,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color = patternColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.65;

    const double spacing = 88;

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
        _drawIslamicStar(
          canvas,
          Offset(x, y),
          34,
          paint,
        );
      }
    }

    // Soft center glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.gold.withValues(alpha: 0.025),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width / 2,
            size.height * 0.42,
          ),
          radius: size.width * 0.75,
        ),
      );

    canvas.drawCircle(
      Offset(
        size.width / 2,
        size.height * 0.42,
      ),
      size.width * 0.75,
      glowPaint,
    );
  }

  void _drawIslamicStar(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    final outer = Path();
    final inner = Path();

    // 8-point star
    for (int i = 0; i <= 16; i++) {
      final angle =
          -math.pi / 2 + (math.pi * 2 / 16) * i;

      final r = i.isEven
          ? radius
          : radius * 0.47;

      final point = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );

      if (i == 0) {
        outer.moveTo(
          point.dx,
          point.dy,
        );
      } else {
        outer.lineTo(
          point.dx,
          point.dy,
        );
      }
    }

    canvas.drawPath(
      outer,
      paint,
    );

    // Inner octagon
    for (int i = 0; i <= 8; i++) {
      final angle =
          -math.pi / 8 + (math.pi * 2 / 8) * i;

      final point = Offset(
        center.dx + math.cos(angle) * radius * 0.48,
        center.dy + math.sin(angle) * radius * 0.48,
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
  }

  @override
  bool shouldRepaint(
    covariant IslamicBackgroundPainter oldDelegate,
  ) {
    return oldDelegate.patternColor != patternColor;
  }
}
