import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KnowledgeHubScreen extends StatefulWidget {
  const KnowledgeHubScreen({super.key});

  @override
  State<KnowledgeHubScreen> createState() => _KnowledgeHubScreenState();
}

class _KnowledgeHubScreenState extends State<KnowledgeHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _categoryTabController;
  String _searchQuery = '';
  final String _selectedCategory = 'All';
  String _selectedContentType = 'All';
  final List<String> _bookmarkedArticles = [];

  final List<String> _categories = [
    'All',
    'Crops',
    'Pests',
    'Post-Harvest',
    'Livestock',
    'Agribusiness',
    'Organic'
  ];

  final List<String> _contentTypes = [
    'All',
    'Articles',
    'Videos',
    'Infographics',
    'PDF Guides'
  ];

  @override
  void initState() {
    super.initState();
    _categoryTabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _categoryTabController.dispose();
    super.dispose();
  }

  // Sample data - in real app, this would come from API
  List<KnowledgeItem> _getSampleKnowledgeItems() {
    return [
      KnowledgeItem(
        id: '1',
        title: 'Effective Maize Pest Control Strategies',
        author: 'Dr. Sarah Mbeki',
        authorImage: null,
        category: 'Pest & Disease Control',
        contentType: 'Article',
        description: 'Comprehensive guide on identifying and controlling major maize pests including fall armyworm and stem borers.',
        readTime: '8 min read',
        rating: 4.7,
        ratingCount: 234,
        publishDate: '2024-05-15',
        tags: ['maize', 'pest control', 'fall armyworm'],
        thumbnailImage: null,
        isBookmarked: false,
        downloadCount: 1250,
        hasOfflineAccess: true,
      ),
      KnowledgeItem(
        id: '2',
        title: 'Soil Health Management for Small-Scale Farmers',
        author: 'Prof. James Kiprotich',
        authorImage: null,
        category: 'Crop Management',
        contentType: 'Video',
        description: 'Learn how to improve soil fertility using organic methods and affordable fertilizers.',
        readTime: '12 min watch',
        rating: 4.9,
        ratingCount: 567,
        publishDate: '2024-05-20',
        tags: ['soil health', 'organic farming', 'fertilizers'],
        thumbnailImage: null,
        isBookmarked: true,
        downloadCount: 890,
        hasOfflineAccess: true,
      ),
      KnowledgeItem(
        id: '3',
        title: 'Post-Harvest Storage Solutions',
        author: 'Dr. Mary Wanjiku',
        authorImage: null,
        category: 'Post-Harvest Handling',
        contentType: 'PDF Guide',
        description: 'Downloadable guide on proper storage techniques to reduce post-harvest losses.',
        readTime: '15 min read',
        rating: 4.6,
        ratingCount: 189,
        publishDate: '2024-05-18',
        tags: ['storage', 'post-harvest', 'grain'],
        thumbnailImage: null,
        isBookmarked: false,
        downloadCount: 2100,
        hasOfflineAccess: true,
      ),
      KnowledgeItem(
        id: '4',
        title: 'Dairy Cattle Nutrition Infographic',
        author: 'Dr. Peter Mwangi',
        authorImage: null,
        category: 'Livestock Care',
        contentType: 'Infographic',
        description: 'Visual guide to proper dairy cattle feeding and nutrition requirements.',
        readTime: '3 min read',
        rating: 4.5,
        ratingCount: 145,
        publishDate: '2024-05-22',
        tags: ['dairy', 'cattle', 'nutrition'],
        thumbnailImage: null,
        isBookmarked: false,
        downloadCount: 780,
        hasOfflineAccess: false,
      ),
    ];
  }

  List<KnowledgeItem> _getFilteredItems() {
    List<KnowledgeItem> items = _getSampleKnowledgeItems();
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      items = items.where((item) =>
          item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()))).toList();
    }

    // Filter by category
    if (_selectedCategory != 'All') {
      items = items.where((item) => item.category == _selectedCategory).toList();
    }

    // Filter by content type
    if (_selectedContentType != 'All') {
      items = items.where((item) => item.contentType == _selectedContentType).toList();
    }

    return items;
  }

  Widget _buildKnowledgeCard(KnowledgeItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2B5320).withValues(alpha: 0.1),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail/Header
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2B5320).withValues(alpha: 0.8),
                  const Color(0xFF4CAF50).withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Content type icon
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getContentTypeIcon(item.contentType),
                          size: 16,
                          color: const Color(0xFF2B5320),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.contentType,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF2B5320),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bookmark button
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => _toggleBookmark(item.id),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: item.isBookmarked ? Colors.amber : const Color(0xFF2B5320),
                        size: 20,
                      ),
                    ),
                  ),
                ),
                // Offline indicator
                if (item.hasOfflineAccess)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.offline_pin, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'Offline',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.category,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Title
                Text(
                  item.title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2B5320),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Description
                Text(
                  item.description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Author and meta info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: item.authorImage != null ? AssetImage(item.authorImage!) : null,
                      child: item.authorImage == null 
                          ? Text(
                              item.author[0],
                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.author,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF2B5320),
                            ),
                          ),
                          Text(
                            item.readTime,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          '${item.rating}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          ' (${item.ratingCount})',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Tags
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: item.tags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#$tag',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 12),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _viewContent(item),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2B5320),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Text(
                          'Read Now',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.download,
                      onPressed: () => _downloadContent(item),
                      tooltip: 'Download (${item.downloadCount})',
                    ),
                    const SizedBox(width: 4),
                    _buildActionButton(
                      icon: Icons.share,
                      onPressed: () => _shareContent(item),
                      tooltip: 'Share',
                    ),
                    const SizedBox(width: 4),
                    _buildActionButton(
                      icon: Icons.thumb_up_outlined,
                      onPressed: () => _rateContent(item, true),
                      tooltip: 'Helpful',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: const Color(0xFF2B5320),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Content type filter
          ..._contentTypes.map((type) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(type),
              selected: _selectedContentType == type,
              onSelected: (selected) {
                setState(() {
                  _selectedContentType = selected ? type : 'All';
                });
              },
              selectedColor: const Color(0xFF2B5320).withValues(alpha: 0.2),
              checkmarkColor: const Color(0xFF2B5320),
              labelStyle: GoogleFonts.poppins(
                fontSize: 12,
                color: _selectedContentType == type ? const Color(0xFF2B5320) : Colors.grey[600],
              ),
            ),
          )),
        ],
      ),
    );
  }

  IconData _getContentTypeIcon(String contentType) {
    switch (contentType) {
      case 'Article':
        return Icons.article;
      case 'Video':
        return Icons.play_circle;
      case 'Infographic':
        return Icons.image;
      case 'PDF Guide':
        return Icons.picture_as_pdf;
      default:
        return Icons.description;
    }
  }

  void _toggleBookmark(String itemId) {
    setState(() {
      if (_bookmarkedArticles.contains(itemId)) {
        _bookmarkedArticles.remove(itemId);
      } else {
        _bookmarkedArticles.add(itemId);
      }
    });
    
    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _bookmarkedArticles.contains(itemId) ? 'Added to bookmarks' : 'Removed from bookmarks',
          style: GoogleFonts.poppins(),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _viewContent(KnowledgeItem item) {
    // Navigate to detailed content view
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContentDetailScreen(item: item),
      ),
    );
  }

  void _downloadContent(KnowledgeItem item) {
    // Handle content download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading "${item.title}"...', style: GoogleFonts.poppins()),
      ),
    );
  }

  void _shareContent(KnowledgeItem item) {
    // Handle content sharing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing "${item.title}"', style: GoogleFonts.poppins()),
      ),
    );
  }

  void _rateContent(KnowledgeItem item, bool isHelpful) {
    // Handle content rating
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isHelpful ? 'Marked as helpful!' : 'Feedback received',
          style: GoogleFonts.poppins(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _getFilteredItems();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search articles, guides, videos...',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF2B5320)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2B5320)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),

            // Category tabs
            TabBar(
              controller: _categoryTabController,
              isScrollable: true,
              labelColor: const Color(0xFF2B5320),
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: const Color(0xFF2B5320),
              labelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 13, // Slightly smaller font size
              ),
              unselectedLabelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                fontSize: 13,
              ),
              tabs: _categories.map((category) => Tab(
                child: Text(
                  category,
                  maxLines: 2, // Allow text to wrap to two lines
                  textAlign: TextAlign.center, // Center the wrapped text
                ),
              )).toList(),
            ),

            const SizedBox(height: 8),

            // Filter chips
            _buildFilterChips(),

            const SizedBox(height: 16),

            // Results count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '${filteredItems.length} results found',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      // Show filter options
                    },
                    icon: const Icon(Icons.tune, size: 18),
                    label: Text('Filter', style: GoogleFonts.poppins(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2B5320),
                    ),
                  ),
                ],
              ),
            ),

            // Content list
            filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No content found',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true, // Allow ListView to fit within the scroll view
                    physics: const NeverScrollableScrollPhysics(), // Prevent nested scrolling
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      // Update bookmark status from state
                      item.isBookmarked = _bookmarkedArticles.contains(item.id);
                      return _buildKnowledgeCard(item);
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
// Data model for knowledge items
class KnowledgeItem {
  final String id;
  final String title;
  final String author;
  final String? authorImage;
  final String category;
  final String contentType;
  final String description;
  final String readTime;
  final double rating;
  final int ratingCount;
  final String publishDate;
  final List<String> tags;
  final String? thumbnailImage;
  bool isBookmarked;
  final int downloadCount;
  final bool hasOfflineAccess;

