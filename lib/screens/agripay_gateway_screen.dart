import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AgriPayGatewayScreen extends StatefulWidget {
  const AgriPayGatewayScreen({super.key});

  @override
  State<AgriPayGatewayScreen> createState() => _AgriPayGatewayScreenState();
}

class _AgriPayGatewayScreenState extends State<AgriPayGatewayScreen> {
  double walletBalance = 12850.50;

  Widget _buildPaymentMethodCard({
    required String title,
    required String subtitle,
    required String logoPath,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isActive ? Border.all(color: const Color(0xFF388E3C), width: 2) : null,
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF388E3C).withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.payment,
                  color: Color(0xFF388E3C),
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
              if (isActive) 
                const Icon(Icons.check_circle, color: Color(0xFF388E3C))
              else
                const Icon(Icons.chevron_right, color: Color(0xFF388E3C)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard({
    required String title,
    required String amount,
    required String date,
    required String type,
    required bool isCredit,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCredit 
            ? const Color(0xFF388E3C).withAlpha(26)
            : const Color(0xFFD32F2F).withAlpha(26),
          child: Icon(
            isCredit ? Icons.arrow_downward : Icons.arrow_upward,
            color: isCredit ? const Color(0xFF388E3C) : const Color(0xFFD32F2F),
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('$type • $date'),
        trailing: Text(
          '${isCredit ? '+' : '-'}KSh $amount',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: isCredit ? const Color(0xFF388E3C) : const Color(0xFFD32F2F),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF388E3C).withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF388E3C), size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF388E3C),
                ),
                textAlign: TextAlign.center,
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
        backgroundColor: const Color(0xFF388E3C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'AgriPay Gateway',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            onPressed: () => _showQRScanner(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Digital Wallet Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF388E3C),
                    const Color(0xFF388E3C).withAlpha(204),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF388E3C).withAlpha(77),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Digital Wallet',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Icon(Icons.account_balance_wallet, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'KSh ${walletBalance.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildQuickActionButton(
                        title: 'Add Money',
                        icon: Icons.add,
                        onTap: () => _showAddMoney(context),
                      ),
                      const SizedBox(width: 12),
                      _buildQuickActionButton(
                        title: 'Send Money',
                        icon: Icons.send,
                        onTap: () => _showSendMoney(context),
                      ),
                      const SizedBox(width: 12),
                      _buildQuickActionButton(
                        title: 'Withdraw',
                        icon: Icons.call_made,
                        onTap: () => _showWithdraw(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Payment Methods Section
            Text(
              'Payment Methods',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2B5320),
              ),
            ),
            const SizedBox(height: 12),
            
            _buildPaymentMethodCard(
              title: 'M-PESA',
              subtitle: 'Mobile money payments',
              logoPath: 'assets/mpesa_logo.png',
              isActive: true,
              onTap: () => _configureMpesa(context),
            ),
            
            _buildPaymentMethodCard(
              title: 'Airtel Money',
              subtitle: 'Airtel mobile payments',
              logoPath: 'assets/airtel_logo.png',
              isActive: false,
              onTap: () => _configureAirtel(context),
            ),
            
            _buildPaymentMethodCard(
              title: 'Bank Transfer',
              subtitle: 'Direct bank payments',
              logoPath: 'assets/bank_logo.png',
              isActive: true,
              onTap: () => _configureBankTransfer(context),
            ),
            
            _buildPaymentMethodCard(
              title: 'Card Payment',
              subtitle: 'Visa & Mastercard',
              logoPath: 'assets/card_logo.png',
              isActive: false,
              onTap: () => _configureCard(context),
            ),
            
            const SizedBox(height: 24),
            
            // Recent Transactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2B5320),
                  ),
                ),
                TextButton(
                  onPressed: () => _showAllTransactions(context),
                  child: Text(
                    'View All',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF388E3C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            _buildTransactionCard(
              title: 'Payment from John Farmer',
              amount: '2,500.00',
              date: 'Today, 2:30 PM',
              type: 'M-PESA',
              isCredit: true,
            ),
            
            _buildTransactionCard(
              title: 'Input Purchase - Seeds Ltd',
              amount: '1,200.00',
              date: 'Yesterday, 10:15 AM',
              type: 'Wallet',
              isCredit: false,
            ),
            
            _buildTransactionCard(
              title: 'Transport Payment',
              amount: '800.00',
              date: 'Dec 18, 3:45 PM',
              type: 'M-PESA',
              isCredit: false,
            ),
            
            _buildTransactionCard(
              title: 'Loan Disbursement',
              amount: '15,000.00',
              date: 'Dec 15, 9:00 AM',
              type: 'Bank Transfer',
              isCredit: true,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPaymentOptions(context),
        backgroundColor: const Color(0xFF388E3C),
        child: const Icon(Icons.payment, color: Colors.white),
      ),
    );
  }

  void _showQRScanner(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code Scanner'),
        content: const Text('This will open the QR code scanner to make payments.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('QR Scanner coming soon!')),
              );
            },
            child: const Text('Open Scanner'),
          ),
        ],
      ),
    );
  }

  void _showAddMoney(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Money to Wallet',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (KSh)',
                border: OutlineInputBorder(),
                prefixText: 'KSh ',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'mpesa', child: Text('M-PESA')),
                DropdownMenuItem(value: 'bank', child: Text('Bank Transfer')),
                DropdownMenuItem(value: 'card', child: Text('Debit/Credit Card')),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add money functionality coming soon!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF388E3C),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Add Money', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSendMoney(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send Money',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Recipient Phone Number',
                border: OutlineInputBorder(),
                prefixText: '+254 ',
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (KSh)',
                border: OutlineInputBorder(),
                prefixText: 'KSh ',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Send money functionality coming soon!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF388E3C),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Send Money', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWithdraw(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Money'),
        content: const Text('Withdraw money from your digital wallet to M-PESA or bank account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Withdrawal functionality coming soon!')),
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _configureMpesa(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('M-PESA is already configured!')),
    );
  }

  void _configureAirtel(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Airtel Money configuration coming soon!')),
    );
  }

  void _configureBankTransfer(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bank transfer is already configured!')),
    );
  }

  void _configureCard(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Card payment configuration coming soon!')),
    );
  }

  void _showAllTransactions(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Full transaction history coming soon!')),
    );
  }

  void _showPaymentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Make Payment',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('Scan QR Code'),
              onTap: () {
                Navigator.pop(context);
                _showQRScanner(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Pay by Phone Number'),
              onTap: () {
                Navigator.pop(context);
                _showSendMoney(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Generate QR for Payment'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('QR generation coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}