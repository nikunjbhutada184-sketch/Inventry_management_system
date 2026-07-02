import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../widgets/sales_chart.dart';
import '../widgets/stock_pie_chart.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Welcome Banner ───
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withAlpha(200),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back! 👋',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Here\'s your inventory overview',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimary.withAlpha(200),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── Stats Grid ───
            const SectionHeader(title: 'Overview'),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
              children: [
                StatCard(
                  title: 'Total Products',
                  value: '142',
                  icon: Icons.inventory_2_rounded,
                  iconColor: colorScheme.primary,
                  iconBackgroundColor: colorScheme.primaryContainer,
                  subtitle: '+12 this week',
                  onTap: () => context.push('/products'),
                ),
                StatCard(
                  title: 'Total Categories',
                  value: '8',
                  icon: Icons.category_rounded,
                  iconColor: colorScheme.tertiary,
                  iconBackgroundColor: colorScheme.tertiaryContainer,
                  subtitle: 'Groups',
                  onTap: () => context.push('/categories'),
                ),
                StatCard(
                  title: 'Low Stock',
                  value: '14',
                  icon: Icons.warning_amber_rounded,
                  iconColor: colorScheme.error,
                  iconBackgroundColor: colorScheme.errorContainer,
                  subtitle: 'Needs attention',
                  onTap: () => context.push('/products'),
                ),
                StatCard(
                  title: 'Total Customers',
                  value: '3,240',
                  icon: Icons.people_alt_rounded,
                  iconColor: Colors.teal,
                  iconBackgroundColor: Colors.teal.withAlpha(40),
                  subtitle: '+84 new',
                  onTap: () => context.push('/customers'),
                ),
                StatCard(
                  title: 'Total Suppliers',
                  value: '24',
                  icon: Icons.local_shipping_rounded,
                  iconColor: Colors.deepPurple,
                  iconBackgroundColor: Colors.deepPurple.withAlpha(40),
                  subtitle: 'Active',
                  onTap: () => context.push('/suppliers'),
                ),
                StatCard(
                  title: "Today's Sales",
                  value: '₹14,500',
                  icon: Icons.point_of_sale_rounded,
                  iconColor: colorScheme.secondary,
                  iconBackgroundColor: colorScheme.secondaryContainer,
                  subtitle: '+14% vs yesterday',
                  onTap: () => context.push('/sales'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ─── Charts Section ───
            const SectionHeader(title: 'Analytics'),
            const SizedBox(height: 8),
            const SalesChart(),
            const SizedBox(height: 16),
            const StockPieChart(),
            
            const SizedBox(height: 24),

            // ─── Recent Activity ───
            const SectionHeader(
              title: 'Recent Activity',
              actionLabel: 'View All',
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 40,
                        color: colorScheme.onSurfaceVariant.withAlpha(120),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No recent activity',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
