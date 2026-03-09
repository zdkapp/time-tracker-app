import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 计薪模式枚举
enum SalaryMode {
  standard,  // 标准工时（5天8小时外算加班）
  hourly,    // 小时工模式（按小时计薪）
  comprehensive // 综合工时（月超168小时算加班）
}

/// 工资设置页面
class SalarySettingPage extends StatefulWidget {
  const SalarySettingPage({super.key});

  @override
  _SalarySettingPageState createState() => _SalarySettingPageState();
}

class _SalarySettingPageState extends State<SalarySettingPage> {
  // 计薪模式
  SalaryMode _salaryMode = SalaryMode.standard;
  
  // 标准工时设置
  double _baseSalary = 0.0; // 底薪
  double _dailyStandardHours = 8.0; // 每天标准工时
  double _normalOvertimeRate = 1.5; // 平时加班倍数
  double _weekendOvertimeRate = 2.0; // 周末加班倍数
  double _holidayOvertimeRate = 3.0; // 节假日加班倍数
  
  // 小时工设置
  double _hourlyWage = 0.0; // 时薪
  
  // 综合工时设置
  double _monthlyStandardHours = 168.0; // 月标准工时
  
  // 加载状态
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 加载保存的设置
    _loadSettings();
  }

  /// 加载保存的设置
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 加载计薪模式
      final modeIndex = prefs.getInt('salaryMode') ?? 0;
      _salaryMode = SalaryMode.values[modeIndex];
      
      // 加载标准工时设置
      _baseSalary = prefs.getDouble('baseSalary') ?? 0.0;
      _dailyStandardHours = prefs.getDouble('dailyStandardHours') ?? 8.0;
      _normalOvertimeRate = prefs.getDouble('normalOvertimeRate') ?? 1.5;
      _weekendOvertimeRate = prefs.getDouble('weekendOvertimeRate') ?? 2.0;
      _holidayOvertimeRate = prefs.getDouble('holidayOvertimeRate') ?? 3.0;
      
      // 加载小时工设置
      _hourlyWage = prefs.getDouble('hourlyWage') ?? 0.0;
      
      // 加载综合工时设置
      _monthlyStandardHours = prefs.getDouble('monthlyStandardHours') ?? 168.0;
    } catch (e) {
      print('加载设置失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 保存设置
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 保存计薪模式
      prefs.setInt('salaryMode', _salaryMode.index);
      
      // 保存标准工时设置
      prefs.setDouble('baseSalary', _baseSalary);
      prefs.setDouble('dailyStandardHours', _dailyStandardHours);
      prefs.setDouble('normalOvertimeRate', _normalOvertimeRate);
      prefs.setDouble('weekendOvertimeRate', _weekendOvertimeRate);
      prefs.setDouble('holidayOvertimeRate', _holidayOvertimeRate);
      
      // 保存小时工设置
      prefs.setDouble('hourlyWage', _hourlyWage);
      
      // 保存综合工时设置
      prefs.setDouble('monthlyStandardHours', _monthlyStandardHours);
      
      // 显示保存成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('设置已保存')),
      );
    } catch (e) {
      print('保存设置失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存失败，请重试')),
      );
    }
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
        title: const Text('工资设置'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 计薪模式选择
            const Text(
              '计薪模式',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<SalaryMode>(
                    title: const Text('标准工时'),
                    value: SalaryMode.standard,
                    groupValue: _salaryMode,
                    onChanged: (value) {
                      setState(() {
                        _salaryMode = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<SalaryMode>(
                    title: const Text('小时工'),
                    value: SalaryMode.hourly,
                    groupValue: _salaryMode,
                    onChanged: (value) {
                      setState(() {
                        _salaryMode = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<SalaryMode>(
                    title: const Text('综合工时'),
                    value: SalaryMode.comprehensive,
                    groupValue: _salaryMode,
                    onChanged: (value) {
                      setState(() {
                        _salaryMode = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 根据计薪模式显示不同的设置项
            if (_salaryMode == SalaryMode.standard) _buildStandardModeSettings(),
            if (_salaryMode == SalaryMode.hourly) _buildHourlyModeSettings(),
            if (_salaryMode == SalaryMode.comprehensive) _buildComprehensiveModeSettings(),
            
            const SizedBox(height: 32),
            
            // 保存按钮
            SizedBox(
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
                  '保存设置',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 标准工时模式设置
  Widget _buildStandardModeSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '标准工时设置',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        // 底薪
        _buildTextField(
          label: '底薪',
          value: _baseSalary.toStringAsFixed(2),
          onChanged: (value) {
            setState(() {
              _baseSalary = double.tryParse(value) ?? 0.0;
            });
          },
          hintText: '请输入底薪',
        ),
        const SizedBox(height: 16),
        
        // 每天标准工时
        _buildTextField(
          label: '每天标准工时',
          value: _dailyStandardHours.toStringAsFixed(1),
          onChanged: (value) {
            setState(() {
              _dailyStandardHours = double.tryParse(value) ?? 8.0;
            });
          },
          hintText: '默认8小时',
        ),
        const SizedBox(height: 16),
        
        // 加班倍数
        const Text('加班倍数', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        
        // 平时加班倍数
        _buildTextField(
          label: '平时加班',
          value: _normalOvertimeRate.toStringAsFixed(1),
          onChanged: (value) {
            setState(() {
              _normalOvertimeRate = double.tryParse(value) ?? 1.5;
            });
          },
          hintText: '默认1.5倍',
        ),
        const SizedBox(height: 8),
        
        // 周末加班倍数
        _buildTextField(
          label: '周末加班',
          value: _weekendOvertimeRate.toStringAsFixed(1),
          onChanged: (value) {
            setState(() {
              _weekendOvertimeRate = double.tryParse(value) ?? 2.0;
            });
          },
          hintText: '默认2倍',
        ),
        const SizedBox(height: 8),
        
        // 节假日加班倍数
        _buildTextField(
          label: '节假日加班',
          value: _holidayOvertimeRate.toStringAsFixed(1),
          onChanged: (value) {
            setState(() {
              _holidayOvertimeRate = double.tryParse(value) ?? 3.0;
            });
          },
          hintText: '默认3倍',
        ),
      ],
    );
  }

  /// 小时工模式设置
  Widget _buildHourlyModeSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '小时工设置',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        // 时薪
        _buildTextField(
          label: '时薪',
          value: _hourlyWage.toStringAsFixed(2),
          onChanged: (value) {
            setState(() {
              _hourlyWage = double.tryParse(value) ?? 0.0;
            });
          },
          hintText: '请输入时薪',
        ),
      ],
    );
  }

  /// 综合工时模式设置
  Widget _buildComprehensiveModeSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '综合工时设置',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        // 时薪
        _buildTextField(
          label: '时薪',
          value: _hourlyWage.toStringAsFixed(2),
          onChanged: (value) {
            setState(() {
              _hourlyWage = double.tryParse(value) ?? 0.0;
            });
          },
          hintText: '请输入时薪',
        ),
        const SizedBox(height: 16),
        
        // 月标准工时
        _buildTextField(
          label: '月标准工时',
          value: _monthlyStandardHours.toStringAsFixed(1),
          onChanged: (value) {
            setState(() {
              _monthlyStandardHours = double.tryParse(value) ?? 168.0;
            });
          },
          hintText: '默认168小时',
        ),
      ],
    );
  }

  /// 构建文本输入框
  Widget _buildTextField({
    required String label,
    required String value,
    required Function(String) onChanged,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        TextField(
          controller: TextEditingController(text: value),
          onChanged: onChanged,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }
}
