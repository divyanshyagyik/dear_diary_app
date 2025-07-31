import 'package:dart_sentiment/dart_sentiment.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import '../controllers/diary_controller.dart';

class EntryEditPage extends StatefulWidget {
  final DiaryEntry? entry;

  const EntryEditPage({Key? key, this.entry}) : super(key: key);

  @override
  _EntryEditPageState createState() => _EntryEditPageState();
}

class _EntryEditPageState extends State<EntryEditPage> {
  final Sentiment _sentiment = Sentiment();
  final DiaryController _diaryController = Get.find();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _contentController = TextEditingController(text: widget.entry?.content ?? '');
    _selectedDate = widget.entry?.date ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? 'New Entry' : 'Edit Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveEntry,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                TextButton(
                  child: const Text('Change Date'),
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveEntry() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      Get.snackbar('Error', 'Title cannot be empty');
      return;
    }

    final analysis = _sentiment.analysis('$title $content');
    final sentimentScore = analysis['score'] ?? 0;
    final entry = DiaryEntry(
      id: widget.entry?.id, // Preserve ID if editing
      title: title,
      content: content,
      date: _selectedDate,
      sentimentScore: sentimentScore,
    );

    await _diaryController.addOrUpdateEntry(entry);
    Get.back();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}