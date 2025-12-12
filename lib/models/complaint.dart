class Complaint {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime createdAt;
  final bool isResolved;
  final List<SupportMessage> messages;

  Complaint({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.createdAt,
    this.isResolved = false,
    List<SupportMessage>? messages,
  }) : messages = messages ?? [];
}

class SupportMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime sentAt;
  final bool isFromCurrentUser;

  SupportMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.sentAt,
    this.isFromCurrentUser = false,
  });
}