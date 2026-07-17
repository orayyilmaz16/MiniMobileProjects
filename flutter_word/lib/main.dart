import 'package:flutter/material.dart';
import 'package:flutter_word/models/word.dart';
import 'package:flutter_word/screens/add_word_screen.dart';
import 'package:flutter_word/screens/word_list_screen.dart';
import 'package:flutter_word/services/isar_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isarService = IsarService();
  try {
    await isarService.init();

    // Word eklenecekKelime = Word(
    //   englishWord: 'garden',
    //   turkishWord: 'bahçe',
    //   wordType: 'noun',
    //   story: 'A common greeting in English.',
    // );
    // await isarService.saveWord(eklenecekKelime);
    final words = await isarService.getAllWords();
    debugPrint('Getirilen kelimeler: $words');
  } catch (e) {
    debugPrint('Main dartda init başlatılırken hata: $e');
  }
  runApp(MyApp(isarService: isarService));
}

class MyApp extends StatelessWidget {
  final IsarService isarService;
  const MyApp({super.key, required this.isarService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(isarService: isarService),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final IsarService isarService;
  const MyHomePage({super.key, required this.isarService});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedScreen = 0;
  Word? _wordToEdit;

  void _editWord(Word guncellenicekKelime) {
    setState(() {
      _selectedScreen = 1;
      _wordToEdit = guncellenicekKelime;
    });
  }

  List<Widget> getScreens() {
    return [
      WordList(isarService: widget.isarService, onEditWord: _editWord),
      AddWordScreen(
        isarService: widget.isarService,
        wordToEdit: _wordToEdit,
        onSave: () {
          setState(() {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Kelime başarıyla eklendi!')),
            );
            _selectedScreen = 0;
            _wordToEdit = null;
          });
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kelimelerim')),
      body: getScreens()[_selectedScreen],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedScreen,
        destinations: [
          NavigationDestination(icon: Icon(Icons.list_alt), label: "Kelimeler"),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            label: _wordToEdit == null ? "Kelime Ekle" : "Kelime Güncelle",
          ),
        ],
        onDestinationSelected: (value) {
          setState(() {
            _selectedScreen = value;
            if (_selectedScreen == 0) {
              _wordToEdit = null;
            }
          });
        },
      ),
    );
  }
}
