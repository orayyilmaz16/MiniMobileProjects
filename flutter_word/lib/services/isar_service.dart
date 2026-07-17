import 'package:flutter/material.dart';
import 'package:flutter_word/models/word.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  late Isar isar;

  Future<void> init() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      isar = await Isar.open([WordSchema], directory: directory.path);
      debugPrint('Isar init oldu');
    } catch (e) {
      debugPrint('Isar init olurken hata: $e');
    }
  }

  Future<void> saveWord(Word word) async {
    try {
      isar.writeTxn(() async {
        final id = await isar.words.put(word);
        debugPrint('Yeni kelime olan ${word.englishWord} kaydedildi. ID: $id');
      });
    } catch (e) {
      debugPrint('Kelime eklenirken hata: $e');
    }
  }

  Future<List<Word>> getAllWords() async {
    try {
      final words = await isar.words.where().findAll();
      debugPrint(
        'Tüm kelimeler getirildi. Toplam kelime sayısı: ${words.length}',
      );
      return words;
    } catch (e) {
      debugPrint('Tüm kelimeler getirilirken hata: $e');
      return [];
    }
  }

  Future<void> deleteWord(int id) async {
    try {
      isar.writeTxn(() async {
        await isar.words.delete(id);
        debugPrint('Kelime silindi. ID: $id');
      });
    } catch (e) {
      debugPrint('Kelime silinirken hata: $e');
    }
  }

  Future<void> updateWord(Word word) async {
    try {
      isar.writeTxn(() async {
        final id = await isar.words.put(word);
        debugPrint('Kelime olan ${word.englishWord} güncellendi. ID: $id');
      });
    } catch (e) {
      debugPrint('Kelime güncellenirken hata: $e');
    }
  }

  Future<void> toggleWordLearned(int id) async {
    try {
      await isar.writeTxn(() async {
        final word = await isar.words.get(id);
        if (word != null) {
          word.isLearned = !word.isLearned;
          await isar.words.put(word);
          debugPrint('Kelime güncellendi!');
        } else {
          debugPrint('Kelime bulunamadı.');
        }
      });
    } catch (e) {
      debugPrint('Kelime güncellenirken hata: $e');
    }
  }
}
