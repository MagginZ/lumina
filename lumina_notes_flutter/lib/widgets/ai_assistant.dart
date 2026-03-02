import 'package:flutter/material.dart';
import '../models/message.dart';
import '../theme/app_theme.dart';
import '../services/ai_service.dart';

class AiAssistant extends StatefulWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final String noteContent;
  final Function(String)? onSaveToNote;

  const AiAssistant({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.noteContent,
    this.onSaveToNote,
  });

  @override
  State<AiAssistant> createState() => _AiAssistantState();
}

class _AiAssistantState extends State<AiAssistant> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    AiService.resetChat();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(ChatMessage(role: 'user', content: text));
      _inputController.clear();
      _isLoading = true;
    });

    try {
      final response = await AiService.chat(text, widget.noteContent);
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(role: 'assistant', content: response));
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            role: 'assistant',
            content: '请求失败：$e。请检查 env 中是否已配置 OPENROUTER_API_KEY。',
          ));
          _isLoading = false;
        });
      }
    }
  }

  void _handleSaveToNote(String content) {
    widget.onSaveToNote?.call(content);
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        GestureDetector(
          onTap: widget.onClose,
          child: Container(
            color: Colors.black.withValues(alpha: 0.2),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Material(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: SafeArea(
              top: false,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'AI 助手',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: widget.onClose,
                            style: IconButton.styleFrom(
                              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                            ),
                            icon: Icon(Icons.close, size: 18, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Flexible(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _messages.length + (_isLoading ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (i == _messages.length) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '思考中...',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          final msg = _messages[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Align(
                              alignment: msg.role == 'user'
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.85,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: msg.role == 'user'
                                      ? AppColors.primary
                                      : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: Radius.circular(msg.role == 'user' ? 16 : 4),
                                    bottomRight: Radius.circular(msg.role == 'user' ? 4 : 16),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      msg.content,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: msg.role == 'user'
                                            ? Colors.white
                                            : (isDark ? Colors.grey[200] : const Color(0xFF334155)),
                                      ),
                                    ),
                                    if (msg.role == 'assistant') ...[
                                      const SizedBox(height: 12),
                                      TextButton.icon(
                                        onPressed: () => _handleSaveToNote(msg.content),
                                        icon: const Icon(Icons.add, size: 14, color: AppColors.primary),
                                        label: const Text(
                                          '保存到笔记',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _inputController,
                              enabled: !_isLoading,
                              onSubmitted: (_) => _handleSend(),
                              decoration: InputDecoration(
                                hintText: '关于这条笔记，想问什么...',
                                hintStyle: TextStyle(color: Colors.grey[500]),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _isLoading ? null : () => _handleSend(),
                            icon: const Icon(Icons.arrow_circle_up, color: AppColors.primary, size: 32),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
