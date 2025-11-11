// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../ticket/views/ticket_screen.dart';

class BookingPage extends StatefulWidget {
  final String busName;
  final String price;
  final String? departure;
  final String? arrival;
  final String? date;


  const BookingPage({
    super.key,
    required this.busName,
    required this.price,
    this.departure,
    this.arrival,
    this.date,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final seatsCtrl = TextEditingController(text: '1');
  final cardCtrl = TextEditingController();
  final expiryCtrl = TextEditingController();
  final cvvCtrl = TextEditingController();
  final nameOnCardCtrl = TextEditingController();

  bool _isProcessing = false;
  String _selectedPaymentMethod = 'card';

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    seatsCtrl.dispose();
    cardCtrl.dispose();
    expiryCtrl.dispose();
    cvvCtrl.dispose();
    nameOnCardCtrl.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().split(' ').length < 2) {
      return 'Please enter your full name (first and last)';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (value.replaceAll(RegExp(r'[^\d]'), '').length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? _validateSeats(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter number of seats';
    }
    final seats = int.tryParse(value);
    if (seats == null || seats < 1) {
      return 'Please enter a valid number';
    }
    if (seats > 10) {
      return 'Maximum 10 seats per booking';
    }
    return null;
  }

  String? _validateCard(String? value) {
    if (_selectedPaymentMethod != 'card') return null;
    if (value == null || value.isEmpty) {
      return 'Please enter card number';
    }
    final cleaned = value.replaceAll(' ', '');
    if (cleaned.length < 13 || cleaned.length > 19) {
      return 'Please enter a valid card number';
    }
    return null;
  }

  String? _validateExpiry(String? value) {
    if (_selectedPaymentMethod != 'card') return null;
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
      return 'Invalid format';
    }
    final parts = value.split('/');
    final month = int.tryParse(parts[0]);
    if (month == null || month < 1 || month > 12) {
      return 'Invalid month';
    }
    return null;
  }

  String? _validateCVV(String? value) {
    if (_selectedPaymentMethod != 'card') return null;
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    if (value.length < 3 || value.length > 4) {
      return 'Invalid CVV';
    }
    return null;
  }

  double _calculateTotal() {
    final pricePerSeat =
        double.tryParse(widget.price.replaceAll('\$', '')) ?? 0;
    final seats = int.tryParse(seatsCtrl.text) ?? 1;
    return pricePerSeat * seats;
  }

  Future<void> _processBooking() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isProcessing = true);

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TicketPage(
          name: nameCtrl.text,
          bus: widget.busName,
          price: _calculateTotal().toStringAsFixed(2),
          seats: seatsCtrl.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text("Complete Booking"),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Trip Summary Card
                    _buildTripSummaryCard(),
                    const SizedBox(height: 20),

                    // Passenger Details
                    _buildSectionHeader("Passenger Details", Icons.person),
                    const SizedBox(height: 12),
                    _buildCard(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: nameCtrl,
                            validator: _validateName,
                            textCapitalization: TextCapitalization.words,
                            decoration: _inputDecoration(
                              "Full Name",
                              "John Doe",
                              Icons.person_outline,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: emailCtrl,
                            validator: _validateEmail,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(
                              "Email Address",
                              "john.doe@example.com",
                              Icons.email_outlined,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: phoneCtrl,
                            validator: _validatePhone,
                            keyboardType: TextInputType.phone,
                            decoration: _inputDecoration(
                              "Phone Number",
                              "+1 (555) 123-4567",
                              Icons.phone_outlined,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: seatsCtrl,
                            validator: _validateSeats,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: _inputDecoration(
                              "Number of Seats",
                              "1",
                              Icons.event_seat_outlined,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Payment Method Selection
                    _buildSectionHeader("Payment Method", Icons.payment),
                    const SizedBox(height: 12),
                    _buildCard(
                      child: Column(
                        children: [
                          _buildPaymentOption(
                            'card',
                            'Credit/Debit Card',
                            Icons.credit_card,
                          ),
                          const Divider(height: 1),
                          _buildPaymentOption(
                            'mobile',
                            'Mobile Money',
                            Icons.phone_android,
                          ),
                          const Divider(height: 1),
                          _buildPaymentOption(
                            'cash',
                            'Pay at Counter',
                            Icons.money,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Payment Details (conditional)
                    if (_selectedPaymentMethod == 'card') ...[
                      _buildSectionHeader("Card Details", Icons.credit_card),
                      const SizedBox(height: 12),
                      _buildCard(
                        child: Column(
                          children: [
                            TextFormField(
                              controller: nameOnCardCtrl,
                              validator: _validateName,
                              textCapitalization: TextCapitalization.words,
                              decoration: _inputDecoration(
                                "Name on Card",
                                "John Doe",
                                Icons.person_outline,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: cardCtrl,
                              validator: _validateCard,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                _CardNumberFormatter(),
                              ],
                              decoration: _inputDecoration(
                                "Card Number",
                                "1234 5678 9012 3456",
                                Icons.credit_card,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: expiryCtrl,
                                    validator: _validateExpiry,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      _ExpiryDateFormatter(),
                                    ],
                                    decoration: _inputDecoration(
                                      "Expiry Date",
                                      "MM/YY",
                                      Icons.calendar_today,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: cvvCtrl,
                                    validator: _validateCVV,
                                    keyboardType: TextInputType.number,
                                    obscureText: true,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(4),
                                    ],
                                    decoration: _inputDecoration(
                                      "CVV",
                                      "123",
                                      Icons.lock_outline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ] else if (_selectedPaymentMethod == 'mobile') ...[
                      _buildSectionHeader(
                        "Mobile Money Details",
                        Icons.phone_android,
                      ),
                      const SizedBox(height: 12),
                      _buildCard(
                        child: Column(
                          children: [
                            TextFormField(
                              keyboardType: TextInputType.phone,
                              decoration: _inputDecoration(
                                "Mobile Money Number",
                                "+1 (555) 123-4567",
                                Icons.phone_outlined,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 20,
                                    color: Colors.blue[700],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "You'll receive a payment prompt on your phone",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ] else if (_selectedPaymentMethod == 'cash') ...[
                      const SizedBox(height: 12),
                      _buildCard(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 48,
                                color: Colors.orange[700],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Pay at Counter",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Please pay at the bus terminal counter at least 30 minutes before departure",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Terms and Conditions
                    _buildCard(
                      child: Row(
                        children: [
                          Icon(
                            Icons.verified_user,
                            size: 20,
                            color: Colors.green[600],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Your payment is secured with 256-bit encryption",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // Bottom Payment Summary
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTripSummaryCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.directions_bus,
                  color: Colors.blue[700],
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.busName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.date != null)
                      Text(
                        widget.date!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.departure != null && widget.arrival != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "From",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        widget.departure!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward, color: Colors.grey[400]),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "To",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        widget.arrival!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Price per seat",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                "\$${widget.price.replaceAll('\$', '')}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildPaymentOption(String value, String title, IconData icon) {
    final isSelected = _selectedPaymentMethod == value;
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.blue : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final total = _calculateTotal();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Amount",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Text(
                      "\$${total.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isProcessing ? null : _processBooking,
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Row(
                          children: [
                            Text(
                              "Confirm & Pay",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Card number formatter
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i + 1 != text.length) {
        buffer.write(' ');
      }
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

// Expiry date formatter
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    if (text.length > 4) {
      return oldValue;
    }
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 1 && text.length > 2) {
        buffer.write('/');
      }
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
