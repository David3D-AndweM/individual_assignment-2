import '../entities/chat_entity.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  Future<void> createChat(ChatEntity chat);
  Future<ChatEntity?> getChat(String chatId);
  Future<List<ChatEntity>> getUserChats(String userId);
  Future<void> sendMessage(MessageEntity message);
  Future<List<MessageEntity>> getChatMessages(String chatId);
  Stream<List<MessageEntity>> getChatMessagesStream(String chatId);
  Future<void> markMessageAsRead(String messageId);
  Future<void> deleteChat(String chatId);
}
