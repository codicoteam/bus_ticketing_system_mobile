import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/bindings/app_bindings.dart';
import 'app/modules/home/views/home_screen.dart';
import 'app/modules/auth/views/signup_screen.dart';
import 'app/modules/auth/views/login_screen.dart'; // Add this import
import 'app/modules/welcome_screens/views/onboarding_screen2.dart';
import 'app/modules/welcome_screens/views/splash_screen1.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

  runApp(BusTicketApp(onboardingCompleted: onboardingCompleted));
}

class BusTicketApp extends StatelessWidget {
  final bool onboardingCompleted;

  const BusTicketApp({super.key, required this.onboardingCompleted});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp( // Changed from MaterialApp to GetMaterialApp
      title: 'Bus Ticket',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      initialBinding: AppBindings(), // Add GetX bindings
      
      // Using GetX navigation instead of traditional routes
      home: onboardingCompleted ? const SignUpScreen() : const SplashScreen(),
      
      // Optional: You can still use named routes alongside GetX
      getPages: [
        GetPage(name: '/splashscreen', page: () => const SplashScreen()),
        GetPage(name: '/onboarding2', page: () => const OnboardingScreen2()),
        GetPage(name: '/signup', page: () => const SignUpScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()), // Add login route
        GetPage(name: '/home', page: () => const HomePage()),
      ],
    );
  }
}