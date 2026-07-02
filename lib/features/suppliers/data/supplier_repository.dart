import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_helper.dart';
import '../domain/models/supplier.dart';

final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  return SupplierRepository();
});

class SupplierRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  static const String _tableName = 'suppliers';

  Future<List<Supplier>> getSuppliers() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Supplier.fromMap(maps[i]));
  }

  Future<Supplier?> getSupplier(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Supplier.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertSupplier(Supplier supplier) async {
    final db = await _dbHelper.database;
    return await db.insert(_tableName, supplier.toMap());
  }

  Future<int> updateSupplier(Supplier supplier) async {
    final db = await _dbHelper.database;
    return await db.update(
      _tableName,
      supplier.toMap(),
      where: 'id = ?',
      whereArgs: [supplier.id],
    );
  }

  Future<int> deleteSupplier(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Supplier>> searchSuppliers(String query) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'name LIKE ? OR phone LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Supplier.fromMap(maps[i]));
  }
}
