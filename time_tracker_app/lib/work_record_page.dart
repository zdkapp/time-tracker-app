import 'dart:async';
import 'package:flutter/material.dart';
import 'database_helper.dart';

/// 记工时页面
class WorkRecordPage extends StatefulWidget {
  const WorkRecordPage({super.key});

  @override
  State<WorkRecordPage> createState() => _WorkRecordPageState();
}

class _WorkRecordPageState extends State<WorkRecordPage> {
  // 今日记录
  Map<String, dynamic>? _todayRecord;
  // 已工作时长
  double _workedHours = 0.0;
  // 计时器
  Timer? _timer;
  // 加载状态
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 加载今日记录
    _loadTodayRecord();
  }

  @override
  void dispose() {
    // 取消计时器
    _timer?.cancel();
    super.dispose();
  }

  /// 加载今日记录
  Future<void> _loadTodayRecord() async {
    try {
      _todayRecord = await DatabaseHelper.instance.getTodayRecord();
      if (_todayRecord != null && _todayRecord![DatabaseHelper.columnEndTime] == null) {
        // 已打上班卡，开始计时
        _startTimer();
      }
    } catch (e) {
      print('加载今日记录失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 开始计时
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_todayRecord != null && _todayRecord![DatabaseHelper.columnEndTime] == null) {
        setState(() {
          _workedHours = DatabaseHelper.instance.calculateHours(
            _todayRecord![DatabaseHelper.columnStartTime],
            DateTime.now().toIso8601String(),
          );
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  /// 上班打卡
  Future<void> _clockIn() async {
    try {
      DateTime now = DateTime.now();
      String date = now.toIso8601String().split('T')[0];
      String startTime = now.toIso8601String();

      Map<String, dynamic> record = {
        DatabaseHelper.columnDate: date,
        DatabaseHelper.columnStartTime: startTime,
        DatabaseHelper.columnEndTime: null,
        DatabaseHelper.columnHours: 0.0,
        DatabaseHelper.columnOvertimeType: 0,
        DatabaseHelper.columnRemark: '',
      };

      await DatabaseHelper.instance.insert(record);
      await _loadTodayRecord();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('上班打卡成功')),
      );
    } catch (e) {
      print('上班打卡失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('打卡失败，请重试')),
      );
    }
  }

  /// 下班打卡
  Future<void> _clockOut() async {
    try {
      if (_todayRecord == null) return;

      DateTime now = DateTime.now();
      String endTime = now.toIso8601String();
      double hours = DatabaseHelper.instance.calculateHours(
        _todayRecord![DatabaseHelper.columnStartTime],
        endTime,
      );

      Map<String, dynamic> updatedRecord = {
        ..._todayRecord!,
        DatabaseHelper.columnEndTime: endTime,
        DatabaseHelper.columnHours: hours,
      };

      await DatabaseHelper.instance.update(updatedRecord);
      await _loadTodayRecord();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('下班打卡成功')),
      );
    } catch (e) {
      print('下班打卡失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('打卡失败，请重试')),
      );
    }
  }

  /// 跳转到补记页面
  void _goToRecordPage() {
    // 这里可以导航到补记页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('补记功能开发中')),
    );
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部日期和星期
            _buildDateSection(),
            const SizedBox(height: 24),
            
            // 中间大卡片
            _buildWorkStatusCard(),
            const SizedBox(height: 32),
            
            // 底部补记按钮
            _buildRecordButton(),
          ],
        ),
      ),
    );
  }

  /// 构建日期和星期部分
  Widget _buildDateSection() {
    DateTime now = DateTime.now();
    String date = '${now.year}年${now.month}月${now.day}日';
    String weekday = _getWeekday(now.weekday);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          weekday,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  /// 获取星期
  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1: return '星期一';
      case 2: return '星期二';
      case 3: return '星期三';
      case 4: return '星期四';
      case 5: return '星期五';
      case 6: return '星期六';
      case 7: return '星期日';
      default: return '';
    }
  }

  /// 构建工作状态卡片
  Widget _buildWorkStatusCard() {
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
              '今日工时',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // 根据打卡状态显示不同内容
            if (_todayRecord == null) 
              _buildNotClockedInStatus()
            else if (_todayRecord![DatabaseHelper.columnEndTime] == null) 
              _buildClockedInNotOutStatus()
            else 
              _buildClockedOutStatus(),
          ],
        ),
      ),
    );
  }

  /// 未打卡状态
  Widget _buildNotClockedInStatus() {
    return Column(
      children: [
        const Text(
          '尚未打卡',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _clockIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '上班打卡',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  /// 已上班未下班状态
  Widget _buildClockedInNotOutStatus() {
    return Column(
      children: [
        Text(
          '已工作 ${_workedHours.toStringAsFixed(1)} 小时',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '开始时间: ${_formatTime(_todayRecord![DatabaseHelper.columnStartTime])}',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _clockOut,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '下班打卡',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  /// 已下班状态
  Widget _buildClockedOutStatus() {
    double hours = _todayRecord![DatabaseHelper.columnHours] ?? 0.0;
    double overtime = hours > 8 ? hours - 8 : 0.0;

    return Column(
      children: [
        Text(
          '今日总工时: ${hours.toStringAsFixed(1)} 小时',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '加班时长: ${overtime.toStringAsFixed(1)} 小时',
          style: const TextStyle(fontSize: 16, color: Colors.orange),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Text('开始时间', style: TextStyle(color: Colors.grey)),
                Text(_formatTime(_todayRecord![DatabaseHelper.columnStartTime])),
              ],
            ),
            Column(
              children: [
                const Text('结束时间', style: TextStyle(color: Colors.grey)),
                Text(_formatTime(_todayRecord![DatabaseHelper.columnEndTime])),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// 格式化时间
  String _formatTime(String? timeString) {
    if (timeString == null) return '';
    DateTime time = DateTime.parse(timeString);
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// 构建补记按钮
  Widget _buildRecordButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _goToRecordPage,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: const BorderSide(color: Colors.blue),
        ),
        child: const Text(
          '补记',
          style: TextStyle(fontSize: 16, color: Colors.blue),
        ),
      ),
    );
  }
}
  

