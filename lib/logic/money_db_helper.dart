import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MoneyTransaction {
  final int? id;
  final String type; // Income, Expense, Transfer
  final double amount;
  final String date;
  final String category;
  final String account;
  final String? note;

  MoneyTransaction({
    this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.category,
    required this.account,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'date': date,
      'category': category,
      'account': account,
      'note': note,
    };
  }

  factory MoneyTransaction.fromMap(
    Map<String, dynamic> map,
  ) {
    return MoneyTransaction(
      id: map['id'] as int?,
      type: map['type']?.toString() ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: map['date']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      account: map['account']?.toString() ?? '',
      note: map['note']?.toString(),
    );
  }
}

class MoneyDbHelper {
  static final MoneyDbHelper instance = MoneyDbHelper._init();

  static Database? _database;

  MoneyDbHelper._init();

  // ============================================================
  // DATABASE
  // ============================================================

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('sohoz_money_manager.db');

    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();

    final dbFilePath = join(dbPath, fileName);

    return await openDatabase(
      dbFilePath,
      version: 1,
      onCreate: _createDB,
    );
  }

  // ============================================================
  // CREATE DATABASE
  // ============================================================

  Future<void> _createDB(
    Database db,
    int version,
  ) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        account TEXT NOT NULL,
        note TEXT
      )
    ''');
  }

  // ============================================================
  // INSERT TRANSACTION
  // ============================================================

  Future<int> insertTransaction(
    MoneyTransaction transaction,
  ) async {
    final db = await instance.database;

    final data = transaction.toMap();

    // ID database নিজে তৈরি করবে
    data.remove('id');

    return await db.insert(
      'transactions',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ============================================================
  // GET ALL TRANSACTIONS
  // ============================================================

  Future<List<MoneyTransaction>> getAllTransactions() async {
    final db = await instance.database;

    final result = await db.query(
      'transactions',
      orderBy: 'id DESC',
    );

    return result
        .map(
          (json) => MoneyTransaction.fromMap(json),
        )
        .toList();
  }

  // ============================================================
  // GET TRANSACTIONS BY TYPE
  // ============================================================

  Future<List<MoneyTransaction>> getTransactionsByType(
    String type,
  ) async {
    final db = await instance.database;

    final result = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'id DESC',
    );

    return result
        .map(
          (json) => MoneyTransaction.fromMap(json),
        )
        .toList();
  }

  // ============================================================
  // GET TRANSACTIONS BY DATE
  // ============================================================

  Future<List<MoneyTransaction>> getTransactionsByDate(
    String date,
  ) async {
    final db = await instance.database;

    final result = await db.query(
      'transactions',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'id DESC',
    );

    return result
        .map(
          (json) => MoneyTransaction.fromMap(json),
        )
        .toList();
  }

  // ============================================================
  // GET TRANSACTIONS BY CATEGORY
  // ============================================================

  Future<List<MoneyTransaction>> getTransactionsByCategory(
    String category,
  ) async {
    final db = await instance.database;

    final result = await db.query(
      'transactions',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'id DESC',
    );

    return result
        .map(
          (json) => MoneyTransaction.fromMap(json),
        )
        .toList();
  }

  // ============================================================
  // GET TRANSACTIONS BY ACCOUNT
  // ============================================================

  Future<List<MoneyTransaction>> getTransactionsByAccount(
    String account,
  ) async {
    final db = await instance.database;

    final result = await db.query(
      'transactions',
      where: 'account = ?',
      whereArgs: [account],
      orderBy: 'id DESC',
    );

    return result
        .map(
          (json) => MoneyTransaction.fromMap(json),
        )
        .toList();
  }

  // ============================================================
  // UPDATE TRANSACTION
  // ============================================================

  Future<int> updateTransaction(
    MoneyTransaction transaction,
  ) async {
    if (transaction.id == null) {
      return 0;
    }

    final db = await instance.database;

    final data = transaction.toMap();

    // ID update করার প্রয়োজন নেই
    data.remove('id');

    return await db.update(
      'transactions',
      data,
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // ============================================================
  // DELETE TRANSACTION
  // ============================================================

  Future<int> deleteTransaction(
    int id,
  ) async {
    final db = await instance.database;

    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================
  // DELETE ALL TRANSACTIONS
  // ============================================================

  Future<int> deleteAllTransactions() async {
    final db = await instance.database;

    return await db.delete(
      'transactions',
    );
  }

  // ============================================================
  // COUNT TRANSACTIONS
  // ============================================================

  Future<int> getTransactionCount() async {
    final db = await instance.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM transactions',
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ============================================================
  // TOTAL INCOME
  // ============================================================

  Future<double> getTotalIncome() async {
    final db = await instance.database;

    final result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM transactions
      WHERE type = 'Income'
    ''');

    final value = result.first['total'];

    if (value == null) {
      return 0.0;
    }

    return (value as num).toDouble();
  }

  // ============================================================
  // TOTAL EXPENSE
  // ============================================================

  Future<double> getTotalExpense() async {
    final db = await instance.database;

    final result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM transactions
      WHERE type = 'Expense'
    ''');

    final value = result.first['total'];

    if (value == null) {
      return 0.0;
    }

    return (value as num).toDouble();
  }

  // ============================================================
  // BALANCE
  // ============================================================

  Future<double> getBalance() async {
    final income = await getTotalIncome();
    final expense = await getTotalExpense();

    return income - expense;
  }

  // ============================================================
  // CLOSE DATABASE
  // ============================================================

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
