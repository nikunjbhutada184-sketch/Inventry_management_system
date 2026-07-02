import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers/sale_providers.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../../products/domain/models/product.dart';
import '../../../customers/presentation/providers/customer_providers.dart';
import '../../../customers/domain/models/customer.dart';
import '../../../../core/widgets/barcode_scanner_page.dart';

class CreateSalePage extends ConsumerStatefulWidget {
  const CreateSalePage({super.key});

  @override
  ConsumerState<CreateSalePage> createState() => _CreateSalePageState();
}

class _CreateSalePageState extends ConsumerState<CreateSalePage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load fresh products and customers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productsProvider.notifier).loadProducts();
      ref.read(customersProvider.notifier).loadCustomers();
      ref.read(cartProvider.notifier).clearCart();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _discountController.dispose();
    _taxController.dispose();
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
                              subtitle: Text('Stock: ${p.currentStock} | ₹${p.sellingPrice}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.add_shopping_cart),
                                onPressed: () {
                                  if (p.currentStock <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Out of stock!')),
                                    );
                                    return;
                                  }
                                  ref.read(cartProvider.notifier).addProduct(p);
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

  void _showCustomerSelect() {
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final customersState = ref.watch(customersProvider);
          return AlertDialog(
            title: const Text('Select Customer'),
            content: SizedBox(
              width: double.maxFinite,
              child: customersState.when(
                data: (customers) => ListView.builder(
                  shrinkWrap: true,
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final c = customers[index];
                    return ListTile(
                      title: Text(c.name),
                      subtitle: Text(c.phone ?? ''),
                      onTap: () {
                        ref.read(cartProvider.notifier).setCustomer(c);
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
                  ref.read(cartProvider.notifier).setCustomer(null);
                  Navigator.pop(context);
                },
                child: const Text('Walk-in Customer (Clear)'),
              ),
            ],
          );
        }
      ),
    );
  }

  Future<void> _checkout() async {
    try {
      final sale = await ref.read(cartProvider.notifier).checkout();
      if (mounted) {
        context.pushReplacement('/sales/invoice', extra: sale);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cart = ref.watch(cartProvider);
    final currencyFormat = NumberFormat.currency(symbol: '₹');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Point of Sale'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Select Customer',
            onPressed: _showCustomerSelect,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear Cart',
            onPressed: () => ref.read(cartProvider.notifier).clearCart(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Customer Banner
          if (cart.selectedCustomer != null)
            Container(
              color: colorScheme.secondaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.person, color: colorScheme.onSecondaryContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Customer: ${cart.selectedCustomer!.name}',
                      style: TextStyle(color: colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold),
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
                      'Cart is empty.\nTap the button below to add products.',
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
                        subtitle: Text('${currencyFormat.format(item.price)} x ${item.qty} = ${currencyFormat.format(item.total)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => ref.read(cartProvider.notifier).updateQty(item.productId, item.qty - 1),
                            ),
                            Text('${item.qty.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                if (item.product != null && item.qty >= item.product!.currentStock) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Not enough stock!')),
                                  );
                                  return;
                                }
                                ref.read(cartProvider.notifier).updateQty(item.productId, item.qty + 1);
                              },
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
              label: const Text('Add Product to Cart'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ),
          
          // Summary Bottom Sheet
          Container(
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
                    const Text('Subtotal:'),
                    Text(currencyFormat.format(cart.subtotal), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Discount (₹):'),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _discountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) {
                          ref.read(cartProvider.notifier).setDiscount(double.tryParse(val) ?? 0.0);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text('Tax (%):'),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _taxController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) {
                          ref.read(cartProvider.notifier).setTax(double.tryParse(val) ?? 0.0);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Payment:'),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: cart.paymentMethod,
                      items: ['Cash', 'Card', 'UPI']
                          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) ref.read(cartProvider.notifier).setPaymentMethod(val);
                      },
                    ),
                    const Spacer(),
                    Text(
                      'Total: ${currencyFormat.format(cart.grandTotal)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: cart.items.isEmpty ? null : _checkout,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Complete Sale'),
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
