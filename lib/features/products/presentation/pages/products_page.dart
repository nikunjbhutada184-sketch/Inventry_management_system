import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/barcode_scanner_page.dart';
import '../../../../core/services/export_service.dart';
import '../../domain/models/product.dart';
import '../providers/product_providers.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(productsProvider.notifier).searchProducts(query);
  }

  void _scanBarcode(BuildContext context, WidgetRef ref) async {
    final code = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerPage()),
    );
    if (code != null && code is String) {
      _searchController.text = code;
      ref.read(productsProvider.notifier).searchProducts(code);
      
      // Check if product exists
      final products = ref.read(productsProvider).value ?? [];
      if (products.isEmpty) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Product Not Found'),
            content: Text('No product found with barcode $code. Would you like to create a new product?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  final newProduct = Product(
                    id: '', // dummy
                    name: '',
                    barcode: code,
                    purchasePrice: 0,
                    sellingPrice: 0,
                    currentStock: 0,
                    minStock: 0,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  context.push('/products/form', extra: newProduct);
                },
                child: const Text('Create'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(productsProvider.notifier).deleteProduct(product.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final productsState = ref.watch(productsProvider);
    final currencyFormat = NumberFormat.currency(symbol: '₹');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Export Inventory',
            onPressed: () async {
              final products = ref.read(productsProvider).value ?? [];
              if (products.isNotEmpty) {
                await ExportService.exportInventoryToExcel(products);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: SearchBar(
                    controller: _searchController,
                    hintText: 'Search by name, SKU or barcode...',
                    leading: const Icon(Icons.search),
                    onChanged: (value) {
                      ref.read(productsProvider.notifier).searchProducts(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () => _scanBarcode(context, ref),
                ),
              ],
            ),
          ),
          Expanded(
            child: productsState.when(
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: colorScheme.onSurfaceVariant.withAlpha(100),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchController.text.isEmpty
                        ? 'No products found.\nTap + to add one!'
                        : 'No products match your search.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: products.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final product = products[index];
              final isLowStock = product.currentStock <= product.minStock;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    image: product.imagePath != null
                        ? DecorationImage(
                            image: FileImage(File(product.imagePath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: product.imagePath == null
                      ? Icon(
                          Icons.image_not_supported_outlined,
                          color: colorScheme.onSurfaceVariant,
                        )
                      : null,
                ),
                title: Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      '₹${product.sellingPrice.toStringAsFixed(2)} • Stock: ${product.currentStock} ${product.unit ?? ''}',
                    ),
                    if (isLowStock) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 14, color: colorScheme.error),
                          const SizedBox(width: 4),
                          Text(
                            'Low Stock',
                            style: TextStyle(color: colorScheme.error, fontSize: 12),
                          ),
                        ],
                      ),
                    ]
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      context.push('/products/form', extra: product);
                    } else if (value == 'delete') {
                      _confirmDelete(context, product);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: colorScheme.error),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: colorScheme.error)),
                        ],
                      ),
                    ),
                  ],
                ),
                onTap: () => context.push('/products/form', extra: product),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error loading products: $err',
              style: TextStyle(color: colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ),
  ],
),
floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/products/form'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
