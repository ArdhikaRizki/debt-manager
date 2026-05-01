import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});


  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
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
                    color: const Color(0xFFFF8A8A),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 20,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Get.back(),
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
                    onTap: () => controller.pickAndUploadPhoto(),
                    child: Stack(
                      children: [
                        Obx(() => Container(
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
                            // Jika photoPath kosong, pakai default icon. Jika ada, pakai gambar (Network/File)
                            backgroundImage: controller.photoPath.value.isEmpty 
                                ? null 
                                : NetworkImage(controller.photoPath.value),
                            child: controller.photoPath.value.isEmpty 
                                ? const Icon(Icons.person, size: 50, color: Colors.grey) 
                                : null,
                          ),
                        )),
                        // Ikon Kamera Kecil di pojok foto
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: Color(0xFFFF8A8A), shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 60),

            // --- INFO USER (Reactive dengan Obx) ---
            Obx(() => Text(controller.username.value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
            )),
            const SizedBox(height: 5),
            Obx(() => Text(controller.bio.value,
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
                  _buildInfoItem(Icons.email_outlined, "Email", controller.email.value),
                  _buildInfoItem(Icons.verified_user_outlined, "Status Akun", "Verified"), // Sesuai is_verified di database
                  
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
                      activeColor: const Color(0xFFFF8A8A),
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8A8A).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.fingerprint, color: Color(0xFFFF8A8A)),
                      ),
                      title: const Text("Login Biometrik", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                      value: controller.isBiometricActive.value,
                      onChanged: (bool value) => controller.toggleBiometric(value),
                    )),
                  ),

                  _buildMenuItem(Icons.lock_outline, "Ubah Password", () {}),
                  const SizedBox(height: 20),
                  _buildMenuItem(Icons.logout, "Logout", () => controller.logout(), isLogout: true),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Widget bantuan untuk Biodata (Hanya Info)
  Widget _buildInfoItem(IconData icon, String title, String subtitle) {
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
          decoration: BoxDecoration(color: const Color(0xFFFF8A8A).withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: const Color(0xFFFF8A8A)),
        ),
        title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(subtitle, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF333333))),
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
            color: isLogout ? Colors.red.withOpacity(0.1) : const Color(0xFFFF8A8A).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isLogout ? Colors.red : const Color(0xFFFF8A8A)),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: isLogout ? Colors.red : const Color(0xFF333333))),
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