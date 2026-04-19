import 'package:flutter/material.dart';
import '../services/openai_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final IbanAIService _aiService = IbanAIService();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': "Hi, I'm your LinguaBuddy! How can I help you learn Iban today?",
      'isUser': false,
    }
  ];
  bool _isLoading = false;

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'text': text, 'isUser': true});
      _isLoading = true;
    });
    _controller.clear();

    // Call Groq / AI Service
    final response = await _aiService.chatWithBot(text);

    if (mounted) {
      setState(() {
        _messages.add({'text': response, 'isUser': false});
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B365D), // Navy Blue
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble, color: Color(0xFFFFC857)),
            SizedBox(width: 10),
            Text('LinguaBuddy', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildChatBubble(context, msg['text'], msg['isUser']);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
               padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
               child: Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
               ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: "Ask LinguaBuddy...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF1B365D)),
                    onPressed: _sendMessage,
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildChatBubble(BuildContext context, String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isUser ? Colors.grey[200] : const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(20),
          ),
        ),
        child: Text(text.replaceAll('**', '').replaceAll(RegExp(r'(?<!\w)\*(?!\w)'), ''), style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
