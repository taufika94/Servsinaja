import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/vehicle_model.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ═══ CONTROLLER ═══
  final _machineController = TextEditingController();
  final _plateController = TextEditingController();

  // ═══ DROPDOWN STATE ═══
  String? _selectedBrand;
  String? _selectedModel;
  String? _selectedType;
  String? _selectedYear;
  String? _selectedColor;

  bool _isScanning = false;
  bool _isLoading = false;
  bool? _isMachineValid;
  bool _flashOn = false;

  // ═══ ERROR STATE ═══
  String? _machineError;
  String? _plateError;
  String? _yearError;
  String? _brandError;
  String? _modelError;
  String? _typeError;
  String? _colorError;

  // ═══ YEARS LIST ═══
  final List<String> _years = List.generate(
    30,
    (i) => (2026 - i).toString(),
  );

  // ═══ WARNA MOTOR YANG VALID ═══
  final List<String> _validColors = [
    'Hitam',
    'Putih',
    'Merah',
    'Biru',
    'Silver',
    'Abu-abu',
    'Kuning',
    'Hijau',
    'Orange',
    'Coklat',
    'Gold',
    'Pink',
    'Ungu',
    'Tosca',
    'Maroon',
    'Cream',
    'Navy',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _machineController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  // ═══ GETTER ═══
  List<String> get _brands => DummyData.motorCatalog.keys.toList();
  List<String> get _models => _selectedBrand != null
      ? DummyData.motorCatalog[_selectedBrand]!.keys.toList()
      : [];
  List<String> get _types =>
      (_selectedBrand != null && _selectedModel != null)
          ? DummyData.motorCatalog[_selectedBrand]![_selectedModel]!
          : [];

  // ═══════════════════════════════════════
  // VALIDASI PLAT NOMOR INDONESIA
  // Format: AB 1234 CD
  // - 1-2 huruf (kode wilayah)
  // - 1-4 angka (nomor)
  // - 1-3 huruf (seri)
  // ═══════════════════════════════════════
  bool _isValidPlateNumber(String plate) {
    final pattern = RegExp(r'^[A-Z]{1,2}\s\d{1,4}\s[A-Z]{1,3}$');
    return pattern.hasMatch(plate.toUpperCase().trim());
  }

  // ═══ FORMAT PLAT NOMOR ═══
  // Otomatis uppercase + spasi
  String _formatPlateNumber(String input) {
    // Hapus semua spasi, uppercase
    final cleaned = input.toUpperCase().replaceAll(RegExp(r'\s+'), '');

    if (cleaned.isEmpty) return '';

    // Regex untuk ekstrak bagian
    final match = RegExp(r'^([A-Z]{1,2})(\d{1,4})([A-Z]{0,3})')
        .firstMatch(cleaned);

    if (match == null) return cleaned;

    final prefix = match.group(1) ?? '';
    final number = match.group(2) ?? '';
    final suffix = match.group(3) ?? '';

    final buffer = StringBuffer();
    buffer.write(prefix);
    if (number.isNotEmpty) {
      buffer.write(' $number');
    }
    if (suffix.isNotEmpty) {
      buffer.write(' $suffix');
    }

    return buffer.toString();
  }

  // ═══ VALIDASI PLAT ═══
  void _validatePlate() {
    final plate = _plateController.text.trim();

    if (plate.isEmpty) {
      setState(() => _plateError = 'Nomor polisi wajib diisi');
      return;
    }

    if (!_isValidPlateNumber(plate)) {
      setState(() => _plateError =
          'Format plat salah. Contoh: AB 1234 CD');
      return;
    }

    setState(() => _plateError = null);
  }

  // ═══════════════════════════════════════
  // VALIDASI NOMOR MESIN
  // ═══════════════════════════════════════
  void _validateMachineNumber() {
    final input = _machineController.text.trim().toUpperCase();

    setState(() => _machineError = null);

    if (input.isEmpty) {
      setState(() => _machineError = 'Nomor mesin tidak boleh kosong');
      return;
    }

    if (input.length < 8) {
      setState(() => _machineError = 'Nomor mesin minimal 8 karakter');
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      final data = DummyData.motorDatabase[input];

      setState(() {
        _isLoading = false;

        if (data != null) {
          _isMachineValid = true;
          _machineError = null;

          _selectedBrand = data['brand'];
          _selectedModel = data['model'];
          _selectedType = data['type'];

          _plateController.clear();
          _yearError = null;
          _plateError = null;
        } else {
          _isMachineValid = false;
          _machineError = null;

          _selectedBrand = null;
          _selectedModel = null;
          _selectedType = null;

          _plateController.clear();
        }
      });

      _tabController.animateTo(1);
    });
  }

  // ═══════════════════════════════════════
  // SIMULASI SCAN
  // ═══════════════════════════════════════
  Future<void> _simulateScan() async {
    setState(() => _isScanning = true);
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isScanning = false);

    final scannedData = DummyData.barcodesToScan[
        DateTime.now().millisecond % DummyData.barcodesToScan.length];

    final machineNumber = scannedData['machineNumber']!;
    final data = DummyData.motorDatabase[machineNumber];

    if (data == null) {
      _showScanFailedDialog();
      return;
    }

    setState(() {
      _isMachineValid = true;
      _machineController.text = machineNumber;
      _selectedBrand = data['brand'];
      _selectedModel = data['model'];
      _selectedType = data['type'];

      _plateController.clear();
    });

    _showScanSuccessDialog(data, machineNumber);
  }

  // ═══════════════════════════════════════
  // DIALOG: SCAN SUKSES
  // ═══════════════════════════════════════
  void _showScanSuccessDialog(
      Map<String, String> data, String machineNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.softOrange.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Image.asset(
                  'assets/images/motor.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.two_wheeler,
                    size: 80,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                "Motor terdeteksi",
                style:
                    AppTextStyles.medium(weight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${data['brand']} ${data['model']}",
                      style: AppTextStyles.medium(
                          weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data['type'] ?? '-',
                      style: AppTextStyles.small(
                          color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.xs),
                      ),
                      child: Text(
                        machineNumber,
                        style: AppTextStyles.small(
                            color: AppColors.textHint),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _tabController.animateTo(1);
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
                    "Lanjut Isi Form",
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
      ),
    );
  }

  // ═══════════════════════════════════════
  // DIALOG: SCAN GAGAL
  // ═══════════════════════════════════════
  void _showScanFailedDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.softOrange.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Image.asset(
                  'assets/images/motor.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.warning_amber_rounded,
                    size: 80,
                    color: AppColors.warning,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                "Barcode tidak dikenali",
                style:
                    AppTextStyles.medium(weight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                "Coba scan ulang atau input nomor mesin manual",
                textAlign: TextAlign.center,
                style: AppTextStyles.small(
                    color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
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
                    "Tutup",
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
      ),
    );
  }

  // ═══════════════════════════════════════
  // DIALOG: KONFIRMASI TAMBAH
  // ═══════════════════════════════════════
  void _showConfirmationDialog(Vehicle newVehicle) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.softOrange.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Apakah Anda yakin ingin menambahkan motor?",
                textAlign: TextAlign.center,
                style:
                    AppTextStyles.medium(weight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: 130,
                height: 130,
                child: Image.asset(
                  'assets/images/motor.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.two_wheeler,
                    size: 100,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
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
                              AppSpacing.radiusXl),
                        ),
                        side: const BorderSide(
                            color: AppColors.divider, width: 1.5),
                        backgroundColor: AppColors.white,
                      ),
                      child: Text(
                        "Tidak",
                        style: AppTextStyles.medium(
                          weight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm + 2),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context, newVehicle);
                      },
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
                      child: Text(
                        "Ya, Tambahkan",
                        style: AppTextStyles.medium(
                          weight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
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

  // ═══════════════════════════════════════
  // SUBMIT FORM
  // ═══════════════════════════════════════
  Future<void> _submit() async {
    // ═══ VALIDASI SEMUA FIELD ═══
    setState(() {
      _brandError = _selectedBrand == null ? 'Merek wajib dipilih' : null;
      _modelError = _selectedModel == null ? 'Model wajib dipilih' : null;
      _typeError = _selectedType == null ? 'Tipe wajib dipilih' : null;
      _yearError = _selectedYear == null ? 'Tahun beli wajib dipilih' : null;
      _colorError = _selectedColor == null ? 'Warna wajib dipilih' : null;
    });

    // ═══ VALIDASI PLAT ═══
    _validatePlate();

    // ═══ CEK ERROR ═══
    if (_brandError != null ||
        _modelError != null ||
        _typeError != null ||
        _yearError != null ||
        _colorError != null ||
        _plateError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lengkapi semua field yang wajib diisi",
              style: AppTextStyles.small(color: Colors.white)),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _isLoading = false);

    final newVehicle = Vehicle(
      id: 'V-${DateTime.now().millisecondsSinceEpoch}',
      brand: _selectedBrand!,
      model: _selectedModel!,
      plateNumber: _plateController.text.trim().toUpperCase(),
      year: int.tryParse(_selectedYear!) ?? 2024,
      color: _selectedColor!,
    );

    _showConfirmationDialog(newVehicle);
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
        title: Text("Tambah Kendaraan",
            style: AppTextStyles.medium(
                weight: FontWeight.w700, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          Container(
            margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenH),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius:
                  BorderRadius.circular(AppSpacing.radiusXl),
              border: Border.all(color: AppColors.divider, width: 1),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primaryOrange,
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusXl),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle:
                  AppTextStyles.medium(weight: FontWeight.w600),
              unselectedLabelStyle:
                  AppTextStyles.medium(weight: FontWeight.w500),
              tabs: const [
                Tab(text: "Scan Barcode"),
                Tab(text: "Input Manual"),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildScanTab(),
                _buildManualTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // TAB 1: SCAN
  // ═══════════════════════════════════════
  Widget _buildScanTab() {
    return Stack(
      children: [
        Container(
          color: Colors.black,
          width: double.infinity,
          height: double.infinity,
        ),
        Center(
          child: SizedBox(
            width: 300,
            height: 180,
            child: Stack(
              children: [
                Positioned(top: 0, left: 0, child: _buildCorner()),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Transform.rotate(
                    angle: 1.5708,
                    child: _buildCorner(),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Transform.rotate(
                    angle: -1.5708,
                    child: _buildCorner(),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Transform.rotate(
                    angle: 3.1416,
                    child: _buildCorner(),
                  ),
                ),
                if (_isScanning)
                  Positioned.fill(
                    child: Center(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration:
                            const Duration(milliseconds: 1500),
                        builder: (context, value, _) {
                          return Transform.translate(
                            offset:
                                Offset(0, (value - 0.5) * 160),
                            child: Container(
                              width: 280,
                              height: 2,
                              color: AppColors.primaryOrange,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          top: AppSpacing.lg,
          right: AppSpacing.lg,
          child: GestureDetector(
            onTap: () => setState(() => _flashOn = !_flashOn),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _flashOn ? Icons.flash_on : Icons.flash_off,
                color: AppColors.white,
                size: 22,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: AppSpacing.screenH,
          right: AppSpacing.screenH,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.xs),
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner,
                      size: 24,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      "Scan barcode atau masukkan nomor mesin untuk mengisi form otomatis",
                      style: AppTextStyles.small(
                        color: AppColors.white,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isScanning ? null : _simulateScan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    disabledBackgroundColor:
                        AppColors.primaryOrange.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusXl),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _isScanning ? "Memindai..." : "Mulai Scan",
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
      ],
    );
  }

  Widget _buildCorner() {
    return SizedBox(
      width: 30,
      height: 30,
      child: CustomPaint(
        painter: _CornerPainter(),
      ),
    );
  }

  // ═══════════════════════════════════════
  // TAB 2: MANUAL
  // ═══════════════════════════════════════
  Widget _buildManualTab() {
    return SingleChildScrollView(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                // ═══ NOMOR MESIN ═══
                _buildLabel("Nomor Mesin"),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(
                        color: AppColors.divider, width: 1),
                  ),
                  child: TextField(
                    controller: _machineController,
                    textCapitalization:
                        TextCapitalization.characters,
                    style: AppTextStyles.small(),
                    decoration: InputDecoration(
                      hintText: 'Contoh: JF12E1234567',
                      hintStyle: AppTextStyles.small(
                          color: AppColors.textHint),
                      suffixIcon: const Icon(Icons.search,
                          color: AppColors.textHint, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md),
                    ),
                    onSubmitted: (_) => _validateMachineNumber(),
                  ),
                ),

                // ═══ STATUS VALIDASI ═══
                if (_isMachineValid == true) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm + 2),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(
                          color: AppColors.success
                              .withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: AppColors.success, size: 16),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            "Nomor mesin ditemukan!",
                            style: AppTextStyles.small(
                                color: AppColors.success,
                                weight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (_isMachineValid == false) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm + 2),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(
                          color: AppColors.warning
                              .withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: AppColors.warning, size: 16),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            "Nomor mesin tidak ditemukan",
                            style: AppTextStyles.small(
                                color: AppColors.warning,
                                weight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.lg),

                // ═══ DATA MOTOR ═══
                Text("Data Motor",
                    style: AppTextStyles.medium(
                        weight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.md),

                // ─── MEREK ───
                _buildLabel("Merek Motor"),
                _buildDropdown(
                  value: _selectedBrand,
                  hint: 'Pilih Merek',
                  items: _brands,
                  errorText: _brandError,
                  onChanged: (val) {
                    setState(() {
                      _selectedBrand = val;
                      _selectedModel = null;
                      _selectedType = null;
                      _brandError = null;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // ─── MODEL ───
                _buildLabel("Model Motor"),
                _buildDropdown(
                  value: _selectedModel,
                  hint: _selectedBrand == null
                      ? 'Pilih Merek'
                      : 'Pilih Model',
                  items: _models,
                  errorText: _modelError,
                  enabled: _selectedBrand != null,
                  onChanged: (val) {
                    setState(() {
                      _selectedModel = val;
                      _selectedType = null;
                      _modelError = null;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // ─── TIPE ───
                _buildLabel("Tipe Motor"),
                _buildDropdown(
                  value: _selectedType,
                  hint: _selectedModel == null
                      ? 'Pilih Tipe Motor'
                      : 'Pilih Tipe',
                  items: _types,
                  errorText: _typeError,
                  enabled: _selectedModel != null,
                  onChanged: (val) {
                    setState(() {
                      _selectedType = val;
                      _typeError = null;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // ─── TAHUN ───
                _buildLabel("Tahun Beli"),
                _buildDropdown(
                  value: _selectedYear,
                  hint: 'Tahun Beli',
                  items: _years,
                  errorText: _yearError,
                  onChanged: (val) {
                    setState(() {
                      _selectedYear = val;
                      _yearError = null;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // ─── NOMOR POLISI ═══
                _buildLabel("Nomor Polisi"),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(
                      color: _plateError != null
                          ? AppColors.danger
                          : AppColors.divider,
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _plateController,
                    textCapitalization: TextCapitalization.characters,
                    textAlign: TextAlign.left,
                    style: AppTextStyles.medium(
                        weight: FontWeight.w700,
                        letterSpacing: 2),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[A-Za-z0-9 ]')),
                      LengthLimitingTextInputFormatter(12),
                    ],
                    decoration: InputDecoration(
                      hintText: 'Contoh : AB 1234 CD',
                      hintStyle: AppTextStyles.small(
                          color: AppColors.textHint,
                          letterSpacing: 0),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md),
                    ),
                    onChanged: (value) {
                      // ═══ AUTO-FORMAT PLAT ═══
                      final formatted = _formatPlateNumber(value);
                      if (formatted != value) {
                        _plateController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(
                              offset: formatted.length),
                        );
                      }

                      // ═══ CLEAR ERROR ═══
                      if (_plateError != null) {
                        setState(() => _plateError = null);
                      }
                    },
                    onSubmitted: (_) => _validatePlate(),
                  ),
                ),
                if (_plateError != null)
                  Padding(
                    padding: const EdgeInsets.only(
                        top: AppSpacing.xs,
                        left: AppSpacing.sm),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.danger, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(_plateError!,
                              style: AppTextStyles.small(
                                  color: AppColors.danger)),
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(
                        top: AppSpacing.xs,
                        left: AppSpacing.sm),
                    child: Text(
                      'Format: AB 1234 CD',
                      style: AppTextStyles.small(
                          color: AppColors.textHint),
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),

                // ─── WARNA (DROPDOWN) ───
                _buildLabel("Warna"),
                _buildDropdown(
                  value: _selectedColor,
                  hint: 'Pilih Warna',
                  items: _validColors,
                  errorText: _colorError,
                  onChanged: (val) {
                    setState(() {
                      _selectedColor = val;
                      _colorError = null;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ═══ TOMBOL SIMPAN ═══
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
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
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text("Tambahkan Motor",
                      style: AppTextStyles.medium(
                          weight: FontWeight.w700,
                          color: AppColors.white)),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  // ═══ LABEL ═══
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs + 2),
      child: Text(
        text,
        style: AppTextStyles.small(weight: FontWeight.w700),
      ),
    );
  }

  // ═══ DROPDOWN ═══
  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
    String? errorText,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: enabled ? AppColors.white : AppColors.background,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: errorText != null
                  ? AppColors.danger
                  : AppColors.divider,
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            style: AppTextStyles.small(),
            icon: const Icon(Icons.keyboard_arrow_down,
                color: AppColors.textSecondary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  AppTextStyles.small(color: AppColors.textHint),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md),
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item, style: AppTextStyles.small()),
              );
            }).toList(),
            onChanged: enabled ? onChanged : null,
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(
                top: AppSpacing.xs, left: AppSpacing.sm),
            child: Text(errorText,
                style: AppTextStyles.small(
                    color: AppColors.danger)),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════
// CORNER PAINTER
// ═══════════════════════════════════════
class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}