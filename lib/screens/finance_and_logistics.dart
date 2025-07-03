import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'agrifinance_access_screen.dart';
import 'agripay_gateway_screen.dart';
import 'agritransport_hub_screen.dart';
import 'agriinputs_market_screen.dart';
import 'agrifinance_planner_screen.dart';

class FinancialServicesScreen extends StatelessWidget {
  const FinancialServicesScreen({super.key});

  Widget _buildServiceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withAlpha(26), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withAlpha(77),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
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
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2B5320),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B5320),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Financial Services',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2B5320).withAlpha(13),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B5320).withAlpha(26),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          color: Color(0xFF2B5320),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Complete Financial Suite',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2B5320),
                              ),
                            ),
                            Text(
                              'Access loans, payments, transport, inputs & planning tools',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                _buildServiceCard(
                  title: 'AgriFinance Access',
                  subtitle: 'Apply for loans, get insurance coverage, and track repayments',
                  icon: Icons.account_balance,
                  color: const Color(0xFF1976D2),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AgriFinanceAccessScreen()),
                  ),
                ),
                
                _buildServiceCard(
                  title: 'AgriPay Gateway',
                  subtitle: 'Mobile money, card payments, and digital wallet services',
                  icon: Icons.payment,
                  color: const Color(0xFF388E3C),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AgriPayGatewayScreen()),
                  ),
                ),
                
                _buildServiceCard(
                  title: 'AgriTransport Hub',
                  subtitle: 'Book transport, track deliveries, and manage logistics',
                  icon: Icons.local_shipping,
                  color: const Color(0xFFFF7043),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AgriTransportHubScreen()),
                  ),
                ),
                
                _buildServiceCard(
                  title: 'AgriInputs Market',
                  subtitle: 'Find verified suppliers for seeds, fertilizers, and equipment',
                  icon: Icons.store,
                  color: const Color(0xFF7B1FA2),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AgriInputsMarketScreen()),
                  ),
                ),
                
                _buildServiceCard(
                  title: 'AgriFinance Planner',
                  subtitle: 'Budget planning, profitability calculator & savings goals',
                  icon: Icons.calculate,
                  color: const Color(0xFFF57C00),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AgriFinancePlannerScreen()),
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}