import 'package:flutter/material.dart';
import 'main_page.dart';
import 'salary_setting_page.dart';
import 'database_initializer.dart';

void main() {
  // 初始化数据库
  DatabaseInitializerWrapper.initialize();
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
      home: const MainPage(),
      routes: {
        '/salary_setting': (context) => const SalarySettingPage(),
      },
    );
  }
}
