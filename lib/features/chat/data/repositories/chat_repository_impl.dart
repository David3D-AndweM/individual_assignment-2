import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/chat_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> createChat(ChatEntity chat) async {
    try {
      final chatModel = ChatModel.fromEntity(chat);
      await _firestore
          .collection('chats')
          .doc(chat.id.isEmpty ? null : chat.id)
          .set(chatModel.toFirestore());
    } catch (e) {
      throw Exception('Failed to create chat: $e');
    }
  }

  // Helper method for backward compatibility
  Future<ChatEntity> createChatWithParams({
    required String swapOfferId,
    required List<String> participantIds,
    required List<String> participantNames,
  }) async {
    try {
      final now = DateTime.now();
      final chatData = {
        'swapOfferId': swapOfferId,
        'participantIds': participantIds,
        'participantNames': participantNames,
        'lastMessage': null,
        'lastMessageTime': null,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      final docRef = await _firestore.collection('chats').add(chatData);
      final doc = await docRef.get();

      return ChatModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to create chat: $e');
    }
  }

  @override
  Future<ChatEntity?> getChat(String chatId) async {
    try {
      final doc = await _firestore.collection('chats').doc(chatId).get();

      if (!doc.exists) {
        return null;
      }

      return ChatModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get chat: $e');
    }
  }

  Future<ChatEntity?> getChatBySwapOfferId(String swapOfferId) async {
    try {
      final querySnapshot = await _firestore
          .collection('chats')
          .where('swapOfferId', isEqualTo: swapOfferId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return ChatModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      throw Exception('Failed to get chat by swap offer ID: $e');
    }
  }

  @override
  Future<List<ChatEntity>> getUserChats(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('chats')
          .where('participantIds', arrayContains: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ChatModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user chats: $e');
    }
  }

  // Helper method to get chats as a stream
  Stream<List<ChatEntity>> getUserChatsStream(String userId) {
    return _firestore
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> updateChatLastMessage({
    required String chatId,
    required String lastMessage,
    required DateTime lastMessageTime,
  }) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': lastMessage,
        'lastMessageTime': Timestamp.fromDate(lastMessageTime),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to update chat last message: $e');
    }
  }

  @override
  Future<void> sendMessage(MessageEntity message) async {
    try {
      final messageModel = MessageModel.fromEntity(message);
      await _firestore
          .collection('chats')
          .doc(message.chatId)
          .collection('messages')
          .doc(message.id.isEmpty ? null : message.id)
          .set(messageModel.toFirestore());

      // Update chat's last message
      await updateChatLastMessage(
        chatId: message.chatId,
        lastMessage: message.content,
        lastMessageTime: message.timestamp,
      );
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Helper method for backward compatibility
  Future<MessageEntity> sendMessageWithParams({
    required String chatId,
    required String senderId,
    required String senderName,
    required String content,
    required MessageType type,
  }) async {
    try {
      final now = DateTime.now();
      final messageData = {
        'chatId': chatId,
        'senderId': senderId,
        'senderName': senderName,
        'content': content,
        'type': type.name,
        'timestamp': Timestamp.fromDate(now),
        'isRead': false,
      };

      final docRef = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(messageData);

      final doc = await docRef.get();
      final message = MessageModel.fromFirestore(doc);

      // Update chat's last message
      await updateChatLastMessage(
        chatId: chatId,
        lastMessage: content,
        lastMessageTime: now,
      );

      return message;
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  @override
  Future<List<MessageEntity>> getChatMessages(String chatId) async {
    try {
      final querySnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get chat messages: $e');
    }
  }

  @override
  Stream<List<MessageEntity>> getChatMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<void> markMessageAsRead(String messageId) async {
    try {
      // This would require knowing the chat ID, so we'll implement it differently
      // For now, we'll mark all messages in a chat as read
    } catch (e) {
      throw Exception('Failed to mark message as read: $e');
    }
  }

  @override
  Future<void> deleteChat(String chatId) async {
    try {
      // Delete all messages in the chat
      final messagesSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();

      final batch = _firestore.batch();
      for (final doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete the chat document
      batch.delete(_firestore.collection('chats').doc(chatId));

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete chat: $e');
    }
  }

  Future<void> markAllMessagesAsRead(String chatId, String userId) async {
    try {
      final messagesSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in messagesSnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
  }
}
