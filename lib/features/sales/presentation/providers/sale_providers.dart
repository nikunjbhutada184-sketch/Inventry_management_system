import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/sale_repository.dart';
import '../../domain/models/sale.dart';
import '../../domain/models/sale_item.dart';
import '../../../products/domain/models/product.dart';
import '../../../customers/domain/models/customer.dart';

final salesProvider = StateNotifierProvider<SalesNotifier, AsyncValue<List<Sale>>>((ref) {
  final repository = ref.watch(saleRepositoryProvider);
  return SalesNotifier(repository);
});

class SalesNotifier extends StateNotifier<AsyncValue<List<Sale>>> {
  final SaleRepository _repository;

  SalesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadSales();
  }

  Future<void> loadSales() async {
    try {
      state = const AsyncValue.loading();
      final sales = await _repository.getRecentSales();
      state = AsyncValue.data(sales);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// ─── POS Cart State ───

class CartState {
  final List<SaleItem> items;
  final Customer? selectedCustomer;
  final double discount;
  final double taxPercent;
  final String paymentMethod;

  CartState({
    this.items = const [],
    this.selectedCustomer,
    this.discount = 0.0,
    this.taxPercent = 0.0,
    this.paymentMethod = 'Cash',
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.total);
  double get taxAmount => (subtotal - discount) * (taxPercent / 100);
  double get grandTotal => subtotal - discount + taxAmount;

  CartState copyWith({
    List<SaleItem>? items,
    Customer? selectedCustomer,
    double? discount,
    double? taxPercent,
    String? paymentMethod,
  }) {
    return CartState(
      items: items ?? this.items,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      discount: discount ?? this.discount,
      taxPercent: taxPercent ?? this.taxPercent,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(ref.watch(saleRepositoryProvider), ref);
});

class CartNotifier extends StateNotifier<CartState> {
  final SaleRepository _repository;
  final Ref _ref;
  final _uuid = const Uuid();

  CartNotifier(this._repository, this._ref) : super(CartState());

  void addProduct(Product product) {
    final existingIndex = state.items.indexWhere((i) => i.productId == product.id);
    if (existingIndex >= 0) {
      // Increase qty
      final existing = state.items[existingIndex];
      final updated = existing.copyWith(qty: existing.qty + 1);
      final newItems = List<SaleItem>.from(state.items);
      newItems[existingIndex] = updated;
      state = state.copyWith(items: newItems);
    } else {
      // Add new
      final newItem = SaleItem(
        id: _uuid.v4(),
        saleId: '', // placeholder, will be set on checkout
        productId: product.id,
        qty: 1,
        price: product.sellingPrice,
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
      final newItems = List<SaleItem>.from(state.items);
      newItems[existingIndex] = updated;
      state = state.copyWith(items: newItems);
    }
  }

  void removeProduct(String productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.productId != productId).toList(),
    );
  }

  void setCustomer(Customer? customer) {
    state = state.copyWith(selectedCustomer: customer);
  }

  void setDiscount(double discount) {
    state = state.copyWith(discount: discount);
  }

  void setTax(double percent) {
    state = state.copyWith(taxPercent: percent);
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  void clearCart() {
    state = CartState();
  }

  Future<Sale> checkout() async {
    if (state.items.isEmpty) throw Exception('Cart is empty');

    final saleId = _uuid.v4();
    final now = DateTime.now();
    
    final sale = Sale(
      id: saleId,
      customerId: state.selectedCustomer?.id,
      date: now,
      subtotal: state.subtotal,
      discount: state.discount,
      tax: state.taxAmount,
      total: state.grandTotal,
      paymentMethod: state.paymentMethod,
      status: 'Completed',
      createdAt: now,
      updatedAt: now,
      customer: state.selectedCustomer,
      items: state.items,
    );

    await _repository.createSale(sale, state.items);
    
    // Refresh sales list globally
    _ref.read(salesProvider.notifier).loadSales();
    
    return sale;
  }
}
