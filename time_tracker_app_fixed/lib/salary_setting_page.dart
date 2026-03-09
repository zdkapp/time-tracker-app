import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 工资设置页面
class SalarySettingPage extends StatefulWidget {
  const SalarySettingPage({super.key});

  @override
  State<SalarySettingPage> createState() => _SalarySettingPageState();
}

class _SalarySettingPageState extends State<SalarySettingPage> {
  // 计薪模式：0-标准工时，1-小时工，2-综合工时
  int _salaryMode = 0;
  // 底薪
  double _baseSalary = 5000.0;
  // 每天标准工时
  double _dailyStandardHours = 8.0;
  // 平时加班倍数
  double _normalOvertimeMultiplier = 1.5;
  // 周末加班倍数
  double _weekendOvertimeMultiplier = 2.0;
  // 节假日加班倍数
  double _holidayOvertimeMultiplier = 3.0;
  // 时薪
  double _hourlyWage = 20.0;
  // 月标准工时
  double _monthlyStandardHours = 168.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// 加载设置
  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _salaryMode = prefs.getInt('salaryMode') ?? 0;
      _baseSalary = prefs.getDouble('baseSalary') ?? 5000.0;
      _dailyStandardHours = prefs.getDouble('dailyStandardHours') ?? 8.0;
      _normalOvertimeMultiplier = prefs.getDouble('normalOvertimeMultiplier') ?? 1.5;
      _weekendOvertimeMultiplier = prefs.getDouble('weekendOvertimeMultiplier') ?? 2.0;
      _holidayOvertimeMultiplier = prefs.getDouble('holidayOvertimeMultiplier') ?? 3.0;
      _hourlyWage = prefs.getDouble('hourlyWage') ?? 20.0;
      _monthlyStandardHours = prefs.getDouble('monthlyStandardHours') ?? 168.0;
    });
  }

  /// 保存设置
  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('salaryMode', _salaryMode);
    await prefs.setDouble('baseSalary', _baseSalary);
    await prefs.setDouble('dailyStandardHours', _dailyStandardHours);
    await prefs.setDouble('normalOvertimeMultiplier', _normalOvertimeMultiplier);
    await prefs.setDouble('weekendOvertimeMultiplier', _weekendOvertimeMultiplier);
    await prefs.setDouble('holidayOvertimeMultiplier', _holidayOvertimeMultiplier);
    await prefs.setDouble('hourlyWage', _hourlyWage);
    await prefs.setDouble('monthlyStandardHours', _monthlyStandardHours);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('设置保存成功')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('工资设置'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 计薪模式选择
            _buildSalaryModeSection(),
            const SizedBox(height: 24),

            // 根据计薪模式显示不同的设置项
            if (_salaryMode == 0) // 标准工时
              _buildStandardSalarySettings()
            else if (_salaryMode == 1) // 小时工
              _buildHourlySalarySettings()
            else if (_salaryMode == 2) // 综合工时
              _buildComprehensiveSalarySettings(),

            const SizedBox(height: 32),

            // 保存按钮
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  /// 构建计薪模式选择部分
  Widget _buildSalaryModeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '计薪模式',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Radio(
              value: 0,
              groupValue: _salaryMode,
              onChanged: (value) {
                setState(() {
                  _salaryMode = value!;
                });
              },
            ),
            const Text('标准工时'),
            const SizedBox(width: 24),
            Radio(
              value: 1,
              groupValue: _salaryMode,
              onChanged: (value) {
                setState(() {
                  _salaryMode = value!;
                });
              },
            ),
            const Text('小时工'),
            const SizedBox(width: 24),
            Radio(
              value: 2,
              groupValue: _salaryMode,
              onChanged: (value) {
                setState(() {
                  _salaryMode = value!;
                });
              },
            ),
            const Text('综合工时'),
          ],
        ),
      ],
    );
  }

  /// 构建标准工时设置
  Widget _buildStandardSalarySettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: '底薪',
          value: _baseSalary.toString(),
          onChanged: (value) {
            setState(() {
              _baseSalary = double.tryParse(value) ?? 0.0;
            });
          },
          suffix: '元',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: '每天标准工时',
          value: _dailyStandardHours.toString(),
          onChanged: (value) {
            setState(() {
              _dailyStandardHours = double.tryParse(value) ?? 8.0;
            });
          },
          suffix: '小时',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: '平时加班倍数',
          value: _normalOvertimeMultiplier.toString(),
          onChanged: (value) {
            setState(() {
              _normalOvertimeMultiplier = double.tryParse(value) ?? 1.5;
            });
          },
          suffix: '倍',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: '周末加班倍数',
          value: _weekendOvertimeMultiplier.toString(),
          onChanged: (value) {
            setState(() {
              _weekendOvertimeMultiplier = double.tryParse(value) ?? 2.0;
            });
          },
          suffix: '倍',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: '节假日加班倍数',
          value: _holidayOvertimeMultiplier.toString(),
          onChanged: (value) {
            setState(() {
              _holidayOvertimeMultiplier = double.tryParse(value) ?? 3.0;
            });
          },
          suffix: '倍',
        ),
      ],
    );
  }

  /// 构建小时工设置
  Widget _buildHourlySalarySettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: '时薪',
          value: _hourlyWage.toString(),
          onChanged: (value) {
            setState(() {
              _hourlyWage = double.tryParse(value) ?? 20.0;
            });
          },
          suffix: '元/小时',
        ),
      ],
    );
  }

  /// 构建综合工时设置
  Widget _buildComprehensiveSalarySettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: '时薪',
          value: _hourlyWage.toString(),
          onChanged: (value) {
            setState(() {
              _hourlyWage = double.tryParse(value) ?? 20.0;
            });
          },
          suffix: '元/小时',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: '月标准工时',
          value: _monthlyStandardHours.toString(),
          onChanged: (value) {
            setState(() {
              _monthlyStandardHours = double.tryParse(value) ?? 168.0;
            });
          },
          suffix: '小时',
        ),
      ],
    );
  }

  /// 构建文本输入框
  Widget _buildTextField({
    required String label,
    required String value,
    required Function(String) onChanged,
    String suffix = '',
  }) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label),
        ),
        Expanded(
          child: TextField(
            controller: TextEditingController.fromValue(
              TextEditingValue(
                text: value,
                selection: TextSelection.collapsed(offset: value.length),
              ),
            ),
            onChanged: onChanged,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              suffixText: suffix,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建保存按钮
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          '保存',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
