import 'package:flutter/material.dart';
import '../models/vehicle_model.dart';
import '../models/service_model.dart';
import '../models/service_history_model.dart';
import '../models/workshop_model.dart';
import '../models/notification_model.dart';
import '../models/chat_model.dart';

class DummyData {

  // ═══════════════════════════════════════
  // NOTIFIKASI
  // ═══════════════════════════════════════
  static List<AppNotification> notifications = [
    AppNotification(
      id: 'N1',
      title: 'Selamat Datang di ServisinAja!',
      message: 'Akun Anda berhasil dibuat. Yuk mulai booking servis pertama Anda.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      icon: Icons.celebration_outlined,
    ),
    AppNotification(
      id: 'N2',
      title: 'Pengingat Servis Rutin',
      message: 'Motor Honda Vario 125 Anda sudah waktunya servis rutin. Sudah 3.000 km sejak servis terakhir.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      icon: Icons.two_wheeler_outlined,
    ),
    AppNotification(
      id: 'N3',
      title: 'Promo Diskon 30%',
      message: 'Khusus member baru! Dapatkan diskon 30% untuk servis pertama Anda. Berlaku sampai akhir bulan.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      icon: Icons.local_offer_outlined,
    ),
    AppNotification(
      id: 'N4',
      title: 'Servis Anda Sedang Diproses',
      message: 'Motor Yamaha NMAX 155 Anda sedang dikerjakan oleh mekanik. Estimasi selesai 45 menit lagi.',
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      icon: Icons.build_outlined,
    ),
    AppNotification(
      id: 'N5',
      title: 'Voucher Gratis untuk Anda',
      message: 'Anda mendapatkan voucher GRATISJEMPUT. Klaim sekarang dan hemat biaya jemput hingga Rp 25.000.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      icon: Icons.card_giftcard_outlined,
      isRead: true,
    ),
    AppNotification(
      id: 'N6',
      title: 'Servis Selesai!',
      message: 'Motor Honda Beat Street Anda telah selesai diservis. Silakan ambil di bengkel.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      icon: Icons.check_circle_outlined,
      isRead: true,
    ),
    AppNotification(
      id: 'N7',
      title: 'Jadwal Servis Besok',
      message: 'Reminder: Jadwal servis Anda besok pukul 10:00 di Servisin Aja - Babarsari. Harap datang 10 menit lebih awal.',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      icon: Icons.event_outlined,
      isRead: true,
    ),
    AppNotification(
      id: 'N8',
      title: 'Rating Servis Anda',
      message: 'Bagaimana pengalaman servis Anda? Beri rating untuk membantu kami meningkatkan layanan.',
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      icon: Icons.star_outline_rounded,
      isRead: true,
    ),
    AppNotification(
      id: 'N9',
      title: 'Tips Perawatan Motor',
      message: 'Cek tekanan angin ban setiap 2 minggu sekali. Ban kempes bikin boros BBM dan tidak aman.',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      icon: Icons.lightbulb_outline,
      isRead: true,
    ),
    AppNotification(
      id: 'N10',
      title: 'Poin Anda Bertambah!',
      message: 'Selamat! Anda mendapatkan 12 poin dari servis terakhir. Kumpulkan terus untuk hadiah menarik.',
      timestamp: DateTime.now().subtract(const Duration(days: 7)),
      icon: Icons.monetization_on_outlined,
      isRead: true,
    ),
  ];

  static int get unreadNotificationCount =>
      notifications.where((n) => !n.isRead).length;

  static void markAllNotificationsAsRead() {
    for (var n in notifications) {
      n.isRead = true;
    }
  }

  // ═══════════════════════════════════════
  // DAFTAR MOTOR TERDAFTAR
  // ═══════════════════════════════════════
  static List<Vehicle> vehicles = [
    Vehicle(
      id: 'V1',
      brand: 'Honda',
      model: 'Vario 125',
      plateNumber: 'AB 1234 CD',
      year: 2022,
      color: 'Hitam',
    ),
    Vehicle(
      id: 'V2',
      brand: 'Yamaha',
      model: 'NMAX 155',
      plateNumber: 'AB 5678 EF',
      year: 2023,
      color: 'Putih',
    ),
    Vehicle(
      id: 'V3',
      brand: 'Honda',
      model: 'Beat Street',
      plateNumber: 'AB 9012 GH',
      year: 2021,
      color: 'Merah',
    ),
  ];

