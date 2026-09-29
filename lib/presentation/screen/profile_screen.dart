import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/dummy/auth_service.dart';
import 'login_screen.dart';
import 'service_history_screen.dart';
import 'multi_vehicle_booking_screen.dart';
import 'edit_profile_screen.dart';
import 'edit_address_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ═══════════════════════════════════════
  // DIALOG LOGOUT
  // ═══════════════════════════════════════
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
        title: Text("Logout",
            style: AppTextStyles.medium(weight: FontWeight.w700)),
        content:
            Text("Yakin ingin keluar dari akun?", style: AppTextStyles.small()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal",
                style: AppTextStyles.small(
                    color: AppColors.textSecondary, weight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () {
              AuthService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: Text("Logout",
                style: AppTextStyles.small(
                    color: AppColors.danger, weight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // BOTTOM SHEET INFO
  // ═══════════════════════════════════════
  void _showInfoBottomSheet({
    required String title,
    required String message,
    IconData icon = Icons.info_outline,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusXl),
          topRight: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      backgroundColor: AppColors.white,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.screenH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm + 2),
                  decoration: BoxDecoration(
                    color: AppColors.softOrange,
                    borderRadius: BorderRadius.circular(AppSpacing.sm + 2),
                  ),
                  child: Icon(icon, color: AppColors.primaryOrange, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(title,
                      style: AppTextStyles.medium(weight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              style: AppTextStyles.small(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.md + 2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                  elevation: 0,
                ),
                child: Text("Tutup",
                    style: AppTextStyles.medium(
                        color: Colors.white, weight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // NAVIGASI DENGAN REFRESH
  // ═══════════════════════════════════════
  Future<void> _navigateAndRefresh(Widget screen) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
    if (result == true && mounted) {
      setState(() {});
    }
  }

  // ═══════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final userName = user?.name ?? 'Guest';
    final userEmail = user?.email ?? '-';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ═══════════════════════════════════════
            // HEADER ORANYE DENGAN CURVE & PROFILE INFO
            // ═══════════════════════════════════════
            Stack(
              children: [
                // Background Oranye Bergelombang
                ClipPath(
                  clipper: _HeaderClipper(),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryOrange,
                          AppColors.discountPrice,
                        ],
                      ),
                    ),
                  ),
                ),

                // Konten Avatar, Nama, dan Email
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 80),
                  child: Column(
                    children: [
                      // Avatar
                      GestureDetector(
                        onTap: () => _showInfoBottomSheet(
                          title: 'Foto Profil',
                          message: 'Fitur ubah foto profil akan segera tersedia. '
                              'Saat ini Anda dapat menggunakan avatar default.',
                          icon: Icons.person,
                        ),
                        child: Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.background,
                                border:
                                    Border.all(color: Colors.white, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/poto.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: AppColors.softOrange,
                                    child: const Icon(
                                      Icons.person,
                                      color: AppColors.primaryOrange,
                                      size: 60,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryOrange,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2.5),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Nama
                      Text(
                        userName,
                        style: AppTextStyles.medium(
                          weight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ).copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: 4),

                      // Email
                      Text(
                        userEmail,
                        style: AppTextStyles.small(
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // ═══════════════════════════════════════
            // MENU SECTION
            // ═══════════════════════════════════════
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
              child: Column(
                children: [
                  // ═══ MENU 1: AKUN SAYA ═══
                  _buildMenuCard([
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      label: 'Edit Profil',
                      onTap: () => _navigateAndRefresh(
                        const EditProfileScreen(),
                      ),
                    ),
                    _buildMenuItem(
                      icon: Icons.two_wheeler_outlined,
                      label: 'Kendaraan Saya',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const MultiVehicleBookingScreen()),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.location_on_outlined,
                      label: 'Alamat',
                      onTap: () => _navigateAndRefresh(
                        const EditAddressScreen(),
                      ),
                    ),
                  ]),

                  const SizedBox(height: AppSpacing.lg),

                  // ═══ MENU 2: PENGATURAN ═══
                  _buildMenuCard([
                    _buildMenuItem(
                      icon: Icons.notifications_outlined,
                      label: 'Notifikasi',
                      onTap: () => _showInfoBottomSheet(
                        title: 'Notifikasi',
                        message: 'Pengaturan notifikasi akan segera tersedia.',
                        icon: Icons.notifications_outlined,
                      ),
                    ),
                    _buildMenuItem(
                      icon: Icons.lock_outline,
                      label: 'Ubah Password',
                      onTap: () => _navigateAndRefresh(
                        const ChangePasswordScreen(),
                      ),
                    ),
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      label: 'Bantuan',
                      onTap: () => _showInfoBottomSheet(
                        title: 'Pusat Bantuan',
                        message: 'Butuh bantuan? Hubungi kami:\n\n'
                            '📞 Telepon: (0274) 1234-5678\n'
                            '✉️ Email: support@servisinaja.id\n'
                            '💬 Chat: menu Pesan Servis\n\n'
                            'Jam operasional: Senin-Sabtu, 08:00-17:00 WIB',
                        icon: Icons.help_outline,
                      ),
                    ),
                    _buildMenuItem(
                      icon: Icons.info_outline,
                      label: 'Tentang Aplikasi',
                      onTap: () => _showInfoBottomSheet(
                        title: 'Servisin Aja',
                        message: 'Versi: 1.0.0\n'
                            'Build: 2024.11\n\n'
                            'Servisin Aja adalah aplikasi booking servis motor '
                            'dengan fitur antar-jemput dan multi-vehicle booking.\n\n'
                            '© 2024 PT Karya Putra Wardjito',
                        icon: Icons.info_outline,
                      ),
                    ),
                  ]),

                  const SizedBox(height: AppSpacing.xl),

                  // ═══ TOMBOL LOGOUT ═══
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _showLogoutDialog,
                      icon: const Icon(Icons.logout,
                          color: AppColors.danger, size: 18),
                      label: Text("Logout",
                          style: AppTextStyles.medium(
                              color: AppColors.danger,
                              weight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.lg - 2),
                        side: const BorderSide(color: AppColors.danger),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd)),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // WIDGET: Menu Card
  // ═══════════════════════════════════════
  Widget _buildMenuCard(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          return Column(
            children: [
              items[i],
              if (i < items.length - 1)
                const Divider(
                  height: 1,
                  indent: AppSpacing.md + 2,
                  endIndent: AppSpacing.lg,
                  color: AppColors.divider,
                ),
            ],
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════
  // WIDGET: Menu Item
  // ═══════════════════════════════════════
  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md + 2, vertical: AppSpacing.lg - 2),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.md + 2),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.small(
                    weight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textHint,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);

    path.quadraticBezierTo(
      size.width / 2,
      size.height + 20,
      size.width,
      size.height - 30,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}