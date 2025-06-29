import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AgriTransportHubScreen extends StatefulWidget {
  const AgriTransportHubScreen({super.key});

  @override
  State<AgriTransportHubScreen> createState() => _AgriTransportHubScreenState();
}

class _AgriTransportHubScreenState extends State<AgriTransportHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildTransportCard({
    required String vehicleType,
    required String driverName,
    required String rating,
    required String price,
    required String eta,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7043).withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getVehicleIcon(vehicleType),
                  color: const Color(0xFFFF7043),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicleType,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2B5320),
                      ),
                    ),
                    Text(
                      driverName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        Text(' $rating'),
                        const SizedBox(width: 16),
                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                        Text(' $eta'),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'KSh $price',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2B5320),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_right, color: Color(0xFFFF7043)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveDeliveryCard({
    required String orderId,
    required String driverName,
    required String currentLocation,
    required String eta,
    required double progress,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #$orderId',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7043).withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'In Transit',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFFFF7043),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Driver: $driverName'),
            Text('Current Location: $currentLocation'),
            Text('ETA: $eta'),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF7043)),
            ),
            const SizedBox(height: 8),
            Text('${(progress * 100).toInt()}% Complete'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _callDriver(context, driverName),
                    icon: const Icon(Icons.phone),
                    label: const Text('Call Driver'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _trackDelivery(context, orderId),
                    icon: const Icon(Icons.location_on),
                    label: const Text('Track Live'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7043),
                      foregroundColor: Colors.white,
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

  Widget _buildPartnerCard({
    required String name,
    required String type,
    required String rating,
    required String vehicles,
    required String speciality,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2B5320),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    type,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                Text(
                  ' $rating',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.local_shipping, size: 16, color: Colors.grey),
                Expanded(
                  child: Text(
                    ' $vehicles',
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Speciality: $speciality',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _contactPartner(context, name),
                    icon: const Icon(Icons.message),
                    label: const Text('Contact'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _viewPartnerProfile(context, name),
                    icon: const Icon(Icons.person),
                    label: const Text('View Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7043),
                      foregroundColor: Colors.white,
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

  Widget _buildBookingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFF7043).withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Book Transport',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFF7043),
                  ),
                ),
                const SizedBox(height: 12),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Pickup Location',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Destination',
                    prefixIcon: Icon(Icons.flag),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Commodity Type',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'maize', child: Text('Maize')),
                          DropdownMenuItem(value: 'beans', child: Text('Beans')),
                          DropdownMenuItem(value: 'vegetables', child: Text('Vegetables')),
                          DropdownMenuItem(value: 'livestock', child: Text('Livestock')),
                        ],
                        onChanged: (value) {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Weight (KG)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _searchTransport(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7043),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Find Transport',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Available Transport',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2B5320),
            ),
          ),
          const SizedBox(height: 12),
          
          _buildTransportCard(
            vehicleType: 'Pickup Truck',
            driverName: 'James Mwangi',
            rating: '4.8',
            price: '1,500',
            eta: '15 mins',
            onTap: () => _bookTransport(context, 'Pickup Truck', 'James Mwangi'),
          ),
          
          _buildTransportCard(
            vehicleType: 'Lorry (3 Ton)',
            driverName: 'Peter Kamau',
            rating: '4.6',
            price: '3,200',
            eta: '25 mins',
            onTap: () => _bookTransport(context, 'Lorry (3 Ton)', 'Peter Kamau'),
          ),
          
          _buildTransportCard(
            vehicleType: 'Motorcycle',
            driverName: 'John Otieno',
            rating: '4.9',
            price: '500',
            eta: '8 mins',
            onTap: () => _bookTransport(context, 'Motorcycle', 'John Otieno'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Deliveries',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2B5320),
            ),
          ),
          const SizedBox(height: 12),
          
          _buildActiveDeliveryCard(
            orderId: 'TH001',
            driverName: 'James Mwangi',
            currentLocation: 'Nakuru - Nairobi Highway',
            eta: '2 hours 15 mins',
            progress: 0.6,
          ),
          
          _buildActiveDeliveryCard(
            orderId: 'TH002',
            driverName: 'Mary Wanjiku',
            currentLocation: 'Kikuyu Town',
            eta: '45 mins',
            progress: 0.8,
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Recent Deliveries',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2B5320),
            ),
          ),
          const SizedBox(height: 12),
          
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.check, color: Colors.white),
              ),
              title: const Text('Order #TH003'),
              subtitle: const Text('Delivered • Dec 18, 2024'),
              trailing: TextButton(
                onPressed: () => _showDeliveryProof(context, 'TH003'),
                child: const Text('View Proof'),
              ),
            ),
          ),
          
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.check, color: Colors.white),
              ),
              title: const Text('Order #TH004'),
              subtitle: const Text('Delivered • Dec 15, 2024'),
              trailing: TextButton(
                onPressed: () => _showDeliveryProof(context, 'TH004'),
                child: const Text('View Proof'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnersTab() {
    final partners = [
      {
        'name': 'Mwangi Transport',
        'type': 'Individual Driver',
        'rating': '4.8',
        'vehicles': '2 Pickups, 1 Lorry',
        'speciality': 'Vegetables & Grains'
      },
      {
        'name': 'Kikuyu Boda Association',
        'type': 'Motorcycle Group',
        'rating': '4.6',
        'vehicles': '15 Motorcycles',
        'speciality': 'Small Parcels'
      },
      {
        'name': 'Highlands Logistics',
        'type': 'Transport Company',
        'rating': '4.7',
        'vehicles': '5 Lorries, 3 Trucks',
        'speciality': 'Bulk Transport'
      },
      {
        'name': 'Kiambu Farmers Coop Transport',
        'type': 'Cooperative',
        'rating': '4.5',
        'vehicles': '8 Trucks, 12 Pickups',
        'speciality': 'Farm Produce'
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2B5320).withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF2B5320),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Connect with verified transport partners in your area',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF2B5320),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            'Transport Partners',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2B5320),
            ),
          ),
          const SizedBox(height: 12),
          
          ...partners.map((partner) => _buildPartnerCard(
            name: partner['name']!,
            type: partner['type']!,
            rating: partner['rating']!,
            vehicles: partner['vehicles']!,
            speciality: partner['speciality']!,
          )),
          
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _becomePartner(context),
              icon: const Icon(Icons.add_business),
              label: const Text('Become a Transport Partner'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF7043),
                side: const BorderSide(color: Color(0xFFFF7043)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get vehicle icons
  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'motorcycle':
        return Icons.two_wheeler;
      case 'pickup truck':
        return Icons.local_shipping;
      case 'lorry (3 ton)':
        return Icons.fire_truck;
      default:
        return Icons.local_shipping;
    }
  }

  // Action methods
  void _searchTransport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Searching for available transport...'),
        backgroundColor: Color(0xFFFF7043),
      ),
    );
  }

  void _bookTransport(BuildContext context, String vehicleType, String driverName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Booking'),
        content: Text('Book transport with $driverName using $vehicleType?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Transport booked with $driverName!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFF7043)),
            child: Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _callDriver(BuildContext context, String driverName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling $driverName...'),
        backgroundColor: Color(0xFFFF7043),
      ),
    );
  }

  void _trackDelivery(BuildContext context, String orderId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening live tracking for order $orderId...'),
        backgroundColor: Color(0xFFFF7043),
      ),
    );
  }

  void _showDeliveryProof(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delivery Proof'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              child: Icon(Icons.photo, size: 50, color: Colors.grey[600]),
            ),
            SizedBox(height: 12),
            Text('Order $orderId delivered successfully'),
            Text('Signed by: John Doe'),
            Text('Time: Dec 18, 2024 - 3:45 PM'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _contactPartner(BuildContext context, String partnerName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening chat with $partnerName...'),
        backgroundColor: Color(0xFFFF7043),
      ),
    );
  }

  void _viewPartnerProfile(BuildContext context, String partnerName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing $partnerName profile...'),
        backgroundColor: Color(0xFFFF7043),
      ),
    );
  }

  void _becomePartner(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Become a Transport Partner'),
        content: Text('Join our network of verified transport providers. Would you like to start the application process?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening partner application form...'),
                  backgroundColor: Color(0xFFFF7043),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFF7043)),
            child: Text('Apply Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Transport Hub',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2B5320),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFF7043),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Book', icon: Icon(Icons.add_circle_outline)),
            Tab(text: 'Track', icon: Icon(Icons.location_on)),
            Tab(text: 'Partners', icon: Icon(Icons.people)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingTab(),
          _buildTrackingTab(),
          _buildPartnersTab(),
        ],
      ),
    );
  }
}