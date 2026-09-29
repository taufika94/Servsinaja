import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/service_history_model.dart';
import '../../data/models/service_model.dart';
import '../../data/models/vehicle_model.dart';
import '../../data/models/workshop_model.dart';
import 'booking_success_screen.dart';

class BookingSummaryScreen extends StatefulWidget {
  final List<Vehicle> vehicles;
  final List<VehicleServiceConfig> configs;
  final Workshop workshop;
  final DateTime date;
  final String time;
  final Map<String, Map<String, dynamic>>? vehicleSchedules;

  const BookingSummaryScreen({
    super.key,
    required this.vehicles,
    required this.configs,
    required this.workshop,
    required this.date,
    required this.time,
    this.vehicleSchedules,
  });

  @override
  State<BookingSummaryScreen> createState() =>
      _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  // ═══ STATE PEMBAYARAN ═══
  int _selectedPaymentIndex = 0;

  // ═══ STATE VOUCHER ═══
  Voucher? _activeVoucher;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'name': 'Kartu Kredit / Debit',
      'cardNumber': '**** 1234',
      'color': const Color(0xFF1A1F71),
    },
    {
      'name': 'Kartu Kredit',
      'cardNumber': '**** 7668',
      'color': const Color(0xFF1A1F71),
    },
  ];

  @override
  void initState() {
    super.initState();
    // Ambil voucher aktif dari DummyData
    _activeVoucher = DummyData.activeVoucher;
  }

  // ═══ GETTERS ═══
  int get _totalServiceFee =>
      widget.configs.fold<int>(0, (sum, c) => sum + c.totalServiceFee);

  int get _totalPartPrice =>
      widget.configs.fold<int>(0, (sum, c) => sum + c.totalPartPrice);

  int get _totalPickupFee =>
      widget.configs.fold<int>(0, (sum, c) => sum + c.pickupFee);

  int get _subtotal =>
      _totalServiceFee + _totalPartPrice + _totalPickupFee;

  // ═══ DISKON DARI VOUCHER AKTIF ═══
  int get _totalDiscount {
    if (_activeVoucher == null) return 0;
    return _activeVoucher!.calculateDiscount(_subtotal);
  }

  int get _grandTotal => _subtotal - _totalDiscount;

  int get _totalDuration =>
      widget.configs.fold<int>(0, (sum, c) => sum + c.totalDuration);

  bool get _hasAnyPickup =>
      widget.configs.any((c) => c.isPickupService);

  DateTime _getVehicleDate(String vehicleId) {
    final sched = widget.vehicleSchedules?[vehicleId];
    return (sched?['date'] as DateTime?) ?? widget.date;
  }

  String _getVehicleTime(String vehicleId) {
    final sched = widget.vehicleSchedules?[vehicleId];
    return (sched?['time'] as String?) ?? widget.time;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.primaryOrange,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Text(
          "Ringkasan Booking",
          style: AppTextStyles.medium(
            weight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),

            // ═══ 1. BENGKEL ═══
            _buildSectionTitle("Bengkel Terpilih"),
            const SizedBox(height: AppSpacing.sm + 2),
            _buildWorkshopCard(),
            const SizedBox(height: AppSpacing.md),

            // ═══ 2. PICKUP BANNER ═══
            if (_hasAnyPickup) ...[
              _buildPickupBanner(),
              const SizedBox(height: AppSpacing.md),
            ],

            // ═══ 3. JADWAL ═══
            _buildSectionTitle("Jadwal Kedatangan"),
            const SizedBox(height: AppSpacing.sm + 2),
            ...widget.vehicles
                .map((v) => _buildVehicleScheduleCard(v)),
            const SizedBox(height: AppSpacing.md),

            // ═══ 4. DETAIL KENDARAAN ═══
            _buildSectionTitle("Detail Kendaraan"),
            const SizedBox(height: AppSpacing.sm + 2),
            ...widget.vehicles
                .map((v) => _buildVehicleDetailCard(v)),
            const SizedBox(height: AppSpacing.md),

            // ═══ 5. PILIH METODE PEMBAYARAN ═══
            _buildSectionTitle("Pilih Metode Pembayaran"),
            const SizedBox(height: AppSpacing.sm + 2),
            ..._paymentMethods.asMap().entries.map((entry) {
              final index = entry.key;
              final method = entry.value;
              return _buildPaymentMethodTile(index, method);
            }),
            const SizedBox(height: AppSpacing.md),

            // ═══ 6. RINGKASAN BIAYA ═══
            _buildSectionTitle("Ringkasan Biaya"),
            const SizedBox(height: AppSpacing.sm + 2),
            _buildSummaryCard(),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),

      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.medium(weight: FontWeight.w700),
    );
  }

  // ═══════════════════════════════════════
  // WORKSHOP CARD
  // ═══════════════════════════════════════
  Widget _buildWorkshopCard() {
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            child: Image.asset(
              widget.workshop.image,
              width: 70,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 70,
                height: 60,
                color: AppColors.softOrange,
                child: const Icon(
                  Icons.store,
                  color: AppColors.primaryOrange,
                  size: 28,
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
                  widget.workshop.name,
                  style:
                      AppTextStyles.medium(weight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.workshop.address,
                  style: AppTextStyles.small(
                      color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs + 2),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 16, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      widget.workshop.rating.toStringAsFixed(1),
                      style: AppTextStyles.small(
                          weight: FontWeight.w700),
                    ),
                    Text(
                      ' (${widget.workshop.reviewCount})',
                      style: AppTextStyles.small(
                          color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Icon(Icons.near_me_outlined,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 2),
                    Text(
                      '${widget.workshop.distanceKm} km',
                      style: AppTextStyles.small(
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // PICKUP BANNER
  // ═══════════════════════════════════════
  Widget _buildPickupBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.softOrange.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: AppColors.primaryOrange.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            child: const Icon(
              Icons.two_wheeler_outlined,
              color: AppColors.primaryOrange,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Layanan Jemput Motor Aktif",
                  style:
                      AppTextStyles.small(weight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  "Kurir akan menghubungi Anda 30 menit sebelum penjemputan",
                  style: AppTextStyles.small(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // VEHICLE SCHEDULE CARD
  // ═══════════════════════════════════════
  Widget _buildVehicleScheduleCard(Vehicle vehicle) {
    final vDate = _getVehicleDate(vehicle.id);
    final vTime = _getVehicleTime(vehicle.id);
    final config = widget.configs
        .firstWhere((c) => c.vehicleId == vehicle.id);
    final isPickup = config.isPickupService;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: "Tanggal Servis",
            value:
                "${vDate.day.toString().padLeft(2, '0')}/${vDate.month.toString().padLeft(2, '0')}/${vDate.year}",
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          _buildInfoRow(
            icon: Icons.access_time,
            label: "Jam Kedatangan",
            value: vTime,
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          if (isPickup)
            _buildInfoRow(
              icon: Icons.two_wheeler_outlined,
              label: "Dijemput",
              value: "Kurir datang ke lokasi Anda",
            )
          else
            _buildInfoRow(
              icon: Icons.directions_bike,
              label: "Datang",
              value: "Antar sendiri ke bengkel",
            ),
          if (isPickup && config.pickupLocation != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.softOrange.withValues(alpha: 0.5),
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.two_wheeler_outlined,
                          size: 16,
                          color: AppColors.primaryOrange),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        "Dijemput ke rumah",
                        style: AppTextStyles.small(
                            weight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm + 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.primaryOrange),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Dijemput dari",
                              style: AppTextStyles.small(
                                  weight: FontWeight.w600,
                                  color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              config.pickupLocation!.address,
                              style: AppTextStyles.small(
                                color: AppColors.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primaryOrange),
        const SizedBox(width: AppSpacing.sm + 2),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.small(
                color: AppColors.textSecondary),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.small(weight: FontWeight.w700),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════
  // VEHICLE DETAIL CARD
  // ═══════════════════════════════════════
  Widget _buildVehicleDetailCard(Vehicle vehicle) {
    final config = widget.configs
        .firstWhere((c) => c.vehicleId == vehicle.id);
    final isPickup = config.isPickupService;
    final subtotal =
        config.totalPrice + (isPickup ? config.pickupFee : 0);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
          Row(
            children: [
              Image.asset(
                DummyData.getMotorImage(vehicle.model),
                width: 50,
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
                  "${vehicle.brand} ${vehicle.model}",
                  style: AppTextStyles.medium(
                      weight: FontWeight.w700),
                ),
              ),
              Text(
                vehicle.plateNumber,
                style: AppTextStyles.small(
                    color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.softOrange.withValues(alpha: 0.4),
              borderRadius:
                  BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Column(
              children: [
                ...config.selectedServices.map((s) {
                  final isCovered = config.isServiceCovered(s.id);
                  return Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppSpacing.sm),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            s.name,
                            style: AppTextStyles.small(
                                color: AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          isCovered
                              ? "GRATIS"
                              : CurrencyFormatter.format(
                                  s.serviceFee),
                          style: AppTextStyles.small(
                            weight: FontWeight.w700,
                            color: isCovered
                                ? AppColors.success
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (isPickup)
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppSpacing.sm),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Biaya Jemput",
                          style: AppTextStyles.small(
                              color: AppColors.textSecondary),
                        ),
                        Text(
                          CurrencyFormatter.format(
                              config.pickupFee),
                          style: AppTextStyles.small(
                              weight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Subtotal",
                      style: AppTextStyles.small(
                          color: AppColors.textSecondary),
                    ),
                    Text(
                      CurrencyFormatter.format(subtotal),
                      style: AppTextStyles.small(
                          weight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // PAYMENT METHOD TILE
  // ═══════════════════════════════════════
  Widget _buildPaymentMethodTile(int index, Map<String, dynamic> method) {
    final isSelected = _selectedPaymentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentIndex = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius:
              BorderRadius.circular(AppSpacing.radiusSm),
          border: isSelected
              ? Border.all(
                  color: AppColors.primaryOrange, width: 1.5)
              : Border.all(color: AppColors.divider, width: 1),
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
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: method['color'] as Color,
                borderRadius:
                    BorderRadius.circular(AppSpacing.xs + 2),
              ),
              child: const Center(
                child: Icon(
                  Icons.credit_card,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                method['cardNumber'] as String,
                style: AppTextStyles.medium(
                    weight: FontWeight.w700),
              ),
            ),
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
                      color: AppColors.white, size: 12)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // SUMMARY CARD
  // ═══════════════════════════════════════
  Widget _buildSummaryCard() {
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
        children: [
          _buildSummaryRow(
              "Jumlah unit", "${widget.vehicles.length} motor"),
          const SizedBox(height: AppSpacing.sm + 2),
          _buildSummaryRow(
            "Total Durasi",
            "${_totalDuration ~/ 60} jam ${_totalDuration % 60} menit",
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          _buildSummaryRow("Biaya Jasa",
              CurrencyFormatter.format(_totalServiceFee)),
          const SizedBox(height: AppSpacing.sm + 2),
          _buildSummaryRow("Suku Cadang",
              CurrencyFormatter.format(_totalPartPrice)),
          const SizedBox(height: AppSpacing.sm + 2),
          _buildSummaryRow("Biaya Jemput",
              CurrencyFormatter.format(_totalPickupFee)),

          // ═══ VOUCHER ROW ═══
          if (_activeVoucher != null) ...[
            const SizedBox(height: AppSpacing.sm + 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_offer,
                        size: 14, color: AppColors.success),
                    const SizedBox(width: 6),
                    Text("Voucher ${_activeVoucher!.code}",
                        style: AppTextStyles.small(
                            color: AppColors.success)),
                  ],
                ),
                Text(
                  '- ${CurrencyFormatter.format(_totalDiscount)}',
                  style: AppTextStyles.small(
                      weight: FontWeight.w700,
                      color: AppColors.success),
                ),
              ],
            ),
          ],

          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
            child: Divider(height: 1, color: AppColors.divider),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Subtotal",
                style:
                    AppTextStyles.medium(weight: FontWeight.w700),
              ),
              Text(
                CurrencyFormatter.format(_grandTotal),
                style: AppTextStyles.medium(
                    weight: FontWeight.w700),
              ),
            ],
          ),

          // ═══ TOMBOL PILIH VOUCHER ═══
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showVoucherPicker,
              icon: const Icon(Icons.local_offer_outlined,
                  size: 18, color: AppColors.primaryOrange),
              label: Text(
                _activeVoucher == null
                    ? 'Pilih Voucher'
                    : 'Voucher: ${_activeVoucher!.code}',
                style: AppTextStyles.medium(
                  weight: FontWeight.w700,
                  color: AppColors.primaryOrange,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusXl),
                ),
                side: const BorderSide(
                    color: AppColors.primaryOrange, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.small(
                color: AppColors.textSecondary)),
        Text(value,
            style: AppTextStyles.small(weight: FontWeight.w600)),
      ],
    );
  }

  // ═══════════════════════════════════════
  // VOUCHER PICKER (Bottom Sheet)
  // ═══════════════════════════════════════
  void _showVoucherPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final claimed = DummyData.claimedVouchers;

          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
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
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  "Pilih Voucher",
                  style: AppTextStyles.medium(
                      weight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  "Voucher terklaim: ${claimed.length}",
                  style: AppTextStyles.small(
                      color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.lg),

                if (claimed.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.local_offer_outlined,
                            size: 60,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Belum ada voucher terklaim',
                            style: AppTextStyles.medium(
                                weight: FontWeight.w600),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Klaim voucher di halaman Promo',
                            style: AppTextStyles.small(
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildVoucherOption(
                            voucher: null,
                            isSelected: _activeVoucher == null,
                            onTap: () {
                              setState(() {
                                _activeVoucher = null;
                                DummyData.setActiveVoucher(null);
                              });
                              setSheetState(() {});
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ...claimed.map((v) {
                            final isSelected =
                                _activeVoucher?.code == v.code;
                            final isValid =
                                _subtotal >= v.minTransaction;

                            return Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm),
                              child: _buildVoucherOption(
                                voucher: v,
                                isSelected: isSelected,
                                isDisabled: !isValid,
                                onTap: isValid
                                    ? () {
                                        setState(() {
                                          _activeVoucher = v;
                                          DummyData.setActiveVoucher(
                                              v);
                                        });
                                        setSheetState(() {});
                                        Navigator.pop(context);
                                      }
                                    : null,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVoucherOption({
    required Voucher? voucher,
    required bool isSelected,
    bool isDisabled = false,
    VoidCallback? onTap,
  }) {
    if (voucher == null) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: isSelected
                ? Border.all(
                    color: AppColors.primaryOrange, width: 1.5)
                : Border.all(color: AppColors.divider, width: 1),
          ),
          child: Row(
            children: [
              const Icon(Icons.block,
                  size: 20, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.sm + 2),
              Expanded(
                child: Text(
                  'Tidak pakai voucher',
                  style: AppTextStyles.small(
                      weight: FontWeight.w600),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle,
                    color: AppColors.primaryOrange, size: 20),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isDisabled ? 0.4 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: isSelected
                ? Border.all(
                    color: AppColors.primaryOrange, width: 1.5)
                : Border.all(color: AppColors.divider, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      voucher.title,
                      style: AppTextStyles.small(
                          weight: FontWeight.w700),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle,
                        color: AppColors.primaryOrange, size: 20),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                voucher.description,
                style: AppTextStyles.small(
                    color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.softOrange,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.xs),
                    ),
                    child: Text(
                      voucher.code,
                      style: AppTextStyles.small(
                        weight: FontWeight.w700,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Min. ${CurrencyFormatter.format(voucher.minTransaction)}',
                    style: AppTextStyles.small(
                        color: AppColors.textHint),
                  ),
                  if (isDisabled) ...[
                    const Spacer(),
                    Text(
                      'Min. belum tercapai',
                      style: AppTextStyles.small(
                          color: AppColors.danger),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // BOTTOM BAR — "BAYAR & BOOKING"
  // ═══════════════════════════════════════
  Widget _buildBottomBar(BuildContext context) {
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
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _onConfirm(context),
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
              "Bayar & Booking",
              style: AppTextStyles.medium(
                weight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onConfirm(BuildContext context) {
    final ticketNumber =
        'SRV-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    _saveToHistory(ticketNumber);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingSuccessScreen(
          vehicles: widget.vehicles,
          configs: widget.configs,
          workshop: widget.workshop.name,
          date: widget.date,
          time: widget.time,
          totalPrice: _grandTotal,
          totalDuration: _totalDuration,
        ),
      ),
    );
  }

  void _saveToHistory(String ticketNumber) {
    for (var vehicle in widget.vehicles) {
      final config = widget.configs
          .firstWhere((c) => c.vehicleId == vehicle.id);

      final paidServices = config.selectedServices
          .where((s) => !config.isServiceCovered(s.id))
          .map((s) => s.name)
          .join(', ');

      final serviceName = paidServices.isNotEmpty
          ? paidServices
          : config.selectedServices.map((s) => s.name).join(', ');

      final history = ServiceHistory(
        id:
            'H-${DateTime.now().millisecondsSinceEpoch}-${vehicle.id}',
        ticketNumber: ticketNumber,
        vehicleId: vehicle.id,
        vehicleName: '${vehicle.brand} ${vehicle.model}',
        plateNumber: vehicle.plateNumber,
        serviceType: serviceName,
        date: DateTime.now(),
        totalPrice: config.totalPrice,
        status: 'Menunggu Konfirmasi',
        workshop: widget.workshop.name,
        currentKm: config.currentKm ?? 0,
      );

      DummyData.addHistory(history);
    }
  }
}