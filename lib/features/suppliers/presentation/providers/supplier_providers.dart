import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/supplier_repository.dart';
import '../../domain/models/supplier.dart';

final suppliersProvider = StateNotifierProvider<SuppliersNotifier, AsyncValue<List<Supplier>>>((ref) {
  final repository = ref.watch(supplierRepositoryProvider);
  return SuppliersNotifier(repository);
});

class SuppliersNotifier extends StateNotifier<AsyncValue<List<Supplier>>> {
  final SupplierRepository _repository;

  SuppliersNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadSuppliers();
  }

  Future<void> loadSuppliers() async {
    try {
      state = const AsyncValue.loading();
      final suppliers = await _repository.getSuppliers();
      state = AsyncValue.data(suppliers);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> searchSuppliers(String query) async {
    if (query.isEmpty) {
      loadSuppliers();
      return;
    }
    try {
      state = const AsyncValue.loading();
      final suppliers = await _repository.searchSuppliers(query);
      state = AsyncValue.data(suppliers);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addSupplier(Supplier supplier) async {
    await _repository.insertSupplier(supplier);
    await loadSuppliers();
  }

  Future<void> updateSupplier(Supplier supplier) async {
    await _repository.updateSupplier(supplier);
    await loadSuppliers();
  }

  Future<void> deleteSupplier(String id) async {
    await _repository.deleteSupplier(id);
    await loadSuppliers();
  }
}
