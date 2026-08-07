import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/word_model.dart';
import '../services/database_service.dart';

final wordListProvider =
StateNotifierProvider<WordListNotifier, List<Word>>((ref) {
  return WordListNotifier();
});

class WordListNotifier extends StateNotifier<List<Word>> {
  WordListNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    await loadWords();
  }

  Future<void> loadWords() async {
    state = await DatabaseService.instance.getAllWords();
  }

  Future<void> addWord(String english, String turkish) async {
    await DatabaseService.instance
        .addWord(Word(english: english, turkish: turkish));
    await loadWords();
  }

  Future<void> updateWord(Word word) async {
    await DatabaseService.instance.updateWord(word);
    await loadWords();
  }

  Future<void> deleteWord(int id) async {
    await DatabaseService.instance.deleteWord(id);
    await loadWords();
  }

  Future<void> deleteAllWords() async {
    await DatabaseService.instance.deleteAllWords();
    await loadWords();
  }
}