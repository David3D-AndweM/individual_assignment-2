enum BookStatus {
  available('Available'),
  pending('Pending'),
  swapped('Swapped');

  const BookStatus(this.displayName);
  final String displayName;
}

enum BookCondition {
  newCondition('New'),
  likeNew('Like New'),
  good('Good'),
  used('Used');

  const BookCondition(this.displayName);
  final String displayName;
}

class BookEntity {
  final String id;
  final String title;
  final String author;
  final BookCondition condition;
  final String? imageUrl;
  final String ownerId;
  final String ownerName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final BookStatus status;
  final bool isAvailable;

  const BookEntity({
    required this.id,
    required this.title,
    required this.author,
    required this.condition,
    this.imageUrl,
    required this.ownerId,
    required this.ownerName,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.isAvailable,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
