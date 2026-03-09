import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

/// 数据库助手类
class DatabaseHelper {
  static const _databaseName = "time_tracker.db";
  static const _databaseVersion = 1;

  static const table = 'work_records';

  static const columnId = '_id';
  static const columnDate = 'date';
  static const columnStartTime = 'start_time';
  static const columnEndTime = 'end_time';
  static const columnHours = 'hours';
  static const columnOvertimeType = 'overtime_type';
  static const columnRemark = 'remark';

  // 私有构造函数
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  /// 创建表
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnDate TEXT NOT NULL,
            $columnStartTime TEXT NOT NULL,
            $columnEndTime TEXT,
            $columnHours REAL,
            $columnOvertimeType INTEGER DEFAULT 0,
            $columnRemark TEXT
          )
          ''');
  }

  /// 插入记录
  Future<int> insert(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db!.insert(table, row);
  }

  /// 查询所有记录
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database? db = await instance.database;
    return await db!.query(table);
  }

  /// 根据日期查询记录
  Future<List<Map<String, dynamic>>> queryByDate(String date) async {
    Database? db = await instance.database;
    return await db!.query(table, where: '$columnDate = ?', whereArgs: [date]);
  }

  /// 更新记录
  Future<int> update(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    int id = row[columnId];
    return await db!.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  /// 删除记录
  Future<int> delete(int id) async {
    Database? db = await instance.database;
    return await db!.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  /// 根据日期删除记录
  Future<int> deleteByDate(String date) async {
    Database? db = await instance.database;
    return await db!.delete(table, where: '$columnDate = ?', whereArgs: [date]);
  }

  /// 获取今日记录
  Future<Map<String, dynamic>?> getTodayRecord() async {
    String today = DateTime.now().toIso8601String().split('T')[0];
    List<Map<String, dynamic>> records = await queryByDate(today);
    if (records.isNotEmpty) {
      return records[0];
    }
    return null;
  }

  /// 计算工作时长
  double calculateHours(String startTime, String? endTime) {
    if (endTime == null) return 0.0;
    DateTime start = DateTime.parse(startTime);
    DateTime end = DateTime.parse(endTime);
    Duration duration = end.difference(start);
    return duration.inMinutes / 60.0;
  }
}
