import 'package:flutter/material.dart';

import 'screens/task_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyTasksApp());
}

class MyTasksApp extends StatelessWidget {
  const MyTasksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Tasks',
      theme: AppTheme.lightTheme(),
      home: const TaskScreen(),
    );
  }
}
