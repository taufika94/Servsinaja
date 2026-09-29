import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/vehicle_model.dart';
import 'service_config_screen.dart';
import 'add_vehicle_screen.dart';
import 'schedule_screen.dart';   // ← TAMBAH

class MultiVehicleBookingScreen extends StatefulWidget {
  final bool showBackButton;
  const MultiVehicleBookingScreen({
    super.key,
    this.showBackButton = true,
  });

  @override
  State<MultiVehicleBookingScreen> createState() =>
      _MultiVehicleBookingScreenState();
}

class _MultiVehicleBookingScreenState extends State<MultiVehicleBookingScreen> {
  final List<Vehicle> _vehicles = [];

  @override
  void initState() {
    super.initState();
    for (var v in DummyData.vehicles) {
      _vehicles.add(Vehicle(
        id: v.id,
        brand: v.brand,
        model: v.model,
        plateNumber: v.plateNumber,
        year: v.year,
        color: v.color,
      ));
    }
  }

  int get _countSelected => _vehicles.where((v) => v.isSelected).length;

  Future<void> _openAddVehicle() async {
    final newVehicle = await Navigator.push<Vehicle>(
      context,
      MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
    );

    if (newVehicle != null) {
      final exists = _vehicles.any(
        (v) =>
            v.plateNumber.toLowerCase() == newVehicle.plateNumber.toLowerCase(),
      );

      if (exists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Motor sudah terdaftar",
                style: AppTextStyles.small(color: Colors.white)),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      setState(() {
        _vehicles.add(newVehicle);
        newVehicle.isSelected = true;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${newVehicle.brand} ${newVehicle.model} ditambahkan",
              style: AppTextStyles.small(color: Colors.white)),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ═══════════════════════════════════════
      // APPBAR ORANGE SOLID
      // ═══════════════════════════════════════
      appBar: AppBar(
        backgroundColor: AppColors.primaryOrange,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Pilih kendaraan",
          style: AppTextStyles.medium(
            weight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    color: Colors.white, size: 18),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        automaticallyImplyLeading: widget.showBackButton,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                color: Colors.white, size: 24),
            onPressed: _openAddVehicle,
            tooltip: 'Tambah Motor',
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),

      // ═══════════════════════════════════════
      // BODY
      // ═══════════════════════════════════════
      body: Column(
        children: [
          // ═══ INFO BANNER ═══
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md + 2),
            margin: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.lg,
              AppSpacing.screenH,
              AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(
                color: AppColors.primaryOrange.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.info_outline,
                      color: AppColors.primaryOrange, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    "Pilih satu atau lebih kendaraan. Setiap kendaraan dapat memiliki jenis servis dan keluhan yang berbeda",
                    style: AppTextStyles.small(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ═══ LIST MOTOR ═══
          Expanded(
            child: _vehicles.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenH),
                    itemCount: _vehicles.length,
                    itemBuilder: (context, index) {
                      return _buildVehicleItem(index);
                    },
                  ),
          ),

          // ═══ BOTTOM BAR ═══
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.lg,
              AppSpacing.screenH,
              AppSpacing.md,
            ),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.radiusXl),
                topRight: Radius.circular(AppSpacing.radiusXl),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ═══ TOTAL INFO ═══
                  Row(
                    children: [
                      Text(
                        "Total Kendaraan yang dipilih",
                        style: AppTextStyles.small(
                            color: AppColors.textSecondary),
                      ),
                      const Spacer(),
                      Text(
                        "$_countSelected Unit",
                        style: AppTextStyles.medium(
                          weight: FontWeight.w700,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ═══ TOMBOL LANJUT ═══
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _countSelected > 0
                        ? () {
                            final selected = _vehicles
                                .where((v) => v.isSelected)
                                .toList();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ScheduleScreen(
                                  vehicles: selected,   // ← FIX: pakai `selected`
                                ),
                              ),
                            );
                          }
                        : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.lg),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppSpacing.radiusXl),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Selanjutnya",
                        style: AppTextStyles.medium(
                            weight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // CARD KENDARAAN (dengan checkbox di kiri)
  // ═══════════════════════════════════════
  Widget _buildVehicleItem(int index) {
    final v = _vehicles[index];

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ═══ CHECKBOX (di luar card, kiri) ═══
          GestureDetector(
            onTap: () {
              setState(() {
                _vehicles[index].isSelected = !v.isSelected;
              });
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: v.isSelected
                    ? AppColors.primaryOrange
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: v.isSelected
                      ? AppColors.primaryOrange
                      : AppColors.textHint,
                  width: 1.5,
                ),
              ),
              child: v.isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // ═══ CARD KENDARAAN ═══
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _vehicles[index].isSelected = !v.isSelected;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md + 2),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  border: Border.all(
                    color: AppColors.divider,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // ═══ GAMBAR MOTOR ═══
                    Container(
                      width: 70,
                      height: 55,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusCard),
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusCard),
                        child: Image.asset(
                          DummyData.getMotorImage(v.model),   // ← ambil gambar dinamis
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.two_wheeler,
                            color: AppColors.primaryOrange,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md + 2),

                    // ═══ INFO MOTOR ═══
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${v.brand} ${v.model}",
                            style: AppTextStyles.medium(
                              weight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            v.plateNumber,
                            style: AppTextStyles.small(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            "${v.year}  •  ${v.color}",
                            style: AppTextStyles.small(
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // EMPTY STATE
  // ═══════════════════════════════════════
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.two_wheeler,
                size: 80, color: AppColors.textHint),
            const SizedBox(height: AppSpacing.lg),
            Text(
              "Belum ada motor terdaftar",
              style: AppTextStyles.medium(
                weight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "Tambahkan motor untuk memulai booking",
              style: AppTextStyles.small(color: AppColors.textHint),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: _openAddVehicle,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                "Tambah Motor",
                style: AppTextStyles.medium(
                    color: Colors.white, weight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusCard)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}