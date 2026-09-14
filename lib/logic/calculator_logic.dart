class CalculatorLogic {
  static int parseTimeToMinutes(String value) {
    value = value.trim();

    if (value.isEmpty) return 0;

    final parts = value.split('.');

    if (parts.length != 2) return -1;

    final hours = int.tryParse(parts[0]);
    final minutes = int.tryParse(parts[1]);

    if (hours == null || minutes == null) return -1;

    if (hours < 0 || minutes < 0 || minutes > 59) {
      return -1;
    }

    return (hours * 60) + minutes;
  }

  static String formatHoursAndMinutes(double totalMinutes) {
    int total = totalMinutes.round();

    if (total < 0) {
      total = 0;
    }

    final hours = total ~/ 60;
    final minutes = total % 60;

    if (hours == 0 && minutes == 0) {
      return '০ ঘণ্টা ০ মিনিট';
    }

    if (hours == 0) {
      return '$minutes মিনিট';
    }

    if (minutes == 0) {
      return '$hours ঘণ্টা';
    }

    return '$hours ঘণ্টা $minutes মিনিট';
  }

  static String dailyCount({
    required double days,
    required double value,
  }) {
    if (days <= 0) {
      return 'সঠিক দিন ইনপুট দিন';
    }

    if (value < 0) {
      return 'সঠিক সংখ্যা ইনপুট দিন';
    }

    final result = value / days;

    return result.toStringAsFixed(2);
  }

  static String dailyTime({
    required double days,
    required String time,
  }) {
    if (days <= 0) {
      return 'সঠিক দিন ইনপুট দিন';
    }

    final totalMinutes = parseTimeToMinutes(time);

    if (totalMinutes < 0) {
      return 'সময় সঠিকভাবে লিখুন';
    }

    final dailyAverage = totalMinutes / days;

    return formatHoursAndMinutes(dailyAverage);
  }

  static String monthlyCount({
    required double days,
    required double value,
  }) {
    if (days <= 0) {
      return 'সঠিক দিন ইনপুট দিন';
    }

    if (value < 0) {
      return 'সঠিক সংখ্যা ইনপুট দিন';
    }

    const monthDays = 30.0;

    final dailyAverage = value / days;
    final monthlyAverage = dailyAverage * monthDays;

    return monthlyAverage.toStringAsFixed(2);
  }

  static String monthlyTime({
    required double days,
    required String time,
  }) {
    if (days <= 0) {
      return 'সঠিক দিন ইনপুট দিন';
    }

    final totalMinutes = parseTimeToMinutes(time);

    if (totalMinutes < 0) {
      return 'সময় সঠিকভাবে লিখুন';
    }

    const monthDays = 30.0;

    final dailyAverage = totalMinutes / days;
    final monthlyAverage = dailyAverage * monthDays;

    return formatHoursAndMinutes(monthlyAverage);
  }
}
