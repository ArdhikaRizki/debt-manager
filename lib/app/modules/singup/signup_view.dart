import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/header_clipper.dart';
import 'signup_controller.dart';


class SignupView extends StatelessWidget {
  SignupView({super.key});

  final SignupController controller = Get.put(SignupController());

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
              height: screenHeight * 0.18, // lebih kecil karena 4 field
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Sign up",
                          style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
                      Container(
                          height: 4,
                          width: 60,
                          color: AppColors.primaryTeal,
                          margin: EdgeInsets.only(top: 5)),
                    ],
                  ),
                  SizedBox(height: 16),
                  Column(
                    children: [
                      _buildEmailInputWithVerify(),
                      _buildInput(
                        "Username",
                        "your username",
                        Icons.person_outline,
                        textController: controller.usernameController,
                      ),
                      _buildInput(
                        "Password",
                        "enter your password",
                        Icons.lock_outline,
                        isPass: true,
                        textController: controller.passwordController,
                      ),
                      _buildInput(
                        "Confirm Password",
                        "confirm your password",
                        Icons.lock_outline,
                        isPass: true,
                        textController: controller.confirmPasswordController,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: Obx(
                          () => ElevatedButton(
                            onPressed:
                                controller.isLoading.value ? null : controller.signup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryTeal,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                            ),
                            child: Text(
                              controller.isLoading.value
                                  ? "Loading..."
                                  : "Create Account",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.bgWhite,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Center(
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: RichText(
                            text: TextSpan(
                              text: "Already have an Account! ",
                              style: TextStyle(color: AppColors.textGrey),
                              children: [
                                TextSpan(
                                    text: "Login",
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
                  SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailInputWithVerify() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Email",
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
        TextField(
          controller: controller.emailController,
          decoration: InputDecoration(
            hintText: "demo@email.com",
            prefixIcon: Icon(Icons.email_outlined, size: 20),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Obx(
                () => TextButton(
                  onPressed: (controller.isVerifyFeatureReady.value &&
                          !controller.isVerifying.value)
                      ? controller.verifyEmail
                      : null,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryTeal,
                    disabledForegroundColor:
                        AppColors.textGrey.withOpacity(0.7),
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  child: Text(
                    controller.isVerifying.value ? "Verifying..." : "Verify",
                  ),
                ),
              ),
            ),
            suffixIconConstraints: BoxConstraints(minWidth: 82, minHeight: 40),
            enabledBorder:
                UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textGrey.withOpacity(0.4))),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryTeal)),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildInput(
    String label,
    String hint,
    IconData icon, {
    bool isPass = false,
    TextEditingController? textController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
        TextField(
          controller: textController,
          obscureText: isPass,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            suffixIcon: isPass ? Icon(Icons.visibility_outlined, size: 20) : null,
            enabledBorder:
                UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textGrey.withOpacity(0.4))),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryTeal)),
          ),
        ),
        SizedBox(height: 10), // lebih kecil untuk signup
      ],
    );
  }
}