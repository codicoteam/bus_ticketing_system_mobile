// lib/app/modules/profile/controllers/profile_controller.dart
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';

class ProfileController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  
  final RxBool isLoading = false.obs;

  // You can add more profile-related methods here later
  // For example: update profile, change password, etc.
}