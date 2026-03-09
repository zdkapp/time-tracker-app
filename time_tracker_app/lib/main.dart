import 'package:flutter/material.dart';
import 'work_record_page.dart';
import 'salary_setting_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '工时记录',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WorkRecordPage(),
      routes: {
        '/salary_setting': (context) => const SalarySettingPage(),
      },
    );
  }
}

