import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers/purchase_providers.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../../products/domain/models/product.dart';
import '../../../suppliers/presentation/providers/supplier_providers.dart';
import '../../../suppliers/domain/models/supplier.dart';
import '../../../../core/widgets/barcode_scanner_page.dart';

class CreatePurchasePage extends ConsumerStatefulWidget {
  const CreatePurchasePage({super.key});

  @override
  ConsumerState<CreatePurchasePage> createState() => _CreatePurchasePageState();
}

class _CreatePurchasePageState extends ConsumerState<CreatePurchasePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productsProvider.notifier).loadProducts();
      ref.read(suppliersProvider.notifier).loadSuppliers();
      ref.read(purchaseCartProvider.notifier).clearCart();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showProductSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          builder: (context, scrollController) {
            return Consumer(
              builder: (context, ref, child) {
                final productsState = ref.watch(productsProvider);
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: SearchBar(
                              controller: _searchController,
                              hintText: 'Search products...',
                              leading: const Icon(Icons.search),
                              onChanged: (q) => ref.read(productsProvider.notifier).searchProducts(q),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            icon: const Icon(Icons.qr_code_scanner),
                            onPressed: () async {
                              final code = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const BarcodeScannerPage()),
                              );
                              if (code != null && code is String) {
                                _searchController.text = code;
                                ref.read(productsProvider.notifier).searchProducts(code);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: productsState.when(
                        data: (products) => ListView.builder(
                          controller: scrollController,
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final p = products[index];
                            return ListTile(
                              leading: p.imagePath != null
                                  ? Image.file(File(p.imagePath!), width: 40, height: 40, fit: BoxFit.cover)
                                  : const Icon(Icons.inventory_2),
                              title: Text(p.name),
                              subtitle: Text('Stock: ${p.currentStock} | Cost: ₹${p.purchasePrice}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.add_shopping_cart),
                                onPressed: () {
                                  ref.read(purchaseCartProvider.notifier).addProduct(p);
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          },
                        ),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('Error: $e')),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    ).whenComplete(() {
      _searchController.clear();
      ref.read(productsProvider.notifier).loadProducts();
    });
  }

  void _showSupplierSelect() {
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final suppliersState = ref.watch(suppliersProvider);
          return AlertDialog(
            title: const Text('Select Supplier'),
            content: SizedBox(
              width: double.maxFinite,
              child: suppliersState.when(
                data: (suppliers) => ListView.builder(
                  shrinkWrap: true,
                  itemCount: suppliers.length,
                  itemBuilder: (context, index) {
                    final s = suppliers[index];
                    return ListTile(
                      title: Text(s.name),
                      subtitle: Text(s.phone ?? ''),
                      onTap: () {
                        ref.read(purchaseCartProvider.notifier).setSupplier(s);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  ref.read(purchaseCartProvider.notifier).setSupplier(null);
                  Navigator.pop(context);
                },
                child: const Text('Clear'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _editPrice(String productId, double currentPrice) {
    final controller = TextEditingController(text: currentPrice.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Purchase Price'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final newPrice = double.tryParse(controller.text) ?? currentPrice;
              ref.read(purchaseCartProvider.notifier).updatePrice(productId, newPrice);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _completePurchase() async {
    final cart = ref.read(purchaseCartProvider);
    if (cart.selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a supplier!')),
      );
      return;
    }
    try {
      await ref.read(purchaseCartProvider.notifier).completePurchase();
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase Complete! Inventory updated.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cart = ref.watch(purchaseCartProvider);
    final currencyFormat = NumberFormat.currency(symbol: '₹');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Purchase'),
        actions: [
          IconButton(
            icon: const Icon(Icons.business),
            tooltip: 'Select Supplier',
            onPressed: _showSupplierSelect,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear List',
            onPressed: () => ref.read(purchaseCartProvider.notifier).clearCart(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Supplier Banner
          if (cart.selectedSupplier != null)
            Container(
              color: colorScheme.tertiaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.business, color: colorScheme.onTertiaryContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Supplier: ${cart.selectedSupplier!.name}',
                      style: TextStyle(color: colorScheme.onTertiaryContainer, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            
          // Cart Items
          Expanded(
            child: cart.items.isEmpty
                ? Center(
                    child: Text(
                      'Purchase list is empty.\nTap the button below to add products.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  )
                : ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return ListTile(
                        title: Text(item.product?.name ?? 'Unknown'),
                        subtitle: Row(
                          children: [
                            Text(currencyFormat.format(item.price)),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 16),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _editPrice(item.productId, item.price),
                            ),
                            Text(' x ${item.qty} = ${currencyFormat.format(item.total)}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => ref.read(purchaseCartProvider.notifier).updateQty(item.productId, item.qty - 1),
                            ),
                            Text('${item.qty.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => ref.read(purchaseCartProvider.notifier).updateQty(item.productId, item.qty + 1),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          
          // Add Product Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: OutlinedButton.icon(
              onPressed: _showProductSearch,
              icon: const Icon(Icons.search),
              label: const Text('Add Product to Purchase'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ),
          
          // Summary Bottom Sheet
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Grand Total',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      currencyFormat.format(cart.grandTotal),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: cart.items.isEmpty ? null : _completePurchase,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Complete Purchase & Update Stock'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
