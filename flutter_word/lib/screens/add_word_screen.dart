import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_word/models/word.dart';
import 'package:flutter_word/services/isar_service.dart';
import 'package:image_picker/image_picker.dart';

class AddWordScreen extends StatefulWidget {
  final IsarService isarService;
  final VoidCallback onSave;
  final Word? wordToEdit;
  const AddWordScreen({
    super.key,
    required this.isarService,
    required this.onSave,
    this.wordToEdit,
  });

  @override
  State<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _englishController = TextEditingController();
  final _turkishController = TextEditingController();
  final _storyController = TextEditingController();
  String _selectedWordType = 'Noun';
  bool _isLearned = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  List<String> wordType = [
    'Noun',
    'Adjective',
    'Verb',
    'Adverb',
    'Phrasel Verb',
    'Idiom',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.wordToEdit != null) {
      var guncellenicekKelime = widget.wordToEdit!;
      _englishController.text = guncellenicekKelime.englishWord;
      _turkishController.text = guncellenicekKelime.turkishWord;
      _storyController.text = guncellenicekKelime.story ?? '';
      _selectedWordType = guncellenicekKelime.wordType;
      _isLearned = guncellenicekKelime.isLearned;
    }
  }

  Future<void> _saveWord() async {
    if (_formKey.currentState!.validate()) {
      var _englishWord = _englishController.text;
      var _turkishWord = _turkishController.text;
      var _story = _storyController.text;
      var kelime = Word(
        englishWord: _englishWord,
        turkishWord: _turkishWord,
        wordType: _selectedWordType,
        isLearned: _isLearned,
        story: _story,
      );

      if (widget.wordToEdit != null) {
        kelime.imageBytes = _imageFile != null
            ? await _imageFile!.readAsBytes()
            : null;
        await widget.isarService.saveWord(kelime);
      } else {
        kelime.id = widget.wordToEdit!.id;
        kelime.imageBytes = _imageFile != null
            ? await _imageFile!.readAsBytes()
            : widget.wordToEdit?.imageBytes;
        await widget.isarService.updateWord(kelime);
      }

      await widget.isarService.saveWord(kelime);
      widget.onSave();
    }
  }

  @override
  void dispose() {
    _englishController.dispose();
    _turkishController.dispose();
    _storyController.dispose();
    super.dispose();
  }

  Future<void> _resimSec() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an English word';
                }
                return null;
              },
              controller: _englishController,
              decoration: InputDecoration(
                labelText: 'English Word',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a Turkish word';
                }
                return null;
              },
              controller: _turkishController,
              decoration: InputDecoration(
                labelText: 'Turkish Word',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedWordType,
              decoration: InputDecoration(
                label: Text('Word Type'),
                border: OutlineInputBorder(),
              ),
              items: wordType.map((e) {
                return DropdownMenuItem(child: Text(e), value: e);
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedWordType = value!;
                });
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a story';
                }
                return null;
              },
              controller: _storyController,
              decoration: InputDecoration(
                labelText: 'Word Story',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Text('Learned'),
                Switch(
                  value: _isLearned,
                  onChanged: (value) {
                    setState(() {
                      _isLearned = !_isLearned;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: _resimSec,
              label: Text("Add Image"),
              icon: Icon(Icons.image),
            ),
            SizedBox(height: 8.0),
            if (_imageFile != null ||
                widget.wordToEdit?.imageBytes != null) ...[
              if (_imageFile != null)
                Image.file(_imageFile!, height: 150, fit: BoxFit.cover)
              else if (widget.wordToEdit?.imageBytes != null)
                Image.memory(
                  Uint8List.fromList(widget.wordToEdit!.imageBytes!),
                  height: 150,
                  fit: BoxFit.cover,
                ),
            ],

            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _saveWord,
              child: widget.wordToEdit == null
                  ? Text("Save Word")
                  : Text("Update Word"),
            ),
          ],
        ),
      ),
    );
  }
}
