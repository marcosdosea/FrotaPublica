import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class LocalDatabaseService {
  static final LocalDatabaseService _instance =
      LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'frota_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE abastecimentos_offline (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicleId TEXT,
        journeyId TEXT,
        supplierId TEXT,
        liters REAL,
        odometer INTEGER,
        dateTime TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE vistorias_saida_offline (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicleId TEXT,
        journeyId TEXT,
        inspectionData TEXT,
        dateTime TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE manutencoes_offline (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicleId TEXT,
        description TEXT,
        dateTime TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE fornecedores (
        id TEXT PRIMARY KEY,
        name TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE rotas_percurso (
        journeyId TEXT PRIMARY KEY,
        routeJson TEXT
      )
    ''');
  }

  // Abastecimento offline
  Future<void> insertAbastecimentoOffline(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('abastecimentos_offline', data);
  }

  Future<List<Map<String, dynamic>>> getAbastecimentosOffline() async {
    final db = await database;
    return await db.query('abastecimentos_offline');
  }

  Future<void> deleteAbastecimentoOffline(int id) async {
    final db = await database;
    await db.delete('abastecimentos_offline', where: 'id = ?', whereArgs: [id]);
  }

  // Vistoria de saída offline
  Future<void> insertVistoriaSaidaOffline(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('vistorias_saida_offline', data);
  }

  Future<List<Map<String, dynamic>>> getVistoriasSaidaOffline() async {
    final db = await database;
    return await db.query('vistorias_saida_offline');
  }

  Future<void> deleteVistoriaSaidaOffline(int id) async {
    final db = await database;
    await db
        .delete('vistorias_saida_offline', where: 'id = ?', whereArgs: [id]);
  }

  // Manutenção offline
  Future<void> insertManutencaoOffline(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('manutencoes_offline', data);
  }

  Future<List<Map<String, dynamic>>> getManutencoesOffline() async {
    final db = await database;
    return await db.query('manutencoes_offline');
  }

  Future<void> deleteManutencaoOffline(int id) async {
    final db = await database;
    await db.delete('manutencoes_offline', where: 'id = ?', whereArgs: [id]);
  }

  // Fornecedores
  Future<void> insertOrUpdateFornecedor(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('fornecedores', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getFornecedores() async {
    final db = await database;
    return await db.query('fornecedores');
  }

  Future<void> clearAndPopulateFornecedores(
      List<Map<String, dynamic>> fornecedores) async {
    final db = await database;
    await db.delete('fornecedores');
    for (final fornecedor in fornecedores) {
      await db.insert('fornecedores', fornecedor);
    }
  }

  // Persistência de rota do percurso
  Future<void> saveRouteForJourney(String journeyId, String routeJson) async {
    final db = await database;
    await db.insert(
        'rotas_percurso',
        {
          'journeyId': journeyId,
          'routeJson': routeJson,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getRouteForJourney(String journeyId) async {
    final db = await database;
    final result = await db.query('rotas_percurso',
        where: 'journeyId = ?', whereArgs: [journeyId]);
    if (result.isNotEmpty) {
      return result.first['routeJson'] as String?;
    }
    return null;
  }

  Future<void> deleteRouteForJourney(String journeyId) async {
    final db = await database;
    await db.delete('rotas_percurso',
        where: 'journeyId = ?', whereArgs: [journeyId]);
  }

  // Retorna o maior odômetro de abastecimentos offline para um veículo e percurso
  Future<int?> getMaxOdometerAbastecimentoOffline(
      String vehicleId, String journeyId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT MAX(odometer) as maxOdometer FROM abastecimentos_offline WHERE vehicleId = ? AND journeyId = ?',
      [vehicleId, journeyId],
    );
    if (result.isNotEmpty && result.first['maxOdometer'] != null) {
      return result.first['maxOdometer'] as int;
    }
    return null;
  }
}
