import 'package:flutter/material.dart';
import '../../app/data/services/api_service.dart';
import '../theme/app_colors.dart';

/// Widget reusable untuk menampilkan foto profil anggota via backend proxy.
///
/// Usage:
///   MemberAvatar(userId: member.userId, photoPath: member.user?.photoPath, radius: 22)
class MemberAvatar extends StatelessWidget {
  final int userId;
  final String? photoPath;   // Jika null/kosong → tampilkan icon person
  final double radius;
  final String? fallbackLabel; // Huruf pertama nama (opsional)

  const MemberAvatar({
    super.key,
    required this.userId,
    this.photoPath,
    this.radius = 22,
    this.fallbackLabel,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoPath != null && photoPath!.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryTeal.withOpacity(0.1),
      child: hasPhoto
          ? ClipOval(
              child: Image.network(
                // Gunakan static helper agar tidak perlu instance controller
                ApiService.buildAvatarProxyUrl(userId),
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                // Tampil loading placeholder kecil
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return SizedBox(
                    width: radius * 2,
                    height: radius * 2,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                  );
                },
                // Fallback jika error (token expired, dsb)
                errorBuilder: (_, __, ___) => _buildFallback(),
              ),
            )
          : _buildFallback(),
    );
  }

  Widget _buildFallback() {
    if (fallbackLabel != null && fallbackLabel!.isNotEmpty) {
      return Text(
        fallbackLabel![0].toUpperCase(),
        style: TextStyle(
          fontSize: radius * 0.85,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryTeal,
        ),
      );
    }
    return Icon(
      Icons.person,
      size: radius,
      color: AppColors.primaryTeal,
    );
  }
}
