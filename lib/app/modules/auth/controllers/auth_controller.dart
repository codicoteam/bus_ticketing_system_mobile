import 'package:get/get.dart';
import '../../../data/models/auth_models.dart';
import '../../../data/services/auth_service.dart'; // Only one import

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<AuthResponse> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final signUpData = SignUpRequest(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
      );
      
      final response = await _authService.signUp(signUpData);
      
      if (!response.success) {
        errorMessage.value = response.message;
      }
      
      return response;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred.';
      return AuthResponse(
        success: false,
        message: 'An unexpected error occurred.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final loginData = LoginRequest(
        email: email,
        password: password,
      );
      
      final response = await _authService.signIn(loginData, rememberMe: rememberMe);
      
      if (!response.success) {
        errorMessage.value = response.message;
      }
    
      
      return response;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred.';
      return AuthResponse(
        success: false,
        message: 'An unexpected error occurred.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Add these methods to your AuthController
Future<AuthResponse> signInWithGoogle() async {
  try {
    isLoading.value = true;
    errorMessage.value = '';
    
    // TODO: Implement actual Google Sign-In
    // For now, return a mock response
    return AuthResponse(
      success: false,
      message: 'Google Sign-In not implemented yet',
    );
  } catch (e) {
    errorMessage.value = 'An unexpected error occurred.';
    return AuthResponse(
      success: false,
      message: 'An unexpected error occurred.',
    );
  } finally {
    isLoading.value = false;
  }
}

Future<AuthResponse> signInWithFacebook() async {
  try {
    isLoading.value = true;
    errorMessage.value = '';
    
    // TODO: Implement actual Facebook Sign-In
    // For now, return a mock response
    return AuthResponse(
      success: false,
      message: 'Facebook Sign-In not implemented yet',
    );
  } catch (e) {
    errorMessage.value = 'An unexpected error occurred.';
    return AuthResponse(
      success: false,
      message: 'An unexpected error occurred.',
    );
  } finally {
    isLoading.value = false;
  }
}

  void signOut() {
    _authService.signOut();
  }

  bool get isLoggedIn => _authService.isLoggedIn.value;
  String get authToken => _authService.authToken.value;
  UserData? get userData => _authService.userData.value;
}