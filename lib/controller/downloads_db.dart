import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DownloadsDB {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'downloads.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE downloads (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            lessonId INTEGER,
            title TEXT,
            localPath TEXT
          )
        ''');
      },
    );
  }

  static Future<void> insertDownload(
      int lessonId, String title, String localPath) async {
    final db = await database;
    await db.insert(
      'downloads',
      {
        'lessonId': lessonId,
        'title': title,
        'localPath': localPath,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getAllDownloads() async {
    final db = await database;
    return await db.query('downloads');
  }

  static Future<void> deleteDownload(int id) async {
    final db = await database;
    await db.delete('downloads', where: 'id = ?', whereArgs: [id]);
  }
}
