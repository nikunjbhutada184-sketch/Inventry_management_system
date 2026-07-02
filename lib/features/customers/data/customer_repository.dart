import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_helper.dart';
import '../domain/models/customer.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository();
});

class CustomerRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  static const String _tableName = 'customers';

  Future<List<Customer>> getCustomers() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Customer.fromMap(maps[i]));
  }

  Future<List<Customer>> searchCustomers(String query) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'name LIKE ? OR phone LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Customer.fromMap(maps[i]));
  }

  Future<void> insertCustomer(Customer customer) async {
    final db = await _dbHelper.database;
    await db.insert(_tableName, customer.toMap());
  }

  Future<void> updateCustomer(Customer customer) async {
    final db = await _dbHelper.database;
    await db.update(
      _tableName,
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<void> deleteCustomer(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
