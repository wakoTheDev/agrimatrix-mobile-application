import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'sign_in_screen.dart';
import 'user_profile_screen.dart';
import 'finance_and_logistics.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _handleLogout(BuildContext context) async {
    final authService = AuthService();
    await authService.signOut();
    
    if (!context.mounted) return;

    // Show success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out successfully'),
        backgroundColor: Color(0xFF2B5320),
        duration: Duration(seconds: 2),
      ),
    );

    // Navigate back to sign in screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (route) => false,
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required BuildContext context,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap ?? () => _showDetails(context, title),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2B5320).withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF2B5320),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2B5320),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF2B5320),
              ),
            ],
          ),
          ),
        ),

      );
  
  }


  void _showDetails(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2B5320),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Coming soon...',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final currentUser = authService.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B5320),
        elevation: 0,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (currentUser == null || currentUser.isAnonymous)
                  Text(
                    'Welcome, Guest User',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  )
                else
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError || snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox.shrink();
                      }

                      final userData = snapshot.data?.data() as Map<String, dynamic>?;
                      final userName = userData?['fullName'] as String? ?? 'User';

                      return Text(
                        'Welcome, $userName',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
        toolbarHeight: 80,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            color: Colors.white,
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => const UserProfileScreen()),
            ),
            tooltip: 'Profile',
          ),
          if (!authService.isGuest)
            IconButton(
              icon: const Icon(Icons.logout),
              color: Colors.white,
              onPressed: () => _handleLogout(context),
              tooltip: 'Logout',
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDashboardCard(
                      context: context,
                      title: 'Market Analysis', 
                      subtitle: 'Check market prices and trends',
                      icon: Icons.trending_up,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MarketAnalysisScreen()),
                      ),
                    ),
                    _buildDashboardCard(
                      context: context,
                      title: 'Financial Services',
                      subtitle: 'Access loans and insurance',
                      icon: Icons.account_balance,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FinancialServicesScreen()),
                      ),
                    ),
                    _buildDashboardCard(
                      context: context,
                      title: 'Support & Advice',
                      subtitle: 'Consult with agricultural experts',
                      icon: Icons.support_agent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SupportAdviceScreen()),
                      ),
                    ),
                    _buildDashboardCard(
                      context: context,
                      title: 'Advanced Analytics',
                      subtitle: 'Get insights on your farm',
                      icon: Icons.wb_sunny,
                    ),
                    
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
