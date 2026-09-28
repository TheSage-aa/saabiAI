enum MessageRole { user, assistant }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.isError = false,
  });

  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final bool isError;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      role: json['role'] == 'user' ? MessageRole.user : MessageRole.assistant,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isError: json['isError'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role.name,
      'timestamp': timestamp.toIso8601String(),
      'isError': isError,
    };
  }
}
