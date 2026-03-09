import 'package:flutter/material.dart';
import 'work_record_page.dart';
import 'salary_page.dart';
import 'profile_page.dart';

/// 主页面，包含底部导航栏
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // 当前选中的页面索引
  int _currentIndex = 0;

  // 页面列表
  final List<Widget> _pages = [
    const WorkRecordPage(),
    const SalaryPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: '工时',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: '工资',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
