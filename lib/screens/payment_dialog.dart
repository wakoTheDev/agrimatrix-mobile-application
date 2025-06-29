import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentDialog extends StatefulWidget {
  final int amount;
  final VoidCallback onPaymentSuccess;

  const PaymentDialog({
    super.key,
    required this.amount,
    required this.onPaymentSuccess,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  String _selectedPaymentMethod = 'M-Pesa';
  final _phoneController = TextEditingController();

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'M-Pesa', 'icon': Icons.phone_android, 'color': Colors.green},
    {'name': 'Airtel Money', 'icon': Icons.phone_android, 'color': Colors.red},
    {'name': 'Card Payment', 'icon': Icons.credit_card, 'color': Colors.blue},
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2B5320),
              ),
            ),
            const SizedBox(height: 16),
            
            Text(
              'Amount: KSh ${widget.amount}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Payment Methods
            ..._paymentMethods.map((method) {
              return RadioListTile<String>(
                title: Row(
                  children: [
                    Icon(method['icon'], color: method['color']),
                    const SizedBox(width: 8),
                    Text(method['name'], style: GoogleFonts.poppins()),
                  ],
                ),
                value: method['name'],
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() => _selectedPaymentMethod = value!);
                },
              );
            }).toList(),

            if (_selectedPaymentMethod != 'Card Payment') ...[
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: GoogleFonts.poppins(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixText: '+254 ',
                ),
              ),
            ],

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: GoogleFonts.poppins()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B5320),
                    ),
                    child: Text(
                      'Pay Now',
                      style: GoogleFonts.poppins(color: Colors.white),
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

  void _processPayment() {
    // Simulate payment processing
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Simulate delay
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); 
      Navigator.pop(context); 
      widget.onPaymentSuccess();
    });
  }
}
