import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/debt.dart';
import '../models/product.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('warung.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        selling_price INTEGER NOT NULL,
        cost_price INTEGER NOT NULL,
        stock INTEGER NOT NULL,
        unit TEXT NOT NULL,
        category TEXT NOT NULL DEFAULT 'Lainnya',
        image_path TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total INTEGER NOT NULL,
        profit INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transaction_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        subtotal INTEGER NOT NULL,
        FOREIGN KEY(transaction_id) REFERENCES transactions(id),
        FOREIGN KEY(product_id) REFERENCES products(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE debts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_name TEXT NOT NULL,
        amount INTEGER NOT NULL,
        status TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE products ADD COLUMN category TEXT NOT NULL DEFAULT 'Lainnya'",
      );
      await db.execute('ALTER TABLE products ADD COLUMN image_path TEXT');
    }
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final result = await db.query('products', orderBy: 'name ASC');
    return result.map((row) => Product.fromMap(row)).toList();
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateProductStock(int id, int stock) async {
    final db = await database;
    return await db.update(
      'products',
      {'stock': stock},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertTransaction(Map<String, Object?> transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction);
  }

  Future<int> insertTransactionItem(Map<String, Object?> item) async {
    final db = await database;
    return await db.insert('transaction_items', item);
  }

  Future<int> insertDebt(Debt debt) async {
    final db = await database;
    return await db.insert('debts', debt.toMap());
  }

  Future<List<Debt>> getDebts() async {
    final db = await database;
    final result = await db.query('debts', orderBy: 'id DESC');
    return result.map((row) => Debt.fromMap(row)).toList();
  }

  Future<int> updateDebtStatus(int id, String status) async {
    final db = await database;
    return await db.update(
      'debts',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteDebt(int id) async {
    final db = await database;
    return await db.delete('debts', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getRevenueToday() async {
    final db = await database;
    final today = DateTime.now();
    final start = DateTime(
      today.year,
      today.month,
      today.day,
    ).toIso8601String();
    final end = DateTime(
      today.year,
      today.month,
      today.day,
      23,
      59,
      59,
    ).toIso8601String();
    final result = await db.rawQuery(
      'SELECT SUM(total) as total FROM transactions WHERE created_at BETWEEN ? AND ?',
      [start, end],
    );
    return result.first['total'] as int? ?? 0;
  }

  Future<int> getProfitToday() async {
    final db = await database;
    final today = DateTime.now();
    final start = DateTime(
      today.year,
      today.month,
      today.day,
    ).toIso8601String();
    final end = DateTime(
      today.year,
      today.month,
      today.day,
      23,
      59,
      59,
    ).toIso8601String();
    final result = await db.rawQuery(
      'SELECT SUM(profit) as profit FROM transactions WHERE created_at BETWEEN ? AND ?',
      [start, end],
    );
    return result.first['profit'] as int? ?? 0;
  }

  Future<int> getTransactionCountToday() async {
    final db = await database;
    final today = DateTime.now();
    final start = DateTime(
      today.year,
      today.month,
      today.day,
    ).toIso8601String();
    final end = DateTime(
      today.year,
      today.month,
      today.day,
      23,
      59,
      59,
    ).toIso8601String();
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM transactions WHERE created_at BETWEEN ? AND ?',
      [start, end],
    );
    return result.first['count'] as int? ?? 0;
  }

  Future<List<Product>> getLowStockProducts(int threshold) async {
    final db = await database;
    final result = await db.query(
      'products',
      where: 'stock <= ?',
      whereArgs: [threshold],
      orderBy: 'stock ASC',
    );
    return result.map((row) => Product.fromMap(row)).toList();
  }
}
