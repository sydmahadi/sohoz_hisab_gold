import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class CalendarEvent {
  final String id;
  final DateTime date;
  final String title;
  final String time;
  final String note;

  CalendarEvent({
    required this.id,
    required this.date,
    required this.title,
    required this.time,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'time': time,
      'note': note,
    };
  }

  factory CalendarEvent.fromMap(Map<String, dynamic> map) {
    return CalendarEvent(
      id: map['id']?.toString() ?? '',
      date: DateTime.tryParse(
            map['date']?.toString() ?? '',
          ) ??
          DateTime.now(),
      title: map['title']?.toString() ?? '',
      time: map['time']?.toString() ?? '',
      note: map['note']?.toString() ?? '',
    );
  }
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();

  List<CalendarEvent> events = [];

  int hijriAdjustment = 0;

  DateTime displayedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );

  final PageController _pageController =
      PageController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ============================================================
  // STORAGE
  // ============================================================

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final savedEvents =
        prefs.getStringList('calendar_events') ?? [];

    final loadedEvents = <CalendarEvent>[];

    for (final item in savedEvents) {
      try {
        final parts = item.split('|||');

        if (parts.length >= 5) {
          loadedEvents.add(
            CalendarEvent(
              id: parts[0],
              date:
                  DateTime.tryParse(parts[1]) ??
                      DateTime.now(),
              title: parts[2],
              time: parts[3],
              note: parts[4],
            ),
          );
        }
      } catch (_) {}
    }

    setState(() {
      events = loadedEvents;

      hijriAdjustment =
          prefs.getInt('hijri_adjustment') ?? 0;
    });
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();

    final data = events.map((event) {
      return [
        event.id,
        event.date.toIso8601String(),
        event.title.replaceAll('|||', ' '),
        event.time.replaceAll('|||', ' '),
        event.note.replaceAll('|||', ' '),
      ].join('|||');
    }).toList();

    await prefs.setStringList(
      'calendar_events',
      data,
    );
  }

  Future<void> _saveHijriAdjustment() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      'hijri_adjustment',
      hijriAdjustment,
    );
  }

  // ============================================================
  // DATE HELPERS
  // ============================================================

  String monthName(int month) {
    const months = [
      'জানুয়ারি',
      'ফেব্রুয়ারি',
      'মার্চ',
      'এপ্রিল',
      'মে',
      'জুন',
      'জুলাই',
      'আগস্ট',
      'সেপ্টেম্বর',
      'অক্টোবর',
      'নভেম্বর',
      'ডিসেম্বর',
    ];

    return months[month - 1];
  }

  String monthNameEnglish(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }

  String weekdayBangla(int weekday) {
    const days = [
      'সোমবার',
      'মঙ্গলবার',
      'বুধবার',
      'বৃহস্পতিবার',
      'শুক্রবার',
      'শনিবার',
      'রবিবার',
    ];

    return days[weekday - 1];
  }

  String englishNumberToBangla(String value) {
    const en = '0123456789';
    const bn = '০১২৩৪৫৬৭৮৯';

    String result = '';

    for (final char in value.split('')) {
      final index = en.indexOf(char);

      if (index >= 0) {
        result += bn[index];
      } else {
        result += char;
      }
    }

    return result;
  }

  String bn(int number) {
    return englishNumberToBangla(
      number.toString(),
    );
  }

  String formatDate(DateTime date) {
    return '${date.day} ${monthName(date.month)} ${date.year}';
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  // ============================================================
  // HIJRI CALCULATION
  // ============================================================

  Map<String, int> hijriDate(DateTime date) {
    final adjustedDate = date.add(
      Duration(days: hijriAdjustment),
    );

    int jd;

    int y = adjustedDate.year;
    int m = adjustedDate.month;
    int d = adjustedDate.day;

    if (m <= 2) {
      y -= 1;
      m += 12;
    }

    final a = (y / 100).floor();
    final b =
        2 - a + (a / 4).floor();

    jd =
        (365.25 * (y + 4716)).floor() +
            (30.6001 * (m + 1)).floor() +
            d +
            b -
            1524;

    // Gregorian Julian Day -> Islamic Civil
    final l = jd - 1948440 + 10632;

    final n =
        ((l - 1) / 10631).floor();

    final l2 =
        l -
        10631 * n +
        354;

    final j =
        (((10985 - l2) / 5316).floor()) *
                ((50 * l2 / 17719).floor()) +
            ((l2 / 5670).floor()) *
                ((43 * l2 / 15238).floor());

    final l3 =
        l2 -
        ((30 - j) / 15).floor() *
            ((17719 * j) / 50).floor() -
        (j / 16).floor() *
            ((15238 * j) / 43).floor() +
        29;

    final month =
        ((24 * l3) / 709).floor();

    final day =
        l3 -
        ((709 * month) / 24).floor();

    final year =
        30 * n +
        j -
        30;

    return {
      'day': day,
      'month': month,
      'year': year,
    };
  }

  String hijriMonthName(int month) {
    const months = [
      'মুহররম',
      'সফর',
      'রবিউল আউয়াল',
      'রবিউস সানি',
      'জমাদিউল আউয়াল',
      'জমাদিউস সানি',
      'রজব',
      'শাবান',
      'রমজান',
      'শাওয়াল',
      'জিলকদ',
      'জিলহজ',
    ];

    if (month < 1 || month > 12) {
      return '';
    }

    return months[month - 1];
  }

  String hijriText(DateTime date) {
    final h = hijriDate(date);

    return '${bn(h['day']!)} '
        '${hijriMonthName(h['month']!)} '
        '${bn(h['year']!)}';
  }

  // ============================================================
  // BANGLA DATE
  // ============================================================

  String banglaDate(DateTime date) {
    /*
      বাংলাদেশের প্রচলিত বাংলা ক্যালেন্ডারের
      একটি ব্যবহারিক হিসাব।

      ১৪ এপ্রিল = ১ বৈশাখ
      এরপর মাসগুলোর দিন:
      বৈশাখ ৩১
      জ্যৈষ্ঠ ৩১
      আষাঢ় ৩১
      শ্রাবণ ৩১
      ভাদ্র ৩১
      আশ্বিন ৩০
      কার্তিক ৩০
      অগ্রহায়ণ ৩০
      পৌষ ৩০
      মাঘ ৩০
      ফাল্গুন ২৯/৩০
      চৈত্র ৩০
    */

    final year = date.year;

    DateTime pohelaBoishakh =
        DateTime(year, 4, 14);

    if (date.isBefore(pohelaBoishakh)) {
      pohelaBoishakh =
          DateTime(year - 1, 4, 14);
    }

    int banglaYear =
        pohelaBoishakh.year - 593;

    int difference =
        date.difference(pohelaBoishakh).inDays;

    final monthDays = [
      31, // বৈশাখ
      31, // জ্যৈষ্ঠ
      31, // আষাঢ়
      31, // শ্রাবণ
      31, // ভাদ্র
      30, // আশ্বিন
      30, // কার্তিক
      30, // অগ্রহায়ণ
      30, // পৌষ
      30, // মাঘ
      29, // ফাল্গুন
      30, // চৈত্র
    ];

    final isLeapYear =
        (pohelaBoishakh.year % 4 == 0);

    if (isLeapYear) {
      monthDays[10] = 30;
    }

    int monthIndex = 0;

    while (
        monthIndex < 12 &&
        difference >= monthDays[monthIndex]) {
      difference -= monthDays[monthIndex];
      monthIndex++;
    }

    if (monthIndex >= 12) {
      monthIndex = 11;
      difference = 29;
    }

    const monthNames = [
      'বৈশাখ',
      'জ্যৈষ্ঠ',
      'আষাঢ়',
      'শ্রাবণ',
      'ভাদ্র',
      'আশ্বিন',
      'কার্তিক',
      'অগ্রহায়ণ',
      'পৌষ',
      'মাঘ',
      'ফাল্গুন',
      'চৈত্র',
    ];

    return '${bn(difference + 1)} '
        '${monthNames[monthIndex]} '
        '${bn(banglaYear)}';
  }

  // ============================================================
  // HOLIDAYS
  // ============================================================

  String? holidayName(DateTime date) {
    // Bangladesh 2026 major public holidays
    if (date.year == 2026) {
      final key =
          '${date.month}-${date.day}';

      const holidays = {
        '2-21': 'শহীদ দিবস ও আন্তর্জাতিক মাতৃভাষা দিবস',
        '3-26': 'স্বাধীনতা ও জাতীয় দিবস',
        '5-1': 'মে দিবস',
        '12-16': 'বিজয় দিবস',
        '12-25': 'বড়দিন',
      };

      if (holidays.containsKey(key)) {
        return holidays[key];
      }
    }

    // Friday
    if (date.weekday == DateTime.friday) {
      return 'শুক্রবার';
    }

    return null;
  }

  String? islamicEventName(DateTime date) {
    final h = hijriDate(date);

    final month = h['month']!;
    final day = h['day']!;

    if (month == 1 && day == 1) {
      return 'ইসলামি নববর্ষ';
    }

    if (month == 1 && day == 10) {
      return 'আশুরা';
    }

    if (month == 3 && day == 12) {
      return 'ঈদে মিলাদুন্নবী ﷺ';
    }

    if (month == 7 && day == 27) {
      return 'শবে মেরাজ';
    }

    if (month == 8 && day == 15) {
      return 'শবে বরাত';
    }

    if (month == 9 && day == 1) {
      return 'রমজান শুরু';
    }

    if (month == 9 && day == 27) {
      return 'লাইলাতুল কদর';
    }

    if (month == 10 && day == 1) {
      return 'ঈদুল ফিতর';
    }

    if (month == 12 && day == 9) {
      return 'আরাফার দিন';
    }

    if (month == 12 && day == 10) {
      return 'ঈদুল আজহা';
    }

    return null;
  }

  // ============================================================
  // EVENTS
  // ============================================================

  List<CalendarEvent> eventsForDate(
    DateTime date,
  ) {
    return events
        .where(
          (event) =>
              isSameDate(event.date, date),
        )
        .toList();
  }

  List<CalendarEvent> get upcomingEvents {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    final result = events
        .where(
          (event) =>
              !event.date.isBefore(today),
        )
        .toList();

    result.sort(
      (a, b) =>
          a.date.compareTo(b.date),
    );

    return result;
  }

  Future<void> _addEvent() async {
    final titleController =
        TextEditingController();

    final timeController =
        TextEditingController();

    final noteController =
        TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          AppTheme.backgroundSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom:
                MediaQuery.of(context)
                    .viewInsets
                    .bottom +
                    20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.event_note_rounded,
                      color: AppTheme.gold,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'ইভেন্ট যোগ করুন',
                      style: TextStyle(
                        color:
                            AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  formatDate(selectedDate),
                  style: TextStyle(
                    color:
                        AppTheme.goldLight,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 18),

                TextField(
                  controller: titleController,
                  style: TextStyle(
                    color:
                        AppTheme.textPrimary,
                  ),
                  decoration:
                      _inputDecoration(
                    'ইভেন্টের নাম',
                    Icons.title_rounded,
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: timeController,
                  style: TextStyle(
                    color:
                        AppTheme.textPrimary,
                  ),
                  decoration:
                      _inputDecoration(
                    'সময়',
                    Icons.access_time_rounded,
                    hint: 'যেমন: সকাল ১০:৩০',
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: noteController,
                  maxLines: 3,
                  style: TextStyle(
                    color:
                        AppTheme.textPrimary,
                  ),
                  decoration:
                      _inputDecoration(
                    'বিস্তারিত / নোট',
                    Icons.notes_rounded,
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (titleController
                          .text
                          .trim()
                          .isEmpty) {
                        return;
                      }

                      final event =
                          CalendarEvent(
                        id: DateTime.now()
                            .microsecondsSinceEpoch
                            .toString(),
                        date: selectedDate,
                        title:
                            titleController.text
                                .trim(),
                        time:
                            timeController.text
                                .trim(),
                        note:
                            noteController.text
                                .trim(),
                      );

                      setState(() {
                        events.add(event);
                      });

                      await _saveEvents();

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(
                      Icons.save_rounded,
                    ),
                    label: const Text(
                      'ইভেন্ট সংরক্ষণ',
                    ),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          AppTheme.gold,
                      foregroundColor:
                          Colors.black,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    titleController.dispose();
    timeController.dispose();
    noteController.dispose();
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: AppTheme.gold,
      ),
      labelStyle: TextStyle(
        color: AppTheme.textMuted,
      ),
      hintStyle: TextStyle(
        color: AppTheme.textMuted,
      ),
      filled: true,
      fillColor: AppTheme.cardColor,
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppTheme.gold.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppTheme.gold.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppTheme.gold,
          width: 1.2,
        ),
      ),
    );
  }

  Future<void> _showHijriAdjustment() async {
    int tempValue = hijriAdjustment;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              backgroundColor:
                  AppTheme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(22),
              ),
              title: Row(
                children: [
                  const Icon(
                    Icons.mosque_rounded,
                    color: AppTheme.gold,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'হিজরি সমন্বয়',
                    style: TextStyle(
                      color:
                          AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Text(
                    'স্থানীয় চাঁদ দেখার তারিখের সঙ্গে '
                    'মিলিয়ে হিজরি তারিখ সমন্বয় করুন।',
                    style: TextStyle(
                      color:
                          AppTheme.textMuted,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding:
                        const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          AppTheme.backgroundSecondary,
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        IconButton(
                          onPressed:
                              tempValue > -2
                                  ? () {
                                      setDialogState(
                                        () {
                                          tempValue--;
                                        },
                                      );
                                    }
                                  : null,
                          icon: const Icon(
                            Icons.remove_circle,
                          ),
                          color: AppTheme.gold,
                        ),

                        const SizedBox(width: 18),

                        Text(
                          tempValue == 0
                              ? '০ দিন'
                              : tempValue > 0
                                  ? '+${bn(tempValue)} দিন'
                                  : '${bn(tempValue)} দিন',
                          style: TextStyle(
                            color:
                                AppTheme.goldLight,
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(width: 18),

                        IconButton(
                          onPressed:
                              tempValue < 2
                                  ? () {
                                      setDialogState(
                                        () {
                                          tempValue++;
                                        },
                                      );
                                    }
                                  : null,
                          icon: const Icon(
                            Icons.add_circle,
                          ),
                          color: AppTheme.gold,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'বাতিল',
                    style: TextStyle(
                      color:
                          AppTheme.textMuted,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      hijriAdjustment =
                          tempValue;
                    });

                    await _saveHijriAdjustment();

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        AppTheme.gold,
                    foregroundColor:
                        Colors.black,
                  ),
                  child: const Text(
                    'সংরক্ষণ',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // MONTH NAVIGATION
  // ============================================================

  void _previousMonth() {
    setState(() {
      displayedMonth = DateTime(
        displayedMonth.year,
        displayedMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      displayedMonth = DateTime(
        displayedMonth.year,
        displayedMonth.month + 1,
        1,
      );
    });
  }

  void _goToday() {
    final now = DateTime.now();

    setState(() {
      selectedDate = now;
      displayedMonth =
          DateTime(now.year, now.month, 1);
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool isDark = AppTheme.isDark;

    final upcoming =
        upcomingEvents.take(5).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        title: const Text('ক্যালেন্ডার'),

        actions: [
          IconButton(
            onPressed: _showHijriAdjustment,
            tooltip: 'হিজরি সমন্বয়',
            icon: const Icon(
              Icons.tune_rounded,
            ),
          ),
        ],
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: _addEvent,
        backgroundColor: AppTheme.gold,
        foregroundColor: Colors.black,
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text(
          'ইভেন্ট',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: ListView(
          padding:
              const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            100,
          ),
          children: [

            // =================================================
            // TODAY / SELECTED DATE CARD
            // =================================================

            _buildDateHeader(),

            const SizedBox(height: 14),

            // =================================================
            // MONTH SELECTOR
            // =================================================

            _buildMonthSelector(),

            const SizedBox(height: 10),

            // =================================================
            // CUSTOM CALENDAR
            // =================================================

            _buildCalendar(),

            const SizedBox(height: 14),

            // =================================================
            // SELECTED DATE EVENTS
            // =================================================

            _buildSelectedDateEvents(),

            const SizedBox(height: 14),

            // =================================================
            // UPCOMING EVENTS
            // =================================================

            _buildUpcomingEvents(
              upcoming,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DATE HEADER
  // ============================================================

  Widget _buildDateHeader() {
    final h = hijriDate(selectedDate);

    final selectedEvents =
        eventsForDate(selectedDate);

    final islamic =
        islamicEventName(selectedDate);

    final holiday =
        holidayName(selectedDate);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkGreen,
            AppTheme.primaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.gold.withValues(
            alpha: 0.55,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.darkGreen.withValues(
              alpha: 0.25,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                color: AppTheme.gold,
                size: 32,
              ),

              Text(
                'নির্বাচিত তারিখ',
                style: TextStyle(
                  color:
                      AppTheme.goldLight,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              IconButton(
                onPressed: _goToday,
                icon: const Icon(
                  Icons.today_rounded,
                  color: AppTheme.gold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            bn(selectedDate.day),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            '${monthName(selectedDate.month)} ${bn(selectedDate.year)}',
            style: const TextStyle(
              color: AppTheme.goldLight,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            weekdayBangla(
              selectedDate.weekday,
            ),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 14),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(
                alpha: 0.16,
              ),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  banglaDate(selectedDate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${bn(h['day']!)} ${hijriMonthName(h['month']!)} ${bn(h['year']!)} হিজরি',
                  style: const TextStyle(
                    color:
                        AppTheme.goldLight,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          if (islamic != null ||
              holiday != null ||
              selectedEvents.isNotEmpty) ...[
            const SizedBox(height: 12),

            Wrap(
              alignment:
                  WrapAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: [
                if (holiday != null &&
                    holiday != 'শুক্রবার')
                  _headerBadge(
                    holiday,
                    Icons.flag_rounded,
                  ),

                if (islamic != null)
                  _headerBadge(
                    islamic,
                    Icons.mosque_rounded,
                  ),

                if (selectedEvents.isNotEmpty)
                  _headerBadge(
                    '${selectedEvents.length}টি ইভেন্ট',
                    Icons.event_rounded,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _headerBadge(
    String text,
    IconData icon,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppTheme.gold.withValues(
          alpha: 0.16,
        ),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.gold.withValues(
            alpha: 0.35,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppTheme.gold,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MONTH SELECTOR
  // ============================================================

  Widget _buildMonthSelector() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
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
      child: Row(
        children: [
          IconButton(
            onPressed: _previousMonth,
            icon: const Icon(
              Icons.chevron_left_rounded,
            ),
            color: AppTheme.gold,
          ),

          Expanded(
            child: Column(
              children: [
                Text(
                  '${monthName(displayedMonth.month)} ${bn(displayedMonth.year)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        AppTheme.textPrimary,
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  monthNameEnglish(
                    displayedMonth.month,
                  ),
                  style: TextStyle(
                    color:
                        AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: _nextMonth,
            icon: const Icon(
              Icons.chevron_right_rounded,
            ),
            color: AppTheme.gold,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CUSTOM CALENDAR
  // ============================================================

  Widget _buildCalendar() {
    final firstDay = DateTime(
      displayedMonth.year,
      displayedMonth.month,
      1,
    );

    final daysInMonth = DateTime(
      displayedMonth.year,
      displayedMonth.month + 1,
      0,
    ).day;

    final startingWeekday =
        firstDay.weekday % 7;

    final totalCells =
        ((startingWeekday +
                    daysInMonth) /
                7)
            .ceil() *
        7;

    const weekdays = [
      'রবি',
      'সোম',
      'মঙ্গল',
      'বুধ',
      'বৃহস্পতি',
      'শুক্র',
      'শনি',
    ];

    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        8,
        12,
        8,
        12,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.gold.withValues(
            alpha: 0.3,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children:
                weekdays.map((day) {
              final isFriday =
                  day == 'শুক্র';

              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      color: isFriday
                          ? const Color(
                              0xFFE57373,
                            )
                          : AppTheme.goldLight,
                      fontSize: 11,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 8),

          GridView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 5,
              crossAxisSpacing: 3,
              childAspectRatio: 0.78,
            ),
            itemBuilder: (context, index) {
              final day =
                  index - startingWeekday + 1;

              if (day < 1 ||
                  day > daysInMonth) {
                return const SizedBox();
              }

              final date = DateTime(
                displayedMonth.year,
                displayedMonth.month,
                day,
              );

              return _buildDayCell(date);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(DateTime date) {
    final isSelected =
        isSameDate(date, selectedDate);

    final isToday =
        isSameDate(date, DateTime.now());

    final isFriday =
        date.weekday == DateTime.friday;

    final dayEvents =
        eventsForDate(date);

    final holiday =
        holidayName(date);

    final islamic =
        islamicEventName(date);

    Color background =
        Colors.transparent;

    Color textColor =
        AppTheme.textPrimary;

    if (isSelected) {
      background = AppTheme.gold;
      textColor = Colors.black;
    } else if (isToday) {
      background =
          AppTheme.gold.withValues(
        alpha: 0.18,
      );
    }

    if (!isSelected && isFriday) {
      textColor = const Color(
        0xFFE57373,
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDate = date;
        });
      },
      onLongPress: () {
        setState(() {
          selectedDate = date;
        });
        _addEvent();
      },
      child: Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius:
              BorderRadius.circular(12),
          border: isToday
              ? Border.all(
                  color: AppTheme.gold,
                  width: 1.2,
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Text(
              bn(date.day),
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight:
                    isSelected ||
                            isToday
                        ? FontWeight.bold
                        : FontWeight.w600,
              ),
            ),

            const SizedBox(height: 1),

            Text(
              _shortBanglaDate(date),
              style: TextStyle(
                color: isSelected
                    ? Colors.black54
                    : AppTheme.textMuted,
                fontSize: 7,
              ),
              maxLines: 1,
              overflow:
                  TextOverflow.clip,
            ),

            const SizedBox(height: 2),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                if (dayEvents.isNotEmpty)
                  _dot(
                    isSelected
                        ? Colors.black
                        : AppTheme.gold,
                  ),

                if (holiday != null &&
                    holiday != 'শুক্রবার')
                  _dot(
                    isSelected
                        ? Colors.black54
                        : const Color(
                            0xFFE57373,
                          ),
                  ),

                if (islamic != null)
                  _dot(
                    isSelected
                        ? Colors.black54
                        : const Color(
                            0xFF66BB6A,
                          ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 4,
      height: 4,
      margin:
          const EdgeInsets.symmetric(
        horizontal: 1,
      ),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  String _shortBanglaDate(
    DateTime date,
  ) {
    final value = banglaDate(date);

    final parts = value.split(' ');

    if (parts.length >= 2) {
      return '${parts[0]} ${parts[1]}';
    }

    return value;
  }

  // ============================================================
  // SELECTED DATE EVENTS
  // ============================================================

  Widget _buildSelectedDateEvents() {
    final selectedEvents =
        eventsForDate(selectedDate);

    if (selectedEvents.isEmpty) {
      return Container(
        padding:
            const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.gold.withValues(
              alpha: 0.2,
            ),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.event_available_rounded,
              color: AppTheme.gold,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'এই তারিখে কোনো ইভেন্ট নেই',
                style: TextStyle(
                  color:
                      AppTheme.textMuted,
                ),
              ),
            ),
            IconButton(
              onPressed: _addEvent,
              icon: const Icon(
                Icons.add_circle_outline,
              ),
              color: AppTheme.gold,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'এই তারিখের ইভেন্ট',
          Icons.event_note_rounded,
        ),

        const SizedBox(height: 8),

        ...selectedEvents.map(
          (event) =>
              _eventCard(event),
        ),
      ],
    );
  }

  // ============================================================
  // UPCOMING EVENTS
  // ============================================================

  Widget _buildUpcomingEvents(
    List<CalendarEvent> upcoming,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'আসন্ন ইভেন্ট',
          Icons.notifications_active_rounded,
        ),

        const SizedBox(height: 8),

        if (upcoming.isEmpty)
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius:
                  BorderRadius.circular(20),
              border: Border.all(
                color:
                    AppTheme.gold.withValues(
                  alpha: 0.2,
                ),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.event_busy_rounded,
                  color:
                      AppTheme.textMuted,
                  size: 36,
                ),
                const SizedBox(height: 8),
                Text(
                  'কোনো আসন্ন ইভেন্ট নেই',
                  style: TextStyle(
                    color:
                        AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          )
        else
          ...upcoming.map(
            (event) =>
                _eventCard(event),
          ),
      ],
    );
  }

  Widget _sectionTitle(
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.gold,
          size: 21,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color:
                AppTheme.textPrimary,
            fontSize: 17,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EVENT CARD
  // ============================================================

  Widget _eventCard(
    CalendarEvent event,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 8),
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.gold.withValues(
            alpha: 0.2,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 54,
            decoration: BoxDecoration(
              color: AppTheme.gold
                  .withValues(alpha: 0.12),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  bn(event.date.day),
                  style: const TextStyle(
                    color:
                        AppTheme.gold,
                    fontSize: 19,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                Text(
                  monthName(
                    event.date.month,
                  ),
                  style: TextStyle(
                    color:
                        AppTheme.textMuted,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                    color:
                        AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  formatDate(event.date),
                  style: TextStyle(
                    color:
                        AppTheme.goldLight,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                if (event.time
                    .isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    event.time,
                    style: TextStyle(
                      color:
                          AppTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],

                if (event.note
                    .isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    event.note,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                          AppTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),

          IconButton(
            onPressed: () =>
                _deleteEvent(event),
            icon: const Icon(
              Icons.delete_outline_rounded,
            ),
            color:
                AppTheme.textMuted,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DELETE EVENT
  // ============================================================

  Future<void> _deleteEvent(
    CalendarEvent event,
  ) async {
    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              AppTheme.cardColor,
          title: Text(
            'ইভেন্ট মুছে ফেলবেন?',
            style: TextStyle(
              color:
                  AppTheme.textPrimary,
            ),
          ),
          content: Text(
            event.title,
            style: TextStyle(
              color:
                  AppTheme.textMuted,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                false,
              ),
              child: Text(
                'না',
                style: TextStyle(
                  color:
                      AppTheme.textMuted,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                true,
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppTheme.danger,
                foregroundColor:
                    Colors.white,
              ),
              child: const Text(
                'মুছে ফেলুন',
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      events.removeWhere(
        (item) =>
            item.id == event.id,
      );
    });

    await _saveEvents();
  }
}
