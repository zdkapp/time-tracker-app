import 'package:flutter/material.dart';

/// 个人页面
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 用户信息
  Map<String, dynamic> _userInfo = {
    'name': '张三',
    'phone': '13800138000',
    'department': '生产部',
    'position': '操作工',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息卡片
            _buildUserInfoCard(),
            const SizedBox(height: 24),
            
            // 功能选项
            _buildFunctionOptions(),
            const SizedBox(height: 24),
            
            // 关于应用
            _buildAboutSection(),
            const SizedBox(height: 32), // 添加底部间距
          ],
        ),
      ),
    );
  }

  /// 构建用户信息卡片
  Widget _buildUserInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            // 用户头像
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
              child: const Center(
                child: Text(
                  '张',
                  style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 24),
            
            // 用户信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userInfo['name'],
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_userInfo['department']} - ${_userInfo['position']}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _userInfo['phone'],
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建功能选项
  Widget _buildFunctionOptions() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // 工资设置
          _buildOptionItem(
            icon: Icons.settings,
            title: '工资设置',
            onTap: () {
              Navigator.pushNamed(context, '/salary_setting');
            },
          ),
          const Divider(),
          
          // 历史记录
          _buildOptionItem(
            icon: Icons.history,
            title: '历史记录',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('历史记录功能开发中')),
              );
            },
          ),
          const Divider(),
          
          // 数据导出
          _buildOptionItem(
            icon: Icons.file_download,
            title: '数据导出',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('数据导出功能开发中')),
              );
            },
          ),
          const Divider(),
          
          // 帮助与反馈
          _buildOptionItem(
            icon: Icons.help,
            title: '帮助与反馈',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('帮助与反馈功能开发中')),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 构建选项项
  Widget _buildOptionItem({required IconData icon, required String title, required Function() onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  /// 构建关于应用部分
  Widget _buildAboutSection() {
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
              '工时记录',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '版本 1.0.0',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text(
              '为蓝领工人打造的工时记录和工资计算工具',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
