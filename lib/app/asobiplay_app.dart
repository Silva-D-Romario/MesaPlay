import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/home/presentation/home_screen.dart';

class AsobiPlayApp extends StatelessWidget {
  const AsobiPlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AsobiPlay',
      theme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}
