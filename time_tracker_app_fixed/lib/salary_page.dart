import 'package:flutter/material.dart';
import 'database_helper.dart';

/// 工资页面
class SalaryPage extends StatefulWidget {
  const SalaryPage({super.key});

  @override
  State<SalaryPage> createState() => _SalaryPageState();
}

class _SalaryPageState extends State<SalaryPage> {
  // 工资设置
  Map<String, dynamic> _salarySettings = {
    'mode': 0, // 0: 标准工时制, 1: 小时制, 2: 综合工时制
    'baseSalary': 3000.0,
    'hourlyWage': 15.0,
    'overtimeRate1': 1.5,
    'overtimeRate2': 2.0,
    'overtimeRate3': 3.0,
  };
  
  // 本月工时
  double _monthlyHours = 0.0;
  // 本月加班时长
  double _overtimeHours = 0.0;
  // 本月工资
  double _monthlySalary = 0.0;
  // 加载状态
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 加载工资设置和本月工时
    _loadSalarySettings();
    _loadMonthlyHours();
  }

  /// 加载工资设置
  Future<void> _loadSalarySettings() async {
    try {
      // 这里应该从SharedPreferences加载设置
      // 暂时使用默认值
    } catch (e) {
      print('加载工资设置失败: $e');
    }
  }

  /// 加载本月工时
  Future<void> _loadMonthlyHours() async {
    try {
      // 获取本月的开始和结束日期
      DateTime now = DateTime.now();
      DateTime startOfMonth = DateTime(now.year, now.month, 1);
      DateTime endOfMonth = DateTime(now.year, now.month + 1, 0);

      // 加载本月的所有工时记录
      List<Map<String, dynamic>> records = await DatabaseHelper.instance.getRecordsInRange(
        startOfMonth.toIso8601String().split('T')[0],
        endOfMonth.toIso8601String().split('T')[0],
      );

      // 计算总工时和加班时长
      double totalHours = 0.0;
      double overtime = 0.0;

      for (var record in records) {
        double hours = record[DatabaseHelper.columnHours] ?? 0.0;
        totalHours += hours;
        // 假设每天8小时为标准工时，超过的部分为加班
        if (hours > 8) {
          overtime += hours - 8;
        }
      }

      setState(() {
        _monthlyHours = totalHours;
        _overtimeHours = overtime;
        // 计算本月工资
        _calculateSalary();
      });
    } catch (e) {
      print('加载本月工时失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 计算本月工资
  void _calculateSalary() {
    double salary = 0.0;

    switch (_salarySettings['mode']) {
      case 0: // 标准工时制
        // 标准工时制：基本工资 + 加班费
        salary = _salarySettings['baseSalary'];
        // 假设每月标准工时为160小时
        if (_monthlyHours > 160) {
          double overtime = _monthlyHours - 160;
          salary += overtime * (_salarySettings['baseSalary'] / 160) * _salarySettings['overtimeRate1'];
        }
        break;
      case 1: // 小时制
        // 小时制：工时 × 小时工资
        salary = _monthlyHours * _salarySettings['hourlyWage'];
        // 超过标准工时的部分计算加班费
        if (_monthlyHours > 160) {
          double overtime = _monthlyHours - 160;
          salary += overtime * _salarySettings['hourlyWage'] * (_salarySettings['overtimeRate1'] - 1);
        }
        break;
      case 2: // 综合工时制
        // 综合工时制：基本工资 + 加班费
        salary = _salarySettings['baseSalary'];
        // 假设每月标准工时为160小时
        if (_monthlyHours > 160) {
          double overtime = _monthlyHours - 160;
          salary += overtime * (_salarySettings['baseSalary'] / 160) * _salarySettings['overtimeRate1'];
        }
        break;
    }

    setState(() {
      _monthlySalary = salary;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('工资'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/salary_setting');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 本月工资卡片
            _buildSalaryCard(),
            const SizedBox(height: 24),
            
            // 工时统计
            _buildHoursStats(),
            const SizedBox(height: 24),
            
            // 工资明细
            _buildSalaryDetails(),
            const SizedBox(height: 32), // 添加底部间距
          ],
        ),
      ),
    );
  }

  /// 构建工资卡片
  Widget _buildSalaryCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '本月工资',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              '¥${_monthlySalary.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建工时统计
  Widget _buildHoursStats() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '工时统计',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('本月总工时:'),
                Text('${_monthlyHours.toStringAsFixed(1)} 小时'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('本月加班时长:'),
                Text('${_overtimeHours.toStringAsFixed(1)} 小时'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建工资明细
  Widget _buildSalaryDetails() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '工资明细',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // 根据工资模式显示不同的明细
            if (_salarySettings['mode'] == 0 || _salarySettings['mode'] == 2) // 标准工时制或综合工时制
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('基本工资:'),
                      Text('¥${_salarySettings['baseSalary'].toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('加班费:'),
                      Text('¥${(_monthlySalary - _salarySettings['baseSalary']).toStringAsFixed(2)}'),
                    ],
                  ),
                ],
              )
            else if (_salarySettings['mode'] == 1) // 小时制
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('标准工时工资:'),
                      Text('¥${(160 * _salarySettings['hourlyWage']).toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('加班费:'),
                      Text('¥${(_monthlySalary - 160 * _salarySettings['hourlyWage']).toStringAsFixed(2)}'),
                    ],
                  ),
                ],
              ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('总计:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('¥${_monthlySalary.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
