/// 笔记模型
class Note {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final bool isAiGenerated;
  final String updatedAt;
  final String bookId;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    this.isAiGenerated = false,
    required this.updatedAt,
    required this.bookId,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? imageUrl,
    bool? isAiGenerated,
    String? updatedAt,
    String? bookId,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      isAiGenerated: isAiGenerated ?? this.isAiGenerated,
      updatedAt: updatedAt ?? this.updatedAt,
      bookId: bookId ?? this.bookId,
    );
  }
}
