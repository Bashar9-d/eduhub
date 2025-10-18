import 'dart:async';
import 'package:flutter/material.dart';
import '../../controller/group_service.dart';
import '../../model/message_model.dart';

class ChatPage extends StatefulWidget {
  final int groupId;
  final int userId;

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
    _fetchMessages();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _fetchMessages());
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

    _controller.clear(); // مسح فور الضغط
    _fetchMessages(); // تحديث فوري للمحادثة قبل إرسال

    final success = await GroupService.sendMessage(widget.groupId, widget.userId, msg);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send message")),
      );
    } else {
      _fetchMessages(); // تحديث بعد التأكيد
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Course Group Chat"),
        backgroundColor: Colors.purple,
        centerTitle: true,
      ),
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
                  return const Center(child: Text("No messages yet"));
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[messages.length - 1 - index];
                    final isMe = msg.senderId == widget.userId;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.purple : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isMe ? 16 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 16),
                          ),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Text(
                                msg.userName,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            Text(
                              msg.message,
                              style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                msg.time,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isMe ? Colors.white70 : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(14),
                    backgroundColor: Colors.purple,
                  ),
                  onPressed: _sendMessage,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
