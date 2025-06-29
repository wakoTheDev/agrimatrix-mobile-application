import 'package:agrimatrix/screens/booking_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'knowledge_hub_screen.dart';
import 'bookings_tab.dart';
import 'qa_forum_tab.dart';
import 'disease_id_tab.dart';


class ExpertAdviceScreen extends StatefulWidget {
  const ExpertAdviceScreen({super.key});

  @override
  State<ExpertAdviceScreen> createState() => _ExpertAdviceScreenState();
}

class _ExpertAdviceScreenState extends State<ExpertAdviceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isDarkMode = false;
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildExpertCard({
    required String name,
    required String speciality,
    required String description,
    required bool isVerified,
    required double rating,
    required int reviews,
    required List<String> languages,
    required String availability,
    required int articlesPublished,
    required List<String> consultationTypes,
    required String region,
    required double pricePerHour,
    String? profileImage,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2B5320).withOpacity(0.15),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(-6, 0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Profile Image
                CircleAvatar(
                  radius: 30,
                  backgroundImage: profileImage != null ? AssetImage(profileImage) : null,
                  child: profileImage == null ? const Icon(Icons.person) : null,
                ),
                const SizedBox(width: 12),
                // Expert details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2B5320),
                            ),
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, color: Colors.green, size: 20),
                          ],
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          speciality,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.orange[800],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(
                            ' $rating ($reviews reviews)',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoChip(Icons.language, languages.join(', ')),
                _buildInfoChip(Icons.location_on, region),
                _buildInfoChip(Icons.article, '$articlesPublished articles'),
                _buildInfoChip(Icons.access_time, availability),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'KSh ${pricePerHour.toStringAsFixed(0)}/hour',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2B5320),
                  ),
                ),
                const Spacer(),
                ...consultationTypes.map((type) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        type == 'Text'
                            ? Icons.message
                            : type == 'Audio'
                                ? Icons.phone
                                : Icons.videocam,
                        color: const Color(0xFF2B5320),
                        size: 20,
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showBookingDialog(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B5320),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Book Consultation',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showExpertProfile(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2B5320)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'View Profile',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF2B5320),
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

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog() {
    // Sample expert data for demonstration
    final expert = {
      'name': 'Dr. John Smith',
      'speciality': 'Agricultural Consultant',
      'pricePerHour': 2500,
    };

    showDialog(
      context: context,
      builder: (context) => BookingDialog(expert: expert),
    );
  }

  void _showExpertProfile() {
    // Navigate to expert profile page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2B5320), Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AgriConsult Hub',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Connect with verified agri experts',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
                        icon: Icon(
                          _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search and Filter
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search experts, articles, or ask a question...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // Tab Bar
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Experts'),
                Tab(text: 'Knowledge Hub'),
                Tab(text: "Q&A Forum"),
                Tab(text: 'Disease ID'),
                Tab(text: 'Bookings'),
              ],
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Experts Tab
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildExpertCard(
                        name: 'Dr. Sarah Mbeki',
                        speciality: 'Crop Specialist',
                        description: 'Specializes in pest control and disease management',
                        isVerified: true,
                        rating: 4.8,
                        reviews: 156,
                        languages: ['English', 'Kiswahili', 'Kikuyu'],
                        availability: 'Available Now',
                        articlesPublished: 23,
                        consultationTypes: ['Text', 'Audio', 'Video'],
                        region: 'Central Kenya',
                        pricePerHour: 2500,
                      ),
                      _buildExpertCard(
                        name: 'Prof. James Kiprotich',
                        speciality: 'Soil Expert',
                        description: 'Soil health and fertilizer recommendations',
                        isVerified: true,
                        rating: 4.9,
                        reviews: 203,
                        languages: ['English', 'Kiswahili', 'Kalenjin'],
                        availability: 'Available in 2 hours',
                        articlesPublished: 45,
                        consultationTypes: ['Text', 'Audio'],
                        region: 'Rift Valley',
                        pricePerHour: 3000,
                      ),
                    ],
                  ),

                  // Knowledge Hub Tab
                  const KnowledgeHubScreen(),

                  // Q&A Forum Tab
                  const QAForumTab(),

                  // Disease ID Tab
                  const DiseaseIdTab(),

                  // Bookings Tab
                  const BookingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF2B5320),
        child: const Icon(Icons.add),
      ),
    );
  }
}