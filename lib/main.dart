import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/bindings/app_bindings.dart';
import 'app/modules/home/views/home_screen.dart';
import 'app/modules/auth/views/signup_screen.dart';
import 'app/modules/auth/views/login_screen.dart';
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
    return GetMaterialApp(
      title: 'Bus Ticket',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      initialBinding: AppBindings(),
      
      // 🎯 QUICK SWITCH - COMMENT/UNCOMMENT THESE LINES AS NEEDED:
      
      // Option 1: For normal flow (splash → onboarding → signup)
      //home: onboardingCompleted ? const SignUpScreen() : const SplashScreen(),
      
      // Option 2: Direct to HomePage (skip everything)
      home: const HomeScreen(),
      
      // Option 3: Direct to SignUpScreen 
      // home: const SignUpScreen(),
      
      // Option 4: Direct to LoginScreen
      // home: const LoginScreen(),
      
      // Option 5: Start from SplashScreen (full flow)
      // home: const SplashScreen(),

      getPages: [
        GetPage(name: '/splashscreen', page: () => const SplashScreen()),
        GetPage(name: '/onboarding2', page: () => const OnboardingScreen2()),
        GetPage(name: '/signup', page: () => const SignUpScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
      ],
    );
  }
}