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

  void _addField() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  void _removeField(int index) {
    if (_controllers.length <= 2) {
      return;
    }

    _controllers[index].dispose();

    setState(() {
      _controllers.removeAt(index);
    });
  }

  int? _parseTime(String value) {
    final text = value.trim();

    if (text.isEmpty) {
      return 0;
    }

    final parts = text.split('.');

    if (parts.length != 2) {
      return null;
    }

    final hours = int.tryParse(parts[0]);
    final minutes = int.tryParse(parts[1]);

    if (hours == null || minutes == null) {
      return null;
    }

    if (hours < 0 || minutes < 0 || minutes > 59) {
      return null;
    }

    return (hours * 60) + minutes;
  }

  void _calculate() {
    int totalMinutes = 0;

    for (final controller in _controllers) {
      final minutes = _parseTime(controller.text);

      if (minutes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'সময় সঠিকভাবে লিখুন। উদাহরণ: 2.30',
            ),
          ),
        );
        return;
      }

      totalMinutes += minutes;
    }

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    setState(() {
      if (hours == 0 && minutes == 0) {
        _result = '০ ঘণ্টা ০ মিনিট';
      } else if (hours == 0) {
        _result = '$minutes মিনিট';
      } else if (minutes == 0) {
        _result = '$hours ঘণ্টা';
      } else {
        _result = '$hours ঘণ্টা $minutes মিনিট';
      }
    });
  }

  void _clearAll() {
    for (final controller in _controllers) {
      controller.clear();
    }

    setState(() {
      _result = null;
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('সময় যোগ'),
        actions: [
          IconButton(
            onPressed: _clearAll,
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      color: AppTheme.gold,
                      size: 46,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'সময় যোগ করুন',
                      style: TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'সময় লিখুন ঘণ্টা.মিনিট ফরম্যাটে',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'উদাহরণ: 2.30 = ২ ঘণ্টা ৩০ মিনিট',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.goldLight,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...List.generate(
                      _controllers.length,
                      (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _controllers[index],
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'সময় ${index + 1}',
                                    hintText: 'যেমন: 2.30',
                                    prefixIcon: const Icon(
                                      Icons.schedule_rounded,
                                    ),
                                  ),
                                ),
                              ),
                              if (_controllers.length > 2) ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => _removeField(index),
                                  tooltip: 'মুছে ফেলুন',
                                  style: IconButton.styleFrom(
                                    foregroundColor: AppTheme.gold,
                                  ),
                                  icon: const Icon(
                                    Icons.remove_circle_outline_rounded,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 4),

                    OutlinedButton.icon(
                      onPressed: _addField,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('আরও সময় যোগ করুন'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.goldLight,
                        side: const BorderSide(
                          color: AppTheme.gold,
                        ),
                        minimumSize: const Size(
                          double.infinity,
                          50,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    ElevatedButton.icon(
                      onPressed: _calculate,
                      icon: const Icon(Icons.calculate_rounded),
                      label: const Text('হিসাব করুন'),
                    ),
                  ],
                ),
              ),
            ),

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
                      const Text(
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
                        style: const TextStyle(
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
