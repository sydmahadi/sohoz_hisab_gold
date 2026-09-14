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
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
        child: Column(
          children: [
            // =====================================================
            // APP HEADER
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
                    'সহজ হিসাব',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'প্রয়োজনীয় হিসাব ও দৈনন্দিন কাজের সহজ সমাধান',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // =====================================================
            // ABOUT APP
            // =====================================================

            _InfoCard(
              icon: Icons.info_outline_rounded,
              title: 'অ্যাপটি সম্পর্কে',
              child: Text(
                'সহজ হিসাব গোল্ড একটি সহজ, সুন্দর ও ব্যবহারবান্ধব '
                'দৈনন্দিন হিসাব ও প্রয়োজনীয় ইউটিলিটি অ্যাপ। '
                'আয়-ব্যয়ের হিসাব রাখা থেকে শুরু করে বিভিন্ন ধরনের '
                'সময়, তারিখ ও সাধারণ হিসাব করার সুবিধা এখানে একসাথে '
                'রাখা হয়েছে।',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 14,
                  height: 1.75,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // =====================================================
            // MONEY MANAGER
            // =====================================================

            _InfoCard(
              icon: Icons.account_balance_wallet_outlined,
              title: 'আর্থিক হিসাব ব্যবস্থাপনা',
              child: Column(
                children: [
                  _FeatureRow(
                    icon: Icons.add_circle_outline_rounded,
                    title: 'আয়',
                    description:
                        'বেতন, ব্যবসা, উপহার বা অন্যান্য উৎস থেকে পাওয়া '
                        'টাকার হিসাব সংরক্ষণ করা যাবে।',
                  ),
                  _FeatureRow(
                    icon: Icons.remove_circle_outline_rounded,
                    title: 'ব্যয়',
                    description:
                        'খাবার, বাজার, যাতায়াত, বিলসহ বিভিন্ন খাতে '
                        'কত টাকা খরচ হয়েছে তা সংরক্ষণ করা যাবে।',
                  ),
                  _FeatureRow(
                    icon: Icons.swap_horiz_rounded,
                    title: 'টাকা স্থানান্তর',
                    description:
                        'একটি Account থেকে অন্য Account-এ টাকা '
                        'স্থানান্তরের হিসাব রাখা যাবে।',
                  ),
                  _FeatureRow(
                    icon: Icons.account_balance_outlined,
                    title: 'Account',
                    description:
                        'Cash, Bank বা অন্যান্য অর্থের হিসাব আলাদাভাবে '
                        'পরিচালনা করা যাবে।',
                  ),
                  _FeatureRow(
                    icon: Icons.category_outlined,
                    title: 'হিসাবের খাত',
                    description:
                        'আয় ও ব্যয়ের বিভিন্ন খাত ব্যবহার করা যাবে এবং '
                        'প্রয়োজন অনুযায়ী নতুন খাত যোগ করা যাবে।',
                  ),
                  _FeatureRow(
                    icon: Icons.bar_chart_rounded,
                    title: 'পরিসংখ্যান',
                    description:
                        'আয় ও ব্যয়ের তথ্য বিভিন্নভাবে বিশ্লেষণ করে '
                        'কোন খাতে কত টাকা ব্যয় হয়েছে তা দেখা যাবে।',
                  ),
                  _FeatureRow(
                    icon: Icons.description_outlined,
                    title: 'রিপোর্ট',
                    description:
                        'নির্দিষ্ট সময়ের আর্থিক হিসাব সংক্ষেপে '
                        'পর্যালোচনা করা যাবে।',
                  ),
                  _FeatureRow(
                    icon: Icons.history_rounded,
                    title: 'পুরোনো হিসাব',
                    description:
                        'আগের সংরক্ষিত লেনদেনগুলো দেখা এবং প্রয়োজন হলে '
                        'সেগুলো মুছে ফেলা যাবে।',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // =====================================================
            // CALCULATOR
            // =====================================================

            _InfoCard(
              icon: Icons.calculate_outlined,
              title: 'ক্যালকুলেটর',
              child: Text(
                'দৈনন্দিন প্রয়োজনীয় সাধারণ গাণিতিক হিসাব যেমন যোগ, '
                'বিয়োগ, গুণ ও ভাগ দ্রুত করা যাবে। পূর্বের হিসাব '
                'দেখার সুবিধাও ব্যবহার করা যাবে।',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 14,
                  height: 1.7,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // =====================================================
            // DATE CALCULATOR
            // =====================================================

            _InfoCard(
              icon: Icons.date_range_outlined,
              title: 'তারিখ হিসাব',
              child: Text(
                'একটি নির্দিষ্ট তারিখ নির্বাচন করে সেই তারিখ থেকে '
                'কত দিন আগে বা পরে কোনো তারিখ হবে তা সহজে হিসাব '
                'করা যাবে।',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 14,
                  height: 1.7,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // =====================================================
            // TIME CALCULATOR
            // =====================================================

            _InfoCard(
              icon: Icons.access_time_outlined,
              title: 'সময় হিসাব',
              child: Text(
                'ঘণ্টা ও মিনিটের সময় যোগ করে মোট সময় বের করা যাবে। '
                'যেমন 1.30 + 2.50 দিলে মোট 4 ঘণ্টা 20 মিনিটের '
                'সময় হিসাব করা যাবে।',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 14,
                  height: 1.7,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // =====================================================
            // DAILY AVERAGE
            // =====================================================

            _InfoCard(
              icon: Icons.today_outlined,
              title: 'দৈনিক গড়',
              child: Text(
                'একাধিক দিনের তথ্যের ভিত্তিতে দৈনিক গড় হিসাব করা যাবে। '
                'প্রয়োজন অনুযায়ী সংখ্যা বা সময়ের গড় নির্ণয় করা যাবে।',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 14,
                  height: 1.7,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // =====================================================
            // MONTHLY AVERAGE
            // =====================================================

            _InfoCard(
              icon: Icons.calendar_view_month_outlined,
              title: 'মাসিক গড়',
              child: Text(
                'একটি মাসে নির্দিষ্ট সংখ্যক দিনের তথ্য ব্যবহার করে '
                'মাসিক গড় হিসাব করা যাবে। সংখ্যা ও সময়—দুই ধরনের '
                'গড় হিসাব করার সুবিধা রয়েছে।',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 14,
                  height: 1.7,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // =====================================================
            // NOTE
            // =====================================================

            _InfoCard(
              icon: Icons.note_alt_outlined,
              title: 'নোট',
              child: Text(
                'গুরুত্বপূর্ণ তথ্য, মনে রাখার বিষয় বা প্রয়োজনীয় ছোট '
                'নোট অ্যাপের মধ্যে সংরক্ষণ করে রাখা যাবে।',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 14,
                  height: 1.7,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // =====================================================
            // CALENDAR
            // =====================================================

            _InfoCard(
              icon: Icons.calendar_month_outlined,
              title: 'ক্যালেন্ডার',
              child: Text(
                'ক্যালেন্ডারের মাধ্যমে হিজরি,বাংলা ও ইংরেজী তারিখ দেখা এবং প্রয়োজনীয় '
                'তারিখ নির্বাচন করা যাবে। ইভেন্ট শিডিউল করে রাখা যাবে।',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 14,
                  height: 1.7,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // =====================================================
            // BROWSER
            // =====================================================

            _InfoCard(
              icon: Icons.language_outlined,
              title: 'ব্রাউজার',
              child: Text(
                'অ্যাপ থেকে বের না হয়েই নির্ধারিত ওয়েবপেজ বা প্রয়োজনীয় '
                'অনলাইন তথ্য দেখা যাবে। ইন্টারনেট সংযোগ প্রয়োজন হবে।',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 14,
                  height: 1.7,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // =====================================================
            // DEVELOPER
            // =====================================================

            _InfoCard(
              icon: Icons.person_outline_rounded,
              title: 'ডেভেলপার',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sayeed Mahadi',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.email_outlined,
                        color: AppTheme.gold,
                        size: 19,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'mahadisayeed@gmail.com',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
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
                    'ভার্সন',
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

            const SizedBox(height: 10),
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

              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
  final String title;
  final String description;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.gold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppTheme.gold,
              size: 18,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  description,
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12.5,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
