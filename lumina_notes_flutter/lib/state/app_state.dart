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

  /// 从笔记中提取列表显示用的标题：优先 note.title，否则取内容首行
  static String _noteDisplayTitle(Note note) {
    if (note.title.trim().isNotEmpty) return note.title.trim();
    final firstLine = note.content.split('\n').first.trim();
    return firstLine.isNotEmpty ? firstLine : '未命名笔记';
  }

  Future<void> saveNote(Note updatedNote) async {
    await DatabaseService.saveNote(updatedNote);
    final idx = _notes.indexWhere((n) => n.id == updatedNote.id);
    if (idx >= 0) {
      _notes[idx] = updatedNote;
    } else {
      _notes.insert(0, updatedNote);
    }

    final displayTitle = _noteDisplayTitle(updatedNote);
    // 预览：若标题取自内容首行，则预览从第二行开始，避免重复
    String previewContent = updatedNote.content;
    if (updatedNote.title.isEmpty && updatedNote.content.contains('\n')) {
      final lines = updatedNote.content.split('\n');
      previewContent = lines.sublist(1).join('\n');
    }
    final preview = previewContent.length > 50
        ? '${previewContent.substring(0, 50)}...'
        : previewContent;
    // 默认书籍（未分类）同步笔记标题，便于列表显示
    final bookIdx = _books.indexWhere((b) => b.id == updatedNote.bookId);
    final isDefaultBook = bookIdx >= 0 &&
        _books[bookIdx].id == '1' &&
        _books[bookIdx].title == '未分类';
    await DatabaseService.updateBookLastPreview(
      updatedNote.bookId,
      preview.isEmpty ? null : preview,
      updatedNote.updatedAt,
      title: isDefaultBook ? displayTitle : null,
    );
    _updateBookPreview(
      updatedNote.bookId,
      preview: preview,
      updatedAt: updatedNote.updatedAt,
      title: isDefaultBook ? displayTitle : null,
    );

    _currentView = AppView.books;
    _selectedNote = null;
    notifyListeners();
  }

  void _updateBookPreview(String bookId, {String? preview, required String updatedAt, String? title}) {
    final idx = _books.indexWhere((b) => b.id == bookId);
    if (idx >= 0) {
      var updated = _books[idx].copyWith(updatedAt: updatedAt);
      if (preview != null) updated = updated.copyWith(lastNotePreview: preview);
      if (title != null) updated = updated.copyWith(title: title);
      _books[idx] = updated;
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
