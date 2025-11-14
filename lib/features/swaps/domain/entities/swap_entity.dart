enum SwapStatus {
  pending('Pending'),
  accepted('Accepted'),
  rejected('Rejected'),
  completed('Completed'),
  cancelled('Cancelled');

  const SwapStatus(this.displayName);
  final String displayName;
}

class SwapEntity {
  final String id;
  final String requesterId;
  final String requesterName;
  final String ownerId;
  final String ownerName;
  final String bookId;
  final String bookTitle;
  final String bookAuthor;
  final String? bookImageUrl;
  final SwapStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? message;

  const SwapEntity({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.ownerId,
    required this.ownerName,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    this.bookImageUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.message,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SwapEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
