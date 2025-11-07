import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:busticket/main.dart';

void main() {
  testWidgets('Onboarding and SignUp Screen Test', (WidgetTester tester) async {
    // Initialize shared preferences
    SharedPreferences.setMockInitialValues({
      'onboarding_completed': false, // Set this to false to show onboarding
    });

    // Build our app and trigger a frame
    await tester.pumpWidget(const BusTicketApp(onboardingCompleted: false));

    // Verify that the OnboardingScreen is displayed
    expect(
      find.text("Welcome"),
      findsOneWidget,
    ); // Adjust this based on your onboarding screen's title

    // Simulate tapping the 'Get Started' button
    await tester.tap(find.text("Get Started"));
    await tester.pumpAndSettle(); // Wait for animations to finish

    // Verify that the SignUpPage is displayed
    expect(
      find.text("Sign Up"),
      findsOneWidget,
    ); // Adjust this based on your sign-up page's title
  });
}
