import 'package:parcial_moviles_1/domain/articulo.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    // Eliminar la base de datos si es necesario (solo en desarrollo)
    await deleteDatabase(path);  
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY,
        user_id INTEGER,
        image_id INTEGER,
        itemName TEXT,
        calification INTEGER,
        vendedor TEXT,
        rating BOOLEAN
      )
    ''');
  }

  /// Insertar un ítem con el mismo ID del backend
  Future<void> insertItem(Map<String, dynamic> item) async {
    final db = await database;
    try {
      await db.insert('items', item, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print("Error al insertar ítem: $e");
    }
  }

  Future<List<Articulo>> getAllArticulos() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('items');
    
    return List.generate(maps.length, (i) {
      return Articulo(
        nombre: maps[i]['itemName'],
        vendedor: maps[i]['vendedor'],
        calificacion: maps[i]['calification'].toString(),
        imageId: maps[i]['image_id'],
        esFavorito: maps[i]['rating'] == 1,
      );
    });
  }

  /// Eliminar todos los ítems de la BD
  Future<int> deleteAllItems() async {
    Database db = await instance.database;
    return await db.delete('items');
  }
}
