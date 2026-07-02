import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../domain/models/sale.dart';
import '../domain/models/sale_item.dart';
import '../../customers/domain/models/customer.dart';

final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  return SaleRepository();
});

class SaleRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  static const String _salesTable = 'sales';
  static const String _saleItemsTable = 'sale_items';

  Future<String> _generateInvoiceNumber(Database db) async {
    final List<Map<String, dynamic>> maps = await db.query(
      _salesTable,
      columns: ['invoice_number'],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    
    int nextNum = 1;
    if (maps.isNotEmpty && maps.first['invoice_number'] != null) {
      final lastInvoice = maps.first['invoice_number'] as String;
      // Expected format: INV-0001
      final parts = lastInvoice.split('-');
      if (parts.length == 2) {
        final numPart = int.tryParse(parts[1]);
        if (numPart != null) {
          nextNum = numPart + 1;
        }
      }
    }
    
    return 'INV-${nextNum.toString().padLeft(4, '0')}';
  }

  Future<void> createSale(Sale sale, List<SaleItem> items) async {
    final db = await _dbHelper.database;
    
    await db.transaction((txn) async {
      // 1. Generate Invoice Number if null
      String? invoiceNum = sale.invoiceNumber;
      if (invoiceNum == null || invoiceNum.isEmpty) {
        // Wait, _generateInvoiceNumber takes Database, but we are inside txn.
        // We can just query txn
        final List<Map<String, dynamic>> maps = await txn.query(
          _salesTable,
          columns: ['invoice_number'],
          orderBy: 'created_at DESC',
          limit: 1,
        );
        int nextNum = 1;
        if (maps.isNotEmpty && maps.first['invoice_number'] != null) {
          final lastInvoice = maps.first['invoice_number'] as String;
          final parts = lastInvoice.split('-');
          if (parts.length == 2) {
            final numPart = int.tryParse(parts[1]);
            if (numPart != null) {
              nextNum = numPart + 1;
            }
          }
        }
        invoiceNum = 'INV-${nextNum.toString().padLeft(4, '0')}';
      }

      final finalSale = sale.copyWith(invoiceNumber: invoiceNum);

      // 2. Insert Sale
      await txn.insert(_salesTable, finalSale.toMap());

      // 3. Insert Items and update stock
      for (final item in items) {
        final finalItem = item.copyWith(saleId: sale.id);
        await txn.insert(_saleItemsTable, finalItem.toMap());

        // Update product stock
        await txn.rawUpdate(
          'UPDATE products SET current_stock = current_stock - ? WHERE id = ?',
          [item.qty, item.productId],
        );
      }
    });
  }

  Future<List<Sale>> getRecentSales() async {
    final db = await _dbHelper.database;
    
    // Use raw query to join with customers table
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT s.*, c.name as customer_name, c.phone as customer_phone
      FROM $_salesTable s
      LEFT JOIN customers c ON s.customer_id = c.id
      ORDER BY s.created_at DESC
      LIMIT 100
    ''');

    return List.generate(maps.length, (i) {
      final map = maps[i];
      Customer? customer;
      if (map['customer_id'] != null) {
        customer = Customer(
          id: map['customer_id'] as String,
          name: map['customer_name'] as String? ?? 'Unknown',
          phone: map['customer_phone'] as String?,
          createdAt: DateTime.now(), // dummy for transient
          updatedAt: DateTime.now(), // dummy for transient
        );
      }
      return Sale.fromMap(map, customer: customer);
    });
  }
}
