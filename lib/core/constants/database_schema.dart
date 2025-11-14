// Firestore Database Schema Documentation
// 
// This file documents the structure of our Firestore database
// for the BookSwap application.

class DatabaseSchema {
  /// Users Collection: /users/{userId}
  /// 
  /// Structure:
  /// {
  ///   'email': 'user@example.com',
  ///   'displayName': 'John Doe',
  ///   'photoUrl': 'https://...' (optional),
  ///   'isEmailVerified': true,
  ///   'createdAt': Timestamp,
  ///   'updatedAt': Timestamp
  /// }
  static const String usersCollection = 'users';

  /// Books Collection: /books/{bookId}
  /// 
  /// Structure:
  /// {
  ///   'title': 'Introduction to Flutter',
  ///   'author': 'John Smith',
  ///   'condition': 'New', // 'New', 'Like New', 'Good', 'Used'
  ///   'imageUrl': 'https://...' (optional),
  ///   'ownerId': 'userId',
  ///   'ownerName': 'John Doe',
  ///   'isAvailable': true,
  ///   'createdAt': Timestamp,
  ///   'updatedAt': Timestamp
  /// }
  static const String booksCollection = 'books';

  /// Swaps Collection: /swaps/{swapId}
  /// 
  /// Structure:
  /// {
  ///   'requesterId': 'userId1',
  ///   'requesterName': 'Jane Doe',
  ///   'ownerId': 'userId2',
  ///   'ownerName': 'John Doe',
  ///   'bookId': 'bookId',
  ///   'bookTitle': 'Introduction to Flutter',
  ///   'bookImageUrl': 'https://...' (optional),
  ///   'status': 'pending', // 'pending', 'accepted', 'rejected', 'completed', 'cancelled'
  ///   'message': 'I would like to swap this book' (optional),
  ///   'createdAt': Timestamp,
  ///   'updatedAt': Timestamp
  /// }
  static const String swapsCollection = 'swaps';

  /// Chats Collection: /chats/{chatId}
  /// 
  /// Structure:
  /// {
  ///   'swapId': 'swapId',
  ///   'participantIds': ['userId1', 'userId2'],
  ///   'participantNames': ['Jane Doe', 'John Doe'],
  ///   'lastMessage': 'Hello, is the book still available?',
  ///   'lastMessageTime': Timestamp,
  ///   'createdAt': Timestamp,
  ///   'updatedAt': Timestamp
  /// }
  static const String chatsCollection = 'chats';

  /// Messages Subcollection: /chats/{chatId}/messages/{messageId}
  /// 
  /// Structure:
  /// {
  ///   'senderId': 'userId1',
  ///   'senderName': 'Jane Doe',
  ///   'content': 'Hello, is the book still available?',
  ///   'timestamp': Timestamp,
  ///   'isRead': false
  /// }
  static const String messagesSubcollection = 'messages';

  /// Indexes Required:
  /// 
  /// Books Collection:
  /// - Composite index: ownerId (Ascending), createdAt (Descending)
  /// - Composite index: isAvailable (Ascending), createdAt (Descending)
  /// 
  /// Swaps Collection:
  /// - Composite index: requesterId (Ascending), createdAt (Descending)
  /// - Composite index: ownerId (Ascending), createdAt (Descending)
  /// - Composite index: status (Ascending), createdAt (Descending)
  /// 
  /// Messages Subcollection:
  /// - Single field index: timestamp (Descending)
  /// - Composite index: senderId (Ascending), timestamp (Descending)

  /// Security Rules Considerations:
  /// 
  /// 1. Users can only read/write their own user document
  /// 2. Books can be read by anyone, but only created/updated by the owner
  /// 3. Swaps can be read by requester and owner, created by anyone, updated by owner
  /// 4. Chats can be read/written only by participants
  /// 5. Messages can be read by chat participants, created by authenticated users
}
