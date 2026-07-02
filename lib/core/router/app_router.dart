import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/products/presentation/pages/product_form_page.dart';
import '../../features/products/presentation/pages/products_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/sales/presentation/pages/sales_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../widgets/app_shell.dart';
import '../../features/products/domain/models/product.dart';

import '../../features/categories/presentation/pages/categories_page.dart';
import '../../features/categories/presentation/pages/category_form_page.dart';
import '../../features/categories/domain/models/category.dart';

import '../../features/customers/presentation/pages/customers_page.dart';
import '../../features/customers/presentation/pages/customer_form_page.dart';
import '../../features/customers/domain/models/customer.dart';

import '../../features/sales/presentation/pages/create_sale_page.dart';
import '../../features/sales/presentation/pages/invoice_screen.dart';
import '../../features/sales/domain/models/sale.dart';

import '../../features/suppliers/presentation/pages/suppliers_page.dart';
import '../../features/suppliers/presentation/pages/supplier_form_page.dart';
import '../../features/suppliers/domain/models/supplier.dart';

import '../../features/purchases/presentation/pages/purchases_page.dart';
import '../../features/purchases/presentation/pages/create_purchase_page.dart';

/// Provider for the GoRouter instance.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    routes: [
      // ─── Splash Screen ───
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // ─── Login Screen ───
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // ─── Categories ───
      GoRoute(
        path: '/categories',
        name: 'categories',
        builder: (context, state) => const CategoriesPage(),
        routes: [
          GoRoute(
            path: 'form',
            name: 'category_form',
            builder: (context, state) {
              final category = state.extra as Category?;
              return CategoryFormPage(category: category);
            },
          ),
        ],
      ),

      // ─── Customers ───
      GoRoute(
        path: '/customers',
        name: 'customers',
        builder: (context, state) => const CustomersPage(),
        routes: [
          GoRoute(
            path: 'form',
            name: 'customer_form',
            builder: (context, state) {
              final customer = state.extra as Customer?;
              return CustomerFormPage(customer: customer);
            },
          ),
        ],
      ),

      // ─── Suppliers ───
      GoRoute(
        path: '/suppliers',
        name: 'suppliers',
        builder: (context, state) => const SuppliersPage(),
        routes: [
          GoRoute(
            path: 'form',
            name: 'supplier_form',
            builder: (context, state) {
              final supplier = state.extra as Supplier?;
              return SupplierFormPage(supplier: supplier);
            },
          ),
        ],
      ),

      // ─── Purchases ───
      GoRoute(
        path: '/purchases',
        name: 'purchases',
        builder: (context, state) => const PurchasesPage(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'create_purchase',
            builder: (context, state) => const CreatePurchasePage(),
          ),
        ],
      ),

      // ─── Shell Route with Bottom Navigation ───
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0 – Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                name: 'dashboard',
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),

          // Tab 1 – Products
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/products',
                name: 'products',
                builder: (context, state) => const ProductsPage(),
                routes: [
                  GoRoute(
                    path: 'form',
                    name: 'product_form',
                    builder: (context, state) {
                      final product = state.extra as Product?;
                      return ProductFormPage(product: product);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Tab 2 – Sales
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/sales',
                name: 'sales',
                builder: (context, state) => const SalesPage(),
                routes: [
                  GoRoute(
                    path: 'create',
                    name: 'create_sale',
                    builder: (context, state) => const CreateSalePage(),
                  ),
                  GoRoute(
                    path: 'invoice',
                    name: 'invoice',
                    builder: (context, state) {
                      final sale = state.extra as Sale;
                      return InvoiceScreen(sale: sale);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Tab 3 – Reports
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                name: 'reports',
                builder: (context, state) => const ReportsPage(),
              ),
            ],
          ),

          // Tab 4 – Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],

    // ─── Error Page ───
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.explore_off_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Page Not Found',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                state.uri.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.tonalIcon(
                onPressed: () => context.go('/dashboard'),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
});
