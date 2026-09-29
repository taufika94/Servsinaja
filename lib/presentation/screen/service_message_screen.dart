import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import 'chat_history_screen.dart';

class ServiceMessageScreen extends StatelessWidget {
  const ServiceMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
                AppSpacing.screenH, AppSpacing.lg, AppSpacing.screenH, 0),
            child: Row(
              children: [
                Text("Pesan Servis",
                    style: AppTextStyles.medium(weight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
              children: [
                _buildMessageTile(
                  context,
                  name: 'Admin Servisin',
                  message: 'Servis motor Anda sedang diproses ya Kak 😊',
                  time: '10:30',
                  unread: 2,
                  icon: Icons.support_agent,
                  color: AppColors.primaryOrange,
                ),
                _buildMessageTile(
                  context,
                  name: 'Mekanik Budi',
                  message: 'Oli MPX sudah diganti, lanjut cek rem depan',
                  time: '09:15',
                  unread: 0,
                  icon: Icons.engineering,
                  color: Colors.blue,
                ),
                _buildMessageTile(
                  context,
                  name: 'Servisin Aja - Babarsari',
                  message: 'Motor Anda siap diambil besok pagi ya',
                  time: 'Kemarin',
                  unread: 0,
                  icon: Icons.store,
                  color: AppColors.success,
                ),
                _buildMessageTile(
                  context,
                  name: 'Notifikasi Sistem',
                  message: 'Tiket SRV-2024-001250 berhasil dibuat',
                  time: '2 hari lalu',
                  unread: 0,
                  icon: Icons.notifications_active,
                  color: AppColors.warning,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageTile(
    BuildContext context, {
    required String name,
    required String message,
    required String time,
    required int unread,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatHistoryScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md + 2),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(2, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(name,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.medium(
                                weight: FontWeight.w700)),
                      ),
                      Text(time,
                          style: AppTextStyles.small(
                              color: AppColors.textHint)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(message,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.small(
                                color: AppColors.textSecondary)),
                      ),
                      if (unread > 0) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.sm + 2),
                          ),
                          child: Text("$unread",
                              style: AppTextStyles.small(
                                  color: Colors.white,
                                  weight: FontWeight.w700)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}