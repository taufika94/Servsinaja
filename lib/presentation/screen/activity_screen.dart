import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/service_history_model.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  int _mainTabIndex = 0;

  final Set<String> _expandedVehicles = {};

  @override
  void initState() {
    super.initState();
    // ═══ Auto-expand semua kendaraan ═══
    for (var h in DummyData.serviceHistories) {
      _expandedVehicles.add(h.vehicleId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // ═══ JUDUL ═══
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.lg,
              AppSpacing.screenH,
              AppSpacing.xl,
            ),
            child: Center(
              child: Text(
                "Aktivitas Saya",
                style: AppTextStyles.medium(
                  weight: FontWeight.w700,
                  color: Colors.black,
                ).copyWith(fontSize: 18),
              ),
            ),
          ),

          // ═══ TAB: Dalam Proses / Riwayat ═══
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
            height: 48,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl + 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(child: _buildMainTabBtn("Dalam Proses", 0)),
                Expanded(child: _buildMainTabBtn("Riwayat", 1)),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ═══ KONTEN ═══
          Expanded(
            child: _mainTabIndex == 0
                ? _buildServisInProgress()
                : _buildServisHistory(),
          ),
        ],
      ),
    );
  }

  // ═══ TAB BUTTON ═══
  Widget _buildMainTabBtn(String label, int index) {
    final isActive = _mainTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _mainTabIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        child: Text(
          label,
          style: AppTextStyles.medium(
            weight: FontWeight.w600,
            color: isActive ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  // ═══ KONTEN: SERVIS DALAM PROSES ═══
  Widget _buildServisInProgress() {
    final ongoingBookings = DummyData.serviceHistories
        .where((h) => h.status != 'Selesai' && h.status != 'Dibatalkan')
        .toList();

    if (ongoingBookings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.build_circle_outlined,
        title: 'Belum ada servis berjalan',
        subtitle: 'Booking servis Anda akan muncul di sini',
      );
    }

    final grouped = <String, List<ServiceHistory>>{};
    for (var h in ongoingBookings) {
      grouped.putIfAbsent(h.vehicleId, () => []).add(h);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      children: [
        ...grouped.entries.map((entry) {
          return _buildVehicleGroup(entry.key, entry.value, isHistory: false);
        }).toList(),
      ],
    );
  }

  // ═══ KONTEN: SERVIS RIWAYAT ═══
  Widget _buildServisHistory() {
    final completedBookings = DummyData.serviceHistories
        .where((h) => h.status == 'Selesai')
        .toList();

    if (completedBookings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history,
        title: 'Belum ada riwayat servis',
        subtitle: 'Riwayat servis yang selesai akan muncul di sini',
      );
    }

    final grouped = <String, List<ServiceHistory>>{};
    for (var h in completedBookings) {
      grouped.putIfAbsent(h.vehicleId, () => []).add(h);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      children: [
        ...grouped.entries.map((entry) {
          return _buildVehicleGroup(entry.key, entry.value, isHistory: true);
        }).toList(),
      ],
    );
  }

  // ═══ CARD GROUP (dipakai ongoing & history) ═══
  Widget _buildVehicleGroup(
    String vehicleId,
    List<ServiceHistory> histories, {
    required bool isHistory,
  }) {
    histories.sort((a, b) => b.date.compareTo(a.date));
    final latest = histories.first;
    final isExpanded = _expandedVehicles.contains(vehicleId);

    // Hitung total bayar
    final totalPrice =
        histories.fold<int>(0, (sum, h) => sum + h.totalPrice);

    // Progress rata-rata (untuk ongoing)
    double avgProgress = 0;
    if (!isHistory) {
      for (var h in histories) {
        if (h.status.contains('Dikerjakan')) {
          avgProgress += 0.6;
        } else if (h.status.contains('Menunggu')) {
          avgProgress += 0.2;
        } else {
          avgProgress += 0.3;
        }
      }
      avgProgress = histories.isEmpty ? 0 : avgProgress / histories.length;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              padding: const EdgeInsets.all(AppSpacing.md + 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ═══ BARIS 1: GAMBAR + NAMA + PLAT + ARROW ═══
                  Row(
                    children: [
                      Image.asset(
                        DummyData.getMotorImage(latest.vehicleName),
                        width: 56,
                        height: 40,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.two_wheeler,
                          size: 40,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          latest.vehicleName,
                          style: AppTextStyles.medium(
                              weight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        latest.plateNumber,
                        style: AppTextStyles.small(
                            color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppColors.textPrimary,
                          size: 22,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // ═══ BARIS 2: LAYANAN SERVIS + MONTIR ═══
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isHistory)
                              Text(
                                "Proses pengerjaan",
                                style: AppTextStyles.small(
                                    weight: FontWeight.w700),
                              ),
                            if (!isHistory) const SizedBox(height: 2),
                            Text(
                              "Layanan Servis",
                              style: AppTextStyles.small(
                                  color: AppColors.textSecondary),
                            ),
                            Text(
                              "Montir",
                              style: AppTextStyles.small(
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isHistory)
                            Text(
                              "${(avgProgress * 100).toInt()}%",
                              style: AppTextStyles.small(
                                color: AppColors.primaryOrange,
                                weight: FontWeight.w700,
                              ),
                            ),
                          if (!isHistory) const SizedBox(height: 2),
                          Text(
                            latest.serviceType,
                            style: AppTextStyles.small(
                                color: AppColors.textHint),
                          ),
                          Text(
                            "Yayat",
                            style: AppTextStyles.small(
                                color: AppColors.textHint),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // ═══ PROGRESS BAR (hanya ongoing) ═══
                  if (!isHistory) ...[
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                      child: LinearProgressIndicator(
                        value: avgProgress,
                        minHeight: 6,
                        backgroundColor: AppColors.divider,
                        valueColor: const AlwaysStoppedAnimation(
                            AppColors.primaryOrange),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ═══ DETAIL SERVIS (DROPDOWN) ═══
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1, color: AppColors.divider),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md + 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Detail Servis",
                        style: AppTextStyles.medium(
                            weight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ...histories.asMap().entries.map((e) {
                        return _buildServiceItem(
                            e.value, e.key == histories.length - 1);
                      }).toList(),

                      const SizedBox(height: AppSpacing.md),
                      const Divider(height: 1, color: AppColors.divider),
                      const SizedBox(height: AppSpacing.sm),

                      // ═══ TOTAL BAYAR ═══
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Bayar",
                            style: AppTextStyles.small(
                                weight: FontWeight.w700),
                          ),
                          Text(
                            CurrencyFormatter.format(totalPrice),
                            style: AppTextStyles.medium(
                              weight: FontWeight.w700,
                              color: AppColors.primaryOrange,
                            ),
                          ),
                        ],
                      ),
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

  // ═══ ITEM SERVIS (kotak peach) ═══
  Widget _buildServiceItem(ServiceHistory h, bool isLast) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.softOrange,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              h.serviceType,
              style: AppTextStyles.medium(weight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              h.serviceType,
              style: AppTextStyles.small(
                  color: AppColors.textSecondary),
            ),
            const SizedBox(height: 2),
            Text(
              h.ticketNumber,
              style: AppTextStyles.small(
                  color: AppColors.textSecondary),
            ),
            const SizedBox(height: 2),
            Text(
              h.workshop,
              style: AppTextStyles.small(
                  color: AppColors.textSecondary),
            ),
            const SizedBox(height: 2),
            Text(
              "${h.date.day.toString().padLeft(2, '0')}/${h.date.month.toString().padLeft(2, '0')}/${h.date.year}",
              style: AppTextStyles.small(
                  color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  // ═══ EMPTY STATE ═══
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: AppColors.textHint),
            const SizedBox(height: AppSpacing.lg),
            Text(title,
                style: AppTextStyles.medium(
                    weight: FontWeight.w600,
                    color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.small(color: AppColors.textHint)),
          ],
        ),
      ),
    );
  }
}