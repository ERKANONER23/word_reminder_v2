import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/word_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('words.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE words(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        english TEXT NOT NULL,
        turkish TEXT NOT NULL
      )
    ''');
  }

  Future<void> addWord(Word word) async {
    final db = await instance.database;
    await db.insert('words', word.toMap());
  }

  Future<List<Word>> getAllWords() async {
    final db = await instance.database;
    final result = await db.query('words', orderBy: 'id ASC');
    return result.map((map) => Word.fromMap(map)).toList();
  }

  Future<Word?> findWordByEnglish(String english) async {
    final db = await instance.database;
    final result = await db.query(
      'words',
      where: 'LOWER(english) = ?',
      whereArgs: [english.toLowerCase()],
    );
    if (result.isNotEmpty) {
      return Word.fromMap(result.first);
    }
    return null;
  }

  Future<Word?> findWordById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'words',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Word.fromMap(result.first);
    }
    return null;
  }

  Future<void> updateWord(Word word) async {
    final db = await instance.database;
    await db.update(
      'words',
      word.toMap(),
      where: 'id = ?',
      whereArgs: [word.id],
    );
  }

  Future<void> deleteWord(int id) async {
    final db = await instance.database;
    await db.delete('words', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllWords() async {
    final db = await instance.database;
    await db.delete('words');
  }

  Future<int> getWordCount() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM words');
    return result.first.values.first as int;
  }
}