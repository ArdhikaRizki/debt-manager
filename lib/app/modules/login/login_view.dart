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
              height: screenHeight * 0.28, // proporsional
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
                      Text("Sign in",
                          style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
                      Container(
                          height: 4,
                          width: 60,
                          color: AppColors.primaryTeal,
                          margin: EdgeInsets.only(top: 5)),
                    ],
                  ),
                  SizedBox(height: 24),
                  Column(
                    children: [
                      _buildInput(
                        "Email",
                        "demo@email.com",
                        Icons.email_outlined,
                        textController: controller.emailController,
                      ),
                      _buildInput(
                        "Password",
                        "enter your password",
                        Icons.lock_outline,
                        isPass: true,
                        textController: controller.passwordController,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Icon(Icons.check_box_outline_blank, color: AppColors.primaryTeal),
                            SizedBox(width: 5),
                            Text("Remember Me",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark)),
                          ]),
                          Text("Forgot Password?",
                              style: TextStyle(
                                  color: AppColors.primaryTeal,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: Obx(
                          () => ElevatedButton(
                            onPressed:
                                controller.isLoading.value ? null : controller.login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryTeal,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                            ),
                            child: Text(
                              controller.isLoading.value ? "Loading..." : "Login",
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
                          onTap: () => Get.toNamed(AppRoutes.signup),
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an Account ? ",
                              style: TextStyle(color: AppColors.textGrey),
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
                  SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
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
        SizedBox(height: 12),
      ],
    );
  }
}