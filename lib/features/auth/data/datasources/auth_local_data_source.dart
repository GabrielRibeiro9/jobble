import 'package:flutter_tcc/core/database/database_helper.dart';
import 'package:flutter_tcc/features/auth/data/models/user_model.dart';
import 'package:sqflite/sqflite.dart';

abstract class AuthLocalDataSource {
  /// Insere ou atualiza o cache do usuário no banco de dados local
  Future<void> cacheUser(UserModel user);

  /// Obtém o usuário do cache local
  Future<UserModel?> getCachedUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final DatabaseHelper databaseHelper;

  AuthLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<void> cacheUser(UserModel user) async {
    final db = await databaseHelper.database;
    
    // Inserir ou substituir (upsert) baseado na PRIMARY KEY (id)
    await db.insert(
      'users_cache',
      {
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'avatarUrl': user.avatarUrl,
        'organizationId': user.organizationId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final db = await databaseHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query('users_cache');

    if (maps.isNotEmpty) {
      // Retorna o primeiro usuário encontrado no cache
      return UserModel(
        id: maps.first['id'] as String,
        name: maps.first['name'] as String?,
        email: maps.first['email'] as String,
        avatarUrl: maps.first['avatarUrl'] as String?,
        organizationId: maps.first['organizationId'] as String?,
      );
    }

    return null;
  }
}
