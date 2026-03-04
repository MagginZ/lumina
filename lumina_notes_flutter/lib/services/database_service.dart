import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/book.dart';
import '../models/note.dart';

class DatabaseService {
  static const String _boxName = 'lumina_notes';
  static const String _booksKey = 'books';
  static const String _notesKey = 'notes';

  static Box<dynamic>? _box;

  static Future<void> init() async {
    if (_box != null) return;
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
    await _seedIfEmpty();
  }

  static Future<void> flush() async {
    if (_box != null) await _box!.flush();
  }

  static Future<Box<dynamic>> get _db async {
    if (_box == null) await init();
    return _box!;
  }

  static Future<void> _seedIfEmpty() async {
    final db = await _db;
    if (db.get(_booksKey) == null) {
      await db.put(_booksKey, []);
    }
    if (db.get(_notesKey) == null) {
      await db.put(_notesKey, []);
    }
  }

  static Map<String, dynamic> _toMap(dynamic m) {
    if (m is Map) {
      return m.map((k, v) => MapEntry(k.toString(), v));
    }
    return Map<String, dynamic>.from(jsonDecode(m.toString()) as Map);
  }

  static List<Book> _parseBooks(List<dynamic> list) {
    return list.map((m) {
      final map = _toMap(m);
      return Book(
        id: map['id'] as String,
        title: map['title'] as String,
        author: map['author'] as String,
        lastNotePreview: map['lastNotePreview'] as String?,
        updatedAt: map['updatedAt'] as String,
      );
    }).toList();
  }

  static List<Note> _parseNotes(List<dynamic> list) {
    return list.map((m) {
      final map = _toMap(m);
      return Note(
        id: map['id'] as String,
        bookId: map['bookId'] as String,
        title: map['title'] as String,
        content: map['content'] as String,
        imageUrl: map['imageUrl'] as String?,
        isAiGenerated: (map['isAiGenerated'] as bool?) ?? false,
        updatedAt: map['updatedAt'] as String,
      );
    }).toList();
  }

  static Future<List<Book>> getAllBooks() async {
    final db = await _db;
    final list = db.get(_booksKey) as List? ?? [];
    final books = _parseBooks(list);
    books.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return books;
  }

  static Future<List<Note>> getAllNotes() async {
    final db = await _db;
    final list = db.get(_notesKey) as List? ?? [];
    final notes = _parseNotes(list);
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  static Future<void> _saveBooks(List<Book> books) async {
    final db = await _db;
    final json = books.map((b) => {
      'id': b.id,
      'title': b.title,
      'author': b.author,
      'lastNotePreview': b.lastNotePreview,
      'updatedAt': b.updatedAt,
    }).toList();
    await db.put(_booksKey, json);
    await db.flush();
  }

  static Future<void> _saveNotes(List<Note> notes) async {
    final db = await _db;
    final json = notes.map((n) => {
      'id': n.id,
      'bookId': n.bookId,
      'title': n.title,
      'content': n.content,
      'imageUrl': n.imageUrl,
      'isAiGenerated': n.isAiGenerated,
      'updatedAt': n.updatedAt,
    }).toList();
    await db.put(_notesKey, json);
    await db.flush();
  }

  static Future<void> deleteBook(String id) async {
    final books = await getAllBooks();
    final notes = await getAllNotes();
    await _saveBooks(books.where((b) => b.id != id).toList());
    await _saveNotes(notes.where((n) => n.bookId != id).toList());
  }

  static Future<void> deleteNote(String id) async {
    final notes = await getAllNotes();
    await _saveNotes(notes.where((n) => n.id != id).toList());
  }

  static Future<void> saveBook(Book book) async {
    final books = await getAllBooks();
    final idx = books.indexWhere((b) => b.id == book.id);
    if (idx >= 0) {
      books[idx] = book;
    } else {
      books.add(book);
    }
    await _saveBooks(books);
  }

  static Future<void> saveNote(Note note) async {
    final notes = await getAllNotes();
    final idx = notes.indexWhere((n) => n.id == note.id);
    if (idx >= 0) {
      notes[idx] = note;
    } else {
      notes.insert(0, note);
    }
    await _saveNotes(notes);
  }

  static Future<void> updateBookLastPreview(
    String bookId, String? preview, String updatedAt, {String? title}
  ) async {
    final books = await getAllBooks();
    final idx = books.indexWhere((b) => b.id == bookId);
    if (idx >= 0) {
      var updated = books[idx].copyWith(lastNotePreview: preview, updatedAt: updatedAt);
      if (title != null) updated = updated.copyWith(title: title);
      books[idx] = updated;
      await _saveBooks(books);
    }
  }
}
