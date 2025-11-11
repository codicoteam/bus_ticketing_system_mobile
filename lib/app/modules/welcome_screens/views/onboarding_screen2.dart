// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../auth/views/signup_screen.dart'; // Ensure this file exists for navigation

class OnboardingScreen2 extends StatefulWidget {
  const OnboardingScreen2({super.key});

  @override
  State<OnboardingScreen2> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen2> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Book Your Journey',
      description:
          'Search and book bus tickets to thousands of destinations with just a few taps.',
      icon: Icons.search,
    ),
    OnboardingData(
      title: 'Choose Your Seat',
      description:
          'Select your preferred seat from our interactive seat map and travel comfortably.',
      icon: Icons.event_seat,
    ),
    OnboardingData(
      title: 'Secure Payment',
      description:
          'Pay safely with multiple payment options and get instant ticket confirmation.',
      icon: Icons.payment,
    ),
    OnboardingData(
      title: 'Travel Safely',
      description:
          'Show your digital ticket and enjoy a smooth, hassle-free journey.',
      icon: Icons.verified_user,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with logo and Skip
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // FIX: Changed Image.network to Image.asset
                  Image.asset(
                    'assets/images/bus_ticket_logo.png',
                    height: 40,
                    // The errorBuilder is good for a fallback, but won't be called if the asset exists.
                    errorBuilder: (context, error, stackTrace) {
                      // Optional: print error to console for debugging
                      // print('Error loading image: $error');
                      return const Icon(
                        Icons.directions_bus,
                        size: 40,
                        color: Color(0xFF1976D2),
                      );
                    },
                  ),
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: () => _navigateToSignIn(context),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Color(0xFF1976D2),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Onboarding Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) => _buildPage(_pages[index]),
              ),
            ),

            // Dots + Next button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _buildDot(index),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _pages.length - 1) {
                          _navigateToSignIn(context);
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Onboarding Page Builder ---
  Widget _buildPage(OnboardingData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(35),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1976D2).withOpacity(0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(data.icon, size: 80, color: Colors.white),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      data.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      data.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Dots Indicator ---
  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? const Color(0xFF1976D2)
            : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // --- Navigation ---
  void _navigateToSignIn(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
    );
  }
}

// --- Onboarding Data Model ---
class OnboardingData {
  final String title;
  final String description;
  final IconData icon;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
  });
}
