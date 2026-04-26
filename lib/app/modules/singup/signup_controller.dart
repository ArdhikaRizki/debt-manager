import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isVerifyFeatureReady = false.obs;
  final isVerifying = false.obs;
  final isLoading = false.obs;

  // Call this after getting server response about email verification availability.
  void setVerifyFeatureReady(bool isReady) {
    isVerifyFeatureReady.value = isReady;
  }

  Future<void> verifyEmail() async {
    if (!isVerifyFeatureReady.value || isVerifying.value) return;

    isVerifying.value = true;
    try {
      // TODO: Replace with real verify email API call.
      await Future<void>.delayed(const Duration(milliseconds: 700));
    } finally {
      isVerifying.value = false;
    }
  }

  Future<void> signup() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      // TODO: Replace with real signup API call.
      await Future<void>.delayed(const Duration(milliseconds: 700));
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Default false: button stays disabled until server responds with verification capability.
    setVerifyFeatureReady(false);
  }

  @override
  void onClose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
