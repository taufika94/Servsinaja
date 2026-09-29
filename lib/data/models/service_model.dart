import 'pickup_location_model.dart';

// ═══════════════════════════════════════
// PART SELECTION TYPE
// ═══════════════════════════════════════
enum PartSelectionType { single, multiple }

// ═══════════════════════════════════════
// VOUCHER TYPE
// ═══════════════════════════════════════
enum VoucherType { nominal, percent }

// ═══════════════════════════════════════
// VOUCHER
// ═══════════════════════════════════════
class Voucher {
  final String code;
  final String title;
  final String description;
  final VoucherType type;
  final int discountValue;
  final int maxDiscount;
  final int minTransaction;
  final bool isActive;

  Voucher({
    required this.code,
    required this.title,
    required this.description,
    required this.type,
    required this.discountValue,
    this.maxDiscount = 0,
    this.minTransaction = 0,
    this.isActive = true,
  });

  int calculateDiscount(int total) {
    if (total < minTransaction) return 0;
    if (type == VoucherType.percent) {
      final disc = (total * discountValue / 100).round();
      return maxDiscount > 0 && disc > maxDiscount ? maxDiscount : disc;
    }
    return discountValue;
  }

  bool isValidFor(int total) {
    return isActive && total >= minTransaction;
  }
}

// ═══════════════════════════════════════
// TIER SUKU CADANG
// ═══════════════════════════════════════
enum PartTier { original, aftermarket, kw }

extension PartTierExt on PartTier {
  String get label {
    switch (this) {
      case PartTier.original:
        return 'Original';
      case PartTier.aftermarket:
        return 'Aftermarket';
      case PartTier.kw:
        return 'KW / Lokal';
    }
  }

  String get description {
    switch (this) {
      case PartTier.original:
        return 'Part resmi pabrikan, presisi & bergaransi';
      case PartTier.aftermarket:
        return 'Merek pihak ketiga, harga bervariasi';
      case PartTier.kw:
        return 'Part lokal, harga murah, kualitas tidak terjamin';
    }
  }
}

// ═══════════════════════════════════════
// SERVICE OPTION
// ═══════════════════════════════════════
class ServiceOption {
  final String id;
  final String name;
  final int serviceFee;
  final int durationMinutes;
  final String description;
  final String detail;
  final List<String> includes;
  final List<String> excludes;
  final List<String> requiredPartCategories;
  final List<String> optionalPartCategories;
  final int warrantyDays;
  final String serviceType;

  ServiceOption({
    required this.id,
    required this.name,
    required this.serviceFee,
    required this.durationMinutes,
    required this.description,
    required this.detail,
    this.includes = const [],
    this.excludes = const [],
    this.requiredPartCategories = const [],
    this.optionalPartCategories = const [],
    this.warrantyDays = 7,
    this.serviceType = 'Rutin',
  });
}

// ═══════════════════════════════════════
// SPARE PART
// ═══════════════════════════════════════
class SparePart {
  final String id;
  final String name;
  final int price;
  final String category;
  final String description;
  final String exclusiveGroup;
  final PartTier tier;
  final String brand;
  final int warrantyDays;
  final List<String> compatibleModels;
  final bool isRecommended;

  SparePart({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    required this.exclusiveGroup,
    this.tier = PartTier.original,
    this.brand = '',
    this.warrantyDays = 7,
    this.compatibleModels = const [],
    this.isRecommended = false,
  });
}

// ═══════════════════════════════════════
// VEHICLE SERVICE CONFIG
// ═══════════════════════════════════════
class VehicleServiceConfig {
  final String vehicleId;
  final List<ServiceOption> selectedServices;
  final List<SparePart> selectedParts;
  final String complaint;
  final int? currentKm;
  final DateTime? lastServiceDate;

  // ═══ FITUR JEMPUT ═══
  final bool isPickupService;
  final PickupLocation? pickupLocation;
  final double pickupDistanceKm;

  // ═══ VOUCHER ═══
  final Voucher? appliedVoucher;

  VehicleServiceConfig({
    required this.vehicleId,
    this.selectedServices = const [],
    this.selectedParts = const [],
    this.complaint = '',
    this.currentKm,
    this.lastServiceDate,
    this.isPickupService = false,
    this.pickupLocation,
    this.pickupDistanceKm = 0,
    this.appliedVoucher,
  });

  // ═══ Backward compatible ═══
  String? get pickupAddress => pickupLocation?.displayAddress;


  bool isServiceCovered(String serviceId) {
    return selectedServices.any(
      (s) => s.includes.contains(serviceId) && s.id != serviceId,
    );
  }

  bool isServiceDisabled(String serviceId) {
    return selectedServices.any((s) => s.excludes.contains(serviceId));
  }

  int get totalServiceFee {
    return selectedServices
        .where((s) => !isServiceCovered(s.id))
        .fold<int>(0, (sum, s) => sum + s.serviceFee);
  }

  int get totalPartPrice {
    return selectedParts.fold<int>(0, (sum, p) => sum + p.price);
  }

  int get totalPrice => totalServiceFee + totalPartPrice;

  int get totalDuration {
    return selectedServices.fold<int>(0, (sum, s) => sum + s.durationMinutes);
  }

  // ═══ BIAYA JEMPUT ═══
  int get pickupFee {
    if (!isPickupService) return 0;
    final fee = (pickupDistanceKm * 5000).round();
    return fee < 10000 ? 10000 : fee;
  }

  int get subtotal => totalPrice + pickupFee;

  // ═══ DISKON VOUCHER ═══
  int get discountAmount {
    if (appliedVoucher == null) return 0;
    return appliedVoucher!.calculateDiscount(subtotal);
  }

  int get grandTotal => subtotal - discountAmount;

  Set<String> get requiredCategories {
    final set = <String>{};
    for (var s in selectedServices) {
      set.addAll(s.requiredPartCategories);
    }
    return set;
  }

  Set<String> get optionalCategories {
    final set = <String>{};
    for (var s in selectedServices) {
      set.addAll(s.optionalPartCategories);
    }
    return set;
  }

  List<String> get missingRequiredCategories {
    final missing = <String>[];
    for (var category in requiredCategories) {
      final hasPart = selectedParts.any((p) => p.category == category);
      if (!hasPart) missing.add(category);
    }
    return missing;
  }

  SparePart? getPartInCategory(String category) {
    try {
      return selectedParts.firstWhere((p) => p.category == category);
    } catch (e) {
      return null;
    }
  }

  int get maxServiceWarranty {
    if (selectedServices.isEmpty) return 0;
    return selectedServices
        .map((s) => s.warrantyDays)
        .reduce((a, b) => a > b ? a : b);
  }

  int get maxPartWarranty {
    if (selectedParts.isEmpty) return 0;
    return selectedParts
        .map((p) => p.warrantyDays)
        .reduce((a, b) => a > b ? a : b);
  }
}
