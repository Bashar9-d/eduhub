import 'dart:async';
import 'package:flutter/material.dart';
import '../controller/group_service.dart';
import '../model/message_model.dart';
import '../constant/otherwise/color_manage.dart';

class ChatPage extends StatefulWidget {
  final int groupId;
  final int userId;

  const ChatPage({super.key, required this.groupId, required this.userId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final StreamController<List<MessageModel>> _streamController =
  StreamController.broadcast();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadMessagesPeriodically();
  }

  void _loadMessagesPeriodically() {
    _fetchMessages();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => _fetchMessages(),
    );
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

    _controller.clear();
    _fetchMessages();

    final success = await GroupService.sendMessage(
      widget.groupId,
      widget.userId,
      msg,
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send message")),
      );
    } else {
      _fetchMessages();
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
      backgroundColor: const Color(0xFFF4E1FF),
      appBar: AppBar(
        backgroundColor: ColorManage.secondPrimary,
        centerTitle: true,
        title: const Text(
          "Courses Group  Chat",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        foregroundColor: Colors.white,

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
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[messages.length - 1 - index];
                    final isMe = msg.senderId == widget.userId;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Padding(
                                padding:
                                const EdgeInsets.only(left: 8, bottom: 3),
                                child: Text(
                                  msg.userName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              constraints: BoxConstraints(
                                maxWidth:
                                MediaQuery.of(context).size.width * 0.7,
                              ),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? ColorManage.secondPrimary
                                    : const Color(0xFFE39EFF),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft:
                                  Radius.circular(isMe ? 16 : 0),
                                  bottomRight:
                                  Radius.circular(isMe ? 0 : 16),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    msg.message,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    msg.time,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
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
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Type a message",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: ColorManage.secondPrimary,
                  radius: 24,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
