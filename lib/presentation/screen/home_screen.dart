import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/dummy/auth_service.dart';
import '../../data/dummy/dummy_data.dart';
import 'multi_vehicle_booking_screen.dart';
import 'service_history_screen.dart';
import 'chat_history_screen.dart';
import 'nearby_workshop_screen.dart';
import '../widgets/app_background.dart';
import 'notification_screen.dart';
import 'message_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _posterController =
      PageController(viewportFraction: 0.92);
  int _currentPosterIndex = 0;

  final List<Map<String, dynamic>> _posters = [
    {
      'image': 'assets/images/poster1.jpg',
      'title': 'Servis Motor\nAntar Jemput',
      'subtitle': 'Praktis & Tanpa Antre!',
    },
    {
      'image': 'assets/images/poster2.jpg',
      'title': 'Diskon Servis\nHingga 30%',
      'subtitle': 'Khusus member baru',
    },
    {
      'image': 'assets/images/poster3.jpg',
      'title': 'Gratis Oli MPX\nSetiap Servis',
      'subtitle': 'Untuk servis lengkap',
    },
    {
      'image': 'assets/images/poster4.jpg',
      'title': 'Booking Mudah\nMulti Kendaraan',
      'subtitle': '1x transaksi, banyak motor',
    },
  ];

  final List<Map<String, dynamic>> _products = List.generate(
    5,
    (i) => {
      'name': 'Oli MPX 0.8 L',
      'originalPrice': 25000,
      'discountPrice': 20000,
      'image': 'assets/images/Oli.jpg',
    },
  );

  @override
  void dispose() {
    _posterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),

              // 1. Header
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenH),
                child: _buildHeader(context),
              ),
              const SizedBox(height: AppSpacing.xl),

              // 2. Points Banner
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenH),
                child: _buildPointsBanner(),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 3. Poster Carousel
              _buildPosterCarousel(),
              const SizedBox(height: AppSpacing.md),
              _buildPageIndicator(),
              const SizedBox(height: AppSpacing.xl),

              // 4. Connect Motor Card
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenH),
                child: _buildConnectMotorCard(context),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 5. Nearby Workshop Banner
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenH),
                child: _buildNearbyWorkshopBanner(context),
              ),
              const SizedBox(height: AppSpacing.xxl),

              
              // 7. Barang Diskon
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenH),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Barang Diskon',
                          style: AppTextStyles.small(
                            color: AppColors.primaryOrange,
                            weight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Lihat Selengkapnya >',
                          style: AppTextStyles.small(
                            color: AppColors.primaryOrange,
                            weight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ..._products.map((p) => _buildProductCard(p)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        
      ),
    );
  }

  // ══════════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════════
  Widget _buildHeader(BuildContext context) {
    final user = AuthService.currentUser;
    final userName = user?.name ?? 'Guest';
    final userAddress = user?.address ?? 'Jl. Babarsari Jl...';

    return Row(
      children: [
        Container(
          width: 49,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryOrange,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child:
              const Icon(Icons.two_wheeler, color: Colors.white, size: 24),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Halo $userName,",
                style: AppTextStyles.medium(
                  color: AppColors.primaryOrange,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 13, color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      userAddress,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.small(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ═══ TOMBOL NOTIFIKASI + BADGE ═══
        Stack(
          children: [
            _buildIconButton(
              Icons.notifications_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationScreen()),
                );
              },
            ),
            if (DummyData.unreadNotificationCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    DummyData.unreadNotificationCount > 9
                        ? '9+'
                        : '${DummyData.unreadNotificationCount}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.small(
                      color: Colors.white,
                      weight: FontWeight.w700,
                    ).copyWith(fontSize: 9),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.sm),

        // ═══ TOMBOL CHAT + BADGE UNREAD ═══
        Stack(
          children: [
            _buildIconButton(
              Icons.chat_bubble_outline,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const MessageScreen()),
                );
              },
            ),
            if (DummyData.unreadChatCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    DummyData.unreadChatCount > 9
                        ? '9+'
                        : '${DummyData.unreadChatCount}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.small(
                      color: Colors.white,
                      weight: FontWeight.w700,
                    ).copyWith(fontSize: 9),
                  ),
                ),
              ),
          ],
        ),

      ],
    );
  }

  Widget _buildIconButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.primaryOrange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        child: Icon(icon, color: AppColors.primaryOrange, size: 18),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // POINTS BANNER
  // ══════════════════════════════════════════════
  Widget _buildPointsBanner() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                const Icon(Icons.monetization_on,
                    color: Colors.amber, size: 16),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  "12 points",
                  style: AppTextStyles.small(
                    color: AppColors.textPrimary,
                    weight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Container(
              margin:
                  const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryOrange,
                    AppColors.discountPrice,
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                ),
              ),
              child: Center(
                child: Text(
                  "Dapatkan hadiah",
                  style: AppTextStyles.small(
                    color: Colors.white,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  // POSTER CAROUSEL
  // ══════════════════════════════════════════════
  Widget _buildPosterCarousel() {
    return SizedBox(
      height: 130,
      child: PageView.builder(
        controller: _posterController,
        onPageChanged: (i) =>
            setState(() => _currentPosterIndex = i),
        itemCount: _posters.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _posterController,
            builder: (context, _) {
              double scale = 1.0;
              if (_posterController.position.haveDimensions) {
                final page = _posterController.page ?? 0;
                scale = (1 - (page - index).abs() * 0.12)
                    .clamp(0.85, 1.0);
              }
              return Transform.scale(
                scale: scale,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs + 1),
                  child: _buildPosterCard(_posters[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPosterCard(Map<String, dynamic> poster) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            poster['image'] as String,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.softOrange,
                child: const Center(
                  child: Icon(Icons.image_not_supported,
                      color: AppColors.primaryOrange, size: 40),
                ),
              );
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.0),
                  Colors.black.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  poster['title'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.medium(
                    color: Colors.white,
                    weight: FontWeight.w900,
                    height: 1.2,
                  ).copyWith(
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  poster['subtitle'] as String,
                  style: AppTextStyles.small(
                    color: Colors.white,
                    weight: FontWeight.w600,
                  ).copyWith(
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_posters.length, (index) {
        final isActive = _currentPosterIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primaryOrange
                : AppColors.textHint,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  // ══════════════════════════════════════════════
  // CONNECT MOTOR CARD
  // ══════════════════════════════════════════════
  Widget _buildConnectMotorCard(BuildContext context) {
    return Container(
      height: 122,
      padding: const EdgeInsets.only(
          top: AppSpacing.sm + 2,
          left: 15,
          bottom: AppSpacing.sm + 2,
          right: 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 100,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.softOrange,
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            child: Image.asset(
              'assets/images/motor.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.engineering,
                    size: 45, color: AppColors.primaryOrange);
              },
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hubungkan Motormu',
                      style: AppTextStyles.medium(
                        color: AppColors.primaryOrange,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'agar lebih mudah memantau jadwal service dan dapatkan voucher',
                      style: AppTextStyles.small(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const MultiVehicleBookingScreen()),
                    );
                  },
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm + 2,
                        vertical: AppSpacing.sm - 2),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppColors.primaryOrange,
                          AppColors.discountPrice,
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5),
                        bottomLeft: Radius.circular(5),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Hubungkan Motormu',
                        style: AppTextStyles.small(
                          color: Colors.white,
                          weight: FontWeight.w700,
                        ),
                      ),
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

  // ══════════════════════════════════════════════
  // NEARBY WORKSHOP BANNER
  // ══════════════════════════════════════════════
  Widget _buildNearbyWorkshopBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const NearbyWorkshopScreen()),
        );
      },
      child: Container(
        height: 122,
        padding: const EdgeInsets.only(
          top: AppSpacing.sm + 2,
          left: 15,
          bottom: AppSpacing.sm + 2,
          right: 0,
        ),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 9,
                  right: AppSpacing.sm,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Temukan Bengkel Terdekat',
                      style: AppTextStyles.medium(
                        color: AppColors.primaryOrange,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'praktis dan terpercaya',
                      style: AppTextStyles.small(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 110,
              height: 122,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: 10,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppColors.softOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 15,
                    child: Icon(
                      Icons.location_on_outlined,
                      size: 28,
                      color: AppColors.primaryOrange
                          .withValues(alpha: 0.25),
                    ),
                  ),
                  Positioned(
                    right: 5,
                    bottom: 0,
                    child: Image.asset(
                      'assets/images/orang.png',
                      height: 110,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.engineering,
                          size: 70,
                          color: AppColors.primaryOrange,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildMenuButton({
    String? image,
    IconData? icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg - 2),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: image != null
                  ? Image.asset(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        icon ?? Icons.image,
                        color: color,
                        size: 24,
                      ),
                    )
                  : Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.small(weight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // PRODUCT CARD
  // ══════════════════════════════════════════════
  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding:
          const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(
              product['image'] as String,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.softOrange,
                  child: const Icon(Icons.image_not_supported,
                      color: AppColors.primaryOrange, size: 32),
                );
              },
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'] as String,
                        style: AppTextStyles.medium(
                          weight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm - 2),
                      Text(
                        'Rp ${_formatNumber(product['originalPrice'] as int)}',
                        style: AppTextStyles.small(
                          color: AppColors.strikePrice,
                          weight: FontWeight.w300,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: AppColors.strikePrice,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Rp ',
                              style: AppTextStyles.medium(
                                color: AppColors.discountPrice,
                                height: 1.4,
                              ),
                            ),
                            TextSpan(
                              text: _formatNumber(
                                  product['discountPrice'] as int),
                              style: AppTextStyles.medium(
                                color: AppColors.discountPrice,
                                weight: FontWeight.w700,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm + 2),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppColors.primaryOrange,
                          AppColors.discountPrice,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm),
                    ),
                    child: Center(
                      child: Text(
                        'Beli',
                        style: AppTextStyles.medium(
                          color: Colors.white,
                          weight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
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

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}