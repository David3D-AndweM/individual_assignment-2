import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../features/chat/domain/entities/chat_entity.dart';
import '../../features/chat/domain/entities/message_entity.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';

class ChatProvider with ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepositoryImpl();
  
  // State
  List<ChatEntity> _userChats = [];
  List<MessageEntity> _currentChatMessages = [];
  ChatEntity? _currentChat;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Stream subscriptions
  StreamSubscription<List<ChatEntity>>? _userChatsSubscription;
  StreamSubscription<List<MessageEntity>>? _messagesSubscription;

  // Getters
  List<ChatEntity> get userChats => _userChats;
  List<MessageEntity> get currentChatMessages => _currentChatMessages;
  ChatEntity? get currentChat => _currentChat;
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

  // Initialize user chats stream
  Future<void> initializeUserChats(String userId) async {
    try {
      _setLoading(true);
      final chats = await _chatRepository.getUserChats(userId);
      _userChats = chats;
      _setError(null);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load chats: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create or get chat for swap offer
  Future<ChatEntity?> createOrGetChatForSwap({
    required String swapId,
    required List<String> participantIds,
    required List<String> participantNames,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // Create new chat
      final chatId = 'chat_${swapId}_${DateTime.now().millisecondsSinceEpoch}';
      final newChat = ChatEntity(
        id: chatId,
        swapId: swapId,
        participantIds: participantIds,
        participantNames: participantNames,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _chatRepository.createChat(newChat);

      // Send initial system message
      final systemMessage = MessageEntity(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        chatId: chatId,
        senderId: 'system',
        senderName: 'System',
        content: 'Chat started for book swap offer',
        type: MessageType.system,
        timestamp: DateTime.now(),
      );

      await _chatRepository.sendMessage(systemMessage);

      return newChat;
    } catch (e) {
      _setError('Failed to create chat: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Set current chat and load messages
  void setCurrentChat(ChatEntity chat) {
    _currentChat = chat;
    _loadChatMessages(chat.id);
    notifyListeners();
  }

  // Load messages for current chat
  void _loadChatMessages(String chatId) {
    _messagesSubscription?.cancel();
    _messagesSubscription = _chatRepository.getChatMessagesStream(chatId).listen(
      (messages) {
        _currentChatMessages = messages;
        notifyListeners();
      },
      onError: (error) {
        _setError('Failed to load messages: $error');
      },
    );
  }

  // Send message
  Future<void> sendMessage({
    required String content,
    required String senderId,
    required String senderName,
  }) async {
    if (_currentChat == null || content.trim().isEmpty) return;

    try {
      _setError(null);
      
      final message = MessageEntity(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        chatId: _currentChat!.id,
        senderId: senderId,
        senderName: senderName,
        content: content.trim(),
        type: MessageType.text,
        timestamp: DateTime.now(),
      );

      await _chatRepository.sendMessage(message);
    } catch (e) {
      _setError('Failed to send message: $e');
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String userId) async {
    if (_currentChat == null) return;

    try {
      // Implementation can be added later if needed
      // For now, we'll skip this functionality
    } catch (e) {
      // Silently handle error for read receipts
      debugPrint('Failed to mark messages as read: $e');
    }
  }

  // Clear current chat
  void clearCurrentChat() {
    _currentChat = null;
    _currentChatMessages = [];
    _messagesSubscription?.cancel();
    notifyListeners();
  }

  // Get other participant name
  String getOtherParticipantName(ChatEntity chat, String currentUserId) {
    final otherParticipantIndex = chat.participantIds.indexWhere(
      (id) => id != currentUserId,
    );
    
    if (otherParticipantIndex != -1 && 
        otherParticipantIndex < chat.participantNames.length) {
      return chat.participantNames[otherParticipantIndex];
    }
    
    return 'Unknown User';
  }

  @override
  void dispose() {
    _userChatsSubscription?.cancel();
    _messagesSubscription?.cancel();
    super.dispose();
  }
}
