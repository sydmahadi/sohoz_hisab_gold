import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final TextEditingController _noteController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNote = prefs.getString('sohoz_hisab_plus_note') ?? '';

    if (!mounted) return;

    setState(() {
      _noteController.text = savedNote;
    });
  }

  Future<void> _saveNote() async {
    setState(() {
      _isSaving = true;
    });

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'sohoz_hisab_plus_note',
      _noteController.text,
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('নোট সংরক্ষণ করা হয়েছে'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _clearNote() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: const Text(
            'নোট মুছবেন?',
            style: TextStyle(
              color: AppTheme.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'সংরক্ষিত নোটটি মুছে ফেলা হবে।',
            style: TextStyle(
              color: AppTheme.textMuted,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('বাতিল'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
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

    if (shouldClear != true) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('sohoz_hisab_plus_note');

    _noteController.clear();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('নোট মুছে ফেলা হয়েছে'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        title: const Text('নোট করুন'),
        actions: [
          IconButton(
            onPressed: _clearNote,
            icon: const Icon(
              Icons.delete_outline_rounded,
            ),
            tooltip: 'নোট মুছুন',
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Information card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.darkGreen,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppTheme.gold.withOpacity(0.55),
                  width: 0.7,
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    color: AppTheme.gold,
                    size: 30,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'আপনার প্রয়োজনীয় কথা এখানে লিখে রাখুন',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Note area
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppTheme.gold.withOpacity(0.4),
                    width: 0.7,
                  ),
                ),
                child: TextField(
                  controller: _noteController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: 'এখানে আপনার নোট লিখুন...',
                    hintStyle: TextStyle(
                      color: AppTheme.textMuted,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(20),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textDark,
                    height: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveNote,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.save_rounded,
                      ),
                label: Text(
                  _isSaving
                      ? 'সংরক্ষণ হচ্ছে...'
                      : 'নোট সংরক্ষণ করুন',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
