import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/header_clipper.dart';
import 'login_controller.dart';
import '../../routes/app_routes.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: Column(
        children: [
          ClipPath(
            clipper: HeaderClipper(),
            child: Container(
              height: screenHeight * 0.28,
              width: double.infinity,
              color: AppColors.primaryTeal,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(30, 0, 30, 24 + bottomInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Sign in",
                          style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
                      Container(
                          height: 4,
                          width: 60,
                          color: AppColors.primaryTeal,
                          margin: const EdgeInsets.only(top: 5)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Column(
                    children: [
                      _buildInput(
                        "Email",
                        "demo@email.com",
                        Icons.email_outlined,
                        textController: controller.emailController,
                      ),
                      // --- PERUBAHAN DI SINI: Dibungkus Obx agar ikon mata dinamis ---
                      Obx(() => _buildInput(
                        "Password",
                        "enter your password",
                        Icons.lock_outline,
                        isPass: true,
                        obscureText: controller.isPasswordHidden.value,
                        textController: controller.passwordController,
                        onSuffixIconPressed: controller.togglePasswordVisibility,
                      )),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: Obx(
                          () => ElevatedButton(
                            onPressed: controller.isLoading.value ? null : controller.login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryTeal,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                            ),
                            child: Text(
                              controller.isLoading.value ? "Loading..." : "Login",
                              style: const TextStyle(
                                  fontSize: 18,
                                  color: AppColors.bgWhite,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.signup),
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an Account ? ",
                              style: const TextStyle(color: AppColors.textGrey),
                              children: [
                                TextSpan(
                                    text: "Sign up",
                                    style: TextStyle(
                                        color: AppColors.primaryTeal,
                                        fontWeight: FontWeight.bold))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // --- BIOMETRIC LOGIN BUTTON ---
                  Obx(() => controller.isBiometricAvailable.value
                    ? Column(
                        children: [
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: Divider(color: AppColors.textGrey.withOpacity(0.3))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: const Text("atau", style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                              ),
                              Expanded(child: Divider(color: AppColors.textGrey.withOpacity(0.3))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: controller.loginWithBiometric,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryTeal.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primaryTeal.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.fingerprint,
                                    size: 40,
                                    color: AppColors.primaryTeal,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Login dengan Sidik Jari",
                                  style: TextStyle(
                                    color: AppColors.primaryTeal,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- PERUBAHAN DI SINI: Menambahkan parameter obscureText dan onSuffixIconPressed ---
  Widget _buildInput(
    String label,
    String hint,
    IconData icon, {
    bool isPass = false,
    bool obscureText = false,
    TextEditingController? textController,
    VoidCallback? onSuffixIconPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
        TextField(
          controller: textController,
          obscureText: isPass ? obscureText : false, // Diatur berdasarkan state controller
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            // Suffix icon dibungkus IconButton agar bisa diklik
            suffixIcon: isPass
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    onPressed: onSuffixIconPressed,
                  )
                : null,
            enabledBorder:
                UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textGrey.withOpacity(0.4))),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryTeal)),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}