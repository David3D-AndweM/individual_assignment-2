import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/book_entity.dart';

class BookModel extends BookEntity {
  const BookModel({
    required super.id,
    required super.title,
    required super.author,
    required super.condition,
    super.imageUrl,
    required super.ownerId,
    required super.ownerName,
    required super.createdAt,
    required super.updatedAt,
    required super.isAvailable,
    required super.status,
  });

  factory BookModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookModel(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      condition: _parseCondition(data['condition']),
      imageUrl: data['imageUrl'],
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isAvailable: data['isAvailable'] ?? true,
      status: _parseStatus(data['status'] ?? 'available'),
    );
  }

  factory BookModel.fromEntity(BookEntity entity) {
    return BookModel(
      id: entity.id,
      title: entity.title,
      author: entity.author,
      condition: entity.condition,
      imageUrl: entity.imageUrl,
      ownerId: entity.ownerId,
      ownerName: entity.ownerName,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isAvailable: entity.isAvailable,
      status: entity.status,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'condition': condition.displayName,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isAvailable': isAvailable,
    };
  }

  BookModel copyWith({
    String? id,
    String? title,
    String? author,
    BookCondition? condition,
    String? imageUrl,
    String? ownerId,
    String? ownerName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isAvailable,
    BookStatus? status,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      condition: condition ?? this.condition,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isAvailable: isAvailable ?? this.isAvailable,
      status: status ?? this.status,
    );
  }

  static BookStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'available':
        return BookStatus.available;
      case 'pending':
        return BookStatus.pending;
      case 'swapped':
        return BookStatus.swapped;
      default:
        return BookStatus.available;
    }
  }

  static BookCondition _parseCondition(String? condition) {
    switch (condition) {
      case 'New':
        return BookCondition.newCondition;
      case 'Like New':
        return BookCondition.likeNew;
      case 'Good':
        return BookCondition.good;
      case 'Used':
        return BookCondition.used;
      default:
        return BookCondition.good;
    }
  }
}
