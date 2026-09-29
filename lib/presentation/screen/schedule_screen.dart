import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/dummy/auth_service.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/pickup_location_model.dart';
import '../../data/models/vehicle_model.dart';
import '../../data/models/workshop_model.dart';
import 'location_picker_screen.dart';
import 'service_config_screen.dart';

class ScheduleScreen extends StatefulWidget {
  final List<Vehicle> vehicles;

  const ScheduleScreen({
    super.key,
    required this.vehicles,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // ═══ STATE ═══
  List<Workshop> _sortedWorkshops = [];
  Workshop? _selectedWorkshop;

  double? _userLat;
  double? _userLng;
  String _userAddress = '';
  bool _isLoadingLocation = false;
  bool _isLoadingAddress = false;
  String _locationSource = 'unknown';

  final Map<String, DateTime> _vehicleDates = {};
  final Map<String, String> _vehicleTimes = {};

  @override
  void initState() {
    super.initState();
    _sortedWorkshops = List.from(DummyData.workshops);
    _detectUserLocation();
  }

  // ═══════════════════════════════════════
  // DETEKSI LOKASI USER + REVERSE GEOCODE
  // ═══════════════════════════════════════
  Future<void> _detectUserLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      LocationPermission permission =
          await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 8),
        );

        if (mounted) {
          setState(() {
            _userLat = position.latitude;
            _userLng = position.longitude;
            _locationSource = 'gps';
          });
        }

        // ═══ REVERSE GEOCODE: koordinat → alamat lengkap ═══
        await _reverseGeocode(position.latitude, position.longitude);

