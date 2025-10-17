import 'dart:async';
import 'package:flutter/material.dart';
import '../../controller/group_service.dart';
import '../../model/message_model.dart';

class ChatPage extends StatefulWidget {
  final int groupId;
  final int userId; // معرف المستخدم لإرسال الرسائل

  const ChatPage({super.key, required this.groupId, required this.userId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final StreamController<List<MessageModel>> _streamController = StreamController.broadcast();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadMessagesPeriodically();
  }

  void _loadMessagesPeriodically() {
    // جلب الرسائل أول مرة
    _fetchMessages();

    // تحديث الرسائل كل ثانيتين
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _fetchMessages());
  }

  void _fetchMessages() async {
    final messages = await GroupService.getMessages(widget.groupId);
    if (!_streamController.isClosed) {
      _streamController.add(messages);
    }
  }

  void _sendMessage() async {
    final msg = _controller.text.trim();
    if (msg.isEmpty) return;

    final success = await GroupService.sendMessage(widget.groupId, widget.userId, msg);
    if (success) {
      _controller.clear();
      _fetchMessages(); // تحديث الرسائل بعد الإرسال مباشرة
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send message")),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _streamController.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _streamController.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;
                if (messages.isEmpty) {
                  return const Center(child: Text("No messages"));
                }

                return ListView.builder(
                  reverse: true, // الأحدث يظهر في الأسفل
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[messages.length - 1 - index];
                    return ListTile(
                      title: Text(msg.userName),
                      subtitle: Text(msg.message),
                      trailing: Text(msg.time),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: "Type a message"),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
