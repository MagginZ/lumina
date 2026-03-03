import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_assistant.dart';

class EditorView extends StatefulWidget {
  final Note note;

  const EditorView({super.key, required this.note});

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isAiOpen = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void didUpdateWidget(EditorView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.note.id != widget.note.id) {
      _titleController.text = widget.note.title;
      _contentController.text = widget.note.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _handleDone() async {
    final updated = widget.note.copyWith(
      title: _titleController.text,
      content: _contentController.text,
      updatedAt: _formatDateTime(DateTime.now()),
    );
    await context.read<AppState>().saveNote(updated);
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(context, isDark),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        TextField(
                          controller: _titleController,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            hintText: '笔记标题',
                            hintStyle: TextStyle(
                              color: isDark ? Colors.grey[700] : Colors.grey[400],
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        if (widget.note.imageUrl != null) _buildAiImage(isDark),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _contentController,
                          maxLines: null,
                          minLines: 12,
                          style: TextStyle(
                            fontSize: 18,
                            height: 1.6,
                            color: isDark ? Colors.grey[200] : const Color(0xFF334155),
                          ),
                          decoration: InputDecoration(
                            hintText: '在此输入笔记内容...',
                            hintStyle: TextStyle(
                              color: isDark ? Colors.grey[600] : Colors.grey[500],
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Center(
                            child: Text(
                              '编辑于 ${widget.note.updatedAt}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.grey[600] : Colors.grey[500],
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
                ),
                _buildBottomToolbar(isDark),
              ],
            ),
            AiAssistant(
              isOpen: _isAiOpen,
              onClose: () => setState(() => _isAiOpen = false),
              noteContent: _contentController.text,
              onSaveToNote: (content) {
                setState(() {
                  final current = _contentController.text;
                  _contentController.text = current.isEmpty
                      ? content
                      : '$current\n\n--- AI 总结 ---\n$content';
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.backgroundDark : AppColors.backgroundLight)
            .withValues(alpha: 0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () => context.read<AppState>().back(),
            icon: const Icon(Icons.chevron_left, color: AppColors.primary, size: 28),
            label: const Text('笔记', style: TextStyle(color: AppColors.primary, fontSize: 18)),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _isAiOpen = true),
                icon: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 22),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.share, color: AppColors.primary, size: 24),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_horiz, color: AppColors.primary, size: 24),
              ),
              TextButton(
                onPressed: _handleDone,
                child: const Text('完成', style: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiImage(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Image.network(
                      widget.note.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        child: const Icon(Icons.broken_image, size: 48),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'AI 生成',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.refresh, size: 14, color: AppColors.primary),
                        label: const Text('替换', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomToolbar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.backgroundDark : AppColors.backgroundLight)
            .withValues(alpha: 0.8),
        border: Border(
          top: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.check_circle, color: AppColors.primary, size: 24)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.camera_alt, color: AppColors.primary, size: 24)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.brush, color: AppColors.primary, size: 24)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit_note, color: AppColors.primary, size: 24)),
        ],
      ),
    );
  }
}
