import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  final String tableName = 'restaurants';

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'restaurants.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            rating INTEGER NOT NULL,
            category TEXT NOT NULL,
            orderDetails TEXT,
            visitDate TEXT,
            comment TEXT,
            imagePath TEXT -- Campo para armazenar o caminho da imagem
          )
        ''');
      },
    );
  }

  // Inserir um restaurante no banco de dados
  Future<int> insertRestaurant(Map<String, dynamic> restaurant) async {
    final db = await database;
    return await db.insert(tableName, restaurant);
  }

  // Obter todos os restaurantes do banco de dados
  Future<List<Map<String, dynamic>>> getRestaurants() async {
    final db = await database;
    return await db.query(tableName);
  }

  // Atualizar um restaurante no banco de dados
  Future<int> updateRestaurant(Map<String, dynamic> restaurant) async {
    final db = await database;
    return await db.update(
      tableName,
      restaurant,
      where: 'id = ?',
      whereArgs: [restaurant['id']],
    );
  }

  // Excluir um restaurante do banco de dados
  Future<int> deleteRestaurant(int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
