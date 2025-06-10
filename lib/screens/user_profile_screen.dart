import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'sign_in_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final authService = AuthService();

  void _handleLogout() async {
    await authService.signOut();

    if (!mounted) return;

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

  Widget _buildProfileOption({
    required String title,
    required IconData icon,
    VoidCallback? onTap,
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
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: const Color(0xFF2B5320).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF2B5320),
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF2B5320),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Color(0xFF2B5320),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = authService.currentUser;

    if (currentUser == null || currentUser.isAnonymous) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: const Color(0xFF2B5320),
        ),
        body: const Center(
          child: Text('You are browsing as a guest. Please sign in.'),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading profile'));
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>?;
            if (userData == null) {
              return const Center(child: Text('User data not found'));
            }

            final fullName = userData['fullName'] as String? ?? 'User';
            final location = userData['location'] as String? ?? 'Location not set';

            return Column(
              children: [
                // Header with Profile Info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2B5320),
                  ),
                  child: Column(
                    children: [
                      // Profile Picture
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white70,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Color(0xFF2B5320),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Name
                      Text(
                        fullName,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      // Location
                      Text(
                        location,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                // Profile Options
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildProfileOption(
                        title: 'My Dashboard',
                        icon: Icons.dashboard_outlined,
                        onTap: () => Navigator.pop(context),
                      ),
                      _buildProfileOption(
                        title: 'My Crops',
                        icon: Icons.eco_outlined,
                        onTap: () {},
                      ),
                      _buildProfileOption(
                        title: 'Financial Services',
                        icon: Icons.account_balance_outlined,
                        onTap: () {},
                      ),
                      _buildProfileOption(
                        title: 'App Settings',
                        icon: Icons.settings_outlined,
                        onTap: () {},
                      ),
                      _buildProfileOption(
                        title: 'Log Out',
                        icon: Icons.logout,
                        onTap: _handleLogout,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
