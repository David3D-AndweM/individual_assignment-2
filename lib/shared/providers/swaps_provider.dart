import 'package:flutter/material.dart';
import '../../features/swaps/domain/entities/swap_entity.dart';
import '../../features/swaps/domain/repositories/swaps_repository.dart';
import '../../features/swaps/data/repositories/swaps_repository_impl.dart';

class SwapsProvider with ChangeNotifier {
  final SwapsRepository _swapsRepository;
  
  SwapsProvider({SwapsRepository? swapsRepository})
      : _swapsRepository = swapsRepository ?? SwapsRepositoryImpl();

  List<SwapEntity> _swaps = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SwapEntity> get swaps => _swaps;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Create swap offer
  Future<void> createSwapOffer({
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
    _setLoading(true);
    _clearError();

    try {
      final result = await _swapsRepository.createSwapOffer(
        bookId: bookId,
        bookTitle: bookTitle,
        bookAuthor: bookAuthor,
        bookImageUrl: bookImageUrl,
        ownerId: ownerId,
        ownerName: ownerName,
        requesterId: requesterId,
        requesterName: requesterName,
        message: message,
      );

      result.fold(
        (failure) => _setError(failure.message),
        (swapId) {
          // Swap created successfully
          // The swaps list will be updated via stream
        },
      );
    } catch (e) {
      _setError('Failed to create swap offer: $e');
    }

    _setLoading(false);
  }

  // Update swap status
  Future<void> updateSwapStatus({
    required String swapId,
    required SwapStatus status,
    String? message,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _swapsRepository.updateSwapStatus(
        swapId: swapId,
        status: status,
        message: message,
      );

      result.fold(
        (failure) => _setError(failure.message),
        (_) {
          // Status updated successfully
          // The swaps list will be updated via stream
        },
      );
    } catch (e) {
      _setError('Failed to update swap status: $e');
    }

    _setLoading(false);
  }

  // Accept swap offer
  Future<void> acceptSwapOffer(String swapId, {String? message}) async {
    await updateSwapStatus(
      swapId: swapId,
      status: SwapStatus.accepted,
      message: message,
    );
  }

  // Reject swap offer
  Future<void> rejectSwapOffer(String swapId, {String? message}) async {
    await updateSwapStatus(
      swapId: swapId,
      status: SwapStatus.rejected,
      message: message,
    );
  }

  // Cancel swap offer
  Future<void> cancelSwapOffer(String swapId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _swapsRepository.deleteSwap(swapId);

      result.fold(
        (failure) => _setError(failure.message),
        (_) {
          // Swap cancelled successfully
          // The swaps list will be updated via stream
        },
      );
    } catch (e) {
      _setError('Failed to cancel swap offer: $e');
    }

    _setLoading(false);
  }

  // Load swaps for user
  void loadSwapsForUser(String userId) {
    _swapsRepository.getSwapsForUser(userId).listen(
      (swaps) {
        _swaps = swaps;
        _clearError();
        notifyListeners();
      },
      onError: (error) {
        _setError('Failed to load swaps: $error');
      },
    );
  }

  // Get swaps by status
  List<SwapEntity> getSwapsByStatus(SwapStatus status) {
    return _swaps.where((swap) => swap.status == status).toList();
  }

  // Get pending swaps (received offers)
  List<SwapEntity> getPendingReceivedSwaps(String userId) {
    return _swaps
        .where((swap) => 
            swap.ownerId == userId && swap.status == SwapStatus.pending)
        .toList();
  }

  // Get pending swaps (sent offers)
  List<SwapEntity> getPendingSentSwaps(String userId) {
    return _swaps
        .where((swap) => 
            swap.requesterId == userId && swap.status == SwapStatus.pending)
        .toList();
  }

  // Get accepted swaps
  List<SwapEntity> getAcceptedSwaps(String userId) {
    return _swaps
        .where((swap) => 
            (swap.ownerId == userId || swap.requesterId == userId) && 
            swap.status == SwapStatus.accepted)
        .toList();
  }

  // Show swap action dialog
  Future<void> showSwapActionDialog({
    required BuildContext context,
    required SwapEntity swap,
    required String currentUserId,
  }) async {
    final isOwner = swap.ownerId == currentUserId;
    final isRequester = swap.requesterId == currentUserId;

    if (!isOwner && !isRequester) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Swap Offer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Book: ${swap.bookTitle}'),
            Text('Author: ${swap.bookAuthor}'),
            const SizedBox(height: 8),
            if (isOwner) ...[
              Text('Requested by: ${swap.requesterName}'),
              if (swap.message != null) ...[
                const SizedBox(height: 8),
                Text('Message: ${swap.message}'),
              ],
            ] else ...[
              Text('Owner: ${swap.ownerName}'),
              Text('Status: ${swap.status.displayName}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (isOwner && swap.status == SwapStatus.pending) ...[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                rejectSwapOffer(swap.id);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Reject'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                acceptSwapOffer(swap.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Accept'),
            ),
          ] else if (isRequester && swap.status == SwapStatus.pending) ...[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                cancelSwapOffer(swap.id);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Cancel'),
            ),
          ],
        ],
      ),
    );
  }
}
