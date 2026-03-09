import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Windows平台的数据库初始化器
class DatabaseInitializer {
  /// 初始化数据库
  static void initialize() {
    // 初始化Windows平台的数据库工厂
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}
