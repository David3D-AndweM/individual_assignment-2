class ChatEntity {
  final String id;
  final String swapId;
  final List<String> participantIds;
  final List<String> participantNames;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatEntity({
    required this.id,
    required this.swapId,
    required this.participantIds,
    required this.participantNames,
    this.lastMessage,
    this.lastMessageTime,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
