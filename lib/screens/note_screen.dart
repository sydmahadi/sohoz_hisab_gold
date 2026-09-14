import 'dart:convert';

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

  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  // =========================
  // LOAD NOTES
  // =========================

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();

    final savedNotes = prefs.getString(_notesKey);

    List<Map<String, dynamic>> loadedNotes = [];

    if (savedNotes != null && savedNotes.isNotEmpty) {
      try {
        final decoded = jsonDecode(savedNotes);

        if (decoded is List) {
          loadedNotes = decoded
              .map(
                (item) => Map<String, dynamic>.from(item as Map),
              )
              .toList();
        }
      } catch (_) {
        loadedNotes = [];
      }
    }

    // পুরোনো single note থাকলে নতুন notes system-এ নিয়ে আসবে
    if (loadedNotes.isEmpty) {
      final oldNote = prefs.getString(_oldNoteKey) ?? '';

      if (oldNote.trim().isNotEmpty) {
        loadedNotes.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'title': 'পুরোনো নোট',
          'content': oldNote,
          'createdAt': DateTime.now().toIso8601String(),
        });

        await prefs.setString(
          _notesKey,
          jsonEncode(loadedNotes),
        );

        await prefs.remove(_oldNoteKey);
      }
    }

    if (!mounted) return;

    setState(() {
      _notes = loadedNotes;
      _isLoading = false;
    });
  }

  // =========================
  // SAVE NOTES
  // =========================

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _notesKey,
      jsonEncode(_notes),
    );
  }

  // =========================
  // ADD NOTE
  // =========================

  Future<void> _addNote() async {
    final result = await _showNoteDialog();

    if (result == null) return;

    final title = result['title']!.trim();
    final content = result['content']!.trim();

    if (title.isEmpty && content.isEmpty) {
      return;
    }

    final newNote = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title.isEmpty ? 'নোট' : title,
      'content': content,
      'createdAt': DateTime.now().toIso8601String(),
    };

    setState(() {
      _notes.insert(0, newNote);
    });

    await _saveNotes();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('নোট সংরক্ষণ করা হয়েছে'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // =========================
  // EDIT NOTE
  // =========================

  Future<void> _editNote(int index) async {
    final note = _notes[index];

    final result = await _showNoteDialog(
      title: note['title']?.toString() ?? '',
      content: note['content']?.toString() ?? '',
      isEditing: true,
    );

    if (result == null) return;

    final title = result['title']!.trim();
    final content = result['content']!.trim();

    if (title.isEmpty && content.isEmpty) {
      return;
    }

    setState(() {
      _notes[index] = {
        ..._notes[index],
        'title': title.isEmpty ? 'নোট' : title,
        'content': content,
      };
    });

    await _saveNotes();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('নোট আপডেট করা হয়েছে'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // =========================
  // DELETE NOTE
  // =========================

  Future<void> _deleteNote(int index) async {
    final note = _notes[index];

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: Text(
            'নোট মুছবেন?',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '“${note['title']}” নোটটি মুছে ফেলা হবে।',
            style: TextStyle(
              color: AppTheme.textMuted,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('বাতিল'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'মুছুন',
                style: TextStyle(
                  color: AppTheme.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    setState(() {
      _notes.removeAt(index);
    });

    await _saveNotes();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('নোট মুছে ফেলা হয়েছে'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // =========================
  // NOTE DIALOG
  // =========================

  Future<Map<String, String>?> _showNoteDialog({
    String title = '',
    String content = '',
    bool isEditing = false,
  }) async {
    final titleController = TextEditingController(text: title);
    final contentController = TextEditingController(text: content);

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            isEditing ? 'নোট সম্পাদনা' : 'নতুন নোট',
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
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'নোটের শিরোনাম',
                      hintText: 'যেমন: আজকের কাজ',
                      labelStyle: TextStyle(
                        color: AppTheme.textMuted,
                      ),
                      hintStyle: TextStyle(
                        color: AppTheme.textMuted,
                      ),
                      prefixIcon: Icon(
                        Icons.title_rounded,
                        color: AppTheme.gold,
                      ),
                      filled: true,
                      fillColor: AppTheme.cardLight
