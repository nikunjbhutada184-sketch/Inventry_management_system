import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Test Database Initialization
  try {
    await DatabaseHelper.instance.database;
    debugPrint('Database initialized successfully.');
  } catch (e) {
    debugPrint('Database initialization error: $e');
  }

  runApp(
    const ProviderScope(
      child: InventoryProApp(),
    ),
  );
}
