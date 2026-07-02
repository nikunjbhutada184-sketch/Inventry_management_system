import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/customer_repository.dart';
import '../../domain/models/customer.dart';

final customersProvider = StateNotifierProvider<CustomersNotifier, AsyncValue<List<Customer>>>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return CustomersNotifier(repository);
});

class CustomersNotifier extends StateNotifier<AsyncValue<List<Customer>>> {
  final CustomerRepository _repository;

  CustomersNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    try {
      state = const AsyncValue.loading();
      final customers = await _repository.getCustomers();
      state = AsyncValue.data(customers);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> searchCustomers(String query) async {
    if (query.isEmpty) {
      return loadCustomers();
    }
    try {
      state = const AsyncValue.loading();
      final customers = await _repository.searchCustomers(query);
      state = AsyncValue.data(customers);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addCustomer(Customer customer) async {
    try {
      await _repository.insertCustomer(customer);
      await loadCustomers();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      await _repository.updateCustomer(customer);
      await loadCustomers();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await _repository.deleteCustomer(id);
      await loadCustomers();
    } catch (e) {
      rethrow;
    }
  }
}