  static List<Vehicle> availableVehiclesToAdd = [
    Vehicle(
      id: 'V4',
      brand: 'Honda',
      model: 'PCX 160',
      plateNumber: 'AB 1111 XY',
      year: 2023,
      color: 'Silver',
    ),
    Vehicle(
      id: 'V5',
      brand: 'Yamaha',
      model: 'Aerox 155',
      plateNumber: 'AB 2222 ZW',
      year: 2023,
      color: 'Biru',
    ),
  ];

  // ═══════════════════════════════════════
  // LAYANAN SERVIS
  // ═══════════════════════════════════════
  static List<ServiceOption> availableServices = [
    ServiceOption(
      id: 'S1',
      name: 'Servis Berkala Rutin',
      serviceFee: 50000,
      durationMinutes: 90,
      description: 'Pemeriksaan & pembersihan menyeluruh',
      excludes: ['S2'],
      requiredPartCategories: ['Oli Mesin'],
      optionalPartCategories: [
        'Oli Gardan',
        'Filter Udara',
        'Busi',
        'Kampas Rem',
      ],
      warrantyDays: 14,
      serviceType: 'Rutin',
      detail: 'Servis berkala rutin meliputi:\n'
          '• Pembersihan karburator/injector\n'
          '• Cek busi & filter udara\n'
          '• Cek rem, lampu, klakson\n'
          '• Setel rantai/kabel gas\n\n'
          '⚠️ Biaya di atas HANYA JASA. Suku cadang dipilih terpisah.',
    ),
    ServiceOption(
      id: 'S2',
      name: 'Ganti Oli Terpisah',
      serviceFee: 15000,
      durationMinutes: 30,
      description: 'Hanya jasa ganti oli saja',
      excludes: ['S1'],
      requiredPartCategories: ['Oli Mesin'],
      optionalPartCategories: ['Oli Gardan'],
      warrantyDays: 14,
      serviceType: 'Rutin',
      detail: 'Jasa ganti oli saja tanpa servis tambahan.\n\n'
          'Pilih oli mesin & oli gardan di suku cadang.',
    ),
    ServiceOption(
      id: 'S3',
      name: 'Servis CVT & Rem',
      serviceFee: 65000,
      durationMinutes: 120,
      description: 'Servis CVT + sistem pengereman',
      requiredPartCategories: [],
      optionalPartCategories: ['Oli Mesin', 'CVT', 'Kampas Rem'],
      warrantyDays: 30,
      serviceType: 'Spesifik',
      detail: 'Servis CVT & Rem meliputi:\n'
          '• Bongkar & bersihkan CVT\n'
          '• Cek roller & v-belt\n'
          '• Cek kampas rem depan-belakang\n\n'
          '⚠️ Part pengganti dipilih terpisah.',
    ),
    ServiceOption(
      id: 'S4',
      name: 'Servis Kelistrikan & Aki',
      serviceFee: 50000,
      durationMinutes: 60,
      description: 'Cek aki, lampu, klakson, & starter',
      requiredPartCategories: [],
      optionalPartCategories: ['Busi', 'Aki'],
      warrantyDays: 14,
      serviceType: 'Spesifik',
      detail: 'Jasa pengecekan aki, bohlam, klakson, starter, dan jalur kabel.',
    ),
    ServiceOption(
      id: 'S5',
      name: 'Servis Berat / Turun Mesin',
      serviceFee: 450000,
      durationMinutes: 480,
      description: 'Bongkar mesin total (overhaul)',
      excludes: ['S1', 'S2'],
      requiredPartCategories: [],
      optionalPartCategories: [
        'Oli Mesin',
        'Oli Gardan',
        'Filter Udara',
        'CVT',
        'Kampas Rem'
      ],
      warrantyDays: 30,
      serviceType: 'Berat',
      detail: 'Jasa bongkar mesin total untuk perbaikan komponen internal.',
    ),
  ];

