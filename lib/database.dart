import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseSqLite {
  static Future<Database> database() async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, 'my_database.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS todoList (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT
          )
        ''');
      },
    );
  }

  static Future<void> insertData(String title) async {
    final Database db = await database();

    await db.insert(
      'todoList',
      {
        'title': title
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getData() async {
    final Database db = await database();

    return db.query('todoList');
  }

  static Future<void> deleteData(int id) async {
  final Database db = await database();

  await db.delete('todoList', where: 'id = ?', whereArgs: [id]);

  await db.close();
}
}