import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/pickup_location_model.dart';

class LocationPickerScreen extends StatefulWidget {
  final PickupLocation? initialLocation;

  const LocationPickerScreen({super.key, this.initialLocation});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  static const Color _creamBg = Color(0xFFFFF2E8);
  static const Color _creamBorder = Color(0xFFFFE0CC);

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final MapController _mapController = MapController();

  LatLng _selectedLatLng =
      const LatLng(-7.782915, 110.367084); // default: Yogyakarta

  String _address = 'Pilih lokasi di peta';
  bool _isLoadingAddress = false;
  bool _isLoadingLocation = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialLocation != null) {
      _selectedLatLng = LatLng(
        widget.initialLocation!.latitude,
        widget.initialLocation!.longitude,
      );
      _address = widget.initialLocation!.address;
      _noteController.text = widget.initialLocation!.note ?? '';
    } else {
      _initCurrentLocation();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _noteController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════
  // AMBIL LOKASI SAAT INI
  // ═══════════════════════════════════════
  Future<void> _initCurrentLocation() async {
    if (widget.initialLocation != null) return;

    setState(() => _isLoadingLocation = true);

    try {
      // Cek permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _isLoadingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final newLatLng = LatLng(position.latitude, position.longitude);

      _mapController.move(newLatLng, 17);

      setState(() => _selectedLatLng = newLatLng);

      await _reverseGeocode(newLatLng);
    } catch (e) {
      // ignore
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  // ═══════════════════════════════════════
  // REVERSE GEOCODING (Nominatim - GRATIS)
  // ═══════════════════════════════════════
  Future<void> _reverseGeocode(LatLng pos) async {
    setState(() => _isLoadingAddress = true);

    try {
      // Nominatim API — GRATIS, tanpa API key
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=json'
        '&lat=${pos.latitude}'
        '&lon=${pos.longitude}'
        '&zoom=18'
        '&addressdetails=1'
        '&accept-language=id',
      );

      final response = await http.get(
        url,
        headers: {
          // Wajib: Nominatim minta User-Agent
          'User-Agent': 'ServisinAja/1.0 (servisinaja@example.com)',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['display_name'] as String?;

        if (address != null && address.isNotEmpty) {
          setState(() => _address = address);
        } else {
          setState(() => _address = 'Alamat tidak ditemukan');
        }
      } else {
        setState(() => _address = 'Alamat tidak ditemukan');
      }
    } catch (e) {
      setState(() => _address = 'Gagal memuat alamat');
    } finally {
      setState(() => _isLoadingAddress = false);
    }
  }

  // ═══════════════════════════════════════
  // SEARCH ALAMAT (Nominatim)
  // ═══════════════════════════════════════
  Future<void> _searchAddress() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSearching = true);

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?format=json'
        '&q=${Uri.encodeComponent(query)}'
        '&limit=1'
        '&accept-language=id',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'ServisinAja/1.0 (servisinaja@example.com)',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          final newLatLng = LatLng(lat, lon);

          _mapController.move(newLatLng, 17);
          setState(() => _selectedLatLng = newLatLng);

          await _reverseGeocode(newLatLng);
        } else {
          _showSnack('Alamat tidak ditemukan');
        }
      } else {
        _showSnack('Gagal mencari alamat');
      }
    } catch (e) {
      _showSnack('Gagal mencari alamat');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: AppTextStyles.small(color: Colors.white)),
        backgroundColor: AppColors.danger,
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
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Pilih Lokasi Penjemputan',
          style: AppTextStyles.medium(
              weight: FontWeight.w700, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ═══ SEARCH BAR ═══
          Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.white,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _creamBg,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: _creamBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search,
                      color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _searchAddress(),
                      style: AppTextStyles.small(
                          color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Cari alamat...',
                        hintStyle: AppTextStyles.small(
                            color: AppColors.textSecondary),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_isSearching)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryOrange,
                      ),
                    )
                  else if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    ),
                ],
              ),
            ),
          ),

          // ═══ MAP (OpenStreetMap) ═══
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedLatLng,
                    initialZoom: 16,
                    onTap: (tapPos, latLng) async {
                      setState(() => _selectedLatLng = latLng);
                      await _reverseGeocode(latLng);
                    },
                  ),
                  children: [
                    // Tile layer OpenStreetMap
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.servisinaja.app',
                      maxZoom: 19,
                    ),

                    // Marker di tengah
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLatLng,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_pin,
                            color: AppColors.primaryOrange,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // ═══ PIN DI TENGAH (untuk user geser peta) ═══
                // Tidak dipakai kalau pakai MarkerLayer di atas

                // ═══ LOADING OVERLAY ═══
                if (_isLoadingLocation)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryOrange),
                    ),
                  ),

                // ═══ TOMBOL LOKASI SAYA ═══
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: AppColors.white,
                    onPressed: _initCurrentLocation,
                    child: const Icon(Icons.my_location,
                        color: AppColors.primaryOrange),
                  ),
                ),
              ],
            ),
          ),

          // ═══ INFO PANEL ═══
          Container(
            padding: const EdgeInsets.all(16),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alamat
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.location_on,
                            color: AppColors.primaryOrange, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text('Alamat Terpilih',
                                style: AppTextStyles.small(
                                    weight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            _isLoadingAddress
                                ? Row(
                                    children: [
                                      const SizedBox(
                                        width: 12,
                                        height: 12,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color:
                                              AppColors.primaryOrange,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('Mencari alamat...',
                                          style: AppTextStyles.small(
                                              color: AppColors
                                                  .textSecondary)),
                                    ],
                                  )
                                : Text(
                                    _address,
                                    style: AppTextStyles.small(
                                        weight: FontWeight.w300,
                                        color: AppColors
                                            .textSecondary),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Input patokan
                  Text('Patokan (opsional)',
                      style: AppTextStyles.small(
                          weight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _creamBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _creamBorder),
                    ),
                    child: TextField(
                      controller: _noteController,
                      style: AppTextStyles.small(
                          color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText:
                            'Contoh: Pagar hitam sebelah warung',
                        hintStyle: AppTextStyles.small(
                            color: AppColors.textSecondary),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tombol konfirmasi
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoadingAddress
                          ? null
                          : () {
                              final location = PickupLocation(
                                latitude: _selectedLatLng.latitude,
                                longitude: _selectedLatLng.longitude,
                                address: _address,
                                note: _noteController.text.trim(),
                              );
                              Navigator.pop(context, location);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Konfirmasi Lokasi',
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
}