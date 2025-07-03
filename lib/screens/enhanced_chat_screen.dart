import 'package:flutter/material.dart';
import 'dart:async';
import '../services/enhanced_communication_service.dart';
import '../services/user_discovery_service.dart';
import '../models/app_models.dart';
import 'call_screen.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String? receiverImage;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    this.receiverImage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final EnhancedCommunicationService _communicationService = EnhancedCommunicationService();
  final UserDiscoveryService _userDiscovery = UserDiscoveryService();

  List<ChatMessage> _messages = [];
  final bool _isOnline = false;
  String? _currentUserId;
  StreamSubscription<ChatMessage>? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _setupChat();
  }

  Future<void> _setupChat() async {
    final currentUser = await _userDiscovery.getCurrentUser();
    if (currentUser != null) {
      _currentUserId = currentUser.id;
      await _communicationService.initialize(_currentUserId!);
      
      // Listen for incoming messages
      _messageSubscription = _communicationService.messageStream.listen((message) {
        if ((message.senderId == widget.receiverId && message.receiverId == _currentUserId) ||
            (message.senderId == _currentUserId && message.receiverId == widget.receiverId)) {
          setState(() {
            _messages.add(message);
          });
          _scrollToBottom();
        }
      });

      // Get chat history
      await _loadChatHistory();
    }
  }

  Future<void> _loadChatHistory() async {
    // Load previous messages from Firebase/local storage
    // This would typically fetch from your backend
    setState(() {
      // Add some sample messages for demonstration
      _messages = [
        ChatMessage(
          id: '1',
          senderId: widget.receiverId,
          receiverId: _currentUserId!,
          content: 'Hello! I saw your listing for organic tomatoes. Are they still available?',
          type: MessageType.text,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        ChatMessage(
          id: '2',
          senderId: _currentUserId!,
          receiverId: widget.receiverId,
          content: 'Yes, they are! I have about 50kg available at ₹40 per kg.',
          type: MessageType.text,
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
        ),
      ];
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _currentUserId == null) return;

    await _communicationService.sendMessage(
      widget.receiverId,
      content,
      MessageType.text,
    );

    _messageController.clear();
  }

  Future<void> _startCall(CallType callType) async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(
            receiverId: widget.receiverId,
            receiverName: widget.receiverName,
            receiverImage: widget.receiverImage,
            callType: callType,
            isIncoming: false,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start call: $e')),
      );
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: widget.receiverImage != null && widget.receiverImage!.isNotEmpty
                  ? NetworkImage(widget.receiverImage!)
                  : null,
              child: widget.receiverImage == null || widget.receiverImage!.isEmpty
                  ? Text(widget.receiverName.isNotEmpty ? widget.receiverName[0].toUpperCase() : 'U')
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.receiverName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _isOnline ? 'Online' : 'Last seen recently',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () => _startCall(CallType.audio),
          ),
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.white),
            onPressed: () => _startCall(CallType.video),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Show more options menu
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                image: const DecorationImage(
                  image: AssetImage('assets/images/chat_background.png'),
                  fit: BoxFit.cover,
                  opacity: 0.1,
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isMe = message.senderId == _currentUserId;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        if (!isMe) ...[
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: widget.receiverImage != null && widget.receiverImage!.isNotEmpty
                                ? NetworkImage(widget.receiverImage!)
                                : null,
                            child: widget.receiverImage == null || widget.receiverImage!.isEmpty
                                ? Text(widget.receiverName.isNotEmpty ? widget.receiverName[0].toUpperCase() : 'U',
                                    style: const TextStyle(fontSize: 12))
                                : null,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.green.shade600 : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.content,
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTime(message.timestamp),
                                  style: TextStyle(
                                    color: isMe ? Colors.white70 : Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 8),
                          Icon(
                            message.isRead ? Icons.done_all : Icons.done,
                            size: 16,
                            color: message.isRead ? Colors.blue : Colors.grey,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.attach_file, color: Colors.grey.shade600),
                  onPressed: () {
                    // Handle file attachment
                  },
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      maxLines: null,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
