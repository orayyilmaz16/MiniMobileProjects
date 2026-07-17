import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_word/models/word.dart';
import 'package:flutter_word/services/isar_service.dart';

class WordList extends StatefulWidget {
  final IsarService isarService;
  final Function(Word) onEditWord;
  const WordList({
    super.key,
    required this.isarService,
    required this.onEditWord,
  });

  @override
  State<WordList> createState() => _WordListState();
}

class _WordListState extends State<WordList> {
  late Future<List<Word>> _getAllWords;
  List<Word> _kelimeler = [];
  List<Word> _filtrelenmisKelimeler = [];

  List<String> wordType = [
    'All',
    'Noun',
    'Adjective',
    'Verb',
    'Adverb',
    'Phrasel Verb',
    'Idiom',
  ];

  String _selectedWordType = 'All';
  bool _showLearned = false;

  _applyFilter() {
    _filtrelenmisKelimeler = List.from(_kelimeler);

    if (_selectedWordType != 'All') {
      _filtrelenmisKelimeler = _filtrelenmisKelimeler
          .where(
            (kelime) =>
                kelime.wordType.toLowerCase() ==
                _selectedWordType.toLowerCase(),
          )
          .toList();
    }

    if (_showLearned) {
      _filtrelenmisKelimeler = _filtrelenmisKelimeler
          .where((kelime) => kelime.isLearned != _showLearned)
          .toList();
    }
  }

  @override
  void initState() {
    super.initState();
    _getAllWords = _getWordsFromDB();
  }

  Widget _buildFilterCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.filter_alt_rounded),
                SizedBox(width: 8.0),
                Text('Filtrele'),
                SizedBox(width: 12.0),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Kelime Türü',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedWordType,
                    items: wordType
                        .map((e) => DropdownMenuItem(child: Text(e), value: e))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedWordType = value!;
                        _applyFilter();
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Öğrendiklerimi gizle'),
                Switch(
                  value: _showLearned,
                  onChanged: (value) {
                    setState(() {
                      _showLearned = !_showLearned;
                      _applyFilter();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Word>> _getWordsFromDB() async {
    var dbDenGelenKelimeler = await widget.isarService.getAllWords();
    _kelimeler = dbDenGelenKelimeler;
    return dbDenGelenKelimeler;
  }

  void _deleteWord(Word silinecekKelime) async {
    await widget.isarService.deleteWord(silinecekKelime.id);
    _kelimeler.removeWhere((element) => element.id == silinecekKelime.id);
    debugPrint("Liste boyutu: ${_kelimeler.length}");
  }

  void _refreshWords() {
    setState(() {
      _getAllWords = _getWordsFromDB();
    });
  }

  void _toggleUpdateWord(Word oankiKelime) async {
    await widget.isarService.toggleWordLearned(oankiKelime.id);
    setState(() {
      final index = _kelimeler.indexWhere(
        (element) => element.id == oankiKelime.id,
      );
      var degistirelecekKelime = _kelimeler[index];
      degistirelecekKelime.isLearned = !degistirelecekKelime.isLearned;
      _kelimeler[index] = degistirelecekKelime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterCard(),
        Expanded(
          child: FutureBuilder<List<Word>>(
            future: _getAllWords,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Hata var ${snapshot.error.toString()}'),
                );
              }
              if (snapshot.hasData) {
                return snapshot.data?.length == 0
                    ? Center(child: Text('Lütfen kelime ekleyin'))
                    : _buildListView(snapshot.data);
              } else {
                return SizedBox();
              }
            },
          ),
        ),
      ],
    );
  }

  _buildListView(List<Word>? data) {
    _applyFilter();
    debugPrint('Kelime liste uzunluğu: $_filtrelenmisKelimeler.length');
    return ListView.builder(
      itemBuilder: (context, index) {
        var oankiKelime = _filtrelenmisKelimeler[index];
        return Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.endToStart,
          background: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12.0),
            ),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(
              Icons.delete_rounded,
              color: Theme.of(context).colorScheme.error,
              size: 24.0,
            ),
          ),
          onDismissed: (direction) => _deleteWord(oankiKelime),

          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Kelimeyi sil'),
                  content: Text(
                    '${oankiKelime.englishWord} kelimesini silmek istediğinize emin misiniz?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: Text('İptal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: Text('Sil'),
                    ),
                  ],
                );
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: GestureDetector(
              onTap: () => widget.onEditWord(oankiKelime),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 8.0,
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(oankiKelime.englishWord),
                        subtitle: Text(oankiKelime.turkishWord),
                        leading: Chip(label: Text(oankiKelime.wordType)),
                        trailing: Switch(
                          value: oankiKelime?.isLearned ?? false,
                          onChanged: (value) async {
                            _toggleUpdateWord(oankiKelime);
                          },
                        ),
                      ),
                      if (oankiKelime.story != null &&
                          oankiKelime.story!.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondaryContainer.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8.0),
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.lightbulb),
                                  SizedBox(width: 8.0),
                                  Text('Hatırlatıcı Not'),
                                ],
                              ),
                              SizedBox(height: 4.0),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  oankiKelime.story ?? '',
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (oankiKelime.imageBytes != null)
                        Image.memory(
                          Uint8List.fromList(oankiKelime.imageBytes!),
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      itemCount: _filtrelenmisKelimeler.length,
    );
  }
}
