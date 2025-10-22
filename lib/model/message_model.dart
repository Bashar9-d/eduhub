class MessageModel {
  final int messageId;
  final int groupId;
  final int senderId;
  final String message;
  final String userName;
  final String time;

  MessageModel({
    required this.messageId,
    required this.groupId,
    required this.senderId,
    required this.message,
    required this.userName,
    required this.time,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: json['message_id'],
      groupId: json['group_id'],
      senderId: json['sender_id'],
      message: json['message'],
      userName: json['sender_name'],
      time: json['sent_at'],
    );
  }
}
