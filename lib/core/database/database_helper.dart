import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Obter o diretório padrão para armazenar os bancos de dados
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'app_database.db');

    // Abre o banco de dados e cria as tabelas se não existirem
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Criação da tabela de cache de usuários
    await db.execute('''
      CREATE TABLE users_cache (
        id TEXT PRIMARY KEY,
        name TEXT,
        email TEXT NOT NULL,
        avatarUrl TEXT,
        professionalProfileId TEXT
      )
    ''');
  }

  // Método utilitário para deletar o banco de dados caso seja necessário num futuro (ex: logout)
  Future<void> deleteDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'app_database.db');
    await deleteDatabase(path);
    _database = null;
  }
}
