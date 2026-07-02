import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_helper.dart';

final reportsProvider = StateNotifierProvider<ReportsNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  return ReportsNotifier();
});

class ReportsNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  ReportsNotifier() : super(const AsyncValue.loading()) {
    loadReports();
  }

  Future<void> loadReports() async {
    try {
      state = const AsyncValue.loading();
      final db = await DatabaseHelper.instance.database;

      // 1. Daily Sales
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
      final dailyRes = await db.rawQuery(
        'SELECT SUM(total) as dailyTotal FROM sales WHERE created_at >= ?',
        [startOfDay],
      );
      final dailyTotal = (dailyRes.first['dailyTotal'] as num?)?.toDouble() ?? 0.0;

      // 2. Monthly Sales
      final startOfMonth = DateTime(now.year, now.month, 1).millisecondsSinceEpoch;
      final monthlyRes = await db.rawQuery(
        'SELECT SUM(total) as monthlyTotal FROM sales WHERE created_at >= ?',
        [startOfMonth],
      );
      final monthlyTotal = (monthlyRes.first['monthlyTotal'] as num?)?.toDouble() ?? 0.0;

      // 3. Profit / Loss
      // Rough calc: Sales Total - Purchase Total
      final allSalesRes = await db.rawQuery('SELECT SUM(total) as total FROM sales');
      final totalSales = (allSalesRes.first['total'] as num?)?.toDouble() ?? 0.0;

      final allPurchasesRes = await db.rawQuery('SELECT SUM(total) as total FROM purchases');
      final totalPurchases = (allPurchasesRes.first['total'] as num?)?.toDouble() ?? 0.0;
      
      final profitLoss = totalSales - totalPurchases;

      // 4. Inventory Data (Low Stock vs In Stock)
      final lowStockRes = await db.rawQuery('SELECT COUNT(*) as count FROM products WHERE current_stock <= min_stock');
      final inStockRes = await db.rawQuery('SELECT COUNT(*) as count FROM products WHERE current_stock > min_stock');
      
      final lowStockCount = (lowStockRes.first['count'] as num?)?.toInt() ?? 0;
      final inStockCount = (inStockRes.first['count'] as num?)?.toInt() ?? 0;

      state = AsyncValue.data({
        'dailyTotal': dailyTotal,
        'monthlyTotal': monthlyTotal,
        'profitLoss': profitLoss,
        'lowStockCount': lowStockCount,
        'inStockCount': inStockCount,
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
