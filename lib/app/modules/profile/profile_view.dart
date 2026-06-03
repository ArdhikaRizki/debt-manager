import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';
import 'profile_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});


  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
            // --- HEADER & FOTO PROFIL ---
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                ClipPath(
                  clipper: ProfileHeaderClipper(),
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    color: AppColors.primaryTeal,
                  ),
                ),
                const Positioned(
                  top: 55,
                  child: Text("Profile",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                
                // Foto Profil (Bisa diklik untuk ganti)
                Positioned(
                  bottom: -50,
                  child: GestureDetector(
                    onTap: () {
                      if (!controller.isUploading.value) {
                        controller.pickAndUploadPhoto();
                      }
                    },
                    child: Obx(() => Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.grey.shade200,
                            child: controller.localPhotoPath.value.isNotEmpty
                                ? ClipOval(
                                    child: Image.file(
                                      File(controller.localPhotoPath.value),
                                      width: 110,
                                      height: 110,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  )
                                : controller.photoPath.value.isNotEmpty
                                    ? ClipOval(
                                        child: Image.network(
                                          controller.getProxyAvatarUrl(),
                                          width: 110,
                                          height: 110,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.grey.shade400,
                                          ),
                                          loadingBuilder: (_, child, progress) {
                                            if (progress == null) return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: progress.expectedTotalBytes != null
                                                    ? progress.cumulativeBytesLoaded /
                                                        progress.expectedTotalBytes!
                                                    : null,
                                                strokeWidth: 2,
                                                color: AppColors.primaryTeal,
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : Icon(Icons.person, size: 50, color: Colors.grey.shade400),
                          ),

                        ),
                        // Overlay loading saat upload
                        if (controller.isUploading.value)
                          Positioned.fill(
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0x88000000),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              ),
                            ),
                          ),
                        // Ikon Kamera Kecil di pojok foto
                        if (!controller.isUploading.value)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: AppColors.primaryTeal, shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                            ),
                          ),
                      ],
                    )),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 60),

            // --- INFO USER (Reactive dengan Obx) ---
            Obx(() => Text(controller.username.value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
            )),
            const SizedBox(height: 5),
            Obx(() => Text(controller.email.value,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            )),
            
            const SizedBox(height: 30),

            // --- MENU LIST ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10, bottom: 10),
                    child: Text("Biodata", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                  Obx(() => _buildInfoItem(Icons.email_outlined, "Email", controller.email.value)),
                  Obx(() => _buildInfoItem(
                    Icons.verified_user_outlined, 
                    "Status Akun", 
                    controller.isVerified.value ? "Terverifikasi" : "Belum Terverifikasi",
                    statusColor: controller.isVerified.value ? Colors.green : Colors.orange,
                  )),
                  
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.only(left: 10, bottom: 10),
                    child: Text("Fitur", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                  _buildMenuItem(Icons.access_time_rounded, "Waktu", () => Get.toNamed(AppRoutes.timezone)),
                  _buildMenuItem(Icons.currency_exchange_rounded, "Kurs", () => Get.toNamed(AppRoutes.currency)),
                  _buildMenuItem(Icons.feedback_outlined, "Saran TPM", () => Get.toNamed(AppRoutes.feedback)),
                  
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.only(left: 10, bottom: 10),
                    child: Text("Keamanan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                  
                  // --- TOGGLE BIOMETRIK ---
                  Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, spreadRadius: 2, offset: const Offset(0, 3))
                      ],
                    ),
                    child: Obx(() => SwitchListTile(
                      activeColor: AppColors.primaryTeal,
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.fingerprint, color: AppColors.primaryTeal),
                      ),
                      title: const Text("Login Biometrik", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
                      value: controller.isBiometricActive.value,
                      onChanged: (bool value) => controller.toggleBiometric(value),
                    )),
                  ),

                  const SizedBox(height: 20),
                  _buildMenuItem(Icons.logout, "Logout", () => controller.logout(), isLogout: true),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ));
      }),
    );
    
  }

  // Widget bantuan untuk Biodata (Hanya Info)
  Widget _buildInfoItem(IconData icon, String title, String subtitle, {Color? statusColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, spreadRadius: 2, offset: const Offset(0, 3))],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.primaryTeal.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.primaryTeal),
        ),
        title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(
          subtitle, 
          style: TextStyle(
            fontWeight: FontWeight.w600, 
            color: statusColor ?? AppColors.textDark,
          ),
        ),
      ),
    );
  }

  // Widget bantuan untuk Menu yang bisa diklik
  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, spreadRadius: 2, offset: const Offset(0, 3))],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isLogout ? Colors.red.withOpacity(0.1) : AppColors.primaryTeal.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isLogout ? Colors.red : AppColors.primaryTeal),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: isLogout ? Colors.red : AppColors.textDark)),
        trailing: isLogout ? null : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }
}

// Clipper untuk kurva (sama seperti sebelumnya)
class ProfileHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(size.width / 2, size.height + 50, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}