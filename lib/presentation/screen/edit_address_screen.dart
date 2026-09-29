import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/dummy/auth_service.dart';
// ❌ import '../widgets/app_background.dart';   ← HAPUS

class EditAddressScreen extends StatefulWidget {
  const EditAddressScreen({super.key});

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _addressController;
  late TextEditingController _postalController;

  String? _selectedProvince;
  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedVillage;

  bool _isLoading = false;

  final Map<String, Map<String, Map<String, List<String>>>> _regionData = {
    'DI Yogyakarta': {
      'Sleman': {
        'Depok': ['Caturtunggal', 'Maguwoharjo', 'Condongcatur'],
        'Mlati': ['Sinduadi', 'Sendangadi', 'Tlogoadi'],
      },
      'Kota Yogyakarta': {
        'Umbulharjo': ['Semaki', 'Muju Muju', 'Warungboto'],
        'Kotagede': ['Prenggan', 'Purbayan', 'Rejowinangun'],
      },
    },
    'DKI Jakarta': {
      'Jakarta Selatan': {
        'Kebayoran Baru': ['Gunung', 'Melawai', 'Petogogan'],
        'Tebet': ['Tebet Barat', 'Tebet Timur', 'Menteng Dalam'],
      },
      'Jakarta Pusat': {
        'Menteng': ['Menteng', 'Pegangsaan', 'Cikini'],
        'Tanah Abang': ['Bendungan Hilir', 'Karet Tengsin', 'Petamburan'],
      },
    },
    'Jawa Tengah': {
      'Semarang': {
        'Tembalang': ['Bulusan', 'Kramas', 'Tembalang'],
        'Banyumanik': ['Pudakpayung', 'Gedawang', 'Jabungan'],
      },
    },
    'Jawa Timur': {
      'Surabaya': {
        'Gubeng': ['Airlangga', 'Baratajaya', 'Kertajaya'],
        'Wonokromo': ['Darmo', 'Jagir', 'Ngagel'],
      },
    },
  };

