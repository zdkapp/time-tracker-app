import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

// 假类型
enum LeaveType {
  none,
  rest,
  personalLeave,
  sickLeave,
}

/// 记工时页面
class WorkRecordPage extends StatefulWidget {
  const WorkRecordPage({super.key});

  @override
  State<WorkRecordPage> createState() => _WorkRecordPageState();
}

class _WorkRecordPageState extends State<WorkRecordPage> {
  // 日历控制器
  CalendarFormat _calendarFormat = CalendarFormat.month;
  // 选中的日期
  DateTime _selectedDay = DateTime.now();
  // 焦点日期
  DateTime _focusedDay = DateTime.now();
  // 工时记录映射
  Map<String, Map<String, dynamic>> _workHoursMap = {};
  // 工时控制器
  TextEditingController _hoursController = TextEditingController();
  // 加载状态
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 加载工时记录
    _loadWorkHours();
  }

  @override
  void dispose() {
    _hoursController.dispose();
    super.dispose();
  }

  /// 加载工时记录
  Future<void> _loadWorkHours() async {
    try {
      // 获取当月的开始和结束日期
      DateTime now = _focusedDay;
      DateTime startOfMonth = DateTime(now.year, now.month, 1);
      DateTime endOfMonth = DateTime(now.year, now.month + 1, 0);

      // 构建工时记录映射
      Map<String, Map<String, dynamic>> workHoursMap = {};
      
      // 首先尝试从数据库加载数据
      try {
        List<Map<String, dynamic>> records = await DatabaseHelper.instance.getRecordsInRange(
          startOfMonth.toIso8601String().split('T')[0],
          endOfMonth.toIso8601String().split('T')[0],
        );

        for (var record in records) {
          String dateString = record[DatabaseHelper.columnDate];
          double hours = record[DatabaseHelper.columnHours] ?? 0.0;
          String remark = record[DatabaseHelper.columnRemark] ?? '';
          workHoursMap[dateString] = {
            'hours': hours,
            'leaveType': _getLeaveTypeFromRemark(remark).index // 确保存储的是索引值
          };
        }
      } catch (e) {
        print('从数据库加载工时记录失败: $e');
        // 数据库加载失败，尝试从本地存储加载
        await _loadFromLocalStorage(workHoursMap, startOfMonth, endOfMonth);
      }

      setState(() {
        _workHoursMap = workHoursMap;
        _isLoading = false;
      });
    } catch (e) {
      print('加载工时记录失败: $e');
      // 即使加载失败，也设置加载状态为false，让用户可以使用应用
      setState(() {
        _isLoading = false;
        // 显示错误提示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('加载工时记录失败，数据可能无法保存')),
        );
      });
    }
  }

  /// 从本地存储加载数据
  Future<void> _loadFromLocalStorage(Map<String, Map<String, dynamic>> workHoursMap, DateTime startOfMonth, DateTime endOfMonth) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String monthKey = 'work_hours_${startOfMonth.year}_${startOfMonth.month}';
      String? savedData = prefs.getString(monthKey);
      
      if (savedData != null) {
        Map<String, dynamic> data = jsonDecode(savedData);
        data.forEach((key, value) {
          if (value is Map) {
            // 确保leaveType是int类型
            int leaveTypeIndex = 0;
            if (value['leaveType'] != null) {
              if (value['leaveType'] is int) {
                leaveTypeIndex = value['leaveType'];
              } else if (value['leaveType'] is String) {
                // 尝试从字符串解析
                try {
                  leaveTypeIndex = int.parse(value['leaveType']);
                } catch (e) {
                  leaveTypeIndex = 0;
                }
              }
            }
            workHoursMap[key] = {
              'hours': value['hours'] ?? 0.0,
              'leaveType': leaveTypeIndex
            };
          } else {
            // 兼容旧数据格式
            workHoursMap[key] = {
              'hours': double.tryParse(value.toString()) ?? 0.0,
              'leaveType': 0 // 使用索引值
            };
          }
        });
      }
    } catch (e) {
      print('从本地存储加载工时记录失败: $e');
    }
  }

  /// 从备注获取假类型
  LeaveType _getLeaveTypeFromRemark(String remark) {
    switch (remark) {
      case '休息':
        return LeaveType.rest;
      case '事假':
        return LeaveType.personalLeave;
      case '病假':
        return LeaveType.sickLeave;
      default:
        return LeaveType.none;
    }
  }

  /// 保存工时记录
  Future<void> _saveWorkHours(DateTime date, double hours, LeaveType leaveType) async {
    try {
      String dateString = date.toIso8601String().split('T')[0];
      String remark = '';
      
      // 根据假类型设置备注
      switch (leaveType) {
        case LeaveType.rest:
          remark = '休息';
          hours = 0;
          break;
        case LeaveType.personalLeave:
          remark = '事假';
          hours = 0;
          break;
        case LeaveType.sickLeave:
          remark = '病假';
          hours = 0;
          break;
        default:
          if (hours <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('请输入有效的工时')),
            );
            return;
          }
      }

      // 尝试保存到数据库
      bool dbSaved = false;
      try {
        // 检查是否已有记录
        List<Map<String, dynamic>> records = await DatabaseHelper.instance.queryByDate(dateString);

        if (records.isEmpty) {
          // 创建新记录
          Map<String, dynamic> record = {
            DatabaseHelper.columnDate: dateString,
            DatabaseHelper.columnStartTime: DateTime.now().toIso8601String(),
            DatabaseHelper.columnEndTime: DateTime.now().toIso8601String(),
            DatabaseHelper.columnHours: hours,
            DatabaseHelper.columnOvertimeType: 0,
            DatabaseHelper.columnRemark: remark,
          };

          int result = await DatabaseHelper.instance.insert(record);
          dbSaved = result != -1;
        } else {
          // 更新现有记录
          Map<String, dynamic> updatedRecord = {
            ...records[0],
            DatabaseHelper.columnHours: hours,
            DatabaseHelper.columnRemark: remark,
          };

          int result = await DatabaseHelper.instance.update(updatedRecord);
          dbSaved = result != -1;
        }
      } catch (e) {
        print('保存到数据库失败: $e');
        dbSaved = false;
      }

      // 无论数据库是否保存成功，都保存到本地存储作为备选
      await _saveToLocalStorage(dateString, hours, leaveType);

      // 更新工时记录映射
      setState(() {
        _workHoursMap[dateString] = {
          'hours': hours,
          'leaveType': leaveType.index
        };
      });

      if (dbSaved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('记录保存成功')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('记录已保存到本地，可能无法同步到数据库')),
        );
      }
    } catch (e) {
      print('保存记录失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存失败，请重试')),
      );
      // 即使保存失败，也更新本地映射，让用户看到界面变化
      setState(() {
        String dateString = date.toIso8601String().split('T')[0];
        _workHoursMap[dateString] = {
          'hours': leaveType == LeaveType.none ? double.tryParse(_hoursController.text) ?? 0.0 : 0,
          'leaveType': leaveType.index
        };
      });
    }
  }

  /// 保存到本地存储
  Future<void> _saveToLocalStorage(String dateString, double hours, LeaveType leaveType) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      DateTime date = DateTime.parse(dateString);
      String monthKey = 'work_hours_${date.year}_${date.month}';
      
      // 获取当月的所有数据
      String? savedData = prefs.getString(monthKey);
      Map<String, dynamic> data = savedData != null ? jsonDecode(savedData) : {};
      
      // 更新或添加当前日期的数据
      data[dateString] = {
        'hours': hours,
        'leaveType': leaveType.index // 确保存储的是索引值
      };
      
      // 保存回本地存储
      await prefs.setString(monthKey, jsonEncode(data));
    } catch (e) {
      print('保存到本地存储失败: $e');
    }
  }

  /// 显示工时输入对话框
  void _showWorkHoursDialog(DateTime date) {
    // 检查是否已有工时记录
    String dateString = date.toIso8601String().split('T')[0];
    double existingHours = 0.0;
    LeaveType selectedLeaveType = LeaveType.none;
    
    if (_workHoursMap.containsKey(dateString)) {
      existingHours = _workHoursMap[dateString]!['hours'] ?? 0.0;
      int leaveTypeIndex = _workHoursMap[dateString]!['leaveType'] ?? 0;
      selectedLeaveType = LeaveType.values[leaveTypeIndex];
    }
    
    _hoursController.text = existingHours.toString();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('${date.year}年${date.month}月${date.day}日 记录'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 假类型选项
                  Column(
                    children: [
                      RadioListTile<LeaveType>(
                        title: const Text('正常工作'),
                        value: LeaveType.none,
                        groupValue: selectedLeaveType,
                        onChanged: (value) {
                          setState(() {
                            selectedLeaveType = value!;
                          });
                        },
                      ),
                      RadioListTile<LeaveType>(
                        title: const Text('休息'),
                        value: LeaveType.rest,
                        groupValue: selectedLeaveType,
                        onChanged: (value) {
                          setState(() {
                            selectedLeaveType = value!;
                          });
                        },
                      ),
                      RadioListTile<LeaveType>(
                        title: const Text('事假'),
                        value: LeaveType.personalLeave,
                        groupValue: selectedLeaveType,
                        onChanged: (value) {
                          setState(() {
                            selectedLeaveType = value!;
                          });
                        },
                      ),
                      RadioListTile<LeaveType>(
                        title: const Text('病假'),
                        value: LeaveType.sickLeave,
                        groupValue: selectedLeaveType,
                        onChanged: (value) {
                          setState(() {
                            selectedLeaveType = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  
                  // 工时输入（仅当选择正常工作时显示）
                  if (selectedLeaveType == LeaveType.none) 
                    TextField(
                      controller: _hoursController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '请输入工时',
                        border: OutlineInputBorder(),
                        suffixText: '小时',
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    double hours = double.tryParse(_hoursController.text) ?? 0.0;
                    _saveWorkHours(date, hours, selectedLeaveType);
                    Navigator.pop(context);
                  },
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// 获取工时颜色
  Color _getWorkHoursColor(DateTime date) {
    String dateString = date.toIso8601String().split('T')[0];
    if (_workHoursMap.containsKey(dateString)) {
      Map<String, dynamic> record = _workHoursMap[dateString]!;
      // 确保leaveType是int类型
      int leaveTypeIndex = 0;
      if (record['leaveType'] != null) {
        if (record['leaveType'] is int) {
          leaveTypeIndex = record['leaveType'];
        } else if (record['leaveType'] is String) {
          // 尝试从字符串解析
          try {
            leaveTypeIndex = int.parse(record['leaveType']);
          } catch (e) {
            leaveTypeIndex = 0;
          }
        }
      }
      // 确保索引值在有效范围内
      if (leaveTypeIndex < 0 || leaveTypeIndex >= LeaveType.values.length) {
        leaveTypeIndex = 0;
      }
      LeaveType leaveType = LeaveType.values[leaveTypeIndex];
      
      switch (leaveType) {
        case LeaveType.rest:
          return Colors.grey[200]!;
        case LeaveType.personalLeave:
          return Colors.orange[100]!;
        case LeaveType.sickLeave:
          return Colors.red[100]!;
        default:
          double hours = record['hours'] ?? 0.0;
          if (hours == 0) {
            return Colors.grey[200]!;
          } else if (hours < 8) {
            return Colors.yellow[100]!;
          } else if (hours == 8) {
            return Colors.green[100]!;
          } else {
            return Colors.blue[100]!;
          }
      }
    } else {
      return Colors.grey[200]!;
    }
  }

  /// 计算当月总工时
  double _calculateTotalWorkHours() {
    double total = 0.0;
    DateTime now = _focusedDay;
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    for (int day = startOfMonth.day; day <= endOfMonth.day; day++) {
      DateTime date = DateTime(now.year, now.month, day);
      String dateString = date.toIso8601String().split('T')[0];
      if (_workHoursMap.containsKey(dateString)) {
        double hours = _workHoursMap[dateString]!['hours'] ?? 0.0;
        total += hours;
      }
    }
    
    return total;
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
        title: const Text('记工时'),
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
            // 日历
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // 年月选择和总工时
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // 年选择器
                            DropdownButton<int>(
                              value: _focusedDay.year,
                              items: List.generate(10, (index) {
                                int year = DateTime.now().year - 5 + index;
                                return DropdownMenuItem<int>(
                                  value: year,
                                  child: Text('$year年'),
                                );
                              }),
                              onChanged: (value) {
                                setState(() {
                                  _focusedDay = DateTime(value!, _focusedDay.month, 1);
                                  _selectedDay = _focusedDay;
                                });
                              },
                            ),
                            const SizedBox(width: 16),
                            // 月选择器
                            DropdownButton<int>(
                              value: _focusedDay.month,
                              items: List.generate(12, (index) {
                                int month = index + 1;
                                return DropdownMenuItem<int>(
                                  value: month,
                                  child: Text('$month月'),
                                );
                              }),
                              onChanged: (value) {
                                setState(() {
                                  _focusedDay = DateTime(_focusedDay.year, value!, 1);
                                  _selectedDay = _focusedDay;
                                });
                              },
                            ),
                          ],
                        ),
                        Text(
                          '总工时: ${_calculateTotalWorkHours().toStringAsFixed(1)}h',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      constraints: const BoxConstraints(
                        maxHeight: 400, // 限制日历高度
                      ),
                      child: TableCalendar(
                        firstDay: DateTime.now().subtract(const Duration(days: 365)),
                        lastDay: DateTime.now().add(const Duration(days: 365)),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                          // 显示工时输入对话框
                          _showWorkHoursDialog(selectedDay);
                        },
                        calendarFormat: _calendarFormat,
                        onFormatChanged: (format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          setState(() {
                            _focusedDay = focusedDay;
                          });
                        },
                        headerVisible: false, // 隐藏默认的月份标题
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(color: Colors.black),
                          weekendStyle: TextStyle(color: Colors.black),
                        ),
                        // 使用 calendarBuilders 来自定义星期几的显示
                        calendarBuilders: CalendarBuilders(
                          dowBuilder: (context, date) {
                            Widget textWidget;
                            switch (date.weekday) {
                              case 1: textWidget = const Text('周一'); break;
                              case 2: textWidget = const Text('周二'); break;
                              case 3: textWidget = const Text('周三'); break;
                              case 4: textWidget = const Text('周四'); break;
                              case 5: textWidget = const Text('周五'); break;
                              case 6: textWidget = const Text('周六'); break;
                              case 7: textWidget = const Text('周日'); break;
                              default: textWidget = const Text(''); break;
                            }
                            return Container(
                              alignment: Alignment.center,
                              child: textWidget,
                            );
                          },
                          defaultBuilder: (context, date, focusedDay) {
                          String dateString = date.toIso8601String().split('T')[0];
                          double hours = 0.0;
                          String leaveText = '';
                          
                          if (_workHoursMap.containsKey(dateString)) {
                            Map<String, dynamic> record = _workHoursMap[dateString]!;
                            hours = record['hours'] ?? 0.0;
                            // 确保leaveType是int类型
                            int leaveTypeIndex = 0;
                            if (record['leaveType'] != null) {
                              if (record['leaveType'] is int) {
                                leaveTypeIndex = record['leaveType'];
                              } else if (record['leaveType'] is String) {
                                // 尝试从字符串解析
                                try {
                                  leaveTypeIndex = int.parse(record['leaveType']);
                                } catch (e) {
                                  leaveTypeIndex = 0;
                                }
                              }
                            }
                            // 确保索引值在有效范围内
                            if (leaveTypeIndex < 0 || leaveTypeIndex >= LeaveType.values.length) {
                              leaveTypeIndex = 0;
                            }
                            LeaveType leaveType = LeaveType.values[leaveTypeIndex];
                            
                            switch (leaveType) {
                              case LeaveType.rest:
                                leaveText = '休息';
                                break;
                              case LeaveType.personalLeave:
                                leaveText = '事假';
                                break;
                              case LeaveType.sickLeave:
                                leaveText = '病假';
                                break;
                              default:
                                break;
                            }
                          }
                          
                          return Container(
                            margin: const EdgeInsets.all(4.0),
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: _getWorkHoursColor(date),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            width: 100,
                            height: 100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: isSameDay(date, _selectedDay) ? Colors.blue : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                if (leaveText.isNotEmpty) 
                                  Text(
                                    leaveText,
                                    style: const TextStyle(fontSize: 9.0, color: Colors.black54),
                                    textAlign: TextAlign.center,
                                  ),
                                if (hours > 0 && leaveText.isEmpty) 
                                  Text(
                                    '${hours.toStringAsFixed(1)}h',
                                    style: const TextStyle(fontSize: 9.0, color: Colors.black54),
                                    textAlign: TextAlign.center,
                                  ),
                              ],
                            ),
                          );
                        },
                        selectedBuilder: (context, date, focusedDay) {
                          String dateString = date.toIso8601String().split('T')[0];
                          double hours = 0.0;
                          String leaveText = '';
                          
                          if (_workHoursMap.containsKey(dateString)) {
                            Map<String, dynamic> record = _workHoursMap[dateString]!;
                            hours = record['hours'] ?? 0.0;
                            // 确保leaveType是int类型
                            int leaveTypeIndex = 0;
                            if (record['leaveType'] != null) {
                              if (record['leaveType'] is int) {
                                leaveTypeIndex = record['leaveType'];
                              } else if (record['leaveType'] is String) {
                                // 尝试从字符串解析
                                try {
                                  leaveTypeIndex = int.parse(record['leaveType']);
                                } catch (e) {
                                  leaveTypeIndex = 0;
                                }
                              }
                            }
                            // 确保索引值在有效范围内
                            if (leaveTypeIndex < 0 || leaveTypeIndex >= LeaveType.values.length) {
                              leaveTypeIndex = 0;
                            }
                            LeaveType leaveType = LeaveType.values[leaveTypeIndex];
                            
                            switch (leaveType) {
                              case LeaveType.rest:
                                leaveText = '休息';
                                break;
                              case LeaveType.personalLeave:
                                leaveText = '事假';
                                break;
                              case LeaveType.sickLeave:
                                leaveText = '病假';
                                break;
                              default:
                                break;
                            }
                          }
                          
                          return Container(
                            margin: const EdgeInsets.all(4.0),
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            width: 100,
                            height: 100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '${date.day}',
                                  style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(height: 2),
                                if (leaveText.isNotEmpty) 
                                  Text(
                                    leaveText,
                                    style: const TextStyle(fontSize: 9.0, color: Colors.white70),
                                    textAlign: TextAlign.center,
                                  ),
                                if (hours > 0 && leaveText.isEmpty) 
                                  Text(
                                    '${hours.toStringAsFixed(1)}h',
                                    style: const TextStyle(fontSize: 9.0, color: Colors.white70),
                                    textAlign: TextAlign.center,
                                  ),
                              ],
                            ),
                          );
                        },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // 工时说明
            _buildWorkHoursLegend(),
            const SizedBox(height: 32), // 添加底部间距
          ],
        ),
      ),
    );
  }

  /// 构建工时说明
  Widget _buildWorkHoursLegend() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '工时说明',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('未记录工时'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.yellow[100],
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('工时不足8小时'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('标准工时8小时'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('加班工时'),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '假期说明',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('休息'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('事假'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('病假'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}