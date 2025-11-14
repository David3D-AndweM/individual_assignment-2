import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/swap_entity.dart';

class SwapModel extends SwapEntity {
  const SwapModel({
    required super.id,
    required super.requesterId,
    required super.requesterName,
    required super.ownerId,
    required super.ownerName,
    required super.bookId,
    required super.bookTitle,
    required super.bookAuthor,
    super.bookImageUrl,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.message,
  });

  factory SwapModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SwapModel(
      id: doc.id,
      requesterId: data['requesterId'] ?? '',
      requesterName: data['requesterName'] ?? '',
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      bookId: data['bookId'] ?? '',
      bookTitle: data['bookTitle'] ?? '',
      bookAuthor: data['bookAuthor'] ?? '',
      bookImageUrl: data['bookImageUrl'],
      status: _parseStatus(data['status']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      message: data['message'],
    );
  }

  factory SwapModel.fromEntity(SwapEntity entity) {
    return SwapModel(
      id: entity.id,
      requesterId: entity.requesterId,
      requesterName: entity.requesterName,
      ownerId: entity.ownerId,
      ownerName: entity.ownerName,
      bookId: entity.bookId,
      bookTitle: entity.bookTitle,
      bookAuthor: entity.bookAuthor,
      bookImageUrl: entity.bookImageUrl,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      message: entity.message,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'requesterId': requesterId,
      'requesterName': requesterName,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'bookAuthor': bookAuthor,
      'bookImageUrl': bookImageUrl,
      'status': status.displayName.toLowerCase(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'message': message,
    };
  }

  SwapModel copyWith({
    String? id,
    String? requesterId,
    String? requesterName,
    String? ownerId,
    String? ownerName,
    String? bookId,
    String? bookTitle,
    String? bookAuthor,
    String? bookImageUrl,
    SwapStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? message,
  }) {
    return SwapModel(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      bookId: bookId ?? this.bookId,
      bookTitle: bookTitle ?? this.bookTitle,
      bookAuthor: bookAuthor ?? this.bookAuthor,
      bookImageUrl: bookImageUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      message: message ?? this.message,
    );
  }

  static SwapStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return SwapStatus.pending;
      case 'accepted':
        return SwapStatus.accepted;
      case 'rejected':
        return SwapStatus.rejected;
      case 'completed':
        return SwapStatus.completed;
      case 'cancelled':
        return SwapStatus.cancelled;
      default:
        return SwapStatus.pending;
    }
  }
}
