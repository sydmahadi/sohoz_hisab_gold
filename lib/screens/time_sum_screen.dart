import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TimeSumScreen extends StatefulWidget {
  const TimeSumScreen({super.key});

  @override
  State<TimeSumScreen> createState() => _TimeSumScreenState();
}

class _TimeSumScreenState extends State<TimeSumScreen> {
  final List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  String? _result;

  // ============================================================
  // ADD FIELD
  // ============================================================

  void _addField() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  // ============================================================
  // REMOVE FIELD
  // ============================================================

  void _removeField(int index) {
    if (_controllers.length <= 2) {
      return;
    }

    _controllers[index].dispose();

    setState(() {
      _controllers.removeAt(index);
    });
  }

  // ============================================================
  // PARSE TIME
  // Format: hours.minutes
  // Example: 2.30 = 2 hours 30 minutes
  //          200.20 = 200 hours 20 minutes
  // ============================================================

  int? _parseTime(String value) {
    final text = value.trim();

    if (text.isEmpty) {
      return null;
    }

    final parts = text.split('.');

    if (parts.length > 2) {
      return null;
    }

    final hours = int.tryParse(parts[0]);

    if (hours == null || hours < 0) {
      return null;
    }

    int minutes = 0;

    if (parts.length == 2) {
      final minuteText = parts[1];

      if (minuteText.isEmpty) {
        minutes = 0;
      } else {
        minutes = int.tryParse(minuteText) ?? -1;
      }
    }

    if (minutes < 0 || minutes > 59) {
      return null;
    }

    return (hours * 60) + minutes;
  }

  // ============================================================
  // CALCULATE
  // ============================================================

  void _calculate() {
    int totalMinutes = 0;

    for (final controller in _controllers) {
      final value = controller.text.trim();

      if (value.isEmpty) {
        continue;
      }

      final minutes = _parseTime(value);

      if (minutes == null) {
        setState(() {
          _result =
              'সঠিক সময় লিখুন।\nউদাহরণ: 2.30 অথবা 200.20';
        });
        return;
      }

      totalMinutes += minutes;
    }

    if (totalMinutes == 0) {
      setState(() {
        _result = 'কমপক্ষে একটি সময় ইনপুট দিন';
      });
      return;
    }

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    setState(() {
      _result = '$hours ঘণ্টা $minutes মিনিট';
    });
  }

  // ============================================================
  // CLEAR
  // ============================================================

  void _clear() {
    for (final controller in _controllers) {
      controller.clear();
    }

    setState(() {
      _result = null;
    });
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }

    super.dispose();
  }

  // ============================================================
  // INPUT FIELD
  // ============================================================

  Widget _buildTimeField(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controllers[index],
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: TextStyle(
                color: AppTheme.textPrimary,
              ),
              decoration: InputDecoration(
                labelText: 'সময় ${index + 1}',
                hintText: 'যেমন: 2.30',
                prefixIcon: Icon(
                  Icons.access_time_rounded,
                  color: AppTheme.gold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (_controllers.length > 2)
            IconButton(
              onPressed: () => _removeField(index),
              tooltip: 'মুছে ফেলুন',
              icon: Icon(
                Icons.remove_circle_outline,
                color: AppTheme.danger,
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('সময় যোগ'),
        actions: [
          IconButton(
            onPressed: _clear,
            tooltip: 'সব মুছে ফেলুন',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==================================================
            // HEADER CARD
            // ==================================================

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.access_time_filled_rounded,
                      color: AppTheme.gold,
                      size: 46,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'সময় যোগ করুন',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'একাধিক সময় যোগ করে মোট সময় বের করুন',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ==================================================
            // INPUT CARD
            // ==================================================

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'সময়গুলো লিখুন',
                      style: TextStyle(
                        color: AppTheme.goldLight,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),

                    ...List.generate(
                      _controllers.length,
                      (index) => _buildTimeField(index),
                    ),

                    const SizedBox(height: 4),

                    OutlinedButton.icon(
                      onPressed: _addField,
                      icon: const Icon(
                        Icons.add_circle_outline,
                      ),
                      label: const Text('আরও সময় যোগ করুন'),
                    ),

                    const SizedBox(height: 14),

                    ElevatedButton.icon(
                      onPressed: _calculate,
                      icon: const Icon(
                        Icons.calculate_rounded,
                      ),
                      label: const Text('হিসাব করুন'),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'ফরম্যাট: ঘণ্টা.মিনিট\n'
                      'উদাহরণ: 2.30 = ২ ঘণ্টা ৩০ মিনিট\n'
                      '200.20 = ২০০ ঘণ্টা ২০ মিনিট',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ==================================================
            // RESULT
            // ==================================================

            if (_result != null) ...[
              const SizedBox(height: 18),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.gold,
                        size: 46,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'মোট সময়',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _result!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.goldLight,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