  KnowledgeItem({
    required this.id,
    required this.title,
    required this.author,
    this.authorImage,
    required this.category,
    required this.contentType,
    required this.description,
    required this.readTime,
    required this.rating,
    required this.ratingCount,
    required this.publishDate,
    required this.tags,
    this.thumbnailImage,
    required this.isBookmarked,
    required this.downloadCount,
    required this.hasOfflineAccess,
  });
}

// Content detail screen
class ContentDetailScreen extends StatelessWidget {
  final KnowledgeItem item;

  const ContentDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AgriKnowledge Hub',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF2B5320),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(item.isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () {
              // Toggle bookmark
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share content
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              item.title,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2B5320),
              ),
            ),
            const SizedBox(height: 16),
            
            // Author info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: item.authorImage != null ? AssetImage(item.authorImage!) : null,
                  child: item.authorImage == null 
                      ? Text(
                          item.author[0],
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.author,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2B5320),
                        ),
                      ),
                      Text(
                        '${item.readTime} • ${item.publishDate}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${item.rating} (${item.ratingCount})',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Content would go here
            Container(
              width: double.infinity,
              height: kToolbarHeight + 8,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getContentTypeIcon(item.contentType),
                      size: 48,
                      color: const Color(0xFF2B5320),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${item.contentType} Content',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2B5320),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Content would be displayed here',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Description
            Text(
              'Description',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2B5320),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Tags
            Text(
              'Tags',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2B5320),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: item.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2B5320).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '#$tag',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF2B5320),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
            
            const SizedBox(height: 32),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: Text('Download', style: GoogleFonts.poppins()),
                    onPressed: () {
                      // Handle download
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Downloading content...', style: GoogleFonts.poppins()),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B5320),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.thumb_up),
                    label: Text('Helpful', style: GoogleFonts.poppins()),
                    onPressed: () {
                      // Handle rating
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Thank you for your feedback!', style: GoogleFonts.poppins()),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2B5320),
                      side: const BorderSide(color: Color(0xFF2B5320)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getContentTypeIcon(String contentType) {
    switch (contentType) {
      case 'Article':
        return Icons.article;
      case 'Video':
        return Icons.play_circle;
      case 'Infographic':
        return Icons.image;
      case 'PDF Guide':
        return Icons.picture_as_pdf;
      default:
        return Icons.description;
    }
  }
}