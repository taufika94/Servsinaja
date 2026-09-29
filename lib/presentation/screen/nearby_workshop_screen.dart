import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/workshop_model.dart';

class NearbyWorkshopScreen extends StatefulWidget {
  const NearbyWorkshopScreen({super.key});

  @override
  State<NearbyWorkshopScreen> createState() =>
      _NearbyWorkshopScreenState();
}

class _NearbyWorkshopScreenState extends State<NearbyWorkshopScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController =
      TextEditingController();

  // Default: Yogyakarta
  static const LatLng _defaultCenter = LatLng(-7.782915, 110.367084);

  LatLng _mapCenter = _defaultCenter;
  Workshop? _selectedWorkshop;

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ═══ List bengkel terurut berdasarkan jarak ═══
  List<Workshop> get _sortedWorkshops {
    final list = List<Workshop>.from(DummyData.workshops);
    list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return list;
  }

  // ═══ Hitung jarak user ke bengkel ═══
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

  // ═══ Fokus ke bengkel ═══
  void _focusWorkshop(Workshop workshop) {
    setState(() {
      _selectedWorkshop = workshop;
      _mapCenter = LatLng(workshop.latitude, workshop.longitude);
    });
    _mapController.move(_mapCenter, 16);
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
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Text(
          "Lokasi Terdekat",
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

      // ═══ BODY ═══
      body: Column(
        children: [
          // ═══ PETA ═══
          SizedBox(
            height: 280,
            child: Stack(
              children: [
                // Peta OpenStreetMap
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _mapCenter,
                    initialZoom: 15,
                    onTap: (_, __) {
                      setState(() => _selectedWorkshop = null);
                    },
                  ),
                  children: [
                    // Tile layer
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.servisinaja.app',
                      maxZoom: 19,
                    ),

                    // Marker bengkel
                    MarkerLayer(
                      markers: DummyData.workshops.map((w) {
                        final isSelected =
                            _selectedWorkshop?.id == w.id;
                        return Marker(
                          point:
                              LatLng(w.latitude, w.longitude),
                          width: isSelected ? 50 : 40,
                          height: isSelected ? 50 : 40,
                          child: GestureDetector(
                            onTap: () => _focusWorkshop(w),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryOrange
                                    : AppColors.discountPrice,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.2),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.storefront,
                                color: AppColors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                // ═══ SEARCH BAR ═══
                Positioned(
                  top: AppSpacing.md,
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(
                          AppSpacing.radiusXl),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: AppColors.primaryOrange,
                          size: 18,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: AppTextStyles.small(),
                            decoration: InputDecoration(
                              hintText:
                                  'Jl. Babarsari, Tambakbayan...',
                              hintStyle: AppTextStyles.small(
                                  color: AppColors.textHint),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.search,
                          color: AppColors.primaryOrange,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),

                // ═══ TOMBOL LOKASI SAYA ═══
                Positioned(
                  right: AppSpacing.md,
                  bottom: AppSpacing.md,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: AppColors.white,
                    elevation: 2,
                    onPressed: () {
                      _mapController.move(_defaultCenter, 15);
                      setState(() {
                        _mapCenter = _defaultCenter;
                        _selectedWorkshop = null;
                      });
                    },
                    child: const Icon(
                      Icons.my_location,
                      color: AppColors.primaryOrange,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ═══ LIST BENGKEL ═══
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusXl),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ═══ HEADER ═══
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenH,
                      AppSpacing.lg,
                      AppSpacing.screenH,
                      AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: AppColors.textPrimary,
                          size: 18,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          "Lokasi Terdekat",
                          style: AppTextStyles.medium(
                              weight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),

                  // ═══ LIST ═══
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenH),
                      itemCount: _sortedWorkshops.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final w = _sortedWorkshops[index];
                        final isSelected =
                            _selectedWorkshop?.id == w.id;
                        return _buildWorkshopTile(w,
                            isSelected: isSelected);
                      },
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
  // WORKSHOP TILE
  // ═══════════════════════════════════════
  Widget _buildWorkshopTile(Workshop workshop,
      {bool isSelected = false}) {
    return GestureDetector(
      onTap: () => _focusWorkshop(workshop),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══ FOTO BENGKEL ═══
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              child: Image.asset(
                workshop.image,
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

            // ═══ INFO BENGKEL ═══
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama
                  Text(
                    workshop.name,
                    style: AppTextStyles.medium(
                        weight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // Alamat
                  Text(
                    workshop.address,
                    style: AppTextStyles.small(
                        color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),

                  // Rating + Jarak
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
                            color: AppColors.success,
                            weight: FontWeight.w600),
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
          ],
        ),
      ),
    );
  }
}