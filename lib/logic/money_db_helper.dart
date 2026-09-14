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
      id: map['id'],
      type: map['type'],
      amount: map['amount'],
      date: map['date'],
      category: map['category'],
      account: map['account'],
      note: map['note'],
    );
  }
}

class MoneyDbHelper {
  static final MoneyDbHelper instance = MoneyDbHelper._init();
  static Database? _database;

  MoneyDbHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sohoz_money_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
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

  Future<int> insertTransaction(MoneyTransaction trans) async {
    final db = await instance.database;
    int id = await db.insert('transactions', trans.toMap());
    
    // ডাটা এন্ট্রি হওয়ার সাথে সাথে ড্রাইভে অটো ব্যাকআপ যাবে
    autoBackupToDrive();
    return id;
  }

  Future<List<MoneyTransaction>> getAllTransactions() async {
    final db = await instance.database;
    final result = await db.query('transactions', orderBy: 'id DESC');
    return result.map((json) => MoneyTransaction.fromMap(json)).toList();
  }

  // Google Drive Integration
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope],
  );

  static Future<void> autoBackupToDrive() async {
    try {
      GoogleSignInAccount? account = _googleSignIn.currentUser;
      account ??= await _googleSignIn.signInSilently();
      
      if (account != null) {
        var httpClient = await _googleSignIn.authenticatedClient();
        if (httpClient == null) return;
        
        var driveApi = drive.DriveApi(httpClient);
        final dbPath = await getDatabasesPath();
        final path = join(dbPath, 'sohoz_money_manager.db');
        File file = File(path);

        if (await file.exists()) {
          var media = drive.Media(file.openRead(), file.lengthSync());
          var driveFile = drive.File();
          driveFile.name = "sohoz_hisab_gold_backup.db";

          await driveApi.files.create(driveFile, uploadMedia: media);
        }
      }
    } catch (e) {
      // ব্যাকআপ ব্যর্থ হলে শান্তভাবে হ্যান্ডেল করবে
    }
  }

  static Future<bool> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      return account != null;
    } catch (e) {
      return false;
    }
  }
}
