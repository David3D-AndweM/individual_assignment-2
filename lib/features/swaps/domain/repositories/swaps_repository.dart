import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/swap_entity.dart';

abstract class SwapsRepository {
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
  });

  Future<Either<Failure, void>> updateSwapStatus({
    required String swapId,
    required SwapStatus status,
    String? message,
  });

  Future<Either<Failure, void>> deleteSwap(String swapId);

  Stream<List<SwapEntity>> getSwapsForUser(String userId);
  
  Stream<List<SwapEntity>> getSwapsForBook(String bookId);
  
  Future<Either<Failure, SwapEntity?>> getSwapById(String swapId);
}
