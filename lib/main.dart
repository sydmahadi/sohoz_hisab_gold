import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ShohozHisabPlusApp());
}

class ShohozHisabPlusApp extends StatelessWidget {
  const ShohozHisabPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder দিয়ে থিম রিয়্যাক্টিভ করা হয়েছে
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'সহজ হিসাব গোল্ড',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode, // ডার্ক বা লাইট মোড সিলেক্ট করবে
          home: const HomeScreen(),
        );
      },
    );
  }
}
