import 'package:cricket_app/models/game_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqliteService {
  static Future<Database> initializeDB() async {
    String path = await getDatabasesPath();

    return openDatabase(
      join(path, 'database.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE archives(id INTEGER PRIMARY KEY AUTOINCREMENT, data TEXT NOT NULL, date TEXT)",
        );
      },
      version: 1,
    );
  }

  static Future<int> createItem(GameModel model) async {
    final Database db = await initializeDB();
    final id = await db.insert('archives',
        {'data': model.toJson(), 'date': model.endTime.millisecondsSinceEpoch},
        conflictAlgorithm: ConflictAlgorithm.replace);

    return id;
  }

  static Future<List<GameModel>> getItems() async {
    final db = await initializeDB();
    final List<Map<String, Object?>> queryResult =
        await db.query('archives', orderBy: 'date DESC');
    return queryResult
        .map((item) => GameModel.fromJson(item['data'].toString()))
        .toList();
  }

  static Future<void> deleteAll() async {
    final db = await initializeDB();
    await db.delete('archives');
  }

  static Future<void> delete(GameModel model) async {
    final db = await initializeDB();
    await db.delete('archives',
        where: "date = ?", whereArgs: [model.endTime.millisecondsSinceEpoch]);
  }
}
