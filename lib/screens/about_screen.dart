import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('অ্যাপ সম্পর্কে'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        child: Column(
          children: [
            // =====================================================
            // APP LOGO / HEADER
            // =====================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: AppTheme.gold.withValues(alpha: 0.38),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: AppTheme.isDark ? 0.18 : 0.07,
                    ),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.gold.withValues(alpha: 0.10),
                      border: Border.all(
                        color: AppTheme.gold.withValues(alpha: 0.55),
                        width: 1.3,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.rotate(
                          angle: 0.785398,
                          child: Container(
                            width: 42,
                            height: 42,
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
                        const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppTheme.gold,
                          size: 30,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.goldLight,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'সহজ হিসাব গোল্ড',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'প্রয়োজনীয় সব হিসাব এক জায়গায়',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // =====================================================
            // ABOUT
            // =====================================================

            _InfoCard(
              icon: Icons.info_outline_rounded,
              title: 'অ্যাপটি সম্পর্কে',
              child: Text(
                'সহজ হিসাব গোল্ড একটি সহজ, সুন্দর ও ব্যবহারবান্ধব '
                'হিসাব ও প্রয়োজনীয় ইউটিলিটি অ্যাপ। দৈনন্দিন জীবনের '
                'বিভিন্ন ধরনের হিসাব ও প্রয়োজনীয় কিছু সুবিধা '
                'এক জায়গায় ব্যবহার করার জন্য অ্যাপটি তৈরি করা হয়েছে।',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 14,
                  height: 1.7,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // =====================================================
            // FEATURES
            // =====================================================

            _InfoCard(
              icon: Icons.apps_rounded,
              title: 'প্রধান সুবিধাসমূহ',
              child: Column(
                children: [
                  _FeatureRow(
                    icon: Icons.account_balance_wallet_outlined,
                    text: 'মানি ম্যানেজার',
                  ),
                  _FeatureRow(
                    icon: Icons.edit_note_outlined,
                    text: 'এন্ট্রি ও তথ্য ব্যবস্থাপনা',
                  ),
                  _FeatureRow(
                    icon: Icons.note_alt_outlined,
                    text: 'নোট সংরক্ষণ',
                  ),
                  _FeatureRow(
                    icon: Icons.calculate_outlined,
                    text: 'ক্যালকুলেটর',
                  ),
                  _FeatureRow(
                    icon: Icons.calendar_month_outlined,
                    text: 'ক্যালেন্ডার',
                  ),
                  _FeatureRow(
                    icon: Icons.date_range_outlined,
                    text: 'তারিখ হিসাব',
                  ),
                  _FeatureRow(
                    icon: Icons.access_time_outlined,
                    text: 'সময় যোগ',
                  ),
                  _FeatureRow(
                    icon: Icons.today_outlined,
                    text: 'দৈনিক গড় হিসাব',
                  ),
                  _FeatureRow(
                    icon: Icons.calendar_view_month_outlined,
                    text: 'মাসিক গড় হিসাব',
                  ),
                  _FeatureRow(
                    icon: Icons.language_outlined,
                    text: 'ব্রাউজার',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // =====================================================
            // DEVELOPER
            // =====================================================

            _InfoCard(
              icon: Icons.code_rounded,
              title: 'ডেভেলপার',
              child: Column(
                children: [
                  Text(
                    'Talpatar Sepai',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Developed by Talpatar Sepai',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // =====================================================
            // VERSION
            // =====================================================

            _InfoCard(
              icon: Icons.verified_outlined,
              title: 'অ্যাপের তথ্য',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Version',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '1.0.0',
                    style: TextStyle(
                      color: AppTheme.goldLight,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =====================================================
            // FOOTER
            // =====================================================

            Container(
              width: 70,
              height: 1,
              color: AppTheme.gold.withValues(alpha: 0.45),
            ),

            const SizedBox(height: 8),

            Text(
              'Developed by Talpatar Sepai',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// INFO CARD
// ===============================================================

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.gold.withValues(alpha: 0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: AppTheme.isDark ? 0.12 : 0.05,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.gold.withValues(alpha: 0.20),
                  ),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.gold,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }
}

// ===============================================================
// FEATURE ROW
// ===============================================================

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.gold,
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