  // ═══════════════════════════════════════
  // SUKU CADANG per Motor
  // ═══════════════════════════════════════
  static List<SparePart> availableParts = [
    // ═══ OLI MESIN ═══
    SparePart(
      id: 'OIL_VARIO_MPX',
      name: 'MPX2 0.8L',
      price: 45000,
      category: 'Oli Mesin',
      description: 'Oli mesin original Honda',
      exclusiveGroup: 'oli_mesin',
      tier: PartTier.original,
      brand: 'AHM',
      warrantyDays: 30,
      isRecommended: true,
      compatibleModels: [
        'Vario 125',
        'Vario 150',
        'Vario 160',
        'Beat Street',
        'Beat POP',
        'PCX 160',
      ],
    ),
    SparePart(
      id: 'OIL_VARIO_SPX',
      name: 'SPX2 0.8L',
      price: 60000,
      category: 'Oli Mesin',
      description: 'Oli mesin premium Honda',
      exclusiveGroup: 'oli_mesin',
      tier: PartTier.aftermarket,
      brand: 'AHM',
      warrantyDays: 30,
      compatibleModels: [
        'Vario 125',
        'Vario 150',
        'Vario 160',
        'Beat Street',
        'Beat POP',
        'PCX 160',
      ],
    ),
    SparePart(
      id: 'OIL_NMAX_YAMALUBE',
      name: 'Yamalube Super Sport 1L',
      price: 70000,
      category: 'Oli Mesin',
      description: 'Oli mesin original Yamaha',
      exclusiveGroup: 'oli_mesin',
      tier: PartTier.original,
      brand: 'Yamaha',
      warrantyDays: 30,
      isRecommended: true,
      compatibleModels: ['NMAX 155', 'Aerox 155', 'Mio M3', 'Lexi 125'],
    ),

    // ═══ OLI GARDAN ═══
    SparePart(
      id: 'GARDAN_AHM',
      name: 'Oli Gardan AHM',
      price: 35000,
      category: 'Oli Gardan',
      description: 'Oli gardan original Honda',
      exclusiveGroup: 'oli_gardan',
      tier: PartTier.original,
      brand: 'AHM',
      warrantyDays: 30,
      isRecommended: true,
      compatibleModels: [
        'Vario 125',
        'Vario 150',
        'Vario 160',
        'Beat Street',
        'Beat POP',
        'PCX 160',
      ],
    ),
    SparePart(
      id: 'GARDAN_YGP',
      name: 'Oli Gardan YGP',
      price: 35000,
      category: 'Oli Gardan',
      description: 'Oli gardan original Yamaha',
      exclusiveGroup: 'oli_gardan',
      tier: PartTier.original,
      brand: 'YGP',
      warrantyDays: 30,
      isRecommended: true,
      compatibleModels: ['NMAX 155', 'Aerox 155', 'Mio M3', 'Lexi 125'],
    ),

    // ═══ FILTER UDARA ═══
    SparePart(
      id: 'FILTER_VARIO',
      name: 'Filter Udara Vario',
      price: 45000,
      category: 'Filter Udara',
      description: 'Filter udara original Vario',
      exclusiveGroup: 'filter_udara',
      tier: PartTier.original,
      brand: 'AHM',
      warrantyDays: 30,
      compatibleModels: [
        'Vario 125',
        'Vario 150',
        'Vario 160',
        'Beat Street',
        'Beat POP',
      ],
    ),
    SparePart(
      id: 'FILTER_NMAX',
      name: 'Filter Udara NMAX',
      price: 55000,
      category: 'Filter Udara',
      description: 'Filter udara original NMAX',
      exclusiveGroup: 'filter_udara',
      tier: PartTier.original,
      brand: 'YGP',
      warrantyDays: 30,
      compatibleModels: ['NMAX 155', 'Aerox 155'],
    ),

    // ═══ KAMPAS REM ═══
    SparePart(
      id: 'KAMPAS_VARIO',
      name: 'Kampas Rem Depan Vario',
      price: 55000,
      category: 'Kampas Rem',
      description: 'Kampas rem depan original Vario',
      exclusiveGroup: 'kampas_depan',
      tier: PartTier.original,
      brand: 'AHM',
      warrantyDays: 30,
      compatibleModels: ['Vario 125', 'Vario 150', 'Vario 160'],
    ),
    SparePart(
      id: 'KAMPAS_NMAX',
      name: 'Kampas Rem Depan NMAX',
      price: 65000,
      category: 'Kampas Rem',
      description: 'Kampas rem depan original NMAX',
      exclusiveGroup: 'kampas_depan',
      tier: PartTier.original,
      brand: 'YGP',
      warrantyDays: 30,
      compatibleModels: ['NMAX 155', 'Aerox 155'],
    ),

    // ═══ CVT ═══
    SparePart(
      id: 'ROLLER_VARIO',
      name: 'Roller Set Vario',
      price: 55000,
      category: 'CVT',
      description: 'Roller set original Vario',
      exclusiveGroup: 'roller',
      tier: PartTier.original,
      brand: 'AHM',
      warrantyDays: 60,
      compatibleModels: ['Vario 125', 'Vario 150', 'Vario 160'],
    ),
    SparePart(
      id: 'VBELT_VARIO',
      name: 'V-Belt Vario',
      price: 85000,
      category: 'CVT',
      description: 'V-belt original Vario',
      exclusiveGroup: 'v_belt',
      tier: PartTier.original,
      brand: 'AHM',
      warrantyDays: 90,
      compatibleModels: ['Vario 125', 'Vario 150', 'Vario 160'],
    ),
    SparePart(
      id: 'ROLLER_NMAX',
      name: 'Roller Set NMAX',
      price: 65000,
      category: 'CVT',
      description: 'Roller set original NMAX',
      exclusiveGroup: 'roller',
      tier: PartTier.original,
      brand: 'YGP',
      warrantyDays: 60,
      compatibleModels: ['NMAX 155', 'Aerox 155'],
    ),
    SparePart(
      id: 'VBELT_NMAX',
      name: 'V-Belt NMAX',
      price: 130000,
      category: 'CVT',
      description: 'V-belt original NMAX',
      exclusiveGroup: 'v_belt',
      tier: PartTier.original,
      brand: 'YGP',
      warrantyDays: 90,
      compatibleModels: ['NMAX 155', 'Aerox 155'],
    ),

    // ═══ BUSI ═══
    SparePart(
      id: 'BUSI_NGK',
      name: 'Busi NGK Iridium',
      price: 65000,
      category: 'Busi',
      description: 'Busi iridium premium',
      exclusiveGroup: 'busi',
      tier: PartTier.aftermarket,
      brand: 'NGK',
      warrantyDays: 30,
      isRecommended: true,
    ),

    // ═══ AKI ═══
    SparePart(
      id: 'AKI_GS',
      name: 'Aki GS Astra 5AH',
      price: 245000,
      category: 'Aki',
      description: 'Aki basah bergaransi',
      exclusiveGroup: 'aki',
      tier: PartTier.aftermarket,
      brand: 'GS Astra',
      warrantyDays: 180,
      isRecommended: true,
    ),
  ];

