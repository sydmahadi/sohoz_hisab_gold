import 'dart:convert';
import 'dart:typed_data';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:shared_preferences/shared_preferences.dart';

import 'money_db_helper.dart';

class GoogleDriveBackup {
  GoogleDriveBackup._();

  static final GoogleDriveBackup instance =
      GoogleDriveBackup._();

  static const String _backupFileName =
      'sohoz_hisab_backup.json';

  static const String _lastBackupKey =
      'google_drive_last_backup';

  static const List<String> _scopes = <String>[
    drive.DriveApi.driveFileScope,
  ];

  final GoogleSignIn _googleSignIn =
      GoogleSignIn.instance;

  bool _initialized = false;

  // ============================================================
  // INITIALIZE GOOGLE SIGN IN
  // ============================================================

  Future<void> initialize() async {
    if (_initialized) return;

    await _googleSignIn.initialize();

    _initialized = true;
  }

  // ============================================================
  // SIGN IN
  // ============================================================

  Future<GoogleSignInAccount> signIn() async {
    await initialize();

    final GoogleSignInAccount account =
        await _googleSignIn.authenticate();

    return account;
  }

  // ============================================================
  // GET CURRENT USER
  // ============================================================

  GoogleSignInAccount? get currentUser {
    return _googleSignIn.currentUser;
  }

  // ============================================================
  // AUTHORIZE DRIVE
  // ============================================================

  Future<dynamic> _getAuthorization(
    GoogleSignInAccount user,
  ) async {
    final authorization =
        await user.authorizationClient.authorizationForScopes(
      _scopes,
    );

    if (authorization != null) {
      return authorization;
    }

    return await user.authorizationClient.authorizeScopes(
      _scopes,
    );
  }

  // ============================================================
  // GET DRIVE API
  // ============================================================

  Future<drive.DriveApi> _getDriveApi() async {
    await initialize();

    GoogleSignInAccount? user =
        _googleSignIn.currentUser;

    if (user == null) {
      user = await signIn();
    }

    final authorization =
        await _getAuthorization(user);

    final client = authorization.authClient(
      scopes: _scopes,
    );

    return drive.DriveApi(client);
  }

  // ============================================================
  // CREATE BACKUP DATA
  // ============================================================

  Future<Map<String, dynamic>> _createBackupData() async {
    final transactions =
        await MoneyDbHelper.instance.getAllTransactions();

    final accounts =
        await MoneyDbHelper.instance.getAccounts();

    return {
      'app': 'সহজ হিসাব',
      'backupVersion': 1,
      'createdAt':
          DateTime.now().toUtc().toIso8601String(),

      'accounts': accounts,

      'transactions': transactions.map(
        (transaction) {
          return transaction.toMap();
        },
      ).toList(),
    };
  }

  // ============================================================
  // FIND EXISTING BACKUP
  // ============================================================

  Future<drive.File?> _findBackupFile(
    drive.DriveApi api,
  ) async {
    final result = await api.files.list(
      q: "name = '$_backupFileName' "
          "and trashed = false",
      spaces: 'drive',
      $fields: 'files(id,name,modifiedTime)',
      pageSize: 10,
    );

    final files = result.files;

    if (files == null || files.isEmpty) {
      return null;
    }

    return files.first;
  }

  // ============================================================
  // BACKUP
  // ============================================================

  Future<void> backup() async {
    final api = await _getDriveApi();

    final backupData =
        await _createBackupData();

    final jsonString =
        const JsonEncoder.withIndent('  ')
            .convert(backupData);

    final bytes =
        Uint8List.fromList(
      utf8.encode(jsonString),
    );

    final media = drive.Media(
      Stream<Uint8List>.value(bytes),
      bytes.length,
    );

    final existingFile =
        await _findBackupFile(api);

    if (existingFile == null) {
      final file = drive.File();

      file.name = _backupFileName;
      file.description =
          'সহজ হিসাব Money Manager Backup';

      await api.files.create(
        file,
        uploadMedia: media,
      );
    } else {
      await api.files.update(
        drive.File(
          name: _backupFileName,
          description:
              'সহজ হিসাব Money Manager Backup',
        ),
        existingFile.id!,
        uploadMedia: media,
      );
    }

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _lastBackupKey,
      DateTime.now().toIso8601String(),
    );
  }

  // ============================================================
  // RESTORE
  // ============================================================

  Future<void> restore() async {
    final api = await _getDriveApi();

    final backupFile =
        await _findBackupFile(api);

    if (backupFile == null ||
        backupFile.id == null) {
      throw Exception(
        'Google Drive-এ কোনো backup পাওয়া যায়নি।',
      );
    }

    final media =
        await api.files.get(
      backupFile.id!,
      downloadOptions:
          drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final List<int> data = [];

    await for (final chunk in media.stream) {
      data.addAll(chunk);
    }

    final jsonString =
        utf8.decode(data);

    final Map<String, dynamic> backupData =
        jsonDecode(jsonString)
            as Map<String, dynamic>;

    final dynamic accountsData =
        backupData['accounts'];

    final dynamic transactionsData =
        backupData['transactions'];

    if (accountsData is! List ||
        transactionsData is! List) {
      throw Exception(
        'Backup file সঠিক নয়।',
      );
    }

    final List<String> accounts =
        accountsData
            .map((item) => item.toString())
            .where((item) => item.trim().isNotEmpty)
            .toList();

    final List<MoneyTransaction> transactions =
        transactionsData.map((item) {
      final map =
          Map<String, dynamic>.from(
        item as Map,
      );

      return MoneyTransaction.fromMap(
        map,
      );
    }).toList();

    await MoneyDbHelper.instance
        .restoreBackup(
      accounts: accounts,
      transactions: transactions,
    );
  }

  // ============================================================
  // LAST BACKUP
  // ============================================================

  Future<DateTime?> getLastBackup() async {
    final prefs =
        await SharedPreferences.getInstance();

    final value =
        prefs.getString(_lastBackupKey);

    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  // ============================================================
  // SIGN OUT
  // ============================================================

  Future<void> signOut() async {
    await initialize();

    await _googleSignIn.signOut();
  }
}
