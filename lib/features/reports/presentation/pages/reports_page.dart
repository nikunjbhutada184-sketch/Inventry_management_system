import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/reports_providers.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final reportsState = ref.watch(reportsProvider);
    final currencyFormat = NumberFormat.currency(symbol: '₹');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(reportsProvider.notifier).loadReports(),
          )
        ],
      ),
      body: reportsState.when(
        data: (data) {
          final profitLoss = data['profitLoss'] as double;
          final isProfit = profitLoss >= 0;
          
          return RefreshIndicator(
            onRefresh: () async => ref.read(reportsProvider.notifier).loadReports(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Quick Stats
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Daily Sales',
                        value: currencyFormat.format(data['dailyTotal']),
                        icon: Icons.today,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'Monthly Sales',
                        value: currencyFormat.format(data['monthlyTotal']),
                        icon: Icons.calendar_month,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _StatCard(
                  title: 'Net Profit / Loss (All Time)',
                  value: currencyFormat.format(profitLoss.abs()),
                  icon: isProfit ? Icons.trending_up : Icons.trending_down,
                  color: isProfit ? Colors.green : Colors.red,
                  subtitle: isProfit ? 'Profit' : 'Loss',
                ),
                const SizedBox(height: 32),
                
                // Charts Section
                Text(
                  'Inventory Status',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                SizedBox(
                  height: 250,
                  child: Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainer,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 60,
                          sections: [
                            PieChartSectionData(
                              color: Colors.red.shade400,
                              value: (data['lowStockCount'] as int).toDouble(),
                              title: '${data['lowStockCount']} Low',
                              radius: 40,
                              titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            PieChartSectionData(
                              color: Colors.green.shade400,
                              value: (data['inStockCount'] as int).toDouble(),
                              title: '${data['inStockCount']} OK',
                              radius: 40,
                              titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
