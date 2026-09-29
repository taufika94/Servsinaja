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
import 'main_screen.dart';

class BookingSuccessScreen extends StatefulWidget {
  final List<Vehicle> vehicles;
  final List<VehicleServiceConfig> configs;
  final String workshop;
  final DateTime date;
  final String time;
  final int totalPrice;
  final int totalDuration;

  const BookingSuccessScreen({
    super.key,
    required this.vehicles,
    required this.configs,
    required this.workshop,
    required this.date,
    required this.time,
    required this.totalPrice,
    required this.totalDuration,
  });

  @override
  State<BookingSuccessScreen> createState() =>
      _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen> {
  String get _ticketNumber =>
      'SRV-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

  @override
  void initState() {
    super.initState();
    
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ═══ APPBAR ═══
      appBar: AppBar(
        backgroundColor: AppColors.primaryOrange,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Text(
          "Booking Berhasil",
          style: AppTextStyles.medium(
            weight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
      ),

      // ═══ BODY ═══
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenH),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),

            // ═══ ICON SUKSES ═══
            SizedBox(
              width: 100,
              height: 100,
              child: CustomPaint(
                painter: _RosettePainter(
                  color: AppColors.success,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check,
                    color: AppColors.white,
                    size: 45,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ═══ TITLE ═══
            Text(
              "Booking Berhasil!",
              style: AppTextStyles.medium(
                weight: FontWeight.w700,
                color: AppColors.textPrimary,
              ).copyWith(fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              "Tiket servis Anda telah dibuat",
              textAlign: TextAlign.center,
              style: AppTextStyles.small(
                  color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ═══ TIKET ═══
            _buildTicketCard(),

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),

      // ═══ BOTTOM BAR ═══
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  // ═══════════════════════════════════════
  // TICKET CARD
  // ═══════════════════════════════════════
  Widget _buildTicketCard() {
    return Container(
      width: double.infinity,
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
          // ═══ HEADER: NO TIKET + BADGE ═══
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "No. Tiket",
                    style: AppTextStyles.small(
                        color: AppColors.textHint),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _ticketNumber,
                    style: AppTextStyles.small(
                      weight: FontWeight.w700,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange,
                  borderRadius: BorderRadius.circular(
                      AppSpacing.radiusSm),
                ),
                child: Text(
                  "Menunggu Konfirmasi",
                  style: AppTextStyles.small(
                    weight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
            child: Divider(height: 1, color: AppColors.divider),
          ),

          // ═══ INFO ROWS ═══
          _buildInfoRow(Icons.store, widget.workshop),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoRow(
            Icons.calendar_today,
            "${widget.date.day.toString().padLeft(2, '0')}/${widget.date.month.toString().padLeft(2, '0')}/${widget.date.year}  •  ${widget.time}",
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoRow(
            Icons.two_wheeler,
            "${widget.vehicles.length} kendaraan",
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
            child: Divider(height: 1, color: AppColors.divider),
          ),

          // ═══ RINCIAN PER KENDARAAN ═══
          Text(
            "Rincian Setiap Kendaraan",
            style: AppTextStyles.small(
                weight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),

          ...List.generate(widget.vehicles.length, (i) {
            final v = widget.vehicles[i];
            final config = widget.configs
                .firstWhere((c) => c.vehicleId == v.id);

            final paidServices = config.selectedServices
                .where((s) => !config.isServiceCovered(s.id))
                .toList();
            final freeServices = config.selectedServices
                .where((s) => config.isServiceCovered(s.id))
                .toList();

            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.softOrange.withValues(alpha: 0.4),
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ═══ BARIS 1: BADGE UNIT + NAMA MOTOR ═══
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.xs),
                        ),
                        child: Text(
                          "Unit ${i + 1}",
                          style: AppTextStyles.small(
                            weight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          "${v.brand} ${v.model}",
                          style: AppTextStyles.small(
                            weight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // ═══ BARIS 2: PLAT NOMOR ═══
                  Text(
                    v.plateNumber,
                    style: AppTextStyles.small(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // ═══ BARIS 3+: SERVICES ═══
                  ...paidServices.map((s) => Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          s.name,
                          style: AppTextStyles.small(
                              weight: FontWeight.w500),
                        ),
                      )),
                  ...freeServices.map((s) => Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          "${s.name} (GRATIS)",
                          style: AppTextStyles.small(
                              color: AppColors.success),
                        ),
                      )),
                ],
              ),
            );
          }),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
            child: Divider(height: 1, color: AppColors.divider),
          ),

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
                CurrencyFormatter.format(widget.totalPrice),
                style: AppTextStyles.small(
                    weight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // INFO ROW
  // ═══════════════════════════════════════
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryOrange),
        const SizedBox(width: AppSpacing.sm + 2),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.small(
              weight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════
  // BOTTOM BAR
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
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => const MainScreen()),
                (route) => false,
              );
            },
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
              "Kembali ke Beranda",
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
}

// ═══════════════════════════════════════
// ROSETTE PAINTER (untuk icon sukses)
// ═══════════════════════════════════════
class _RosettePainter extends CustomPainter {
  final Color color;

  _RosettePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.82;

    const points = 12; // jumlah gerigi
    const angleStep = 3.141592653589793 * 2 / (points * 2);

    final path = Path();
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = i * angleStep - 3.141592653589793 / 2;
      final x = center.dx + radius * _cos(angle);
      final y = center.dy + radius * _sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  double _cos(double angle) => _taylorCos(angle);
  double _sin(double angle) => _taylorSin(angle);

  double _taylorCos(double x) {
    while (x > 3.141592653589793) {
      x -= 2 * 3.141592653589793;
    }
    while (x < -3.141592653589793) {
      x += 2 * 3.141592653589793;
    }

    final x2 = x * x;
    return 1 -
        x2 / 2 +
        x2 * x2 / 24 -
        x2 * x2 * x2 / 720 +
        x2 * x2 * x2 * x2 / 40320;
  }

  double _taylorSin(double x) {
    while (x > 3.141592653589793) {
      x -= 2 * 3.141592653589793;
    }
    while (x < -3.141592653589793) {
      x += 2 * 3.141592653589793;
    }

    final x2 = x * x;
    return x -
        x * x2 / 6 +
        x * x2 * x2 / 120 -
        x * x2 * x2 * x2 / 5040 +
        x * x2 * x2 * x2 * x2 / 362880;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}