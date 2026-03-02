import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static String? _apiKey;
  static final List<Map<String, String>> _chatHistory = [];

  static const String _baseUrl = 'https://openrouter.ai/api/v1';
  // 免费模型，可更换为其他 :free 模型
  static const String _model = 'arcee-ai/trinity-large-preview:free';

  static void init(String apiKey) {
    _apiKey = apiKey.trim().isNotEmpty ? apiKey.trim() : null;
    _chatHistory.clear();
  }

  static Future<String> chat(String userMessage, String noteContent) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('AI 服务未初始化，请检查 env 中的 OPENROUTER_API_KEY');
    }

    final systemContent = '你是一个读书笔记助手。用户会分享他们的笔记内容，你需要基于笔记内容回答问题。请用中文回复，回答要简洁有帮助。';

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemContent},
      ..._chatHistory,
      if (noteContent.isNotEmpty)
        {'role': 'user', 'content': '用户当前笔记内容：\n$noteContent\n\n用户问题：$userMessage'}
      else
        {'role': 'user', 'content': userMessage},
    ];

    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://lumina-notes.app',
      },
      body: jsonEncode({
        'model': _model,
        'messages': messages,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('请求失败: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      return '抱歉，我暂时无法回答这个问题。';
    }

    final content = (choices.first as Map<String, dynamic>)['message'] as Map<String, dynamic>?;
    final text = content?['content'] as String?;
    if (text == null || text.isEmpty) {
      return '抱歉，我暂时无法回答这个问题。';
    }

    _chatHistory.add({'role': 'user', 'content': userMessage});
    _chatHistory.add({'role': 'assistant', 'content': text});

    return text;
  }

  static void resetChat() {
    _chatHistory.clear();
  }
}