  @override
  void initState() {
    super.initState();
    final user = AuthService.currentUser;
    _addressController = TextEditingController(text: user?.address ?? '');
    _postalController = TextEditingController(text: user?.postalCode ?? '');

    if (user?.province != null && user!.province.isNotEmpty) {
      _selectedProvince = user.province;
      if (user.city.isNotEmpty) {
        _selectedCity = user.city;
        if (user.district.isNotEmpty) {
          _selectedDistrict = user.district;
          if (user.village.isNotEmpty) {
            _selectedVillage = user.village;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _postalController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProvince == null ||
        _selectedCity == null ||
        _selectedDistrict == null ||
        _selectedVillage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lengkapi semua data wilayah",
              style: AppTextStyles.small(color: Colors.white)),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final error = AuthService.updateAddress(
      address: _addressController.text.trim(),
      province: _selectedProvince!,
      city: _selectedCity!,
      district: _selectedDistrict!,
      village: _selectedVillage!,
      postalCode: _postalController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error,
              style: AppTextStyles.small(color: Colors.white)),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Alamat berhasil diperbarui",
            style: AppTextStyles.small(color: Colors.white)),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final provinces = _regionData.keys.toList();
    final cities = _selectedProvince != null
        ? _regionData[_selectedProvince]!.keys.toList()
        : <String>[];
    final districts = (_selectedProvince != null && _selectedCity != null)
        ? _regionData[_selectedProvince]![_selectedCity]!.keys.toList()
        : <String>[];
    final villages = (_selectedProvince != null &&
            _selectedCity != null &&
            _selectedDistrict != null)
        ? _regionData[_selectedProvince]![_selectedCity]![_selectedDistrict]!
        : <String>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text("Edit Alamat",
            style: AppTextStyles.medium(
                weight: FontWeight.w700, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryOrange, AppColors.discountPrice],
            ),
          ),
        ),
      ),

      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenH),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),

              Container(
                padding: const EdgeInsets.all(AppSpacing.md + 2),
                decoration: BoxDecoration(
                  color: AppColors.softOrange,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: AppColors.primaryOrange),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        "Isi alamat lengkap mulai dari provinsi hingga kode pos.",
                        style: AppTextStyles.small(
                            color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Alamat, Provinsi, Kota, Kecamatan, Kelurahan, Kode Pos (sama seperti sebelumnya)
              _buildLabel("Alamat Lengkap"),
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                style: AppTextStyles.medium(),
                decoration: _inputDecoration(
                  hint: 'Contoh: Jl. Babarsari No. 45, RT 02/RW 05',
                  icon: Icons.home_outlined,
                ),
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Alamat wajib diisi' : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              _buildLabel("Provinsi"),
              _buildDropdown(
                value: _selectedProvince,
                hint: 'Pilih Provinsi',
                items: provinces,
                onChanged: (val) {
                  setState(() {
                    _selectedProvince = val;
                    _selectedCity = null;
                    _selectedDistrict = null;
                    _selectedVillage = null;
                  });
                },
                icon: Icons.map_outlined,
              ),
              const SizedBox(height: AppSpacing.lg),

              _buildLabel("Kabupaten / Kota"),
              _buildDropdown(
                value: _selectedCity,
                hint: _selectedProvince == null
                    ? 'Pilih provinsi dulu'
                    : 'Pilih Kabupaten/Kota',
                items: cities,
                onChanged: _selectedProvince == null
                    ? null
                    : (val) {
                        setState(() {
                          _selectedCity = val;
                          _selectedDistrict = null;
                          _selectedVillage = null;
                        });
                      },
                icon: Icons.location_city,
              ),
              const SizedBox(height: AppSpacing.lg),

              _buildLabel("Kecamatan"),
              _buildDropdown(
                value: _selectedDistrict,
                hint: _selectedCity == null
                    ? 'Pilih kabupaten/kota dulu'
                    : 'Pilih Kecamatan',
                items: districts,
                onChanged: _selectedCity == null
                    ? null
                    : (val) {
                        setState(() {
                          _selectedDistrict = val;
                          _selectedVillage = null;
                        });
                      },
                icon: Icons.account_balance_outlined,
              ),
              const SizedBox(height: AppSpacing.lg),

              _buildLabel("Kelurahan / Desa"),
              _buildDropdown(
                value: _selectedVillage,
                hint: _selectedDistrict == null
                    ? 'Pilih kecamatan dulu'
                    : 'Pilih Kelurahan/Desa',
                items: villages,
                onChanged: _selectedDistrict == null
                    ? null
                    : (val) {
                        setState(() => _selectedVillage = val);
                      },
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: AppSpacing.lg),

              _buildLabel("Kode Pos"),
              TextFormField(
                controller: _postalController,
                keyboardType: TextInputType.number,
                maxLength: 5,
                style: AppTextStyles.medium(),
                decoration: _inputDecoration(
                  hint: '55281',
                  icon: Icons.pin_outlined,
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Kode pos wajib diisi';
                  }
                  if (val.length != 5) return 'Kode pos harus 5 digit';
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.xl),

              // Preview Alamat
              if (_selectedProvince != null &&
                  _selectedCity != null &&
                  _selectedDistrict != null &&
                  _selectedVillage != null) ...[
                Text("Preview Alamat",
                    style: AppTextStyles.medium(weight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md + 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.08),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusCard),
                    border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          _addressController.text.isEmpty
                              ? '(Alamat lengkap)'
                              : _addressController.text,
                          style: AppTextStyles.small(
                              weight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(
                        "$_selectedVillage, $_selectedDistrict, $_selectedCity, $_selectedProvince ${_postalController.text}",
                        style: AppTextStyles.small(
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusCard)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text("Simpan Alamat",
                          style: AppTextStyles.medium(
                              weight: FontWeight.w700,
                              color: Colors.white)),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child:
          Text(text, style: AppTextStyles.small(weight: FontWeight.w600)),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      style: AppTextStyles.medium(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.small(color: AppColors.textHint),
        prefixIcon: Icon(icon, color: AppColors.textHint, size: 20),
        filled: true,
        fillColor: onChanged == null ? AppColors.background : AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          borderSide:
              const BorderSide(color: AppColors.primaryOrange, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md + 2),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: AppTextStyles.medium()),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.small(color: AppColors.textHint),
      prefixIcon: Icon(icon, color: AppColors.textHint, size: 20),
      filled: true,
      fillColor: AppColors.white,
      counterText: '',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        borderSide:
            const BorderSide(color: AppColors.primaryOrange, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md + 2),
    );
  }
}