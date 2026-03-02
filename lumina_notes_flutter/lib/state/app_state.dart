import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../models/note.dart';
import '../services/database_service.dart';

enum AppView { books, search, editor }

class AppState extends ChangeNotifier {
  AppView _currentView = AppView.books;
  List<Book> _books = [];
  List<Note> _notes = [];
  Note? _selectedNote;
  String _searchQuery = '';
  bool _isLoading = true;
  String? _loadError;

  AppView get currentView => _currentView;
  List<Book> get books => _books;
  List<Note> get notes => _notes;
  Note? get selectedNote => _selectedNote;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get loadError => _loadError;

  set searchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  Future<void> loadData() async {
    _isLoading = true;
    _loadError = null;
    notifyListeners();

    try {
      _books = await DatabaseService.getAllBooks();
      _notes = await DatabaseService.getAllNotes();
    } catch (e) {
      _loadError = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteBook(String id) async {
    await DatabaseService.deleteBook(id);
    _books = _books.where((b) => b.id != id).toList();
    _notes = _notes.where((n) => n.bookId != id).toList();
    notifyListeners();
  }

  Future<void> createNote() async {
    await _createNoteForBookId(
      _books.isNotEmpty ? _books.first.id : null,
      defaultTitle: '',
    );
  }

  Future<void> createNoteForBook(Book book) async {
    await _createNoteForBookId(book.id, defaultTitle: book.title);
  }

  Future<void> _createNoteForBookId(String? bookId, {String defaultTitle = ''}) async {
    if (bookId == null || _books.isEmpty) {
      final defaultBook = Book(
        id: '1',
        title: '未分类',
        author: '默认',
        updatedAt: _formatDateTime(DateTime.now()),
      );
      await DatabaseService.saveBook(defaultBook);
      _books = [defaultBook];
      bookId = '1';
    }

    final newNote = Note(
      id: 'note-${DateTime.now().millisecondsSinceEpoch}',
      bookId: bookId,
      title: defaultTitle,
      content: '',
      updatedAt: _formatDateTime(DateTime.now()),
    );
    await DatabaseService.saveNote(newNote);
    _notes.insert(0, newNote);
    _selectedNote = newNote;
    _currentView = AppView.editor;
    notifyListeners();
  }

  void openNote(Note note) {
    _selectedNote = note;
    _currentView = AppView.editor;
    notifyListeners();
  }

  Future<void> saveNote(Note updatedNote) async {
    await DatabaseService.saveNote(updatedNote);
    final idx = _notes.indexWhere((n) => n.id == updatedNote.id);
    if (idx >= 0) {
      _notes[idx] = updatedNote;
    } else {
      _notes.insert(0, updatedNote);
    }

    final preview = updatedNote.content.length > 50
        ? '${updatedNote.content.substring(0, 50)}...'
        : updatedNote.content;
    await DatabaseService.updateBookLastPreview(
      updatedNote.bookId,
      preview.isEmpty ? null : preview,
      updatedNote.updatedAt,
    );
    _updateBookPreview(updatedNote.bookId, preview, updatedNote.updatedAt);

    _currentView = AppView.books;
    _selectedNote = null;
    notifyListeners();
  }

  void _updateBookPreview(String bookId, String? preview, String updatedAt) {
    final idx = _books.indexWhere((b) => b.id == bookId);
    if (idx >= 0) {
      _books[idx] = _books[idx].copyWith(
        lastNotePreview: preview,
        updatedAt: updatedAt,
      );
    }
  }

  void showBooksView() {
    _currentView = AppView.books;
    _selectedNote = null;
    notifyListeners();
  }

  void showSearchView() {
    _currentView = AppView.search;
    notifyListeners();
  }

  void back() {
    if (_currentView == AppView.editor || _currentView == AppView.search) {
      _currentView = AppView.books;
      _selectedNote = null;
      notifyListeners();
    }
  }

  List<Note> getFilteredNotes(String query) {
    if (query.isEmpty) return _notes;
    final q = query.toLowerCase();
    return _notes.where((n) {
      return n.title.toLowerCase().contains(q) ||
          n.content.toLowerCase().contains(q);
    }).toList();
  }

  Note? findNoteByBook(Book book) {
    try {
      return _notes.firstWhere((n) => n.bookId == book.id);
    } catch (_) {
      return null;
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
