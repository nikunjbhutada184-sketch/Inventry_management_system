import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Singleton database helper for SQLite operations.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'inventory_pro.db');

    return await openDatabase(
      path,
      version: 3,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Categories
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        color INTEGER,
        icon INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 2. Products
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        sku TEXT,
        barcode TEXT,
        category_id TEXT,
        purchase_price REAL NOT NULL,
        selling_price REAL NOT NULL,
        current_stock REAL NOT NULL,
        min_stock REAL NOT NULL,
        unit TEXT,
        description TEXT,
        image_path TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL
      )
    ''');

    // 3. Customers
    await db.execute('''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT,
        gst_number TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 4. Suppliers
    await db.execute('''
      CREATE TABLE suppliers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 5. Sales
    await db.execute('''
      CREATE TABLE sales (
        id TEXT PRIMARY KEY,
        customer_id TEXT,
        invoice_number TEXT,
        date INTEGER NOT NULL,
        total REAL NOT NULL,
        discount REAL NOT NULL DEFAULT 0.0,
        tax REAL NOT NULL DEFAULT 0.0,
        payment_method TEXT,
        status TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE SET NULL
      )
    ''');

    // 6. Sale Items
    await db.execute('''
      CREATE TABLE sale_items (
        id TEXT PRIMARY KEY,
        sale_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        qty REAL NOT NULL,
        price REAL NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (sale_id) REFERENCES sales (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE RESTRICT
      )
    ''');

    // 7. Purchases
    await db.execute('''
      CREATE TABLE purchases (
        id TEXT PRIMARY KEY,
        supplier_id TEXT,
        invoice_number TEXT,
        date INTEGER NOT NULL,
        total REAL NOT NULL,
        status TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (supplier_id) REFERENCES suppliers (id) ON DELETE SET NULL
      )
    ''');

    // 8. Purchase Items
    await db.execute('''
      CREATE TABLE purchase_items (
        id TEXT PRIMARY KEY,
        purchase_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        qty REAL NOT NULL,
        price REAL NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (purchase_id) REFERENCES purchases (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE RESTRICT
      )
    ''');

    // 9. Settings
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE categories ADD COLUMN color INTEGER');
      await db.execute('ALTER TABLE categories ADD COLUMN icon INTEGER');
      
      await db.execute('ALTER TABLE customers ADD COLUMN gst_number TEXT');
      
      await db.execute('ALTER TABLE sales ADD COLUMN invoice_number TEXT');
      await db.execute('ALTER TABLE sales ADD COLUMN discount REAL NOT NULL DEFAULT 0.0');
      await db.execute('ALTER TABLE sales ADD COLUMN tax REAL NOT NULL DEFAULT 0.0');
      await db.execute('ALTER TABLE sales ADD COLUMN payment_method TEXT');
    }
    
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE purchases ADD COLUMN invoice_number TEXT');
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
