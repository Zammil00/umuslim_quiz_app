import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/domain/entities/user_entity.dart';
import '../../../../app/domain/usecases/register_user_usecase.dart';

class RegisterController extends GetxController {
  final RegisterUserUseCase _registerUserUseCase;

  RegisterController(this._registerUserUseCase);

  final formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Observable for Role selection
  final Rx<UserRole> selectedRole = UserRole.user.obs;

  final isLoading = false.obs;

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void setRole(UserRole role) {
    selectedRole.value = role;
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await _registerUserUseCase(
        email: emailController.text.trim(),
        password: passwordController.text,
        fullName: fullNameController.text.trim(),
        role: selectedRole.value,
      );

      Get.snackbar(
        'Success',
        'Registration successful',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate to Home or Login
      Get.offAllNamed('/home'); // Or whatever the initial route is
    } catch (e) {
      print(
        'Registration Error: $e',
      ); // Print full error to console for debugging
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5), // User needs time to read
      );
    } finally {
      isLoading.value = false;
    }
  }
}
