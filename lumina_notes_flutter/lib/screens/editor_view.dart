import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
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
  String? _pendingImageUrl;

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

  String? get _effectiveImageUrl {
    if (_pendingImageUrl != null && _pendingImageUrl!.isEmpty) return null;
    return _pendingImageUrl ?? widget.note.imageUrl;
  }

  Future<void> _saveAndBack() async {
    _unfocusForWeb();
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    await _handleDone();
  }

  /// Web 平台：先解除输入框焦点，避免 pointer 断言错误导致无法点击
  void _unfocusForWeb() {
    FocusScope.of(context).unfocus();
  }

  Future<void> _handleDone() async {
    final clearImage = _pendingImageUrl != null && _pendingImageUrl!.isEmpty;
    final imageUrl = clearImage ? null : (_pendingImageUrl ?? widget.note.imageUrl);
    final updated = widget.note.copyWith(
      title: _titleController.text,
      content: _contentController.text,
      imageUrl: imageUrl,
      clearImageUrl: clearImage,
      isAiGenerated: _pendingImageUrl != null ? false : widget.note.isAiGenerated,
      updatedAt: _formatDateTime(DateTime.now()),
    );
    await context.read<AppState>().saveNote(updated);
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('拍照'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    try {
      final picker = ImagePicker();
      final xFile = await picker.pickImage(source: source, imageQuality: 85);
      if (xFile == null) return;
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}${path.extension(xFile.path)}';
      final savedFile = await File(xFile.path).copy('${dir.path}/$fileName');
      setState(() => _pendingImageUrl = savedFile.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加图片失败: $e')),
        );
      }
    }
  }

  void _showFormatMenu() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.horizontal_rule),
              title: const Text('插入分隔线'),
              onTap: () {
                _insertAtCursor('\n---\n');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('插入日期'),
              onTap: () {
                final now = DateTime.now();
                _insertAtCursor('${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.format_list_bulleted),
              title: const Text('插入待办格式'),
              onTap: () {
                _insertAtCursor('\n- [ ] ');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.format_list_numbered),
              title: const Text('插入有序列表'),
              onTap: () {
                _insertAtCursor('\n1. ');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _insertAtCursor(String text) {
    final controller = _contentController;
    final pos = controller.selection.baseOffset;
    if (pos < 0) {
      controller.text += text;
    } else {
      controller.text = controller.text.substring(0, pos) + text + controller.text.substring(pos);
      controller.selection = TextSelection.collapsed(offset: pos + text.length);
    }
  }

  void _showMoreMenu() {
    final hasImage = _effectiveImageUrl != null;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasImage)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('移除图片'),
                onTap: () {
                  setState(() => _pendingImageUrl = '');
                  Navigator.pop(ctx);
                },
              ),
            if (!hasImage)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('暂无更多选项', style: TextStyle(color: Colors.grey)),
              ),
          ],
        ),
      ),
    );
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
        child: _buildEditorBody(isDark),
      ),
    );
  }

  Widget _buildEditorBody(bool isDark) {
    final stack = Stack(
      children: [
        Column(
          children: [
            _wrapWithWebUnfocus(_buildHeader(context, isDark)),
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
                          onTapOutside: (_) => FocusScope.of(context).unfocus(),
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
                      if (_effectiveImageUrl != null) _buildAiImage(isDark),
                      const SizedBox(height: 16),
                        TextField(
                          controller: _contentController,
                          onTapOutside: (_) => FocusScope.of(context).unfocus(),
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
            _wrapWithWebUnfocus(_buildBottomToolbar(isDark)),
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
    );
    return stack;
  }

  /// Web：点击时先解除输入框焦点，避免 pointer 断言导致无法点击
  Widget _wrapWithWebUnfocus(Widget child) {
    if (!kIsWeb) return child;
    return Listener(
      onPointerDown: (_) => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: child,
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
            onPressed: () => _saveAndBack(),
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
    final url = _effectiveImageUrl!;
    final isLocalFile = url.startsWith('/') || url.startsWith('file:');
    final isAiGenerated = _pendingImageUrl == null && widget.note.isAiGenerated;

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
                    child: isLocalFile
                        ? Image.file(
                            File(url.startsWith('file:') ? url.substring(7) : url),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildImageError(isDark),
                          )
                        : Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildImageError(isDark),
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
                          Icon(
                            isAiGenerated ? Icons.auto_awesome : Icons.image,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isAiGenerated ? 'AI 生成' : '图片',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: _pickImage,
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

  Widget _buildImageError(bool isDark) => Container(
    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
    child: const Icon(Icons.broken_image, size: 48),
  );

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
          IconButton(
            onPressed: _handleDone,
            icon: const Icon(Icons.check_circle, color: AppColors.primary, size: 24),
            tooltip: '保存',
          ),
          IconButton(
            onPressed: _pickImage,
            icon: const Icon(Icons.camera_alt, color: AppColors.primary, size: 24),
            tooltip: '添加图片',
          ),
          IconButton(
            onPressed: _showFormatMenu,
            icon: const Icon(Icons.brush, color: AppColors.primary, size: 24),
            tooltip: '格式',
          ),
          IconButton(
            onPressed: _showMoreMenu,
            icon: const Icon(Icons.edit_note, color: AppColors.primary, size: 24),
            tooltip: '更多',
          ),
        ],
      ),
    );
  }
}
