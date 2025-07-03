import 'package:flutter/material.dart';
import 'dart:async';
import '../services/user_discovery_service.dart';
import '../services/logging_service.dart';
import '../models/app_models.dart';
import 'enhanced_chat_screen.dart';

class UserDiscoveryScreen extends StatefulWidget {
  const UserDiscoveryScreen({super.key});

  @override
  State<UserDiscoveryScreen> createState() => _UserDiscoveryScreenState();
}

class _UserDiscoveryScreenState extends State<UserDiscoveryScreen>
    with SingleTickerProviderStateMixin {
  final UserDiscoveryService _userDiscovery = UserDiscoveryService();
  final TextEditingController _searchController = TextEditingController();
  
  late TabController _tabController;
  Timer? _searchTimer;
  
  List<UserSearchResult> _searchResults = [];
  List<UserSearchResult> _recentContacts = [];
  List<UserSearchResult> _nearbyUsers = [];
  List<Chat> _userChats = [];
  
  bool _isSearching = false;
  bool _isLoadingRecents = true;
  bool _isLoadingNearby = true;
  bool _isLoadingChats = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadRecentContacts(),
      _loadNearbyUsers(),
      _loadUserChats(),
    ]);
  }

  Future<void> _loadRecentContacts() async {
    setState(() => _isLoadingRecents = true);
    try {
      final contacts = await _userDiscovery.getRecentContacts();
      setState(() {
        _recentContacts = contacts;
        _isLoadingRecents = false;
      });
    } catch (e) {
      setState(() => _isLoadingRecents = false);
      LoggingService.error('Error loading recent contacts', e);
    }
  }

  Future<void> _loadNearbyUsers() async {
    setState(() => _isLoadingNearby = true);
    try {
      // In a real app, you'd get user's location first
      final nearby = await _userDiscovery.getNearbyUsers(
        latitude: 28.6139, // Example: New Delhi
        longitude: 77.2090,
        radiusKm: 50,
      );
      setState(() {
        _nearbyUsers = nearby;
        _isLoadingNearby = false;
      });
    } catch (e) {
      setState(() => _isLoadingNearby = false);
      LoggingService.error('Error loading nearby users', e);
    }
  }

  Future<void> _loadUserChats() async {
    setState(() => _isLoadingChats = true);
    try {
      final chats = await _userDiscovery.getUserChats();
      setState(() {
        _userChats = chats;
        _isLoadingChats = false;
      });
    } catch (e) {
      setState(() => _isLoadingChats = false);
      LoggingService.error('Error loading user chats', e);
    }
  }

  void _onSearchChanged(String query) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    
    try {
      final results = await _userDiscovery.searchUsers(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      LoggingService.error('Error searching users', e);
    }
  }

  void _startChat(UserSearchResult user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          receiverId: user.id,
          receiverName: user.name,
          receiverImage: user.profileImage.isEmpty ? null : user.profileImage,
        ),
      ),
    );
  }

  void _startChatFromChatList(Chat chat, String currentUserId) {
    final otherParticipant = chat.participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    
    if (otherParticipant.isNotEmpty) {
      final participantInfo = chat.participantInfo[otherParticipant];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            receiverId: otherParticipant,
            receiverName: participantInfo?['name'] ?? 'Unknown',
            receiverImage: participantInfo?['profileImage'],
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        elevation: 0,
        title: const Text('Messages', style: TextStyle(color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Chats'),
            Tab(text: 'Search'),
            Tab(text: 'Recent'),
            Tab(text: 'Nearby'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatsTab(),
          _buildSearchTab(),
          _buildRecentTab(),
          _buildNearbyTab(),
        ],
      ),
    );
  }

  Widget _buildChatsTab() {
    if (_isLoadingChats) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_userChats.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No chats yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Start a conversation by searching for users',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<AppUser?>(
      future: _userDiscovery.getCurrentUser(),
      builder: (context, snapshot) {
        final currentUserId = snapshot.data?.id ?? '';
        
        return ListView.builder(
          itemCount: _userChats.length,
          itemBuilder: (context, index) {
            final chat = _userChats[index];
            final otherParticipant = chat.participants.firstWhere(
              (id) => id != currentUserId,
              orElse: () => '',
            );
            final participantInfo = chat.participantInfo[otherParticipant];
            
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: participantInfo?['profileImage'] != null && 
                                participantInfo!['profileImage'].isNotEmpty
                    ? NetworkImage(participantInfo['profileImage'])
                    : null,
                child: participantInfo?['profileImage'] == null || 
                       participantInfo!['profileImage'].isEmpty
                    ? Text((participantInfo?['name'] ?? 'U')[0].toUpperCase())
                    : null,
              ),
              title: Text(participantInfo?['name'] ?? 'Unknown User'),
              subtitle: Text(
                chat.lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTime(chat.lastMessageTime),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (chat.unreadCount > 0)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        chat.unreadCount.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                ],
              ),
              onTap: () => _startChatFromChatList(chat, currentUserId),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search users by name or username...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isEmpty && _searchController.text.isNotEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No users found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final user = _searchResults[index];
                        return _buildUserTile(user);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildRecentTab() {
    if (_isLoadingRecents) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recentContacts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No recent contacts',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _recentContacts.length,
      itemBuilder: (context, index) {
        final user = _recentContacts[index];
        return _buildUserTile(user);
      },
    );
  }

  Widget _buildNearbyTab() {
    if (_isLoadingNearby) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_nearbyUsers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No nearby users',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _nearbyUsers.length,
      itemBuilder: (context, index) {
        final user = _nearbyUsers[index];
        return _buildUserTile(user, showLocation: true);
      },
    );
  }

  Widget _buildUserTile(UserSearchResult user, {bool showLocation = false}) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundImage: user.profileImage.isNotEmpty
                ? NetworkImage(user.profileImage)
                : null,
            child: user.profileImage.isEmpty
                ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U')
                : null,
          ),
          if (user.isOnline)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Text(user.name),
          if (user.verified) ...[
            const SizedBox(width: 4),
            const Icon(Icons.verified, color: Colors.blue, size: 16),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('@${user.username}'),
          if (showLocation && user.location.isNotEmpty)
            Text(
              user.location,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.chat, color: Colors.green),
        onPressed: () => _startChat(user),
      ),
      onTap: () => _startChat(user),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
