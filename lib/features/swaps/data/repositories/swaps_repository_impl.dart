import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/swap_entity.dart';
import '../../domain/repositories/swaps_repository.dart';
import '../models/swap_model.dart';

class SwapsRepositoryImpl implements SwapsRepository {
  final FirebaseFirestore _firestore;

  SwapsRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Either<Failure, String>> createSwapOffer({
    required String bookId,
    required String bookTitle,
    required String bookAuthor,
    String? bookImageUrl,
    required String ownerId,
    required String ownerName,
    required String requesterId,
    required String requesterName,
    String? message,
  }) async {
    try {
      // Check if swap already exists for this book and requester
      final existingSwap = await _firestore
          .collection('swaps')
          .where('bookId', isEqualTo: bookId)
          .where('requesterId', isEqualTo: requesterId)
          .where('status', whereIn: ['pending', 'accepted'])
          .get();

      if (existingSwap.docs.isNotEmpty) {
        return Left(Failure('You already have a pending swap offer for this book'));
      }

      final now = DateTime.now();
      final swapData = {
        'bookId': bookId,
        'bookTitle': bookTitle,
        'bookAuthor': bookAuthor,
        'bookImageUrl': bookImageUrl,
        'ownerId': ownerId,
        'ownerName': ownerName,
        'requesterId': requesterId,
        'requesterName': requesterName,
        'status': SwapStatus.pending.name,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
        'message': message,
      };

      final docRef = await _firestore.collection('swaps').add(swapData);

      // Update book status to pending
      await _firestore.collection('books').doc(bookId).update({
        'status': 'pending',
        'updatedAt': Timestamp.fromDate(now),
      });

      return Right(docRef.id);
    } catch (e) {
      return Left(Failure('Failed to create swap offer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateSwapStatus({
    required String swapId,
    required SwapStatus status,
    String? message,
  }) async {
    try {
      final now = DateTime.now();
      final updateData = {
        'status': status.name,
        'updatedAt': Timestamp.fromDate(now),
      };

      if (message != null) {
        updateData['message'] = message;
      }

      await _firestore.collection('swaps').doc(swapId).update(updateData);

      // If swap is accepted or rejected, update book status
      if (status == SwapStatus.accepted || status == SwapStatus.rejected) {
        final swapDoc = await _firestore.collection('swaps').doc(swapId).get();
        if (swapDoc.exists) {
          final swapData = swapDoc.data()!;
          final bookId = swapData['bookId'];
          
          String bookStatus;
          if (status == SwapStatus.accepted) {
            bookStatus = 'swapped';
          } else {
            // Check if there are other pending swaps for this book
            final otherPendingSwaps = await _firestore
                .collection('swaps')
                .where('bookId', isEqualTo: bookId)
                .where('status', isEqualTo: 'pending')
                .get();
            
            bookStatus = otherPendingSwaps.docs.isNotEmpty ? 'pending' : 'available';
          }

          await _firestore.collection('books').doc(bookId).update({
            'status': bookStatus,
            'updatedAt': Timestamp.fromDate(now),
          });
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(Failure('Failed to update swap status: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSwap(String swapId) async {
    try {
      // Get swap data before deletion to update book status
      final swapDoc = await _firestore.collection('swaps').doc(swapId).get();
      
      if (swapDoc.exists) {
        final swapData = swapDoc.data()!;
        final bookId = swapData['bookId'];
        
        // Delete the swap
        await _firestore.collection('swaps').doc(swapId).delete();
        
        // Check if there are other pending swaps for this book
        final otherPendingSwaps = await _firestore
            .collection('swaps')
            .where('bookId', isEqualTo: bookId)
            .where('status', isEqualTo: 'pending')
            .get();
        
        // Update book status
        final bookStatus = otherPendingSwaps.docs.isNotEmpty ? 'pending' : 'available';
        await _firestore.collection('books').doc(bookId).update({
          'status': bookStatus,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      }

      return const Right(null);
    } catch (e) {
      return Left(Failure('Failed to delete swap: ${e.toString()}'));
    }
  }

  @override
  Stream<List<SwapEntity>> getSwapsForUser(String userId) {
    return _firestore
        .collection('swaps')
        .where('requesterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SwapModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Stream<List<SwapEntity>> getSwapsForBook(String bookId) {
    return _firestore
        .collection('swaps')
        .where('bookId', isEqualTo: bookId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SwapModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<Either<Failure, SwapEntity?>> getSwapById(String swapId) async {
    try {
      final doc = await _firestore.collection('swaps').doc(swapId).get();
      
      if (!doc.exists) {
        return const Right(null);
      }

      final swap = SwapModel.fromFirestore(doc);
      return Right(swap);
    } catch (e) {
      return Left(Failure('Failed to get swap: ${e.toString()}'));
    }
  }
}