    // ═══════════════════════════════════════
  // CHAT CONVERSATIONS (list pesan)
  // ═══════════════════════════════════════
  static List<ChatConversation> conversations = [
    // ═══ UNREAD (4) ═══
    ChatConversation(
      id: 'C1',
      name: 'Heru',
      avatar: 'assets/images/avatar/heru.png',
      lastMessage: 'Mas kalau ganti oli gimana ya?',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 30)),
      isOnline: true,
      isRead: false,
    ),
    ChatConversation(
      id: 'C2',
      name: 'Slamet',
      avatar: 'assets/images/avatar/slamet.png',
      lastMessage: 'Motornya saya ambil ya mas',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      isOnline: false,
      isRead: false,
    ),
    ChatConversation(
      id: 'C3',
      name: 'Ryan',
      avatar: 'assets/images/avatar/ryan.png',
      lastMessage: 'Boleh',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 5)),
      isOnline: true,
      isRead: false,
    ),
    ChatConversation(
      id: 'C4',
      name: 'Yayat',
      avatar: 'assets/images/avatar/yayat.png',
      lastMessage: 'Saya OTW',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 6)),
      isOnline: false,
      isRead: false,
    ),

    // ═══ READ (6) — nama & chat BERBEDA ═══
    ChatConversation(
      id: 'C5',
      name: 'Budi Santoso',
      avatar: 'assets/images/avatar/budi.png',
      lastMessage: 'Terima kasih banyak ya, motornya sudah enak dipakai',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      isOnline: false,
      isRead: true,
    ),
    ChatConversation(
      id: 'C6',
      name: 'Dewi Lestari',
      avatar: 'assets/images/avatar/dewi.png',
      lastMessage: 'Besok bisa booking jam 9 pagi?',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      isOnline: false,
      isRead: true,
    ),
    ChatConversation(
      id: 'C7',
      name: 'Andi Pratama',
      avatar: 'assets/images/avatar/andi.png',
      lastMessage: 'Oke siap, saya ke bengkel sekarang',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
      isOnline: false,
      isRead: true,
    ),
    ChatConversation(
      id: 'C8',
      name: 'Rina Wulandari',
      avatar: 'assets/images/avatar/rina.png',
      lastMessage: 'Berapa lama estimasi servis CVT?',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
      isOnline: false,
      isRead: true,
    ),
    ChatConversation(
      id: 'C9',
      name: 'Fajar Nugroho',
      avatar: 'assets/images/avatar/fajar.png',
      lastMessage: 'Sudah saya transfer ya mas',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 3)),
      isOnline: false,
      isRead: true,
    ),
    ChatConversation(
      id: 'C10',
      name: 'Maya Anggraini',
      avatar: 'assets/images/avatar/maya.png',
      lastMessage: 'Aki motor saya soak, bisa dipanggil?',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 4)),
      isOnline: false,
      isRead: true,
    ),
  ];

  static int get unreadChatCount =>
      conversations.where((c) => !c.isRead).length;

  // ═══════════════════════════════════════
  // MAPPING KATEGORI → JASA MINIMAL
  // ═══════════════════════════════════════
  static Map<String, String> categoryToServiceId = {
    'Oli Mesin': 'S2',
    'Oli Gardan': 'S2',
    'Filter Udara': 'S1',
    'Busi': 'S4',
    'Kampas Rem': 'S3',
    'CVT': 'S3',
    'Aki': 'S4',
  };

  static ServiceOption? getServiceById(String id) {
    try {
      return availableServices.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  // ═══════════════════════════════════════
  // WORKSHOPS
  // ═══════════════════════════════════════
  static List<Workshop> workshops = [
    Workshop(
      id: 'W1',
      name: 'Servisin Aja - Babarsari',
      address: 'Jl. Babarsari No. 45, Caturtunggal, Sleman',
      distanceKm: 1.2,
      rating: 4.9,
      reviewCount: 328,
      image: 'assets/images/workshop/babarsari.jpg',
      isOpen: true,
      openTime: '08:00',
      closeTime: '17:00',
      latitude: -7.782915,
      longitude: 110.367084,
    ),
    Workshop(
      id: 'W2',
      name: 'Servisin Aja - Maguwo',
      address: 'Jl. Raya Maguwoharjo No. 12, Sleman',
      distanceKm: 2.8,
      rating: 4.8,
      reviewCount: 215,
      image: 'assets/images/workshop/maguwo.jpg',
      isOpen: true,
      openTime: '08:00',
      closeTime: '17:00',
      latitude: -7.777094,
      longitude: 110.404202,
    ),
    Workshop(
      id: 'W3',
      name: 'Servisin Aja - Seturan',
      address: 'Jl. Seturan Raya No. 88, Sleman',
      distanceKm: 3.5,
      rating: 4.7,
      reviewCount: 189,
      image: 'assets/images/workshop/seturan.jpg',
      isOpen: true,
      openTime: '08:00',
      closeTime: '17:00',
      latitude: -7.770404,
      longitude: 110.408236,
    ),
    Workshop(
      id: 'W4',
      name: 'Servisin Aja - Condongcatur',
      address: 'Jl. Ring Road Utara No. 21, Sleman',
      distanceKm: 4.1,
      rating: 4.6,
      reviewCount: 142,
      image: 'assets/images/workshop/condongcatur.jpg',
      isOpen: false,
      openTime: '09:00',
      closeTime: '16:00',
      latitude: -7.765047,
      longitude: 110.388823,
    ),
  ];

  static List<String> availableTimes = [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
  ];

  // ═══ Helper: format tanggal Indonesia ═══
  static const List<String> _bulanId = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  static const List<String> _hariId = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  static String formatTanggalId(DateTime d) {
    return '${_hariId[d.weekday - 1]}, ${d.day} ${_bulanId[d.month]} ${d.year}';
  }

  static String formatTanggalShort(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  // ═══════════════════════════════════════
  // VOUCHER — MULTI-CLAIM SYSTEM
  // ═══════════════════════════════════════

  /// Daftar voucher yang SUDAH DIKLAIM user (bisa banyak)
  static List<Voucher> claimedVouchers = [];

  /// Voucher yang akan DIPAKAI saat checkout (cuma 1)
  static Voucher? activeVoucher;

  /// Daftar voucher yang TERSEDIA untuk diklaim
  static List<Voucher> availableVouchers = [
    Voucher(
      code: 'HEMAT20',
      title: 'Diskon 20%',
      description: 'Diskon 20% untuk semua layanan',
      type: VoucherType.percent,
      discountValue: 20,
      maxDiscount: 50000,
      minTransaction: 100000,
    ),
    Voucher(
      code: 'NEWUSER',
      title: 'New User Rp 30.000',
      description: 'Khusus pengguna baru',
      type: VoucherType.nominal,
      discountValue: 30000,
      minTransaction: 150000,
    ),
    Voucher(
      code: 'GRATISJEMPUT',
      title: 'Gratis Jemput',
      description: 'Potongan Rp 25.000 untuk biaya jemput',
      type: VoucherType.nominal,
      discountValue: 25000,
      minTransaction: 200000,
    ),
    Voucher(
      code: 'SERVIS10',
      title: 'Diskon 10%',
      description: 'Diskon 10% min. transaksi Rp 50.000',
      type: VoucherType.percent,
      discountValue: 10,
      maxDiscount: 30000,
      minTransaction: 50000,
    ),
    Voucher(
      code: 'NEWUSER30',
      title: 'Voucher New User',
      description: 'Potongan Rp 30.000 untuk user baru',
      type: VoucherType.nominal,
      discountValue: 30000,
      minTransaction: 150000,
    ),
  ];

  static Voucher? findVoucher(String code) {
    try {
      return availableVouchers.firstWhere(
        (v) => v.code.toUpperCase() == code.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }

  static bool isClaimed(Voucher voucher) {
    return claimedVouchers.any((v) => v.code == voucher.code);
  }

  static void claimVoucher(Voucher voucher) {
    if (!isClaimed(voucher)) {
      claimedVouchers.add(voucher);
    }
  }

  static void unclaimVoucher(Voucher voucher) {
    claimedVouchers.removeWhere((v) => v.code == voucher.code);
    if (activeVoucher?.code == voucher.code) {
      activeVoucher = null;
    }
  }

  static void setActiveVoucher(Voucher? voucher) {
    activeVoucher = voucher;
  }

  // ═══════════════════════════════════════
  // KATALOG MOTOR
  // ═══════════════════════════════════════
  static Map<String, Map<String, List<String>>> motorCatalog = {
    'Honda': {
      'Beat': ['Beat Street', 'Beat POP', 'Beat Deluxe'],
      'Vario': ['Vario 125', 'Vario 150', 'Vario 160'],
      'PCX': ['PCX 150', 'PCX 160'],
    },
    'Yamaha': {
      'NMAX': ['NMAX 155', 'NMAX Turbo'],
      'Aerox': ['Aerox 155', 'Aerox Turbo'],
      'Mio': ['Mio M3', 'Mio Soul GT'],
      'Lexi': ['Lexi 125', 'Lexi LX 155'],
    },
  };

  // ═══════════════════════════════════════
  // GAMBAR MOTOR — LENGKAP SEMUA MODEL
  // ═══════════════════════════════════════
  static Map<String, String> motorImageMap = {
    // ═══ HONDA BEAT ═══
    'Beat Street': 'assets/images/motor/beat.jpg',
    'Beat POP': 'assets/images/motor/beat.jpg',
    'Beat Deluxe': 'assets/images/motor/beat.jpg',

    // ═══ HONDA VARIO ═══
    'Vario 125': 'assets/images/motor/vario.jpg',
    'Vario 150': 'assets/images/motor/vario.jpg',
    'Vario 160': 'assets/images/motor/vario.jpg',

    // ═══ HONDA PCX ═══
    'PCX 150': 'assets/images/motor/pcx.jpg',
    'PCX 160': 'assets/images/motor/pcx.jpg',

    // ═══ YAMAHA NMAX ═══
    'NMAX 155': 'assets/images/motor/nmax.jpg',
    'NMAX Turbo': 'assets/images/motor/nmax.jpg',

    // ═══ YAMAHA AEROX ═══
    'Aerox 155': 'assets/images/motor/aerox.jpg',
    'Aerox Turbo': 'assets/images/motor/aerox.jpg',

    // ═══ YAMAHA MIO ═══
    'Mio M3': 'assets/images/motor/mio.jpg',
    'Mio Soul GT': 'assets/images/motor/mio.jpg',

    // ═══ YAMAHA LEXI ═══
    'Lexi 125': 'assets/images/motor/lexi.jpg',
    'Lexi LX 155': 'assets/images/motor/lexi.jpg',

    // ═══ FALLBACK ═══
    'default': 'assets/images/motor.png',
  };

  /// Get gambar motor dengan SMART FALLBACK
  ///
  /// 1. Cari exact match di `motorImageMap`
  /// 2. Kalau tidak ada, cari berdasarkan prefix (Vario 150 → Vario 125)
  /// 3. Kalau masih tidak ada, pakai `default.png`
    /// Get gambar motor dengan SMART FALLBACK
  ///
  /// 1. Cari exact match di `motorImageMap`
  /// 2. Kalau tidak ada, coba hapus brand (Honda/Yamaha) dulu
  /// 3. Kalau tidak ada, cari berdasarkan kata kunci (Vario, NMAX, Beat, dll)
  /// 4. Kalau masih tidak ada, pakai `default.png`
  static String getMotorImage(String type) {
    // ═══ 1. Direct lookup ═══
    if (motorImageMap.containsKey(type)) {
      return motorImageMap[type]!;
    }

    // ═══ 2. Coba hapus brand (Honda/Yamaha) ═══
    const brands = ['Honda ', 'Yamaha ', 'honda ', 'yamaha '];
    for (var brand in brands) {
      if (type.startsWith(brand)) {
        final withoutBrand = type.substring(brand.length);
        if (motorImageMap.containsKey(withoutBrand)) {
          return motorImageMap[withoutBrand]!;
        }
      }
    }

    // ═══ 3. Cari berdasarkan kata kunci ═══
    const keywords = [
      'Vario', 'Beat', 'PCX',              // Honda
      'NMAX', 'Aerox', 'Mio', 'Lexi',      // Yamaha
    ];

    for (var keyword in keywords) {
      if (type.toLowerCase().contains(keyword.toLowerCase())) {
        for (var key in motorImageMap.keys) {
          if (key == 'default') continue;
          if (key.toLowerCase().contains(keyword.toLowerCase())) {
            return motorImageMap[key]!;
          }
        }
      }
    }

    // ═══ 4. Ultimate fallback ═══
    return motorImageMap['default']!;
  }


  // ═══════════════════════════════════════
  // DATABASE NOMOR MESIN
  // ═══════════════════════════════════════
  static Map<String, Map<String, String>> motorDatabase = {
    'JF12E1234567': {'brand': 'Honda', 'model': 'Beat', 'type': 'Beat Street'},
    'JF12E7654321': {'brand': 'Honda', 'model': 'Vario', 'type': 'Vario 160'},
    'G3E1E2345678': {'brand': 'Yamaha', 'model': 'NMAX', 'type': 'NMAX 155'},
    'G3E1E8765432': {
      'brand': 'Yamaha',
      'model': 'Aerox',
      'type': 'Aerox Turbo'
    },
    'JM31E3456789': {'brand': 'Honda', 'model': 'PCX', 'type': 'PCX 160'},
  };

  static List<Map<String, String>> barcodesToScan = [
    {'machineNumber': 'JF12E1234567'},
    {'machineNumber': 'G3E1E2345678'},
    {'machineNumber': 'JM31E3456789'},
  ];

  // ═══════════════════════════════════════
  // RIWAYAT SERVIS
  // ═══════════════════════════════════════
  // ═══════════════════════════════════════
  // RIWAYAT SERVIS
  // ═══════════════════════════════════════
    // ═══════════════════════════════════════
  // RIWAYAT SERVIS
  // ═══════════════════════════════════════
  static List<ServiceHistory> serviceHistories = [
    // ═══ DALAM PROSES — V1 (Honda Vario 125) ═══
    ServiceHistory(
      id: 'H1',
      ticketNumber: 'SRV-2026-24108',
      vehicleId: 'V1',
      vehicleName: 'Honda Vario 125',
      plateNumber: 'AD 1234 H',
      serviceType: 'Ganti Oli Terpisah',
      date: DateTime(2026, 9, 29),
      totalPrice: 85000,
      status: 'Menunggu Konfirmasi',
      workshop: 'ServisinAja - Seturan',
      currentKm: 87,
    ),

    // ═══ DALAM PROSES — V2 (Yamaha NMAX 155) ═══
    ServiceHistory(
      id: 'H2',
      ticketNumber: 'SRV-2026-24109',
      vehicleId: 'V2',
      vehicleName: 'Yamaha NMAX 155',
      plateNumber: 'AB 5678 EF',
      serviceType: 'Servis CVT & Rem',
      date: DateTime(2026, 9, 29),
      totalPrice: 125000,
      status: 'Dikerjakan',
      workshop: 'ServisinAja - Babarsari',
      currentKm: 15200,
    ),

    // ═══ DALAM PROSES — V3 (Honda Beat Street) ═══
    ServiceHistory(
      id: 'H3',
      ticketNumber: 'SRV-2026-24110',
      vehicleId: 'V3',
      vehicleName: 'Honda Beat Street',
      plateNumber: 'AB 9012 GH',
      serviceType: 'Servis Berkala Rutin',
      date: DateTime(2026, 9, 28),
      totalPrice: 100000,
      status: 'Menunggu Konfirmasi',
      workshop: 'ServisinAja - Maguwo',
      currentKm: 8500,
    ),

    // ═══ RIWAYAT — V1 (Honda Vario 125) ═══
    ServiceHistory(
      id: 'H4',
      ticketNumber: 'SRV-2024-001234',
      vehicleId: 'V1',
      vehicleName: 'Honda Vario 125',
      plateNumber: 'AD 1234 H',
      serviceType: 'Servis Lengkap',
      date: DateTime(2024, 11, 15),
      totalPrice: 175000,
      status: 'Selesai',
      workshop: 'Servisin Aja - Babarsari',
      currentKm: 15000,
    ),
    ServiceHistory(
      id: 'H5',
      ticketNumber: 'SRV-2024-000987',
      vehicleId: 'V1',
      vehicleName: 'Honda Vario 125',
      plateNumber: 'AD 1234 H',
      serviceType: 'Ganti Oli Terpisah',
      date: DateTime(2024, 8, 20),
      totalPrice: 75000,
      status: 'Selesai',
      workshop: 'Servisin Aja - Seturan',
      currentKm: 12500,
    ),

    // ═══ RIWAYAT — V2 (Yamaha NMAX 155) ═══
    ServiceHistory(
      id: 'H6',
      ticketNumber: 'SRV-2024-001100',
      vehicleId: 'V2',
      vehicleName: 'Yamaha NMAX 155',
      plateNumber: 'AB 5678 EF',
      serviceType: 'Servis CVT & Rem',
      date: DateTime(2024, 10, 5),
      totalPrice: 200000,
      status: 'Selesai',
      workshop: 'Servisin Aja - Babarsari',
      currentKm: 13500,
    ),

    // ═══ RIWAYAT — V3 (Honda Beat Street) ═══
    ServiceHistory(
      id: 'H7',
      ticketNumber: 'SRV-2024-000850',
      vehicleId: 'V3',
      vehicleName: 'Honda Beat Street',
      plateNumber: 'AB 9012 GH',
      serviceType: 'Servis Berkala Rutin',
      date: DateTime(2024, 9, 12),
      totalPrice: 120000,
      status: 'Selesai',
      workshop: 'Servisin Aja - Maguwo',
      currentKm: 7200,
    ),
  ];

  static void addHistory(ServiceHistory history) {
    serviceHistories.insert(0, history);
  }



  // ═══════════════════════════════════════
  // CHAT
  // ═══════════════════════════════════════
  static List<ChatMessage> chatMessages = [
    ChatMessage(
      id: 'C1',
      sender: 'Admin',
      message: 'Halo Kak Fika! Ada yang bisa kami bantu?',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isUser: false,
    ),
  ];

  // ═══════════════════════════════════════
  // REKOMENDASI per KATEGORI
  // ═══════════════════════════════════════
  static Map<String, Map<String, String>> categoryRecommendation = {
    'Oli Mesin': {
      'reason': 'Oli mesin perlu diganti berkala agar mesin tetap halus',
      'frequency': 'Setiap 2.000-3.000 km atau 2-3 bulan',
      'tips': 'Pilih sesuai rekomendasi pabrikan motor Anda',
    },
    'Oli Gardan': {
      'reason': 'Oli gardan menjaga transmisi matic tetap halus',
      'frequency': 'Setiap 8.000 km',
      'tips': 'Wajib untuk motor matic',
    },
    'Filter Udara': {
      'reason': 'Filter kotor bikin mesin boros & susah dinyalakan',
      'frequency': 'Setiap 8.000-10.000 km',
      'tips': 'Ganti bersamaan tune-up',
    },
    'Kampas Rem': {
      'reason': 'Kampas tipis bahaya & pengereman tidak pakem',
      'frequency': 'Setiap 10.000-15.000 km',
      'tips': 'Ganti depan-belakang sekaligus agar seimbang',
    },
    'CVT': {
      'reason': 'Roller & v-belt aus bikin tarikan berat',
      'frequency': 'Roller 15.000 km, V-Belt 20.000 km',
      'tips': 'Cek setiap 8.000 km',
    },
    'Busi': {
      'reason': 'Busi aus bikin starter susah & boros',
      'frequency': 'Setiap 8.000 km',
      'tips': 'Iridium lebih awet dari standar',
    },
    'Aki': {
      'reason': 'Aki lemah bikin motor susah starter',
      'frequency': 'Setiap 1-2 tahun',
      'tips': 'Cek voltase rutin',
    },
  };
  
}
