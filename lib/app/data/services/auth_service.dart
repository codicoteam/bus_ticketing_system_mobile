import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';

class AuthService extends GetxService {
  final RxBool isLoggedIn = false.obs;
  final RxString authToken = ''.obs;
  final Rx<UserData?> userData = Rx<UserData?>(null);

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _rememberMeKey = 'remember_me';

  final String baseUrl = 'https://busticketing-tq3o.onrender.com/api';

  @override
  Future<void> onInit() async {
    await loadAuthState();
    super.onInit();
  }

  Future<void> loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_rememberMeKey) ?? false;
    
    if (rememberMe) {
      final storedToken = prefs.getString(_tokenKey) ?? '';
      if (storedToken.isNotEmpty) {
        authToken.value = storedToken;
        final userString = prefs.getString(_userKey);
        if (userString != null) {
          try {
            final userMap = json.decode(userString);
            userData.value = UserData.fromJson(userMap);
            isLoggedIn.value = true;
          } catch (e) {
            print('Error loading user data: $e');
            await clearAuthData();
          }
        }
      }
    }
  }

  // Add this method to check if user is properly authenticated
  bool get isAuthenticated {
    return isLoggedIn.value && authToken.value.isNotEmpty;
  }

  // Update getAuthHeaders to handle unauthenticated state
  Map<String, String> getAuthHeaders() {
    if (!isAuthenticated) {
      print('WARNING: No valid authentication token found');
      return {
        'Content-Type': 'application/json',
      };
    }
    
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${authToken.value}',
    };
  }

  // Add method to clear auth data
  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_rememberMeKey);
    
    authToken.value = '';
    userData.value = null;
    isLoggedIn.value = false;
  }

  // KEEP ONLY ONE signOut METHOD - Remove the duplicate
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      await prefs.remove(_rememberMeKey);
      
      authToken.value = '';
      userData.value = null;
      isLoggedIn.value = false;
      
      print('User logged out successfully');
    } catch (e) {
      print('Error during sign out: $e');
      // Even if there's an error, reset the state
      authToken.value = '';
      userData.value = null;
      isLoggedIn.value = false;
    }
  }

  Future<AuthResponse> signUp(SignUpRequest signUpData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(signUpData.toJson()),
      );

      print('SignUp Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        // Success - parse the user data directly
        final Map<String, dynamic> responseData = json.decode(response.body);
        final authResponse = AuthResponse.fromSignUpJson(responseData);
        
        // For signup, we don't get a token immediately, user needs to login
        userData.value = authResponse.user;
        
        return authResponse;
      } else {
        // Error response
        final Map<String, dynamic> errorData = json.decode(response.body);
        return AuthResponse.fromErrorJson(errorData);
      }
    } catch (e) {
      print('SignUp Error: $e');
      return AuthResponse.error('Network error. Please check your connection.');
    }
  }

  Future<AuthResponse> signIn(LoginRequest loginData, {bool rememberMe = false}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(loginData.toJson()),
      );

      print('Login Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final authResponse = AuthResponse.fromLoginJson(responseData);
        
        if (authResponse.success && authResponse.token != null) {
          authToken.value = authResponse.token!;
          userData.value = authResponse.user;
          isLoggedIn.value = true;
          await _saveAuthData(rememberMe);
        }
        
        return authResponse;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        return AuthResponse.fromErrorJson(errorData);
      }
    } catch (e) {
      print('Login Error: $e');
      return AuthResponse.error('Network error. Please check your connection.');
    }
  }

  Future<void> _saveAuthData(bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, rememberMe);
    
    if (rememberMe && authToken.value.isNotEmpty) {
      await prefs.setString(_tokenKey, authToken.value);
      if (userData.value != null) {
        await prefs.setString(_userKey, json.encode(userData.value!.toJson()));
      }
    }
  }
}