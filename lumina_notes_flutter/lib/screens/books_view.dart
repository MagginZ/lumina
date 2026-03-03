import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class BooksView extends StatelessWidget {
  const BooksView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, state),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: state.books.length + 1,
                itemBuilder: (context, index) {
                  if (index == state.books.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text(
                          '共 ${state.books.length} 本书',
                          style: TextStyle(
                            color: isDark
                                ? Colors.grey[500]
                                : Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }
                  return _BookItem(book: state.books[index]);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => state.createNote(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.edit_note, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF0F172A) : Colors.white)
            .withValues(alpha: 0.95),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '书籍',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              IconButton(
                onPressed: () => state.createNote(),
                icon: const Icon(Icons.add, color: AppColors.primary, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => state.showSearchView(),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey[500], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '搜索',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 17,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.mic, color: Colors.grey[500], size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookItem extends StatelessWidget {
  final Book book;

  const _BookItem({required this.book});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Slidable(
      key: ValueKey(book.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => _showDeleteDialog(context),
            backgroundColor: AppColors.iosRed,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: '删除',
          ),
        ],
      ),
      child: Material(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        child: InkWell(
          onTap: () async {
            final state = context.read<AppState>();
            final note = state.findNoteByBook(book);
            if (note != null) {
              state.openNote(note);
            } else {
              await state.createNoteForBook(book);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        book.title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      book.updatedAt,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (book.author != '默认') ...[
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (book.lastNotePreview != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    book.lastNotePreview!,
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final state = context.read<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark
            ? const Color(0xFF1E1E1E).withValues(alpha: 0.95)
            : const Color(0xFFF2F2F2).withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('删除书籍？'),
        content: Text(
          '确定要删除「${book.title}」及其所有笔记吗？此操作不可撤销。',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消', style: TextStyle(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () async {
              await state.deleteBook(book.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('删除', style: TextStyle(color: AppColors.iosRed, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
