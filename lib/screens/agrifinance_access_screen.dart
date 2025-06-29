import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AgriFinanceAccessScreen extends StatefulWidget {
  const AgriFinanceAccessScreen({super.key});

  @override
  State<AgriFinanceAccessScreen> createState() => _AgriFinanceAccessScreenState();
}

class _AgriFinanceAccessScreenState extends State<AgriFinanceAccessScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildInfoCard({
    required String title,
    required String subtitle,
    required IconData icon,
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
                  color: const Color(0xFF1976D2).withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF1976D2), size: 24),
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
              const Icon(Icons.chevron_right, color: Color(0xFF1976D2)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoanApplicationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2).withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF1976D2)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Complete your loan application in minutes',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1976D2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          _buildInfoCard(
            title: 'Input Loans',
            subtitle: 'Finance seeds, fertilizers, and farming inputs',
            icon: Icons.eco,
            onTap: () => _showLoanDetails(context, 'Input Loans'),
          ),
          
          _buildInfoCard(
            title: 'Equipment Financing',
            subtitle: 'Get funding for tractors, irrigation, and tools',
            icon: Icons.agriculture,
            onTap: () => _showLoanDetails(context, 'Equipment Financing'),
          ),
          
          _buildInfoCard(
            title: 'Seasonal Credit',
            subtitle: 'Working capital for planting and harvest seasons',
            icon: Icons.calendar_today,
            onTap: () => _showLoanDetails(context, 'Seasonal Credit'),
          ),
          
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _startLoanApplication(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Start Loan Application',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLendersTab() {
    final lenders = [
      {'name': 'Kenya Women Finance Trust', 'rate': '12-15%', 'type': 'Microfinance'},
      {'name': 'Faulu Microfinance', 'rate': '14-18%', 'type': 'Microfinance'},
      {'name': 'Equity Bank', 'rate': '13-16%', 'type': 'Commercial Bank'},
      {'name': 'Cooperative Bank', 'rate': '12-14%', 'type': 'Commercial Bank'},
      {'name': 'Apollo Agriculture', 'rate': '15-20%', 'type': 'Agri-Fintech'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: lenders.map((lender) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF1976D2).withAlpha(26),
              child: const Icon(Icons.account_balance, color: Color(0xFF1976D2)),
            ),
            title: Text(
              lender['name']!,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('${lender['type']} • Interest: ${lender['rate']}'),
            trailing: TextButton(
              onPressed: () => _showLenderDetails(context, lender),
              child: const Text('View Details'),
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildInsuranceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoCard(
            title: 'Crop Insurance',
            subtitle: 'Protection against drought, pests, and floods',
            icon: Icons.agriculture,
            onTap: () => _showInsuranceDetails(context, 'Crop Insurance'),
          ),
          
          _buildInfoCard(
            title: 'Livestock Insurance',
            subtitle: 'Cover for disease, theft, and accidents',
            icon: Icons.pets,
            onTap: () => _showInsuranceDetails(context, 'Livestock Insurance'),
          ),
          
          _buildInfoCard(
            title: 'Weather Insurance',
            subtitle: 'Index-based protection against weather risks',
            icon: Icons.wb_cloudy,
            onTap: () => _showInsuranceDetails(context, 'Weather Insurance'),
          ),
          
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showInsuranceApplication(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Get Insurance Quote',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Loans',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLoanSummary('Input Loan #001', 'KSh 45,000', 'KSh 15,000', '2024-08-15'),
                  const Divider(),
                  _buildLoanSummary('Equipment Loan #002', 'KSh 120,000', 'KSh 80,000', '2024-09-20'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Insurance Claims',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildClaimStatus('Crop Insurance Claim', 'Under Review', Icons.hourglass_empty),
                  const Divider(),
                  _buildClaimStatus('Weather Insurance Claim', 'Approved', Icons.check_circle),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanSummary(String loanName, String totalAmount, String remaining, String dueDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loanName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total: $totalAmount'),
            Text('Remaining: $remaining', style: const TextStyle(color: Colors.red)),
          ],
        ),
        Text('Next Due: $dueDate', style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildClaimStatus(String claimName, String status, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: status == 'Approved' ? Colors.green : Colors.orange),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(claimName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              Text('Status: $status'),
            ],
          ),
        ),
      ],
    );
  }

  void _showLoanDetails(BuildContext context, String loanType) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loanType,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loan Amount: KSh 10,000 - 500,000\nInterest Rate: 12-18% per annum\nRepayment Period: 6-24 months\nProcessing Time: 2-5 working days',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _startLoanApplication(context);
                },
                child: const Text('Apply Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLenderDetails(BuildContext context, Map<String, String> lender) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lender['name']!),
        content: Text(
          'Type: ${lender['type']}\nInterest Rate: ${lender['rate']}\n\nRequirements:\n• Valid ID\n• Farm ownership proof\n• 6 months bank statements\n• Business plan',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startLoanApplication(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showInsuranceDetails(BuildContext context, String insuranceType) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              insuranceType,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Premium: 2-5% of sum insured\nCoverage: Up to KSh 1,000,000\nClaim Settlement: 14-30 days\nValidity: 1 year',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showInsuranceApplication(context);
                },
                child: const Text('Get Quote'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startLoanApplication(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Loan Application'),
        content: const Text('This will redirect you to the loan application form. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Loan application form coming soon!')),
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showInsuranceApplication(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insurance Application'),
        content: const Text('Get a personalized insurance quote. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Insurance quote form coming soon!')),
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'AgriFinance Access',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Loans'),
            Tab(text: 'Lenders'),
            Tab(text: 'Insurance'),
            Tab(text: 'Tracking'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLoanApplicationTab(),
          _buildLendersTab(),
          _buildInsuranceTab(),
          _buildTrackingTab(),
        ],
      ),
    );
  }
}