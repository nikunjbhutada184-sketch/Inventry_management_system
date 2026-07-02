import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/category_repository.dart';
import '../../domain/models/category.dart';

final categoriesProvider = StateNotifierProvider<CategoriesNotifier, AsyncValue<List<Category>>>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return CategoriesNotifier(repository);
});

class CategoriesNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final CategoryRepository _repository;

  CategoriesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      state = const AsyncValue.loading();
      final categories = await _repository.getCategories();
      state = AsyncValue.data(categories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> searchCategories(String query) async {
    if (query.isEmpty) {
      return loadCategories();
    }
    try {
      state = const AsyncValue.loading();
      final categories = await _repository.searchCategories(query);
      state = AsyncValue.data(categories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      await _repository.insertCategory(category);
      await loadCategories();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _repository.updateCategory(category);
      await loadCategories();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _repository.deleteCategory(id);
      await loadCategories();
    } catch (e) {
      rethrow;
    }
  }
}
