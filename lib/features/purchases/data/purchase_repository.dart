import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../domain/models/purchase.dart';
import '../domain/models/purchase_item.dart';
import '../../suppliers/domain/models/supplier.dart';

final purchaseRepositoryProvider = Provider<PurchaseRepository>((ref) {
  return PurchaseRepository();
});

class PurchaseRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  static const String _purchasesTable = 'purchases';
  static const String _purchaseItemsTable = 'purchase_items';

  Future<void> createPurchase(Purchase purchase, List<PurchaseItem> items) async {
    final db = await _dbHelper.database;
    
    await db.transaction((txn) async {
      // 1. Generate Invoice Number if null
      String? invoiceNum = purchase.invoiceNumber;
      if (invoiceNum == null || invoiceNum.isEmpty) {
        final List<Map<String, dynamic>> maps = await txn.query(
          _purchasesTable,
          columns: ['invoice_number'],
          orderBy: 'created_at DESC',
          limit: 1,
        );
        int nextNum = 1;
        if (maps.isNotEmpty && maps.first['invoice_number'] != null) {
          final lastInvoice = maps.first['invoice_number'] as String;
          // Expected format: PINV-0001
          final parts = lastInvoice.split('-');
          if (parts.length == 2) {
            final numPart = int.tryParse(parts[1]);
            if (numPart != null) {
              nextNum = numPart + 1;
            }
          }
        }
        invoiceNum = 'PINV-${nextNum.toString().padLeft(4, '0')}';
      }

      final finalPurchase = purchase.copyWith(invoiceNumber: invoiceNum);

      // 2. Insert Purchase
      await txn.insert(_purchasesTable, finalPurchase.toMap());

      // 3. Insert Items and increase stock
      for (final item in items) {
        final finalItem = item.copyWith(purchaseId: purchase.id);
        await txn.insert(_purchaseItemsTable, finalItem.toMap());

        // Update product stock (increase for purchases)
        await txn.rawUpdate(
          'UPDATE products SET current_stock = current_stock + ? WHERE id = ?',
          [item.qty, item.productId],
        );
      }
    });
  }

  Future<List<Purchase>> getRecentPurchases() async {
    final db = await _dbHelper.database;
    
    // Join with suppliers table
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT p.*, s.name as supplier_name, s.phone as supplier_phone
      FROM $_purchasesTable p
      LEFT JOIN suppliers s ON p.supplier_id = s.id
      ORDER BY p.created_at DESC
      LIMIT 100
    ''');

    return List.generate(maps.length, (i) {
      final map = maps[i];
      Supplier? supplier;
      if (map['supplier_id'] != null) {
        supplier = Supplier(
          id: map['supplier_id'] as String,
          name: map['supplier_name'] as String? ?? 'Unknown',
          phone: map['supplier_phone'] as String?,
          createdAt: DateTime.now(), // dummy for transient
          updatedAt: DateTime.now(), // dummy for transient
        );
      }
      return Purchase.fromMap(map, supplier: supplier);
    });
  }
}
