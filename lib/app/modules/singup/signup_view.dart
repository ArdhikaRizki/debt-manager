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
                      // OTP field — muncul setelah verify berhasil
                      Obx(() {
                        if (!controller.isOtpSent.value) {
                          return SizedBox.shrink();
                        }
                        return _buildOtpSection();
                      }),
                      Obx(() {
                        if (!controller.isOtpVerified.value) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          children: [
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
                        );
                      }),
                    ],
                  ),
                  SizedBox(height: 16),
                  Column(
                    children: [
                      Obx(() {
                        if (!controller.isOtpVerified.value) {
                          return const SizedBox.shrink();
                        }

                        return SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.signup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryTeal,
                              disabledBackgroundColor:
                                  AppColors.textGrey.withOpacity(0.3),
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
                        );
                      }),
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
        Obx(
          () => TextField(
            controller: controller.emailController,
            enabled: !controller.isOtpSent.value, // disable setelah OTP terkirim
            decoration: InputDecoration(
              hintText: "demo@email.com",
              prefixIcon: Icon(Icons.email_outlined, size: 20),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: controller.isOtpSent.value
                    // Sudah terverifikasi → tampilkan icon centang
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green, size: 22),
                          SizedBox(width: 4),
                          TextButton(
                            onPressed: controller.isVerifying.value
                                ? null
                                : controller.resendOtp,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryTeal,
                              textStyle:
                                  TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            child: Text("Resend"),
                          ),
                        ],
                      )
                    // Belum verify → tampilkan tombol Verify
                    : TextButton(
                        onPressed: controller.isVerifying.value
                            ? null
                            : controller.verifyEmail,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryTeal,
                          disabledForegroundColor:
                              AppColors.textGrey.withOpacity(0.7),
                          textStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        child: Text(
                          controller.isVerifying.value
                              ? "Sending..."
                              : "Verify",
                        ),
                      ),
              ),
              suffixIconConstraints: BoxConstraints(minWidth: 82, minHeight: 40),
              enabledBorder:
                  UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textGrey.withOpacity(0.4))),
              disabledBorder:
                  UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textGrey.withOpacity(0.2))),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryTeal)),
            ),
          ),
        ),
        // Status text
        Obx(() {
          if (controller.verifyStatusText.value.isEmpty) {
            return SizedBox(height: 10);
          }
          return Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 6),
            child: Text(
              controller.verifyStatusText.value,
              style: TextStyle(
                fontSize: 12,
                color: controller.isOtpSent.value
                    ? Colors.green.shade600
                    : Colors.red.shade400,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOtpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Kode OTP",
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
        Obx(() {
          final otpVerified = controller.isOtpVerified.value;

          return TextField(
            controller: controller.otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            enabled: !otpVerified,
            decoration: InputDecoration(
              hintText: "Masukkan 6 digit OTP",
              counterText: '', // hide counter
              prefixIcon: Icon(Icons.pin_outlined, size: 20),
              errorText: controller.otpErrorText.value.isEmpty
                  ? null
                  : controller.otpErrorText.value,
              suffixIcon: otpVerified
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: AppColors.textGrey.withOpacity(0.4))),
              disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green.shade300)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryTeal)),
              errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.shade400)),
              focusedErrorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.shade400)),
            ),
          );
        }),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.isOtpVerified.value) {
            return const SizedBox.shrink();
          }

          return SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: controller.isCheckingOtp.value
                  ? null
                  : controller.validateOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                disabledBackgroundColor: AppColors.textGrey.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                controller.isCheckingOtp.value ? "Checking..." : "Validasi OTP",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
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