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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'সহজ হিসাব প্লাস',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
