import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/home_page.dart';
import 'widget/signup_page.dart';
import 'widget/onboarding_screen2.dart';
import 'widget/splash_screen1.dart';

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
    return MaterialApp(
      title: 'Bus Ticket',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),

      // ✅ No 'home' because we're using routes + initialRoute
      initialRoute: onboardingCompleted ? '/signup' : '/splashscreen',

      routes: {
        '/splashscreen': (context) => const SplashScreen(),
        '/onboarding2': (context) => const OnboardingScreen2(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
