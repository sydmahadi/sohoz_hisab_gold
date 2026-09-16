import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../logic/google_drive_backup.dart';
import '../theme/app_theme.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({
    super.key,
  });

  @override
  State<BackupRestoreScreen> createState() =>
      _BackupRestoreScreenState();
}

class _BackupRestoreScreenState
    extends State<BackupRestoreScreen> {
  bool _loading = false;
  String? _accountEmail;
  DateTime? _lastBackup;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    try {
      await GoogleDriveBackup.instance
          .initialize();

      final user =
          GoogleDriveBackup.instance.currentUser;

      final lastBackup =
          await GoogleDriveBackup.instance
              .getLastBackup();

      if (!mounted) return;

      setState(() {
        _accountEmail = user?.email;
        _lastBackup = lastBackup;
      });
    } catch (_) {}
  }

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
    });

    try {
      final user =
          await GoogleDriveBackup.instance
              .signIn();

      if (!mounted) return;

      setState(() {
        _accountEmail = user.email;
      });

      _showMessage(
        'Google Account সংযুক্ত হয়েছে।',
      );
    } catch (e) {
      _showMessage(
        'Google Sign-In করা যায়নি।',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _backup() async {
    setState(() {
      _loading = true;
    });

    try {
      await GoogleDriveBackup.instance
          .backup();

      final lastBackup =
          await GoogleDriveBackup.instance
              .getLastBackup();

      if (!mounted) return;

      setState(() {
        _lastBackup = lastBackup;
      });

      _showMessage(
        'Backup সফলভাবে Google Drive-এ রাখা হয়েছে।',
      );
    } catch (e) {
      _showMessage(
        'Backup করা যায়নি।\n$e',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _restore() async {
    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Data Restore করবেন?',
          ),
          content: const Text(
            'Google Drive-এর backup দিয়ে '
            'বর্তমান Money Manager-এর data '
            'replace করা হবে।\n\n'
            'বর্তমান data-এর প্রয়োজন থাকলে '
            'আগে Backup করে নিন।',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text('বাতিল'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text('Restore'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      _loading = true;
    });

    try {
      await GoogleDriveBackup.instance
          .restore();

      if (!mounted) return;

      _showMessage(
        'Data সফলভাবে Restore হয়েছে।',
      );

      await Future.delayed(
        const Duration(
          milliseconds: 500,
        ),
      );

      if (mounted) {
        Navigator.pop(
          context,
          true,
        );
      }
    } catch (e) {
      _showMessage(
        'Restore করা যায়নি।\n$e',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _loading = true;
    });

    try {
      await GoogleDriveBackup.instance
          .signOut();

      if (!mounted) return;

      setState(() {
        _accountEmail = null;
      });

      _showMessage(
        'Google Account disconnect হয়েছে।',
      );
    } catch (e) {
      _showMessage(
        'Disconnect করা যায়নি।',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showMessage(
    String message, {
    bool error = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              error ? Colors.red : null,
        ),
      );
  }

  String _formatDate(
    DateTime date,
  ) {
    return DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final cardColor =
        isDark
            ? AppTheme.cardColorDark
            : Colors.white;

    final gold =
        AppTheme.gold;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Backup & Restore',
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ==================================================
              // ACCOUNT CARD
              // ==================================================

              Container(
                padding:
                    const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius:
                      BorderRadius.circular(18),
                  border: Border.all(
                    color: gold.withOpacity(
                      0.25,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration:
                          BoxDecoration(
                        color: gold.withOpacity(
                          0.12,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons
                            .account_circle_outlined,
                        color: gold,
                        size: 30,
                      ),
                    ),
                    const SizedBox(
                      width: 14,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Google Account',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            _accountEmail ??
                                'সংযুক্ত করা হয়নি',
                            style: TextStyle(
                              color: Colors.grey
                                  .shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_accountEmail == null)
                      IconButton(
                        onPressed:
                            _loading
                                ? null
                                : _signIn,
                        icon: Icon(
                          Icons.login,
                          color: gold,
                        ),
                      )
                    else
                      PopupMenuButton<String>(
                        onSelected:
                            (value) {
                          if (value ==
                              'logout') {
                            _signOut();
                          }
                        },
                        itemBuilder:
                            (context) {
                          return const [
                            PopupMenuItem(
                              value:
                                  'logout',
                              child: Text(
                                'Disconnect',
                              ),
                            ),
                          ];
                        },
                      ),
                  ],
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // ==================================================
              // BACKUP
              // ==================================================

              _actionCard(
                icon:
                    Icons.cloud_upload_outlined,
                title:
                    'Backup Now',
                subtitle:
                    'বর্তমান Money Manager data Google Drive-এ সংরক্ষণ করুন',
                color: AppTheme.green,
                onTap:
                    _loading ? null : _backup,
              ),

              const SizedBox(
                height: 12,
              ),

              // ==================================================
              // RESTORE
              // ==================================================

              _actionCard(
                icon:
                    Icons.cloud_download_outlined,
                title:
                    'Restore Data',
                subtitle:
                    'Google Drive থেকে আগের data ফিরিয়ে আনুন',
                color: gold,
                onTap:
                    _loading ? null : _restore,
              ),

              const SizedBox(
                height: 20,
              ),

              // ==================================================
              // LAST BACKUP
              // ==================================================

              Container(
                padding:
                    const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius:
                      BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: gold,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'শেষ Backup',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            _lastBackup == null
                                ? 'এখনও কোনো Backup করা হয়নি'
                                : _formatDate(
                                    _lastBackup!,
                                  ),
                            style: TextStyle(
                              color: Colors.grey
                                  .shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              const Text(
                'গুরুত্বপূর্ণ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              Text(
                'App uninstall করার আগে Backup করে রাখুন। '
                'পরে একই Google Account দিয়ে আবার '
                'sign in করে Restore করলে আগের '
                'Money Manager data ফিরে পাবেন।',
                style: TextStyle(
                  color:
                      Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
            ],
          ),

          if (_loading)
            Container(
              color: Colors.black26,
              child: const Center(
                child:
                    CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius:
            BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration:
                    BoxDecoration(
                  color: color.withOpacity(
                    0.12,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors
                            .grey.shade600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
