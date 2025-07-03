import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QAForumTab extends StatefulWidget {
  const QAForumTab({super.key});

  @override
  State<QAForumTab> createState() => _QAForumTabState();
}

class _QAForumTabState extends State<QAForumTab> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Crop Management',
    'Pest & Disease',
    'Livestock',
    'Post-Harvest',
    'Agribusiness',
    'Organic Farming'
  ];

  // Sample Q&A data
  final List<Map<String, dynamic>> _questions = [
    {
      'id': 'QA001',
      'title': 'How to control fall armyworm in maize?',
      'description': 'I noticed some damage on my maize leaves and suspect it might be fall armyworm. What are the best control methods?',
      'category': 'Pest & Disease',
      'author': 'John Farmer',
      'location': 'Kiambu County',
      'date': '2025-06-20',
      'answers': 3,
      'views': 45,
      'upvotes': 12,
      'tags': ['maize', 'fall-armyworm', 'pest-control'],
      'hasExpertAnswer': true,
      'isFollowing': false,
      'image': null,
    },
    {
      'id': 'QA002',
      'title': 'Best practices for dairy cow feeding',
      'description': 'What should I feed my dairy cows to maximize milk production? I have 10 cows and want to improve their nutrition.',
      'category': 'Livestock',
      'author': 'Mary Wanjiku',
      'location': 'Nakuru County',
      'date': '2025-06-19',
      'answers': 7,
      'views': 89,
      'upvotes': 23,
      'tags': ['dairy', 'cow-feeding', 'nutrition'],
      'hasExpertAnswer': true,
      'isFollowing': true,
      'image': null,
    },
    {
      'id': 'QA003',
      'title': 'Tomato leaves turning yellow - what could be wrong?',
      'description': 'My tomato plants are doing well but some leaves are turning yellow from the bottom up. Is this normal or a disease?',
      'category': 'Crop Management',
      'author': 'Peter Mwangi',
      'location': 'Meru County',
      'date': '2025-06-21',
      'answers': 1,
      'views': 12,
      'upvotes': 3,
      'tags': ['tomatoes', 'yellow-leaves', 'plant-disease'],
      'hasExpertAnswer': false,
      'isFollowing': false,
      'image': 'assets/tomato_leaves.jpg',
    },
  ];

  List<Map<String, dynamic>> get _filteredQuestions {
    if (_selectedCategory == 'All') return _questions;
    return _questions.where((q) => q['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with Ask Question button
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _askQuestion,
                  icon: const Icon(Icons.add),
                  label: const Text('Ask a Question'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B5320),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Category Filter
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedCategory = category);
                  },
                  selectedColor: const Color(0xFF2B5320).withValues (alpha: 0.2),
                  checkmarkColor: const Color(0xFF2B5320),
                ),
              );
            },
          ),
        ),

        // Questions List
        Expanded(
          child: _filteredQuestions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.help_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No questions found',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Be the first to ask a question!',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredQuestions.length,
                  itemBuilder: (context, index) {
                    final question = _filteredQuestions[index];
                    return _buildQuestionCard(question);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B5320).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    question['category'],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2B5320),
                    ),
                  ),
                ),
                if (question['hasExpertAnswer']) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified, size: 12, color: Colors.green),
                        const SizedBox(width: 2),
                        Text(
                          'Expert Answer',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                IconButton(
                  onPressed: () => _toggleFollow(question),
                  icon: Icon(
                    question['isFollowing'] ? Icons.notifications_active : Icons.notifications_none,
                    color: question['isFollowing'] ? const Color(0xFF2B5320) : Colors.grey,
                    size: 20,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Question Title
            Text(
              question['title'],
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2B5320),
              ),
            ),

            const SizedBox(height: 8),

            // Question Description
            Text(
              question['description'],
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Tags
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: (question['tags'] as List<String>).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#$tag',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // Question Footer
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  question['author'],
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 12),
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  question['location'],
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                ),
                const Spacer(),
                Text(
                  question['date'],
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Stats and Actions
            Row(
              children: [
                Row(
                  children: [
                    Icon(Icons.thumb_up, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${question['upvotes']}',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    Icon(Icons.question_answer, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${question['answers']} answers',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${question['views']} views',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _viewQuestion(question),
                  child: Text(
                    'View Details',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF2B5320),
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

  void _askQuestion() {
    // Navigate to ask question screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ask Question dialog coming soon')),
    );
  }

  void _toggleFollow(Map<String, dynamic> question) {
    setState(() {
      question['isFollowing'] = !question['isFollowing'];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          question['isFollowing'] 
              ? 'You will be notified of new answers' 
              : 'Notifications disabled for this question'
        ),
      ),
    );
  }

  void _viewQuestion(Map<String, dynamic> question) {
    // Navigate to question details screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening question details...')),
    );
  }
}