/// 书籍模型
class Book {
  final String id;
  final String title;
  final String author;
  final String? lastNotePreview;
  final String updatedAt;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    this.lastNotePreview,
    required this.updatedAt,
  });

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? lastNotePreview,
    String? updatedAt,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      lastNotePreview: lastNotePreview ?? this.lastNotePreview,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