        _sortWorkshopsByDistance();
        if (mounted) setState(() => _isLoadingLocation = false);
        return;
      }
    } catch (_) {}

    // Fallback: alamat profil
    if (mounted) {
      setState(() {
        _userLat = -7.7956;
        _userLng = 110.3695;
        _userAddress =
            AuthService.currentUser?.address ?? 'Lokasi Anda';
        _locationSource = 'profile';
      });
      _sortWorkshopsByDistance();
      setState(() => _isLoadingLocation = false);
    }
  }

  // ═══════════════════════════════════════
  // REVERSE GEOCODE (Nominatim)
  // ═══════════════════════════════════════
  Future<void> _reverseGeocode(double lat, double lng) async {
    if (!mounted) return;
    setState(() => _isLoadingAddress = true);

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=json'
        '&lat=$lat'
        '&lon=$lng'
        '&zoom=18'
        '&addressdetails=1'
        '&accept-language=id',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'ServisinAja/1.0 (servisinaja@example.com)',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['display_name'] as String?;

        if (mounted) {
          setState(() {
            _userAddress = address ?? 'Lokasi Anda';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _userAddress = 'Lokasi saat ini';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userAddress = 'Lokasi saat ini';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingAddress = false);
      }
    }
  }

  // ═══════════════════════════════════════
  // SORT WORKSHOPS BY DISTANCE
  // ═══════════════════════════════════════
  void _sortWorkshopsByDistance() {
    if (_userLat == null || _userLng == null) return;

    final sorted = DummyData.workshops
        .where((w) => w.isOpen)
        .map((w) {
      final dist = _calculateDistance(
        _userLat!,
        _userLng!,
        w.latitude,
        w.longitude,
      );
      return w.copyWith(distanceKm: dist);
    }).toList();

    sorted.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    setState(() {
      _sortedWorkshops = sorted;
      if (_selectedWorkshop == null && sorted.isNotEmpty) {
        _selectedWorkshop = sorted.first;
      }
    });
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) *
            math.cos(lat2 * p) *
            (1 - math.cos((lon2 - lon1) * p)) /
            2;
    final km = 12742 * math.asin(math.sqrt(a));
    return double.parse(km.toStringAsFixed(2));
  }

  // ═══════════════════════════════════════
  // MANUAL PICK LOCATION
  // ═══════════════════════════════════════
  Future<void> _pickManualLocation() async {
    final result = await Navigator.push<PickupLocation>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          initialLocation: _userLat != null && _userLng != null
              ? PickupLocation(
                  latitude: _userLat!,
                  longitude: _userLng!,
                  address: _userAddress.isNotEmpty
                      ? _userAddress
                      : 'Lokasi Anda',
                )
              : null,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _userLat = result.latitude;
        _userLng = result.longitude;
        _userAddress = result.address;
        _locationSource = 'manual';
      });
      _sortWorkshopsByDistance();
    }
  }

  // ═══════════════════════════════════════
  // PICK DATE
  // ═══════════════════════════════════════
  Future<void> _pickVehicleDate(Vehicle vehicle) async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    final picked = await showDatePicker(
      context: context,
      initialDate: _vehicleDates[vehicle.id] ?? tomorrow,
      firstDate: tomorrow,
      lastDate: DateTime(now.year + 1),
      helpText: "Pilih Tanggal untuk ${vehicle.model}",
      cancelText: "Batal",
      confirmText: "Pilih",

      // ═══ THEME PUTIH KHUSUS DATE PICKER ═══
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              // Header (atas) — putih
              primary: AppColors.white,
              onPrimary: AppColors.textPrimary,

              // Background kalender — putih
              surface: AppColors.white,
              onSurface: AppColors.textPrimary,

              // Warna hari yang dipilih — orange
              secondary: AppColors.primaryOrange,
              onSecondary: AppColors.white,

              // Warna teks
              onSurfaceVariant: AppColors.textSecondary,
            ),
            // Override DatePicker theme
            datePickerTheme: DatePickerThemeData(
              // Background utama
              backgroundColor: AppColors.white,

              // Header background
              headerBackgroundColor: AppColors.white,
              headerForegroundColor: AppColors.textPrimary,

              // Tombol Cancel & OK
              cancelButtonStyle: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
              confirmButtonStyle: TextButton.styleFrom(
                foregroundColor: AppColors.primaryOrange,
              ),

              // Hari yang dipilih
              dayBackgroundColor: WidgetStateProperty.resolveWith(
                (states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.primaryOrange;
                  }
                  return Colors.transparent;
                },
              ),
              dayForegroundColor: WidgetStateProperty.resolveWith(
                (states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.white;
                  }
                  if (states.contains(WidgetState.disabled)) {
                    return AppColors.textHint;
                  }
                  return AppColors.textPrimary;
                },
              ),

              // Hari ini (border)
              todayBorder: const BorderSide(
                color: AppColors.primaryOrange,
                width: 1,
              ),
              todayForegroundColor:
                  WidgetStateProperty.all(AppColors.primaryOrange),

              // Input field (kalau pakai mode input)
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusSm),
                  borderSide:
                      const BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusSm),
                  borderSide: const BorderSide(
                      color: AppColors.primaryOrange, width: 1.5),
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _vehicleDates[vehicle.id] = picked);
    }
  }

  // ═══════════════════════════════════════
  // PICK TIME
  // ═══════════════════════════════════════
  void _pickVehicleTime(Vehicle vehicle) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: AppColors.white,
      builder: (_) => _buildTimePickerSheet(
        title: "Pilih Jam untuk ${vehicle.model}",
        selectedTime: _vehicleTimes[vehicle.id],
        onSelected: (time) {
          Navigator.pop(context);
          setState(() => _vehicleTimes[vehicle.id] = time);
        },
      ),
    );
  }

  Widget _buildTimePickerSheet({
    required String title,
    required String? selectedTime,
    required ValueChanged<String> onSelected,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
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
          Text(title,
              style: AppTextStyles.medium(weight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.xs),
          Text('Pilih salah satu jam yang tersedia',
              style: AppTextStyles.small(
                  color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: DummyData.availableTimes.map((time) {
              final isSelected = selectedTime == time;
              return GestureDetector(
                onTap: () => onSelected(time),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm + 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryOrange
                        : AppColors.white,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryOrange
                          : AppColors.divider,
                    ),
                  ),
                  child: Text(
                    time,
                    style: AppTextStyles.small(
                      weight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════
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
          "Pilih Bengkel & Jadwal",
          style: AppTextStyles.medium(
              weight: FontWeight.w700, color: AppColors.white),
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

            // 1. LOKASI BANNER
            _buildLocationBanner(),
            const SizedBox(height: AppSpacing.lg),

            // 2. PILIH BENGKEL
            _buildSectionTitle("Pilih Bengkel"),
            const SizedBox(height: AppSpacing.md),

            if (_isLoadingLocation)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primaryOrange),
                ),
              )
            else if (_sortedWorkshops.isEmpty)
              _buildEmptyWorkshop()
            else
              ..._sortedWorkshops.asMap().entries.map((entry) {
                final index = entry.key;
                final workshop = entry.value;
                final isNearest = index == 0;
                return _buildWorkshopTile(workshop,
                    isNearest: isNearest);
              }),

            const SizedBox(height: AppSpacing.xl),

            // 3. JADWAL PER MOTOR
            _buildSectionTitle("Pilih Jadwal"),
            const SizedBox(height: AppSpacing.md),
            ...widget.vehicles.map((v) => _buildVehicleScheduleCard(v)),

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: AppTextStyles.medium(weight: FontWeight.w700));
  }

  // ═══════════════════════════════════════
  // LOCATION BANNER
  // ═══════════════════════════════════════
  Widget _buildLocationBanner() {
    final sourceLabel = {
          'gps': 'Lokasi GPS',
          'profile': 'Alamat Profil',
          'manual': 'Lokasi Manual',
          'unknown': 'Lokasi Anda',
        }[_locationSource] ??
        'Lokasi Anda';

    return GestureDetector(
      onTap: _pickManualLocation,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius:
              BorderRadius.circular(AppSpacing.radiusSm),
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.softOrange,
                borderRadius:
                    BorderRadius.circular(AppSpacing.sm),
              ),
              child: const Icon(
                Icons.my_location,
                color: AppColors.primaryOrange,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sourceLabel,
                      style: AppTextStyles.small(
                          weight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  _isLoadingAddress
                      ? Row(
                          children: [
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryOrange,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Mencari alamat...',
                              style: AppTextStyles.small(
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        )
                      : Text(
                          _userAddress.isNotEmpty
                              ? _userAddress
                              : 'Mendeteksi lokasi...',
                          style: AppTextStyles.small(
                              color: AppColors.textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // WORKSHOP TILE
  // ═══════════════════════════════════════
  Widget _buildWorkshopTile(Workshop workshop,
      {bool isNearest = false}) {
    final isSelected = _selectedWorkshop?.id == workshop.id;

    return GestureDetector(
      onTap: () => setState(() => _selectedWorkshop = workshop),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.sm),
                    child: Image.asset(
                      workshop.image,
                      width: 80,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
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
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          workshop.name,
                          style: AppTextStyles.medium(
                              weight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          workshop.address,
                          style: AppTextStyles.small(
                              color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(
                            height: AppSpacing.xs + 2),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 16, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              workshop.rating.toStringAsFixed(1),
                              style: AppTextStyles.small(
                                  weight: FontWeight.w700),
                            ),
                            Text(
                              ' (${workshop.reviewCount})',
                              style: AppTextStyles.small(
                                  color: AppColors.textSecondary),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            const Icon(Icons.near_me_outlined,
                                size: 14,
                                color: AppColors.textSecondary),
                            const SizedBox(width: 2),
                            Text(
                              '${workshop.distanceKm} km',
                              style: AppTextStyles.small(
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isSelected
                        ? AppColors.primaryOrange
                        : AppColors.textHint,
                    size: 22,
                  ),
                ],
              ),
            ),
            if (isNearest)
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 3),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryOrange,
                    borderRadius: BorderRadius.only(
                      topLeft:
                          Radius.circular(AppSpacing.radiusSm),
                      bottomRight:
                          Radius.circular(AppSpacing.radiusSm),
                    ),
                  ),
                  child: Text(
                    'Terdekat',
                    style: AppTextStyles.small(
                      color: AppColors.white,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // EMPTY WORKSHOP
  // ═══════════════════════════════════════
  Widget _buildEmptyWorkshop() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          const Icon(Icons.store_mall_directory_outlined,
              size: 60, color: AppColors.textHint),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Semua Bengkel Sedang Tutup',
            style:
                AppTextStyles.medium(weight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Silakan coba lagi nanti',
            style: AppTextStyles.small(
                color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // VEHICLE SCHEDULE CARD
  // ═══════════════════════════════════════
  Widget _buildVehicleScheduleCard(Vehicle vehicle) {
    final date = _vehicleDates[vehicle.id];
    final time = _vehicleTimes[vehicle.id];

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

          // INNER CREAM
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
                Text('Tanggal Servis',
                    style: AppTextStyles.small(
                        weight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.xs + 2),
                GestureDetector(
                  onTap: () => _pickVehicleDate(vehicle),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm + 2),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm),
                      border: Border.all(
                          color: AppColors.divider, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: AppColors.textSecondary),
                        const SizedBox(
                            width: AppSpacing.sm + 2),
                        Expanded(
                          child: Text(
                            date == null
                                ? 'Pilih Tanggal'
                                : DummyData.formatTanggalId(date),
                            style: AppTextStyles.small(
                              color: date == null
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Jam Kedatangan',
                    style: AppTextStyles.small(
                        weight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.xs + 2),
                GestureDetector(
                  onTap: () => _pickVehicleTime(vehicle),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm + 2),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm),
                      border: Border.all(
                          color: AppColors.divider, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 16,
                            color: AppColors.textSecondary),
                        const SizedBox(
                            width: AppSpacing.sm + 2),
                        Expanded(
                          child: Text(
                            time ?? 'Pilih Jam',
                            style: AppTextStyles.small(
                              color: time == null
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
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
  // BOTTOM BAR
  // ═══════════════════════════════════════
  Widget _buildBottomBar() {
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
            onPressed: _onConfirm,
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
      ),
    );
  }

  // ═══════════════════════════════════════
  // CONFIRM
  // ═══════════════════════════════════════
  void _onConfirm() {
    if (_selectedWorkshop == null) {
      _snack('Pilih bengkel terlebih dahulu');
      return;
    }

    for (var v in widget.vehicles) {
      if (_vehicleDates[v.id] == null) {
        _snack('Pilih tanggal untuk ${v.model}');
        return;
      }
      if (_vehicleTimes[v.id] == null) {
        _snack('Pilih jam untuk ${v.model}');
        return;
      }
    }

    // ═══ Kirim lokasi user (dengan ALAMAT LENGKAP) ═══
    final userLocation = (_userLat != null && _userLng != null)
        ? PickupLocation(
            latitude: _userLat!,
            longitude: _userLng!,
            address: _userAddress.isNotEmpty
                ? _userAddress
                : 'Lokasi Anda',
          )
        : null;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceConfigScreen(
          selectedVehicles: widget.vehicles,
          selectedWorkshop: _selectedWorkshop!,
          vehicleDates: _vehicleDates,
          vehicleTimes: _vehicleTimes,
          userLocation: userLocation,
        ),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: AppTextStyles.small(color: AppColors.white)),
        backgroundColor: AppColors.danger,
      ),
    );
  }
}