import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

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

  factory MoneyTransaction.fromMap(Map<String, dynamic> map) {
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
    final path = join(dbPath, fileName);

    return openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

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

    final id = await db.insert(
      'transactions',
      transaction.toMap(),
    );

    // Entry হওয়ার পর Google Drive-এ backup শুরু হবে।
    // Backup fail হলেও transaction save হওয়া বন্ধ হবে না।
    autoBackupToDrive();

    return id;
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
  // DELETE TRANSACTION
  // ============================================================

  Future<int> deleteTransaction(int id) async {
    final db = await instance.database;

    final result = await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result > 0) {
      autoBackupToDrive();
    }

    return result;
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

    final result = await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );

    if (result > 0) {
      autoBackupToDrive();
    }

    return result;
  }

  // ============================================================
  // GOOGLE DRIVE
  // ============================================================

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveAppdataScope,
      drive.DriveApi.driveFileScope,
    ],
  );

  // ============================================================
  // GOOGLE SIGN-IN
  // ============================================================

  static Future<bool> signInWithGoogle() async {
    try {
      GoogleSignInAccount? account =
          _googleSignIn.currentUser;

      account ??= await _googleSignIn.signInSilently();

      account ??= await _googleSignIn.signIn();

      return account != null;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // GOOGLE DRIVE AUTO BACKUP
  // ============================================================

  static Future<bool> autoBackupToDrive() async {
    try {
      GoogleSignInAccount? account =
          _googleSignIn.currentUser;

      // আগে silent sign-in চেষ্টা
      account ??= await _googleSignIn.signInSilently();

      // প্রয়োজন হলে Google sign-in
      account ??= await _googleSignIn.signIn();

      if (account == null) {
        return false;
      }

      // Google authenticated HTTP client
      final httpClient =
          await _googleSignIn.authenticatedClient();

      if (httpClient == null) {
        return false;
      }

      final driveApi = drive.DriveApi(httpClient);

      // ========================================================
      // LOCAL DATABASE FILE
      // ========================================================

      final dbPath = await getDatabasesPath();

      final dbFilePath = join(
        dbPath,
        'sohoz_money_manager.db',
      );

      final file = File(dbFilePath);

      if (!await file.exists()) {
        return false;
      }

      // ========================================================
      // DRIVE MEDIA
      // ========================================================

      final media = drive.Media(
        file.openRead(),
        await file.length(),
      );

      const backupFileName =
          'sohoz_hisab_gold_backup.db';

      // ========================================================
      // CHECK EXISTING BACKUP
      // ========================================================

      final list = await driveApi.files.list(
        q: "name = '$backupFileName'",
        spaces: 'appDataFolder',
        $fields: 'files(id, name)',
      );

      // ========================================================
      // UPDATE EXISTING BACKUP
      // ========================================================

      if (list.files != null &&
          list.files!.isNotEmpty &&
          list.files!.first.id != null) {
        final fileId = list.files!.first.id!;

        final driveFile = drive.File();

        await driveApi.files.update(
          driveFile,
          fileId,
          uploadMedia: media,
        );

        return true;
      }

      // ========================================================
      // CREATE NEW BACKUP
      // ========================================================

      final driveFile = drive.File();

      driveFile.name = backupFileName;
      driveFile.parents = ['appDataFolder'];

      await driveApi.files.create(
        driveFile,
        uploadMedia: media,
      );

      return true;
    } catch (e) {
      // Backup fail হলেও মূল Money Manager যেন crash না করে।
      return false;
    }
  }
}
