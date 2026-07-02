import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/models/sale.dart';
import '../../../../core/services/export_service.dart';

class InvoiceScreen extends StatelessWidget {
  final Sale sale;

  const InvoiceScreen({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(symbol: '₹');
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        title: const Text('Invoice'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/sales'), // Always go back to sales list
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              await ExportService.exportSalesInvoice(sale);
            },
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              await ExportService.exportSalesInvoice(sale);
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'INVENTORY PRO',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text('123 Business Road\nCity, State 12345\nPhone: (555) 123-4567'),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'RECEIPT',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: colorScheme.onSurfaceVariant.withAlpha(100),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          sale.invoiceNumber ?? 'INV-XXXX',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          dateFormat.format(sale.date),
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                        ),
                      ],
                    )
                  ],
                ),
                const Divider(height: 32, thickness: 2),

                // Customer Info
                if (sale.customer != null) ...[
                  Text(
                    'BILL TO:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sale.customer!.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  if (sale.customer!.phone != null) Text('Phone: ${sale.customer!.phone}'),
                  if (sale.customer!.gstNumber != null) Text('GST: ${sale.customer!.gstNumber}'),
                  const Divider(height: 32),
                ],

                // Items
                Row(
                  children: [
                    const Expanded(flex: 3, child: Text('ITEM', style: TextStyle(fontWeight: FontWeight.bold))),
                    const Expanded(flex: 1, child: Text('QTY', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('TOTAL', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
                const SizedBox(height: 8),
                if (sale.items != null)
                  ...sale.items!.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text(item.product?.name ?? 'Unknown Item')),
                        Expanded(flex: 1, child: Text('${item.qty.toInt()}', textAlign: TextAlign.center)),
                        Expanded(flex: 2, child: Text(currencyFormat.format(item.total), textAlign: TextAlign.right)),
                      ],
                    ),
                  )),
                const Divider(height: 32),

                // Totals
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:'),
                    Text(currencyFormat.format(sale.subtotal)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Discount:'),
                    Text('- ${currencyFormat.format(sale.discount)}', style: TextStyle(color: colorScheme.error)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tax:'),
                    Text('+ ${currencyFormat.format(sale.tax)}'),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      currencyFormat.format(sale.total),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'PAID VIA ${sale.paymentMethod?.toUpperCase() ?? "CASH"}',
                      style: TextStyle(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    'Thank you for your business!',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
