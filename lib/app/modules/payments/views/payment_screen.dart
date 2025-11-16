// lib/app/modules/payment/views/payment_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../controllers/payment_controller.dart';

class PaymentScreen extends StatefulWidget {
  final String bookingId;
  final double amount;
  final String busName;
  final String? departure;
  final String? arrival;
  final String? date;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.amount,
    required this.busName,
    this.departure,
    this.arrival,
    this.date,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentController _paymentController = Get.find<PaymentController>();
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();

  String _selectedPaymentMethod = 'ecocash';

  @override
  void initState() {
    super.initState();
    // Pre-fill with a sample number
    _mobileController.text = '0771234567';
  }

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  String? _validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your mobile number';
    }

    // Remove all non-digit characters including +, spaces, etc.
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');

    String processedNumber = cleaned;

    // Handle international format: +263780197542 → 263780197542 → 0780197542
    if (cleaned.startsWith('263') && cleaned.length == 12) {
      processedNumber = '0${cleaned.substring(3)}'; // Add leading 0
    }

    // Check if we have a valid 10-digit Zimbabwean number
    if (processedNumber.length != 10) {
      return 'Please enter a valid 10-digit mobile number (e.g., 0781234567)';
    }

    // Check if it starts with 07 (all Zimbabwean mobile numbers)
    if (!processedNumber.startsWith('07')) {
      return 'Please enter a valid Zimbabwean mobile number (starting with 07)';
    }

    // Check if it's a valid EcoCash network prefix (second digit)
    final validSecondDigits = ['7', '8', '1', '3']; // 077, 078, 071, 073
    final secondDigit = processedNumber[1];

    if (!validSecondDigits.contains(secondDigit)) {
      return 'Please enter a valid EcoCash number (077, 078, 071, or 073)';
    }

    return null;
  }

  Future<void> _processPayment() async {
  final AuthService authService = Get.find<AuthService>();
  
  // Debug: Check authentication status
  print('User logged in: ${authService.isLoggedIn.value}');
  print('Auth token: ${authService.authToken.value}');
  print('Is authenticated: ${authService.isAuthenticated}');

  if (!_formKey.currentState!.validate()) {
    return;
  }

  if (_selectedPaymentMethod == 'ecocash') {
    await _paymentController.initiateEcoCashPayment(
      bookingId: widget.bookingId,
      mobileNumber: _mobileController.text,
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text("Payment"),
        centerTitle: true,
      ),
      body: Obx(() {
        return Stack(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Booking Summary
                          _buildBookingSummary(),
                          const SizedBox(height: 24),

                          // Payment Method Selection
                          _buildSectionHeader("Payment Method", Icons.payment),
                          const SizedBox(height: 12),
                          _buildPaymentMethodSelection(),
                          const SizedBox(height: 24),

                          // Payment Details
                          if (_selectedPaymentMethod == 'ecocash')
                            _buildEcoCashDetails(),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Action Bar
                  _buildBottomActionBar(),
                ],
              ),
            ),

            // Loading Overlay
            if (_paymentController.isLoading.value ||
                _paymentController.isPolling.value)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Processing Payment...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_paymentController.isPolling.value) ...const [
                        SizedBox(height: 8),
                        Text(
                          'Waiting for payment confirmation...',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildBookingSummary() {
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
                  Icons.confirmation_number,
                  color: Colors.blue[700],
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Booking Reference",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      widget.bookingId,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.departure != null && widget.arrival != null) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.departure!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Departure",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                        widget.arrival!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      Text(
                        "Arrival",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Amount",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "\$${widget.amount.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
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

  Widget _buildPaymentMethodSelection() {
    // Define payment methods with proper typing
    final List<Map<String, String>> paymentMethods = [
      {'value': 'ecocash', 'name': 'EcoCash', 'icon': 'Icons.phone_android'},
      {
        'value': 'card',
        'name': 'Credit/Debit Card',
        'icon': 'Icons.credit_card',
      },
      {'value': 'cash', 'name': 'Pay at Counter', 'icon': 'Icons.money'},
    ];

    return Container(
      width: double.infinity,
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
      child: Column(
        children: paymentMethods.map((method) {
          final String methodValue =
              method['value']!; // Explicitly cast to String
          final String methodName =
              method['name']!; // Explicitly cast to String
          final String iconName = method['icon']!; // Explicitly cast to String

          final isSelected = _selectedPaymentMethod == methodValue;

          // Convert icon string to IconData
          IconData getIconData(String iconName) {
            switch (iconName) {
              case 'Icons.phone_android':
                return Icons.phone_android;
              case 'Icons.credit_card':
                return Icons.credit_card;
              case 'Icons.money':
                return Icons.money;
              default:
                return Icons.payment;
            }
          }

          return InkWell(
            onTap: () => setState(() => _selectedPaymentMethod = methodValue),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                border: isSelected
                    ? Border.all(color: Colors.blue, width: 2)
                    : null,
                borderRadius: BorderRadius.circular(12),
                color: isSelected ? Colors.blue[50] : Colors.transparent,
              ),
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
                    getIconData(iconName),
                    color: isSelected ? Colors.blue : Colors.grey[600],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    methodName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected ? Colors.blue : Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEcoCashDetails() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "EcoCash Payment",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _mobileController,
            validator: _validateMobile,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: "EcoCash Number",
              hintText: "0781234567 or +263781234567", // Updated hint
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Accepted formats:",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "• 0771234567, 0781234567, 0711234567, 0731234567",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange[700],
                        ),
                      ),
                      Text(
                        "• +263771234567, +263781234567",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "You will receive a payment prompt on your EcoCash number.",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
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
            // Error Message
            if (_paymentController.errorMessage.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _paymentController.errorMessage.value,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red[700], size: 20),
                      onPressed: () =>
                          _paymentController.errorMessage.value = '',
                    ),
                  ],
                ),
              ),

            // Success Message
            if (_paymentController.successMessage.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _paymentController.successMessage.value,
                        style: TextStyle(color: Colors.green[700]),
                      ),
                    ),
                  ],
                ),
              ),

            // Payment Status
            if (_paymentController.currentPaymentStatus.value != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: _paymentController.currentPaymentStatus.value!.isPaid
                      ? Colors.green[50]
                      : Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _paymentController.currentPaymentStatus.value!.isPaid
                        ? Colors.green[200]!
                        : Colors.orange[200]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _paymentController.currentPaymentStatus.value!.isPaid
                          ? Icons.check_circle
                          : Icons.pending,
                      color:
                          _paymentController.currentPaymentStatus.value!.isPaid
                          ? Colors.green[700]
                          : Colors.orange[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Payment Status: ${_paymentController.currentPaymentStatus.value!.status.toUpperCase()}',
                        style: TextStyle(
                          color:
                              _paymentController
                                  .currentPaymentStatus
                                  .value!
                                  .isPaid
                              ? Colors.green[700]
                              : Colors.orange[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Pay Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed:
                  _paymentController.isLoading.value ||
                      _paymentController.isPolling.value
                  ? null
                  : _processPayment,
              child: SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_paymentController.isLoading.value ||
                        _paymentController.isPolling.value)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    else
                      const Icon(Icons.payment, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _paymentController.isPolling.value
                          ? "Waiting for Payment..."
                          : "Pay \$${widget.amount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
