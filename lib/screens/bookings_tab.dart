import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingsTab extends StatefulWidget {
  const BookingsTab({super.key});

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> {
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Upcoming', 'Completed', 'Cancelled'];

  // Sample booking data
  final List<Map<String, dynamic>> _bookings = [
    {
      'id': 'BK001',
      'expertName': 'Dr. Sarah Mbeki',
      'expertSpecialty': 'Crop Specialist',
      'date': '2025-06-25',
      'time': '10:00 AM',
      'duration': 60,
      'type': 'Video',
      'status': 'Upcoming',
      'price': 2500,
      'topic': 'Maize pest control strategies',
      'notes': 'Need help with fall armyworm management',
    },
    {
      'id': 'BK002',
      'expertName': 'Prof. James Kiprotich',
      'expertSpecialty': 'Soil Expert',
      'date': '2025-06-20',
      'time': '2:00 PM',
      'duration': 45,
      'type': 'Audio',
      'status': 'Completed',
      'price': 3000,
      'topic': 'Soil pH testing and adjustment',
      'notes': 'Follow-up on soil analysis results',
      'rating': 5,
      'review': 'Excellent advice on soil management',
    },
    {
      'id': 'BK003',
      'expertName': 'Dr. Mary Wanjiku',
      'expertSpecialty': 'Livestock Specialist',
      'date': '2025-06-28',
      'time': '9:00 AM',
      'duration': 30,
      'type': 'Text',
      'status': 'Upcoming',
      'price': 1500,
      'topic': 'Dairy cow nutrition',
      'notes': 'Questions about feed supplements',
    },
  ];

  List<Map<String, dynamic>> get _filteredBookings {
    if (_selectedFilter == 'All') return _bookings;
    return _bookings.where((booking) => booking['status'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter Section
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Filter by status:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filterOptions.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedFilter = filter);
                          },
                          selectedColor: const Color(0xFF2B5320).withOpacity(0.2),
                          checkmarkColor: const Color(0xFF2B5320),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bookings List
        Expanded(
          child: _filteredBookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No bookings found',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Book a consultation with an expert',
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
                  itemCount: _filteredBookings.length,
                  itemBuilder: (context, index) {
                    final booking = _filteredBookings[index];
                    return _buildBookingCard(booking);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final status = booking['status'] as String;
    final statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'ID: ${booking['id']}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Expert Info
            Text(
              booking['expertName'],
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2B5320),
              ),
            ),
            Text(
              booking['expertSpecialty'],
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 12),

            // Consultation Details
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${booking['date']} at ${booking['time']}',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${booking['duration']} min',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Icon(
                  booking['type'] == 'Video'
                      ? Icons.videocam
                      : booking['type'] == 'Audio'
                          ? Icons.phone
                          : Icons.message,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${booking['type']} Consultation',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const Spacer(),
                Text(
                  'KSh ${booking['price']}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2B5320),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Topic and Notes
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Topic: ${booking['topic']}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (booking['notes'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      booking['notes'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Rating (for completed bookings)
            if (status == 'Completed' && booking['rating'] != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Your Rating: ',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  ...List.generate(5, (index) {
                    return Icon(
                      index < booking['rating'] ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ],
              ),
              if (booking['review'] != null) ...[
                const SizedBox(height: 4),
                Text(
                  booking['review'],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],

            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                if (status == 'Upcoming') ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _rescheduleBooking(booking),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF2B5320)),
                      ),
                      child: Text(
                        'Reschedule',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF2B5320),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _joinConsultation(booking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B5320),
                      ),
                      child: Text(
                        'Join',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  ),
                ] else if (status == 'Completed' && booking['rating'] == null) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _rateConsultation(booking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B5320),
                      ),
                      child: Text(
                        'Rate & Review',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _viewBookingDetails(booking),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF2B5320)),
                      ),
                      child: Text(
                        'View Details',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF2B5320),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Upcoming':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _rescheduleBooking(Map<String, dynamic> booking) {
    // Implement reschedule functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reschedule functionality coming soon')),
    );
  }

  void _joinConsultation(Map<String, dynamic> booking) {
    // Implement join consultation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Joining consultation...')),
    );
  }

  void _rateConsultation(Map<String, dynamic> booking) {
    // Implement rating dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rating dialog coming soon')),
    );
  }

  void _viewBookingDetails(Map<String, dynamic> booking) {
    // Implement view details
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Viewing booking details...')),
    );
  }
}