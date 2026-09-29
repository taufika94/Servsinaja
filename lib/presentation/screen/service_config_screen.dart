import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/service_model.dart';
import '../../data/models/vehicle_model.dart';
import '../../data/models/workshop_model.dart';
import '../../data/models/pickup_location_model.dart';
import 'location_picker_screen.dart';
import 'booking_summary_screen.dart';

class ServiceConfigScreen extends StatefulWidget {
  final List<Vehicle> selectedVehicles;
  final Workshop selectedWorkshop;
  final Map<String, DateTime> vehicleDates;
  final Map<String, String> vehicleTimes;
  final PickupLocation? userLocation;

  const ServiceConfigScreen({
    super.key,
    required this.selectedVehicles,
    required this.selectedWorkshop,
    required this.vehicleDates,
    required this.vehicleTimes,
    this.userLocation,
  });

  @override
  State<ServiceConfigScreen> createState() =>
      _ServiceConfigScreenState();
}

class _ServiceConfigScreenState extends State<ServiceConfigScreen> {
  late List<VehicleServiceConfig> _configs;
  final Map<String, TextEditingController> _kmControllers = {};
  final Map<String, TextEditingController> _notesControllers = {};

  @override
  void initState() {
    super.initState();

    // ═══ AUTO-FILL: lokasi + tanggal + voucher ═══
    _configs = widget.selectedVehicles.map((v) {
      final vehicleDate = widget.vehicleDates[v.id];

      return VehicleServiceConfig(
        vehicleId: v.id,
        lastServiceDate: vehicleDate,
        pickupLocation: widget.userLocation,
        pickupDistanceKm: widget.userLocation != null
            ? _calculateDistance(widget.userLocation!)
            : 0,
        appliedVoucher: DummyData.activeVoucher,
      );
    }).toList();

    for (var v in widget.selectedVehicles) {
      _kmControllers[v.id] = TextEditingController();
      _notesControllers[v.id] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var c in _kmControllers.values) {
      c.dispose();
    }
    for (var c in _notesControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ═══════════════════════════════════════
  // UPDATE CONFIG
  // ═══════════════════════════════════════
  void _updateConfig(
    int idx, {
    List<ServiceOption>? services,
    List<SparePart>? parts,
    String? complaint,
    int? km,
    DateTime? lastService,
    bool? isPickupService,
    PickupLocation? pickupLocation,
    double? pickupDistanceKm,
    Voucher? appliedVoucher,
    bool clearVoucher = false,
  }) {
    final old = _configs[idx];
    _configs[idx] = VehicleServiceConfig(
      vehicleId: old.vehicleId,
      selectedServices: services ?? old.selectedServices,
      selectedParts: parts ?? old.selectedParts,
      complaint: complaint ?? old.complaint,
      currentKm: km ?? old.currentKm,
      lastServiceDate: lastService ?? old.lastServiceDate,
      isPickupService: isPickupService ?? old.isPickupService,
      pickupLocation: pickupLocation ?? old.pickupLocation,
      pickupDistanceKm: pickupDistanceKm ?? old.pickupDistanceKm,
      appliedVoucher:
          clearVoucher ? null : (appliedVoucher ?? old.appliedVoucher),
    );
  }

  // ═══════════════════════════════════════
  // HITUNG JARAK (Haversine)
  // ═══════════════════════════════════════
  double _calculateDistance(PickupLocation location) {
    final workshopLat = widget.selectedWorkshop.latitude;
    final workshopLng = widget.selectedWorkshop.longitude;

    const p = 0.017453292519943295;
    final a = 0.5 -
        math.cos((location.latitude - workshopLat) * p) / 2 +
        math.cos(workshopLat * p) *
            math.cos(location.latitude * p) *
            (1 - math.cos((location.longitude - workshopLng) * p)) /
            2;

    final km = 12742 * math.asin(math.sqrt(a));
    return double.parse(km.toStringAsFixed(2));
  }

  // ═══════════════════════════════════════
  // AUTO-SELECT PART REKOMENDASI
  // ═══════════════════════════════════════
  void _autoSelectRecommendedParts(int idx, Vehicle vehicle) {
    final config = _configs[idx];
    if (config.selectedServices.isEmpty) return;

    final newParts = List<SparePart>.from(config.selectedParts);
    bool changed = false;

    final requiredCats = config.requiredCategories;

    for (var cat in requiredCats) {
      final hasPart = newParts.any((p) => p.category == cat);
      if (hasPart) continue;

      final candidates = _getPartsForCategory(cat, vehicle);

      if (candidates.isEmpty) continue;

      // Cari yang direkomendasikan dulu
      SparePart? recommended;
      try {
        recommended = candidates.firstWhere((p) => p.isRecommended);
      } catch (_) {
        recommended = candidates.first;
      }

      newParts.add(recommended);
      changed = true;
    }

    if (changed) {
      _updateConfig(idx, parts: newParts);
    }
  }

  // ═══════════════════════════════════════
  // CEK SERVICE BERTENTANGAN
  // ═══════════════════════════════════════
  bool _isServiceConflicting(ServiceOption a, ServiceOption b) {
    const conflicts = <String, List<String>>{
      'Ganti Oli Terpisah': ['Servis Berkala Rutin'],
      'Servis Berkala Rutin': ['Ganti Oli Terpisah'],
    };

    final list = conflicts[a.name];
    if (list == null) return false;
    return list.contains(b.name);
  }

  // ═══════════════════════════════════════
  // FILTER PART — SMART MATCH
  // ═══════════════════════════════════════
  List<SparePart> _getPartsForCategory(
      String category, Vehicle vehicle) {
    return DummyData.availableParts.where((p) {
      if (p.category != category) return false;

      // ═══ Universal part (kosong) = semua motor ═══
      if (p.compatibleModels.isEmpty) return true;

      // ═══ Exact match ═══
      if (p.compatibleModels.contains(vehicle.model)) return true;

      // ═══ Smart match: prefix ═══
      // "PCX" match "PCX 160", "Vario" match "Vario 125"
      final vehiclePrefix =
          vehicle.model.split(' ').first.toLowerCase();
      for (var model in p.compatibleModels) {
        final partPrefix = model.split(' ').first.toLowerCase();
        if (partPrefix == vehiclePrefix) return true;
      }

      return false;
    }).toList();
  }

  // ═══════════════════════════════════════
  // SERVICE PICKER
  // ═══════════════════════════════════════
  void _showServicePicker(int idx) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          final config = _configs[idx];

          return Dialog(
            insetPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl, vertical: AppSpacing.xxl),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pilih Jenis Servis',
                      style: AppTextStyles.medium(
                          weight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Pilih layanan yang dibutuhkan',
                      style: AppTextStyles.small(
                          color: AppColors.textSecondary)),
                  const SizedBox(height: AppSpacing.lg),

                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: DummyData.availableServices
                            .map((service) {
                          final isSelected = config.selectedServices
                              .any((s) => s.id == service.id);

                          final hasConflict =
                              config.selectedServices.any(
                            (s) =>
                                s.id != service.id &&
                                _isServiceConflicting(s, service),
                          );

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                final newList =
                                    List<ServiceOption>.from(
                                        config.selectedServices);
                                final newParts =
                                    List<SparePart>.from(
                                        config.selectedParts);

                                if (isSelected) {
                                  newList.removeWhere(
                                      (s) => s.id == service.id);

                                  final categoriesStillNeeded =
                                      <String>{};
                                  for (var s in newList) {
                                    categoriesStillNeeded.addAll(
                                        s.requiredPartCategories);
                                    categoriesStillNeeded.addAll(
                                        s.optionalPartCategories);
                                  }
                                  newParts.removeWhere((p) =>
                                      !categoriesStillNeeded
                                          .contains(p.category));
                                } else {
                                  final conflicting = newList
                                      .where((s) =>
                                          _isServiceConflicting(
                                              s, service))
                                      .toList();

                                  if (conflicting.isNotEmpty) {
                                    for (var c in conflicting) {
                                      newList.removeWhere(
                                          (s) => s.id == c.id);
                                    }

                                    final categoriesStillNeeded =
                                        <String>{};
                                    for (var s in newList) {
                                      categoriesStillNeeded.addAll(
                                          s.requiredPartCategories);
                                      categoriesStillNeeded.addAll(
                                          s.optionalPartCategories);
                                    }
                                    categoriesStillNeeded.addAll(
                                        service.requiredPartCategories);
                                    categoriesStillNeeded.addAll(
                                        service.optionalPartCategories);

                                    newParts.removeWhere((p) =>
                                        !categoriesStillNeeded
                                            .contains(p.category));
                                  }

                                  newList.add(service);
                                }

                                _updateConfig(idx,
                                    services: newList,
                                    parts: newParts);

                                if (!isSelected) {
                                  _autoSelectRecommendedParts(
                                      idx,
                                      widget
                                          .selectedVehicles[idx]);
                                }
                              });
                              setDialogState(() {});
                            },
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(
                                  bottom: AppSpacing.md),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusSm),
                                border: isSelected
                                    ? Border.all(
                                        color:
                                            AppColors.primaryOrange,
                                        width: 1.5)
                                    : Border.all(
                                        color: AppColors.divider,
                                        width: 1),
                              ),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primaryOrange
                                          : Colors.transparent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primaryOrange
                                            : AppColors.textHint,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(Icons.check,
                                            color: AppColors.white,
                                            size: 12)
                                        : null,
                                  ),
                                  const SizedBox(
                                      width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(service.name,
                                            style: AppTextStyles
                                                .small(
                                                    weight: FontWeight
                                                        .w700)),
                                        const SizedBox(height: 2),
                                        Text(service.description,
                                            style: AppTextStyles
                                                .small(
                                                    color: AppColors
                                                        .textSecondary)),
                                        if (hasConflict &&
                                            !isSelected)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(
                                                    top: AppSpacing.xs),
                                            child: Text(
                                              'Akan mengganti layanan lain yang dipilih',
                                              style: AppTextStyles
                                                  .small(
                                                      color: AppColors
                                                          .primaryOrange),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(
                                        service.serviceFee),
                                    style: AppTextStyles.small(
                                        weight: FontWeight.w700,
                                        color:
                                            AppColors.primaryOrange),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppSpacing.radiusXl),
                        ),
                        elevation: 0,
                      ),
                      child: Text("Simpan Pilihan",
                          style: AppTextStyles.medium(
                              weight: FontWeight.w700,
                              color: AppColors.white)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════
  // PART PICKER (DENGAN FALLBACK)
  // ═══════════════════════════════════════
  void _showPartPicker(int idx, Vehicle vehicle) {
    final config = _configs[idx];

    if (config.selectedServices.isEmpty) {
      _snack('Pilih jenis servis terlebih dahulu');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          final currentConfig = _configs[idx];

          final allAvailableParts = <SparePart>[];

          final allCats = <String>{
            ...currentConfig.requiredCategories,
            ...currentConfig.optionalCategories,
          };

          for (var cat in allCats) {
            final parts = _getPartsForCategory(cat, vehicle);
            allAvailableParts.addAll(parts);
          }

          // ═══ FALLBACK: kalau kosong, pakai semua part di kategori ═══
          if (allAvailableParts.isEmpty && allCats.isNotEmpty) {
            for (var cat in allCats) {
              final parts = DummyData.availableParts
                  .where((p) => p.category == cat)
                  .toList();
              allAvailableParts.addAll(parts);
            }
          }

          final groupedParts = <String, List<SparePart>>{};
          for (var part in allAvailableParts) {
            groupedParts.putIfAbsent(part.category, () => []).add(part);
          }

          return Dialog(
            insetPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl, vertical: AppSpacing.xxl),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pilih Suku Cadang',
                      style: AppTextStyles.medium(
                          weight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Otomatis filter untuk ${vehicle.model}',
                      style: AppTextStyles.small(
                          color: AppColors.textSecondary)),
                  const SizedBox(height: AppSpacing.lg),

                  // ═══ EMPTY STATE ═══
                  if (groupedParts.isEmpty)
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 40),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.build_outlined,
                                size: 60,
                                color: AppColors.textHint,
                              ),
                              const SizedBox(
                                  height: AppSpacing.md),
                              Text(
                                'Belum ada suku cadang',
                                style: AppTextStyles.medium(
                                    weight: FontWeight.w600),
                              ),
                              const SizedBox(
                                  height: AppSpacing.xs),
                              Text(
                                'untuk ${vehicle.model}',
                                style: AppTextStyles.small(
                                    color:
                                        AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            ...groupedParts.entries.map((entry) {
                              final category = entry.key;
                              final parts = entry.value;
                              final isRequired = currentConfig
                                  .requiredCategories
                                  .contains(category);
                              final isSingle =
                                  _isSingleSelectCategory(category);
                              final selectedPart = currentConfig
                                  .getPartInCategory(category);

                              return Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: AppSpacing.sm,
                                        top: AppSpacing.xs),
                                    child: Row(
                                      children: [
                                        Text(category,
                                            style: AppTextStyles
                                                .medium(
                                                    weight:
                                                        FontWeight
                                                            .w700)),
                                        const SizedBox(
                                            width: AppSpacing.sm),
                                        Container(
                                          padding: const EdgeInsets
                                              .symmetric(
                                                  horizontal:
                                                      AppSpacing.sm,
                                                  vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isRequired
                                                ? AppColors.danger
                                                : AppColors.textHint
                                                    .withValues(
                                                        alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(
                                                    AppSpacing.xs),
                                          ),
                                          child: Text(
                                            isRequired
                                                ? 'Wajib'
                                                : 'Opsional',
                                            style: AppTextStyles
                                                .small(
                                              color: isRequired
                                                  ? AppColors.white
                                                  : AppColors
                                                      .textSecondary,
                                              weight:
                                                  FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        if (isSingle)
                                          Text("Pilih 1",
                                              style: AppTextStyles
                                                  .small(
                                                      color: AppColors
                                                          .primaryOrange,
                                                      weight:
                                                          FontWeight
                                                              .w600)),
                                      ],
                                    ),
                                  ),
                                  ...parts.map((part) {
                                    final isSelected =
                                        selectedPart?.id == part.id;

                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          final config =
                                              _configs[idx];
                                          final newParts =
                                              List<SparePart>.from(
                                                  config.selectedParts);

                                          if (isSingle) {
                                            newParts.removeWhere((p) =>
                                                p.category ==
                                                part.category);
                                            if (!isSelected) {
                                              newParts.add(part);
                                            }
                                          } else {
                                            if (isSelected) {
                                              newParts.removeWhere(
                                                  (p) =>
                                                      p.id == part.id);
                                            } else {
                                              newParts.add(part);
                                            }
                                          }

                                          _updateConfig(idx,
                                              parts: newParts);
                                        });
                                        setDialogState(() {});
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.only(
                                            bottom: AppSpacing.md),
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal:
                                                    AppSpacing.md,
                                                vertical:
                                                    AppSpacing.md),
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius:
                                              BorderRadius.circular(
                                                  AppSpacing
                                                      .radiusSm),
                                          border: isSelected
                                              ? Border.all(
                                                  color: AppColors
                                                      .primaryOrange,
                                                  width: 1.5)
                                              : Border.all(
                                                  color: AppColors
                                                      .divider,
                                                  width: 1),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .center,
                                          children: [
                                            Container(
                                              width: 20,
                                              height: 20,
                                              decoration:
                                                  BoxDecoration(
                                                color: isSelected
                                                    ? AppColors
                                                        .primaryOrange
                                                    : Colors
                                                        .transparent,
                                                shape:
                                                    BoxShape.circle,
                                                border: Border.all(
                                                  color: isSelected
                                                      ? AppColors
                                                          .primaryOrange
                                                      : AppColors
                                                          .textHint,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: isSelected
                                                  ? const Icon(
                                                      Icons.check,
                                                      color: AppColors
                                                          .white,
                                                      size: 12)
                                                  : null,
                                            ),
                                            const SizedBox(
                                                width: AppSpacing.md),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                children: [
                                                  Text(part.name,
                                                      style: AppTextStyles.small(
                                                          weight:
                                                              FontWeight
                                                                  .w700)),
                                                  const SizedBox(
                                                      height: 2),
                                                  Text(
                                                      part.description,
                                                      style: AppTextStyles.small(
                                                          color: AppColors
                                                              .textSecondary)),
                                                  const SizedBox(
                                                      height:
                                                          AppSpacing
                                                              .xs),
                                                  Text(
                                                      CurrencyFormatter
                                                          .format(
                                                              part.price),
                                                      style: AppTextStyles.small(
                                                          weight:
                                                              FontWeight
                                                                  .w700,
                                                          color: AppColors
                                                              .primaryOrange)),
                                                ],
                                              ),
                                            ),
                                            if (part.isRecommended)
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(
                                                        left:
                                                            AppSpacing
                                                                .sm),
                                                child: Icon(
                                                  Icons.star_rounded,
                                                  color:
                                                      Colors.amber,
                                                  size: 22,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  const SizedBox(
                                      height: AppSpacing.xs),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppSpacing.radiusXl),
                        ),
                        elevation: 0,
                      ),
                      child: Text("Simpan Pilihan",
                          style: AppTextStyles.medium(
                              weight: FontWeight.w700,
                              color: AppColors.white)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════
  // VOUCHER DIALOG
  // ═══════════════════════════════════════
  void _showVoucherDialog() {
    final codeController = TextEditingController();
    final currentVoucher =
        _configs.isNotEmpty ? _configs.first.appliedVoucher : null;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusSm)),
            insetPadding: const EdgeInsets.all(AppSpacing.xl),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_offer,
                          color: AppColors.primaryOrange),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Pakai Voucher',
                          style: AppTextStyles.medium(
                              weight: FontWeight.w700)),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Kode Voucher',
                      style: AppTextStyles.small(
                          weight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(
                                AppSpacing.radiusSm),
                            border: Border.all(
                                color: AppColors.divider),
                          ),
                          child: TextField(
                            controller: codeController,
                            textCapitalization:
                                TextCapitalization.characters,
                            style: AppTextStyles.small(
                                color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Contoh: HEMAT20',
                              hintStyle: AppTextStyles.small(
                                  color: AppColors.textHint),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      ElevatedButton(
                        onPressed: () {
                          final code = codeController.text.trim();
                          if (code.isEmpty) return;

                          final voucher =
                              DummyData.findVoucher(code);
                          if (voucher == null) {
                            _snack('Kode voucher tidak ditemukan');
                            return;
                          }

                          final total = _configs.fold<int>(
                              0, (s, c) => s + c.subtotal);
                          if (total < voucher.minTransaction) {
                            _snack(
                                'Minimal transaksi ${CurrencyFormatter.format(voucher.minTransaction)}');
                            return;
                          }

                          setState(() {
                            for (int i = 0;
                                i < _configs.length;
                                i++) {
                              _updateConfig(i,
                                  appliedVoucher: voucher);
                            }
                            DummyData.setActiveVoucher(voucher);
                          });
                          setDialogState(() {});
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Voucher ${voucher.code} berhasil dipakai!',
                                  style: AppTextStyles.small(
                                      color: AppColors.white)),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryOrange,
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.md),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusSm)),
                          elevation: 0,
                        ),
                        child: Text('Pakai',
                            style: AppTextStyles.small(
                                weight: FontWeight.w700,
                                color: AppColors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  if (currentVoucher != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color:
                            AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm),
                        border: Border.all(
                            color: AppColors.success
                                .withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: AppColors.success, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(currentVoucher.title,
                                    style: AppTextStyles.small(
                                        weight: FontWeight.w700,
                                        color: AppColors.success)),
                                Text(currentVoucher.code,
                                    style: AppTextStyles.small(
                                        color: AppColors.success)),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                for (int i = 0;
                                    i < _configs.length;
                                    i++) {
                                  _updateConfig(i,
                                      clearVoucher: true);
                                }
                                DummyData.setActiveVoucher(null);
                              });
                              setDialogState(() {});
                            },
                            child: Text('Hapus',
                                style: AppTextStyles.small(
                                    color: AppColors.danger,
                                    weight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  Text('Voucher Tersedia',
                      style: AppTextStyles.medium(
                          weight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.sm),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children:
                            DummyData.availableVouchers.map((v) {
                          final isApplied =
                              currentVoucher?.code == v.code;

                          return GestureDetector(
                            onTap: () {
                              codeController.text = v.code;
                              setDialogState(() {});
                            },
                            child: Container(
                              margin: const EdgeInsets.only(
                                  bottom: AppSpacing.sm),
                              padding:
                                  const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: isApplied
                                    ? AppColors.primaryOrange
                                        .withValues(alpha: 0.1)
                                    : AppColors.white,
                                borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusSm),
                                border: Border.all(
                                  color: isApplied
                                      ? AppColors.primaryOrange
                                      : AppColors.divider,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryOrange
                                          .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(
                                              AppSpacing.radiusSm),
                                    ),
                                    child: const Icon(
                                        Icons.local_offer,
                                        color:
                                            AppColors.primaryOrange),
                                  ),
                                  const SizedBox(
                                      width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(v.title,
                                            style: AppTextStyles
                                                .small(
                                                    weight: FontWeight
                                                        .w700)),
                                        Text(v.description,
                                            style: AppTextStyles
                                                .small(
                                                    color: AppColors
                                                        .textSecondary)),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Kode: ${v.code} • Min. ${CurrencyFormatter.format(v.minTransaction)}',
                                          style: AppTextStyles
                                              .small(
                                                  weight: FontWeight
                                                      .w600,
                                                  color: AppColors
                                                      .primaryOrange),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════
  // CONFIRM DIALOG
  // ═══════════════════════════════════════
  void _showConfirmDialog(BuildContext context) {
    for (int i = 0; i < _configs.length; i++) {
      final config = _configs[i];
      final v = widget.selectedVehicles[i];

      if (config.selectedServices.isEmpty) {
        _snack('Pilih minimal 1 layanan untuk ${v.model}');
        return;
      }
      if (config.currentKm == null || config.currentKm == 0) {
        _snack('Isi kilometer ${v.model}');
        return;
      }
      if (config.isPickupService) {
        if (config.pickupLocation == null) {
          _snack('Pilih lokasi penjemputan ${v.model}');
          return;
        }
      }
      final missing = config.missingRequiredCategories;
      if (missing.isNotEmpty) {
        _snack('Pilih suku cadang ${missing.join(', ')}');
        return;
      }
    }

    final totalServiceFee =
        _configs.fold<int>(0, (sum, c) => sum + c.totalServiceFee);
    final totalPartPrice =
        _configs.fold<int>(0, (sum, c) => sum + c.totalPartPrice);
    final totalPickupFee =
        _configs.fold<int>(0, (sum, c) => sum + c.pickupFee);
    final totalDiscount =
        _configs.fold<int>(0, (sum, c) => sum + c.discountAmount);
    final grandTotal = totalServiceFee +
        totalPartPrice +
        totalPickupFee -
        totalDiscount;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
        insetPadding: const EdgeInsets.all(AppSpacing.xxl),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          color: AppColors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color:
                      AppColors.primaryOrange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.help_outline,
                    color: AppColors.primaryOrange, size: 32),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Konfirmasi Booking?',
                  style: AppTextStyles.medium(
                      weight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Total ${CurrencyFormatter.format(grandTotal)}. '
                'Bengkel: ${widget.selectedWorkshop.name}',
                textAlign: TextAlign.center,
                style: AppTextStyles.small(
                    color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppSpacing.radiusXl)),
                        side: const BorderSide(
                            color: AppColors.divider),
                      ),
                      child: Text('Batal',
                          style: AppTextStyles.small(
                              weight: FontWeight.w700,
                              color: AppColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);

                        final vehicleSchedules =
                            <String, Map<String, dynamic>>{};
                        for (var v in widget.selectedVehicles) {
                          vehicleSchedules[v.id] = {
                            'date': widget.vehicleDates[v.id],
                            'time': widget.vehicleTimes[v.id],
                          };
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingSummaryScreen(
                              vehicles: widget.selectedVehicles,
                              configs: _configs,
                              workshop: widget.selectedWorkshop,
                              date:
                                  widget.vehicleDates.values.first,
                              time:
                                  widget.vehicleTimes.values.first,
                              vehicleSchedules: vehicleSchedules,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppSpacing.radiusXl)),
                        elevation: 0,
                      ),
                      child: Text('Ya, Booking',
                          style: AppTextStyles.small(
                              weight: FontWeight.w700,
                              color: AppColors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══ HELPERS ═══
  bool _isSingleSelectCategory(String category) {
    return ['Oli Mesin', 'Oli Gardan', 'Busi', 'Aki']
        .contains(category);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(msg, style: AppTextStyles.small(color: AppColors.white)),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  // ═══════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final totalServiceFee =
        _configs.fold<int>(0, (sum, c) => sum + c.totalServiceFee);
    final totalPartPrice =
        _configs.fold<int>(0, (sum, c) => sum + c.totalPartPrice);
    final totalPickupFee =
        _configs.fold<int>(0, (sum, c) => sum + c.pickupFee);
    final totalDiscount =
        _configs.fold<int>(0, (sum, c) => sum + c.discountAmount);
    final grandTotal = totalServiceFee +
        totalPartPrice +
        totalPickupFee -
        totalDiscount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryOrange,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Text("Konfigurasi Servis",
            style: AppTextStyles.medium(
                weight: FontWeight.w700, color: AppColors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildWorkshopInfoBanner(),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenH),
              itemCount: widget.selectedVehicles.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, idx) => _buildVehicleCard(
                  widget.selectedVehicles[idx], idx),
            ),
          ),

          _buildBottomSummary(
            totalServiceFee: totalServiceFee,
            totalPartPrice: totalPartPrice,
            grandTotal: grandTotal,
            unitCount: widget.selectedVehicles.length,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // WORKSHOP INFO BANNER
  // ═══════════════════════════════════════
  Widget _buildWorkshopInfoBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.lg,
        AppSpacing.screenH,
        AppSpacing.md,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            child: Image.asset(
              widget.selectedWorkshop.image,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 50,
                height: 50,
                color: AppColors.softOrange,
                child: const Icon(
                  Icons.store,
                  color: AppColors.primaryOrange,
                  size: 26,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bengkel terpilih",
                  style: AppTextStyles.small(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.selectedWorkshop.name,
                  style: AppTextStyles.medium(
                    weight: FontWeight.w700,
                    color: AppColors.primaryOrange,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // VEHICLE CARD
  // ═══════════════════════════════════════
  Widget _buildVehicleCard(Vehicle vehicle, int idx) {
    final config = _configs[idx];
    final kmController =
        _kmControllers[vehicle.id] ??= TextEditingController();
    final notesController =
        _notesControllers[vehicle.id] ??= TextEditingController();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ═══ HEADER MOTOR ═══
          Row(
            children: [
              Image.asset(
                DummyData.getMotorImage(vehicle.model),
                width: 60,
                height: 60,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.two_wheeler,
                  size: 50,
                  color: AppColors.primaryOrange,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${vehicle.brand} ${vehicle.model}",
                      style: AppTextStyles.medium(
                          weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vehicle.plateNumber,
                      style: AppTextStyles.small(
                          color: AppColors.textSecondary),
                    ),
                    Text(
                      "${vehicle.year}  •  ${vehicle.color}",
                      style: AppTextStyles.small(
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // ═══ INNER CREAM FORM ═══
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.softOrange.withValues(alpha: 0.4),
              borderRadius:
                  BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KILOMETER
                _buildLabel('Kilometer Motor'),
                const SizedBox(height: AppSpacing.xs + 2),
                _buildInput(
                  controller: kmController,
                  hint: 'Contoh : 15000',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  onChanged: (v) =>
                      _updateConfig(idx, km: int.tryParse(v)),
                ),
                const SizedBox(height: AppSpacing.md),

                // JENIS SERVIS
                _buildLabel('Pilih Jenis Servis'),
                const SizedBox(height: AppSpacing.xs + 2),
                _buildPicker(
                  hint: config.selectedServices.isEmpty
                      ? 'Servis Berkala Rutin'
                      : config.selectedServices
                          .map((s) => s.name)
                          .join(', '),
                  isPlaceholder: config.selectedServices.isEmpty,
                  hasChevron: true,
                  onTap: () => _showServicePicker(idx),
                ),
                const SizedBox(height: AppSpacing.md),

                // SUKU CADANG
                _buildLabel('Pilih Suku Cadang'),
                const SizedBox(height: AppSpacing.xs + 2),
                _buildPicker(
                  hint: config.selectedParts.isEmpty
                      ? 'Pilih Suku Cadang'
                      : "${config.selectedParts.length} suku cadang dipilih",
                  isPlaceholder: config.selectedParts.isEmpty,
                  hasChevron: true,
                  onTap: () => _showPartPicker(idx, vehicle),
                ),
                const SizedBox(height: AppSpacing.md),

                // CATATAN
                _buildLabel('Catatan Keluhan atau Perbaikan'),
                const SizedBox(height: AppSpacing.xs + 2),
                _buildInput(
                  controller: notesController,
                  hint:
                      'Contoh : Stang bergertar saat tarikan awal',
                  maxLines: 3,
                  onChanged: (v) =>
                      _updateConfig(idx, complaint: v),
                ),
                const SizedBox(height: AppSpacing.md),

                // TOGGLE JEMPUT
                _buildLabel('Jemput Dari Rumah'),
                const SizedBox(height: AppSpacing.xs + 2),
                _buildPickupToggle(idx, config),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // PICKUP TOGGLE + INFO
  // ═══════════════════════════════════════
  Widget _buildPickupToggle(int idx, VehicleServiceConfig config) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(color: AppColors.divider, width: 1),
          ),
          child: Row(
            children: [
              Icon(
                Icons.two_wheeler_outlined,
                color: config.isPickupService
                    ? AppColors.primaryOrange
                    : AppColors.textHint,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jemput Motor ke Rumah',
                      style: AppTextStyles.small(
                          weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      config.isPickupService
                          ? 'Motor akan dijemput kurir'
                          : 'Antar sendiri ke bengkel',
                      style: AppTextStyles.small(
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Switch(
                value: config.isPickupService,
                activeThumbColor: AppColors.primaryOrange,
                onChanged: (val) {
                  setState(() {
                    _updateConfig(
                      idx,
                      isPickupService: val,
                      pickupLocation: val
                          ? (config.pickupLocation ??
                              widget.userLocation)
                          : null,
                      pickupDistanceKm: val
                          ? (config.pickupDistanceKm > 0
                              ? config.pickupDistanceKm
                              : (widget.userLocation != null
                                  ? _calculateDistance(
                                      widget.userLocation!)
                                  : 3.0))
                          : 0,
                    );
                  });
                },
              ),
            ],
          ),
        ),

        if (config.isPickupService) ...[
          const SizedBox(height: AppSpacing.sm + 2),

          // LOKASI JEMPUT
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius:
                  BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(color: AppColors.divider, width: 1),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: AppColors.primaryOrange,
                ),
                const SizedBox(width: AppSpacing.sm + 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Otomatis dari lokasi Anda',
                        style: AppTextStyles.small(
                          weight: FontWeight.w600,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        config.pickupLocation?.displayAddress ??
                            'Lokasi belum tersedia',
                        style: AppTextStyles.small(
                          color: config.pickupLocation == null
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final result =
                        await Navigator.push<PickupLocation>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LocationPickerScreen(
                          initialLocation: config.pickupLocation,
                        ),
                      ),
                    );

                    if (result != null) {
                      final distance = _calculateDistance(result);
                      setState(() {
                        _updateConfig(
                          idx,
                          pickupLocation: result,
                          pickupDistanceKm: distance,
                        );
                      });
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm),
                    minimumSize: const Size(0, 32),
                    tapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Ubah',
                    style: AppTextStyles.small(
                      color: AppColors.primaryOrange,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm + 2),

          // BIAYA JEMPUT
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.softOrange.withValues(alpha: 0.6),
              borderRadius:
                  BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(
                color:
                    AppColors.primaryOrange.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 18,
                  color: AppColors.primaryOrange,
                ),
                const SizedBox(width: AppSpacing.sm + 2),
                Expanded(
                  child: Text(
                    'Biaya Jemput ${CurrencyFormatter.format(config.pickupFee)} '
                    '(${config.pickupDistanceKm.toStringAsFixed(1)} km × Rp 5.000)',
                    style: AppTextStyles.small(
                      weight: FontWeight.w600,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════
  // LABEL / INPUT / PICKER
  // ═══════════════════════════════════════
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.small(weight: FontWeight.w600),
    );
  }

  Widget _buildInput({
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        style: AppTextStyles.small(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.small(
            weight: FontWeight.w300,
            color: AppColors.textHint,
          ),
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildPicker({
    required String hint,
    IconData? icon,
    bool hasChevron = false,
    bool isPlaceholder = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: AppColors.divider, width: 1),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 17, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.sm + 2),
            ],
            Expanded(
              child: Text(
                hint,
                style: AppTextStyles.small(
                  weight: FontWeight.w300,
                  color: isPlaceholder
                      ? AppColors.textHint
                      : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasChevron)
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // BOTTOM SUMMARY
  // ═══════════════════════════════════════
  Widget _buildBottomSummary({
    required int totalServiceFee,
    required int totalPartPrice,
    required int grandTotal,
    required int unitCount,
  }) {
    final totalPickupFee =
        _configs.fold<int>(0, (sum, c) => sum + c.pickupFee);
    final totalDiscount =
        _configs.fold<int>(0, (sum, c) => sum + c.discountAmount);
    final finalTotal = totalServiceFee +
        totalPartPrice +
        totalPickupFee -
        totalDiscount;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenH,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _rowSummary("Biaya Jasa", totalServiceFee),
            const SizedBox(height: AppSpacing.xs),
            _rowSummary("Suku Cadang", totalPartPrice),
            if (totalPickupFee > 0) ...[
              const SizedBox(height: AppSpacing.xs),
              _rowSummary("Biaya Jemput", totalPickupFee),
            ],
            if (totalDiscount > 0) ...[
              const SizedBox(height: AppSpacing.xs),
              _rowSummaryVoucher("Diskon Voucher", -totalDiscount),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total $unitCount Unit",
                  style: AppTextStyles.medium(
                      weight: FontWeight.w700),
                ),
                Text(
                  CurrencyFormatter.format(finalTotal),
                  style: AppTextStyles.medium(
                    weight: FontWeight.w700,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showConfirmDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusXl),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Selanjutnya",
                  style: AppTextStyles.medium(
                    weight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowSummary(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.small(
                color: AppColors.textSecondary)),
        Text(CurrencyFormatter.format(value),
            style: AppTextStyles.small(
                color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _rowSummaryVoucher(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.small(
                color: AppColors.success)),
        Text(CurrencyFormatter.format(value),
            style: AppTextStyles.small(
                weight: FontWeight.w600,
                color: AppColors.success)),
      ],
    );
  }
}