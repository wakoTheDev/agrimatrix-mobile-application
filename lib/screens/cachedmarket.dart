import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MarketMatrixScreen extends StatelessWidget {
  const MarketMatrixScreen({super.key});

  Widget _buildMarketItem({
    required String cropName,
    required String marketName,
    required String price,
    required IconData cropIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: const Color(0xFF2B5320).withOpacity(0.15),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(-6, 0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Crop Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: const Color(0xFF2B5320).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                cropIcon,
                color: const Color(0xFF2B5320),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Crop and
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cropName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2B5320),
                    ),
                  ),
                  Text(
                    marketName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Price Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2B5320),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'KSH $price/kg',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF2B5320),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Market Matrix',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Real-time pricing',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search crops or markets...',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey[400],
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[400],
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),

            // Market Items List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildMarketItem(
                    cropName: 'Maize',
                    marketName: 'Nairobi Market',
                    price: '45',
                    cropIcon: Icons.grass,
                  ),
                  _buildMarketItem(
                    cropName: 'Carrots',
                    marketName: 'Mombasa Market',
                    price: '80',
                    cropIcon: Icons.eco,
                  ),
                  _buildMarketItem(
                    cropName: 'Tomatoes',
                    marketName: 'Kisumu Market',
                    price: '120',
                    cropIcon: Icons.spa,
                  ),
                ],
              ),            
            ),
          ],
        ),
      ),
    );
  }

}
