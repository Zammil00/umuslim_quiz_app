import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/domain/usecases/login_user_usecase.dart';
import '../../../../app/domain/entities/user_entity.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final LoginUserUseCase _loginUserUseCase;

  LoginController(this._loginUserUseCase);

  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final user = await _loginUserUseCase(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      Get.snackbar(
        'Success',
        'Login successful',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Dismiss keyboard
      FocusManager.instance.primaryFocus?.unfocus();

      // Navigate based on role
      if (user.role == UserRole.admin) {
        // TODO: Redirect to Admin Dashboard when available
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.offAllNamed(Routes.HOME);
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      // Handle Supabase AuthException if possible, but generic string parsing helps too
      if (errorMessage.contains('Invalid login credentials')) {
        errorMessage = 'Invalid email or password';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void goToRegister() {
    Get.toNamed(Routes.REGISTER);
  }
}
