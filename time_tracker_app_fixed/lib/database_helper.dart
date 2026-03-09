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
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, _databaseName);
      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
      );
    } catch (e) {
      print('初始化数据库失败: $e');
      // 抛出错误，让调用者知道数据库初始化失败
      rethrow;
    }
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
    try {
      Database? db = await instance.database;
      if (db != null) {
        return await db.insert(table, row);
      } else {
        print('数据库未初始化，无法插入记录');
        return -1;
      }
    } catch (e) {
      print('插入记录失败: $e');
      return -1;
    }
  }

  /// 查询所有记录
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    try {
      Database? db = await instance.database;
      if (db != null) {
        return await db.query(table);
      } else {
        print('数据库未初始化，无法查询记录');
        return [];
      }
    } catch (e) {
      print('查询记录失败: $e');
      return [];
    }
  }

  /// 根据日期查询记录
  Future<List<Map<String, dynamic>>> queryByDate(String date) async {
    try {
      Database? db = await instance.database;
      if (db != null) {
        return await db.query(table, where: '$columnDate = ?', whereArgs: [date]);
      } else {
        print('数据库未初始化，无法查询记录');
        return [];
      }
    } catch (e) {
      print('查询记录失败: $e');
      return [];
    }
  }

  /// 更新记录
  Future<int> update(Map<String, dynamic> row) async {
    try {
      Database? db = await instance.database;
      if (db != null) {
        int id = row[columnId];
        return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
      } else {
        print('数据库未初始化，无法更新记录');
        return -1;
      }
    } catch (e) {
      print('更新记录失败: $e');
      return -1;
    }
  }

  /// 删除记录
  Future<int> delete(int id) async {
    try {
      Database? db = await instance.database;
      if (db != null) {
        return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
      } else {
        print('数据库未初始化，无法删除记录');
        return -1;
      }
    } catch (e) {
      print('删除记录失败: $e');
      return -1;
    }
  }

  /// 根据日期删除记录
  Future<int> deleteByDate(String date) async {
    try {
      Database? db = await instance.database;
      if (db != null) {
        return await db.delete(table, where: '$columnDate = ?', whereArgs: [date]);
      } else {
        print('数据库未初始化，无法删除记录');
        return -1;
      }
    } catch (e) {
      print('删除记录失败: $e');
      return -1;
    }
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

  /// 查询指定日期范围内的记录
  Future<List<Map<String, dynamic>>> getRecordsInRange(String startDate, String endDate) async {
    try {
      Database? db = await instance.database;
      if (db != null) {
        return await db.query(
          table,
          where: '$columnDate >= ? AND $columnDate <= ?',
          whereArgs: [startDate, endDate],
          orderBy: '$columnDate ASC',
        );
      } else {
        print('数据库未初始化，无法查询记录');
        return [];
      }
    } catch (e) {
      print('查询记录失败: $e');
      return [];
    }
  }
}
