import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database_helper.dart';
import '../../data/purchase_repository.dart';
import '../../domain/models/purchase.dart';
import '../../domain/models/purchase_item.dart';
import '../../../products/domain/models/product.dart';
import '../../../suppliers/domain/models/supplier.dart';

final purchasesProvider = StateNotifierProvider<PurchasesNotifier, AsyncValue<List<Purchase>>>((ref) {
  final repository = ref.watch(purchaseRepositoryProvider);
  return PurchasesNotifier(repository);
});

class PurchasesNotifier extends StateNotifier<AsyncValue<List<Purchase>>> {
  final PurchaseRepository _repository;

  PurchasesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadPurchases();
  }

  Future<void> loadPurchases() async {
    try {
      state = const AsyncValue.loading();
      final purchases = await _repository.getRecentPurchases();
      state = AsyncValue.data(purchases);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// ─── Purchase Cart State ───

class PurchaseCartState {
  final List<PurchaseItem> items;
  final Supplier? selectedSupplier;

  PurchaseCartState({
    this.items = const [],
    this.selectedSupplier,
  });

  double get grandTotal => items.fold(0.0, (sum, item) => sum + item.total);

  PurchaseCartState copyWith({
    List<PurchaseItem>? items,
    Supplier? selectedSupplier,
  }) {
    return PurchaseCartState(
      items: items ?? this.items,
      selectedSupplier: selectedSupplier ?? this.selectedSupplier,
    );
  }
}

final purchaseCartProvider = StateNotifierProvider<PurchaseCartNotifier, PurchaseCartState>((ref) {
  return PurchaseCartNotifier(ref.watch(purchaseRepositoryProvider), ref);
});

class PurchaseCartNotifier extends StateNotifier<PurchaseCartState> {
  final PurchaseRepository _repository;
  final Ref _ref;
  final _uuid = const Uuid();

  PurchaseCartNotifier(this._repository, this._ref) : super(PurchaseCartState());

  void addProduct(Product product) {
    final existingIndex = state.items.indexWhere((i) => i.productId == product.id);
    if (existingIndex >= 0) {
      // Increase qty
      final existing = state.items[existingIndex];
      final updated = existing.copyWith(qty: existing.qty + 1);
      final newItems = List<PurchaseItem>.from(state.items);
      newItems[existingIndex] = updated;
      state = state.copyWith(items: newItems);
    } else {
      // Add new
      final newItem = PurchaseItem(
        id: _uuid.v4(),
        purchaseId: '', // placeholder, will be set on checkout
        productId: product.id,
        qty: 1,
        price: product.purchasePrice,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        product: product,
      );
      state = state.copyWith(items: [...state.items, newItem]);
    }
  }

  void updateQty(String productId, double qty) {
    if (qty <= 0) {
      removeProduct(productId);
      return;
    }
    final existingIndex = state.items.indexWhere((i) => i.productId == productId);
    if (existingIndex >= 0) {
      final updated = state.items[existingIndex].copyWith(qty: qty);
      final newItems = List<PurchaseItem>.from(state.items);
      newItems[existingIndex] = updated;
      state = state.copyWith(items: newItems);
    }
  }

  void updatePrice(String productId, double price) {
    final existingIndex = state.items.indexWhere((i) => i.productId == productId);
    if (existingIndex >= 0) {
      final updated = state.items[existingIndex].copyWith(price: price);
      final newItems = List<PurchaseItem>.from(state.items);
      newItems[existingIndex] = updated;
      state = state.copyWith(items: newItems);
    }
  }

  void removeProduct(String productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.productId != productId).toList(),
    );
  }

  void setSupplier(Supplier? supplier) {
    state = state.copyWith(selectedSupplier: supplier);
  }

  void clearCart() {
    state = PurchaseCartState();
  }

  Future<Purchase> completePurchase() async {
    if (state.items.isEmpty) throw Exception('Purchase list is empty');

    final purchaseId = _uuid.v4();
    final now = DateTime.now();
    
    final purchase = Purchase(
      id: purchaseId,
      supplierId: state.selectedSupplier?.id,
      date: now,
      total: state.grandTotal,
      status: 'Completed',
      createdAt: now,
      updatedAt: now,
      supplier: state.selectedSupplier,
      items: state.items,
    );

    await _repository.createPurchase(purchase, state.items);
    
    // Refresh purchases list globally
    _ref.read(purchasesProvider.notifier).loadPurchases();
    
    return purchase;
  }
}
