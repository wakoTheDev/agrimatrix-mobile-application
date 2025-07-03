import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../models/app_models.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String chatPartnerId;
  final String chatPartnerName;
  final Function(String, String, MessageType, {String? filePath, String? fileName}) onSendMessage;
  final List<ChatMessage> messages;

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.chatPartnerId,
    required this.chatPartnerName,
    required this.onSendMessage,
    required this.messages,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  final bool _isTyping = false;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B5320),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.chatPartnerName[0].toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF2B5320),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chatPartnerName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Online', // In real app, show actual status
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Video call functionality
              _showCallOptions();
            },
            icon: const Icon(Icons.videocam),
          ),
          IconButton(
            onPressed: () {
              // Voice call functionality
              _makeVoiceCall();
            },
            icon: const Icon(Icons.call),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: widget.messages.length,
              itemBuilder: (context, index) {
                final message = widget.messages[index];
                final isCurrentUser = message.senderId == widget.currentUserId;
                return _buildMessageBubble(message, isCurrentUser);
              },
            ),
          ),
          
          // Typing Indicator
          if (_isTyping)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${widget.chatPartnerName} is typing...',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ),
            ),
          
          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Attachment Button
                IconButton(
                  onPressed: _showAttachmentOptions,
                  icon: const Icon(Icons.attach_file, color: Color(0xFF2B5320)),
                ),
                
                // Message Input Field
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Send Button
                FloatingActionButton.small(
                  onPressed: _sendTextMessage,
                  backgroundColor: const Color(0xFF2B5320),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isCurrentUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF2B5320),
              child: Text(
                widget.chatPartnerName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrentUser ? const Color(0xFF2B5320) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
                  bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMessageContent(message, isCurrentUser),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(message.timestamp),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: isCurrentUser ? Colors.white70 : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: Text(
                'Me',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContent(ChatMessage message, bool isCurrentUser) {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: GoogleFonts.poppins(
            color: isCurrentUser ? Colors.white : Colors.black87,
            fontSize: 14,
          ),
        );
      
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.filePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(message.filePath!),
                  width: 200,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            if (message.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                message.content,
                style: GoogleFonts.poppins(
                  color: isCurrentUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        );
      
      case MessageType.file:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isCurrentUser ? Colors.white : Colors.grey[100])?.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.insert_drive_file,
                color: isCurrentUser ? Colors.white : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message.fileName ?? 'File',
                  style: GoogleFonts.poppins(
                    color: isCurrentUser ? Colors.white : Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      
      default:
        return Text(
          message.content,
          style: GoogleFonts.poppins(
            color: isCurrentUser ? Colors.white : Colors.black87,
            fontSize: 14,
          ),
        );
    }
  }

  void _sendTextMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      widget.onSendMessage(
        widget.chatPartnerId,
        text,
        MessageType.text,
      );
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Send Attachment',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  'Camera',
                  Icons.camera_alt,
                  Colors.blue,
                  () => _pickImage(ImageSource.camera),
                ),
                _buildAttachmentOption(
                  'Gallery',
                  Icons.photo_library,
                  Colors.green,
                  () => _pickImage(ImageSource.gallery),
                ),
                _buildAttachmentOption(
                  'Document',
                  Icons.insert_drive_file,
                  Colors.orange,
                  _pickDocument,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        widget.onSendMessage(
          widget.chatPartnerId,
          'Photo',
          MessageType.image,
          filePath: image.path,
        );
        _scrollToBottom();
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: $e');
    }
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        PlatformFile file = result.files.first;
        widget.onSendMessage(
          widget.chatPartnerId,
          'Document',
          MessageType.file,
          filePath: file.path,
          fileName: file.name,
        );
        _scrollToBottom();
      }
    } catch (e) {
      _showErrorSnackBar('Error picking document: $e');
    }
  }

  void _showCallOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Video Call'),
        content: Text('Start video call with ${widget.chatPartnerName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startVideoCall();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B5320),
              foregroundColor: Colors.white,
            ),
            child: const Text('Start Call'),
          ),
        ],
      ),
    );
  }

  void _makeVoiceCall() {
    // In real app, implement WebRTC for voice calling
    _showErrorSnackBar('Voice calling feature coming soon!');
  }

  void _startVideoCall() {
    // In real app, implement WebRTC for video calling
    _showErrorSnackBar('Video calling feature coming soon!');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
