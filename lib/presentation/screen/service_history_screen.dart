import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/service_history_model.dart';
// ❌ import '../widgets/app_background.dart';   ← HAPUS

class ServiceHistoryScreen extends StatefulWidget {
  const ServiceHistoryScreen({super.key});

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  final Set<String> _expandedVehicles = {};

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<ServiceHistory>>{};
    for (var h in DummyData.serviceHistories) {
      grouped.putIfAbsent(h.vehicleId, () => []).add(h);
    }

    return Scaffold(
      backgroundColor: AppColors.background,

      // ═══ APPBAR GRADIENT ═══
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Riwayat Servis",
          style: AppTextStyles.medium(
            weight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.primaryOrange,
                AppColors.discountPrice,
              ],
            ),
          ),
        ),
      ),

      // ✅ BODY LANGSUNG (tanpa AppBackground)
      body: grouped.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.screenH),
              children: [
                // ═══ INFO ═══
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md + 2),
                  decoration: BoxDecoration(
                    color: AppColors.softOrange,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusCard),
                    border: Border.all(
                      color: AppColors.primaryOrange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppColors.primaryOrange),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          "Pantau riwayat servis & jadwal servis berikutnya untuk setiap kendaraan.",
                          style: AppTextStyles.small(
                              color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ═══ LIST KENDARAAN ═══
                ...grouped.entries.map((entry) {
                  return _buildVehicleGroup(entry.key, entry.value);
                }).toList(),
              ],
            ),
    );
  }

  Widget _buildVehicleGroup(
      String vehicleId, List<ServiceHistory> histories) {
    histories.sort((a, b) => b.date.compareTo(a.date));
    final latest = histories.first;
    final totalSpent =
        histories.fold<int>(0, (sum, h) => sum + h.totalPrice);
    final nextServiceInfo = _getNextServiceInfo(latest);
    final isExpanded = _expandedVehicles.contains(vehicleId);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(2, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ═══ HEADER KENDARAAN ═══
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedVehicles.remove(vehicleId);
                } else {
                  _expandedVehicles.add(vehicleId);
                }
              });
            },
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm + 2),
                        decoration: BoxDecoration(
                          color: AppColors.softOrange,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusCard),
                        ),
                        child: const Icon(Icons.two_wheeler,
                            color: AppColors.primaryOrange, size: 24),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(latest.vehicleName,
                                style: AppTextStyles.medium(
                                    weight: FontWeight.w700)),
                            Text(latest.plateNumber,
                                style: AppTextStyles.small(
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: const Icon(Icons.keyboard_arrow_down,
                            color: AppColors.primaryOrange, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatChip(
                          icon: Icons.build_circle_outlined,
                          label: "Total Servis",
                          value: "${histories.length}x",
                          color: AppColors.primaryOrange,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _buildStatChip(
                          icon: Icons.speed,
                          label: "KM Terakhir",
                          value: "${latest.currentKm}",
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatChip(
                          icon: Icons.receipt_long_outlined,
                          label: "Total Biaya",
                          value: CurrencyFormatter.format(totalSpent),
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _buildStatChip(
                          icon: Icons.calendar_today,
                          label: "Servis Terakhir",
                          value:
                              "${latest.date.day}/${latest.date.month}/${latest.date.year}",
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),
                  _buildNextServiceBanner(nextServiceInfo),
                ],
              ),
            ),
          ),

          // ═══ DROPDOWN RIWAYAT ═══
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Column(
              children: [
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Riwayat Servis",
                          style: AppTextStyles.medium(
                              weight: FontWeight.w700)),
                      const SizedBox(height: AppSpacing.md),
                      ...histories.asMap().entries.map((e) {
                        return _buildHistoryItem(
                            e.value, e.key == histories.length - 1);
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.small(
                        color: AppColors.textHint)),
                Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.small(
                        weight: FontWeight.w700,
                        color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextServiceBanner(Map<String, dynamic> info) {
    final Color color = info['color'] as Color;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(info['icon'] as IconData,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(info['title'] as String,
                    style: AppTextStyles.small(
                        weight: FontWeight.w700, color: color)),
                const SizedBox(height: 2),
                Text(info['subtitle'] as String,
                    style: AppTextStyles.small(
                        color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getNextServiceInfo(ServiceHistory latest) {
    final now = DateTime.now();
    final daysSince = now.difference(latest.date).inDays;

    const intervalDays = 120;
    final daysLeft = intervalDays - daysSince;

    if (daysLeft <= 0) {
      return {
        'icon': Icons.warning_amber_rounded,
        'title': 'Servis Segera Diperlukan!',
        'subtitle':
            'Sudah $daysSince hari sejak servis terakhir. Disarankan servis sekarang.',
        'color': AppColors.danger,
      };
    } else if (daysLeft <= 30) {
      return {
        'icon': Icons.schedule,
        'title': 'Servis Berikutnya: $daysLeft hari lagi',
        'subtitle':
            'Sekitar ${now.add(Duration(days: daysLeft)).day}/${now.add(Duration(days: daysLeft)).month}/${now.add(Duration(days: daysLeft)).year}',
        'color': AppColors.warning,
      };
    } else {
      return {
        'icon': Icons.check_circle,
        'title': 'Servis Berikutnya: $daysLeft hari lagi',
        'subtitle':
            'Sekitar ${now.add(Duration(days: daysLeft)).day}/${now.add(Duration(days: daysLeft)).month}/${now.add(Duration(days: daysLeft)).year}',
        'color': AppColors.success,
      };
    }
  }

  Widget _buildHistoryItem(ServiceHistory h, bool isLast) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primaryOrange
                            .withValues(alpha: 0.3),
                        blurRadius: 4),
                  ],
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  color: AppColors.divider,
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          h.serviceType,
                          style: AppTextStyles.medium(
                              weight: FontWeight.w700),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: h.status == 'Selesai'
                              ? AppColors.success
                              : AppColors.warning,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(h.status,
                            style: AppTextStyles.small(
                                color: Colors.white,
                                weight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 11, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                          "${h.date.day}/${h.date.month}/${h.date.year}",
                          style: AppTextStyles.small(
                              color: AppColors.textSecondary)),
                      const SizedBox(width: AppSpacing.md),
                      const Icon(Icons.speed,
                          size: 11, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text("${h.currentKm} km",
                          style: AppTextStyles.small(
                              color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  Row(
                    children: [
                      const Icon(Icons.store,
                          size: 11, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(h.workshop,
                            style: AppTextStyles.small(
                                color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(h.ticketNumber,
                          style: AppTextStyles.small(
                              color: AppColors.textHint)),
                      Text(CurrencyFormatter.format(h.totalPrice),
                          style: AppTextStyles.medium(
                              weight: FontWeight.w700,
                              color: AppColors.primaryOrange)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 80, color: AppColors.textHint),
            const SizedBox(height: AppSpacing.lg),
            Text("Belum ada riwayat servis",
                style: AppTextStyles.medium(
                    weight: FontWeight.w600,
                    color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            Text("Riwayat servis Anda akan muncul di sini",
                style: AppTextStyles.small(color: AppColors.textHint)),
          ],
        ),
      ),
    );
  }
}