// Combined auth models in one file
class SignUpRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phone;
  final String role;

  SignUpRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phone,
    this.role = 'customer',
  });

  Map<String, dynamic> toJson() => {
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "password": password,
    "phone": phone,
    "role": role,
  };
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    "email": email,
    "password": password,
  };
}

// Updated to match your actual API response
class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final UserData? user;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  // For successful signup (201 response)
  factory AuthResponse.fromSignUpJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: true,
      message: 'User registered successfully',
      user: UserData.fromJson(json),
    );
  }

  // For successful login (200 response)
  factory AuthResponse.fromLoginJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? 'Login successful',
      token: json['token'],
      user: json['user'] != null ? UserData.fromJson(json['user']) : null,
    );
  }

  // For error responses
  factory AuthResponse.fromErrorJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: false,
      message: json['message'] ?? 'An error occurred',
    );
  }

  // For network errors
  factory AuthResponse.error(String errorMessage) {
    return AuthResponse(
      success: false,
      message: errorMessage,
    );
  }
}

class UserData {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserData({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'customer',
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'role': role,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}