import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/home/presentation/home_screen.dart';

class MesaPlayApp extends StatelessWidget {
  const MesaPlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MesaPlay',
      theme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}
