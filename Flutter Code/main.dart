import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Health Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      home: const ChatScreen(),
    );
  }
}
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});


  @override
  State<ChatScreen> createState() => _ChatScreenState();
}


class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();


  Future<void> sendMessage() async {
    String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;


    setState(() {
      _messages.add({"sender": "You", "message": userMessage});
      _isLoading = true;
    });


    _controller.clear();
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse(
          "https://nahidmuntasir7-health-assistant-api.hf.space/chat",
        ), // For Android Emulator
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": userMessage}),
      );
if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String aiResponse = responseData["response"][0]["content"];


        setState(() {
          _messages.add({"sender": "AI", "message": aiResponse});
        });
      } else {
        setState(() {
          _messages.add({
            "sender": "AI",
            "message": "Error: Failed to fetch response",
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({"sender": "AI", "message": "Error: $e"});
      });
    }
    setState(() {
      _isLoading = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }


@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Health Assistant")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                bool isUser = msg["sender"] == "You";
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color:
                          isUser ? Colors.deepPurpleAccent : Colors.grey[800],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft:
                            isUser
                                ? const Radius.circular(12)
                                : const Radius.circular(0),
                        bottomRight:
                            isUser
                                ? const Radius.circular(0)
                                : const Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      msg["message"],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(10),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask a health question...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

