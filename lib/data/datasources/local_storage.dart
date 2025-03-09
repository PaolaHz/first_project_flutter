import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalStorage {
  // Singleton pattern
  static final LocalStorage _instance = LocalStorage._internal();
  factory LocalStorage() => _instance;
  LocalStorage._internal();

  static Database? _database;

  //------------------- SharedPreferences (JWT y sesión) -------------------
  static const _jwtKey = 'jwt_token';
  static const _timestampKey = 'login_timestamp';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_jwtKey, token);
    await prefs.setString(_timestampKey, DateTime.now().toString());
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_jwtKey);
  }

  static Future<bool> isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getString(_timestampKey);
    
    if (timestamp == null) return false;
    
    final loginDate = DateTime.parse(timestamp);
    final difference = DateTime.now().difference(loginDate);
    return difference.inDays < 7;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_jwtKey);
    await prefs.remove(_timestampKey);
  }

  //------------------- SQLite (Favoritos) -------------------
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }


   static Future<void> initDatabase() async {
    _database = await _initDatabase();
  }

  static Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'favorites.db');
    
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favorites(
            id INTEGER PRIMARY KEY,
            articleId INTEGER UNIQUE
          )
        ''');
      },
    );
  }

  static Future<void> insertFavorite(int articleId) async {
    final db = await database;
    await db.insert(
      'favorites',
      {'articleId': articleId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteFavorite(int articleId) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'articleId = ?',
      whereArgs: [articleId],
    );
  }

  static Future<List<int>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');
    return List.generate(maps.length, (i) => maps[i]['articleId'] as int);
  }

  static Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('favorites');
  }
}