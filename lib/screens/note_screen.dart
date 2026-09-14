import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  static const String _notesKey = 'sohoz_hisab_plus_notes';
  static const String _oldNoteKey = 'sohoz_hisab_plus_note';

  List<Map<String, String>> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  // ============================================================
  // LOAD NOTES
  // ============================================================

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();

    final savedNotes = prefs.getStringList(_notesKey);

    if (savedNotes != null && savedNotes.isNotEmpty) {
      final loaded = <Map<String, String>>[];

      for (final item in savedNotes) {
        final separatorIndex = item.indexOf('|||');

        if (separatorIndex >= 0) {
          loaded.add({
            'title': item.substring(0, separatorIndex),
            'content': item.substring(separatorIndex + 3),
          });
        }
      }

      if (mounted) {
        setState(() {
          _notes = loaded;
        });
      }

      return;
    }

    // পুরোনো single-note data থাকলে সেটি migrate করা
    final oldNote = prefs.getString(_oldNoteKey);

    if (oldNote != null && oldNote.trim().isNotEmpty) {
      _notes = [
        {
          'title': 'নোট',
          'content': oldNote,
        }
      ];

      await _saveNotes();

      await prefs.remove(_oldNoteKey);

      if (mounted) {
        setState(() {});
      }
    }
  }

  // ============================================================
  // SAVE NOTES
  // ============================================================

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();

    final data = _notes.map((note) {
      final title = note['title'] ?? '';
      final content = note['content'] ?? '';

      return '$title|||$content';
    }).toList();

    await prefs.setStringList(_notesKey, data);
  }

  // ============================================================
  // ADD / EDIT NOTE
  // ============================================================

  Future<void> _addOrEditNote({int? index}) async {
    final existingNote =
        index != null && index >= 0 && index < _notes.length
            ? _notes[index]
            : null;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        final titleController = TextEditingController(
          text: existingNote?['title'] ?? '',
        );

        final contentController = TextEditingController(
          text: existingNote?['content'] ?? '',
        );

        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: Text(
            index == null ? 'নতুন নোট' : 'নোট সম্পাদনা',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                    ),
                    decoration: InputDecoration(
                      labelText: 'নোটের শিরোনাম',
                      labelStyle: TextStyle(
                        color: AppTheme.textMuted,
                      ),
                      filled: true,
                      fillColor: AppTheme.cardLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: contentController,
                    minLines: 5,
                    maxLines: 10,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                    ),
                    decoration: InputDecoration(
                      labelText: 'নোট লিখুন',
                      alignLabelWithHint: true,
                      labelStyle: TextStyle(
                        color: AppTheme.textMuted,
                      ),
                      filled: true,
                      fillColor: AppTheme.cardLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                'বাতিল',
                style: TextStyle(
                  color: AppTheme.textMuted,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    AppTheme.isDark
                        ? AppTheme.gold
                        : AppTheme.darkGreen,
                foregroundColor:
                    AppTheme.isDark
                        ? AppTheme.primaryDark
                        : Colors.white,
              ),
              onPressed: () {
                final title = titleController.text.trim();
                final content = contentController.text.trim();

                if (title.isEmpty && content.isEmpty) {
                  return;
                }

                Navigator.pop(
                  dialogContext,
                  {
                    'title': title.isEmpty ? 'নোট' : title,
                    'content': content,
                  },
                );
              },
              child: const Text('সংরক্ষণ'),
            ),
          ],
        );
      },
    );

    if (result == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      if (index == null) {
        _notes.insert(0, result);
      } else {
        _notes[index] = result;
      }
    });

    await _saveNotes();
  }

  // ============================================================
  // DELETE NOTE
  // ============================================================

  Future<void> _deleteNote(int index) async {
    if (index < 0 || index >= _notes.length) {
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: Text(
            'নোট মুছে ফেলবেন?',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'এই নোটটি স্থায়ীভাবে মুছে যাবে।',
            style: TextStyle(
              color: AppTheme.textMuted,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                'না',
                style: TextStyle(
                  color: AppTheme.textMuted,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.danger,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('মুছে ফেলুন'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) {
      return;
    }

    setState(() {
      _notes.removeAt(index);
    });

    await _saveNotes();
  }

  // ============================================================
  // NOTE CARD
  // ============================================================

  Widget _buildNoteCard(
    BuildContext context,
    Map<String, String> note,
    int index,
  ) {
    final title = note['title'] ?? 'নোট';
    final content = note['content'] ?? '';

    return Card(
      color: AppTheme.cardColor,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: AppTheme.textMuted,
                  ),
                  color: AppTheme.cardColor,
                  onSelected: (value) {
                    if (value == 'edit') {
                      _addOrEditNote(index: index);
                    } else if (value == 'delete') {
                      _deleteNote(index);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            color: AppTheme.gold,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'সম্পাদনা',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            color: AppTheme.danger,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'মুছে ফেলুন',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundSecondary,
        elevation: 0,
        title: Text(
          'নোট',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: AppTheme.textPrimary,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor:
            AppTheme.isDark
                ? AppTheme.gold
                : AppTheme.darkGreen,
        foregroundColor:
            AppTheme.isDark
                ? AppTheme.primaryDark
                : Colors.white,
        onPressed: () => _addOrEditNote(),
        child: const Icon(Icons.add),
      ),
      body: _notes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_alt_outlined,
                    size: 70,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'এখনো কোনো নোট নেই',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'নিচের + বাটনে চাপ দিয়ে নতুন নোট যোগ করুন',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                90,
              ),
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                return _buildNoteCard(
                  context,
                  _notes[index],
                  index,
                );
              },
            ),
    );
  }
}
