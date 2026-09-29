import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/service_model.dart';

class PromoScreen extends StatefulWidget {
  const PromoScreen({super.key});

  @override
  State<PromoScreen> createState() => _PromoScreenState();
}

class _PromoScreenState extends State<PromoScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),

              // ═══ HEADER ═══
              Text(
                "Promo & Voucher",
                style: AppTextStyles.medium(
                  weight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                "Klaim voucher untuk hemat biaya servis",
                style: AppTextStyles.small(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ═══ HERO BANNER ═══
              _buildHeroBanner(),
              const SizedBox(height: AppSpacing.lg),

              // ═══ VOUCHER SAYA (yang sudah diklaim) ═══
              if (DummyData.claimedVouchers.isNotEmpty) ...[
                _buildSectionTitle(
                  "Voucher Saya (${DummyData.claimedVouchers.length})",
                ),
                const SizedBox(height: AppSpacing.sm),
                ...DummyData.claimedVouchers.map((v) {
                  return _buildClaimedVoucherCard(v);
                }).toList(),
                const SizedBox(height: AppSpacing.lg),
              ],

              // ═══ SECTION TITLE ═══
              _buildSectionTitle("Voucher Tersedia"),
              const SizedBox(height: AppSpacing.sm),

              // ═══ LIST VOUCHER TERSEDIA ═══
              ...DummyData.availableVouchers.map((v) {
                final isClaimed = DummyData.isClaimed(v);
                return _buildVoucherCard(v, isClaimed: isClaimed);
              }).toList(),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.medium(
        weight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  // ═══════════════════════════════════════
  // HERO BANNER — PAKAI GAMBAR voucher.jpg
  // ═══════════════════════════════════════
  Widget _buildHeroBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Image.asset(
        'assets/images/voucher.jpg',
        width: double.infinity,
        height: 130,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: double.infinity,
          height: 130,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.primaryOrange,
                AppColors.discountPrice,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius:
                BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: const Center(
            child: Icon(
              Icons.card_giftcard,
              color: Colors.white54,
              size: 60,
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // VOUCHER CARD (TERSEDIA)
  // ═══════════════════════════════════════
  Widget _buildVoucherCard(Voucher voucher, {required bool isClaimed}) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: isClaimed
            ? Border.all(color: AppColors.success, width: 1.5)
            : Border.all(color: AppColors.divider, width: 1),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.softOrange,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.sm),
                ),
                child: const Icon(
                  Icons.local_offer_outlined,
                  color: AppColors.primaryOrange,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            voucher.title,
                            style: AppTextStyles.small(
                              weight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.softOrange,
                            borderRadius: BorderRadius.circular(
                                AppSpacing.xs),
                          ),
                          child: Text(
                            voucher.code,
                            style: AppTextStyles.small(
                              weight: FontWeight.w700,
                              color: AppColors.primaryOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      voucher.description,
                      style: AppTextStyles.small(
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Min. ${CurrencyFormatter.format(voucher.minTransaction)}',
                      style: AppTextStyles.small(
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isClaimed
                  ? () => _unclaim(voucher)
                  : () => _claim(voucher),
              style: ElevatedButton.styleFrom(
                backgroundColor: isClaimed
                    ? AppColors.success
                    : AppColors.primaryOrange,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm + 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusSm),
                ),
                elevation: 0,
              ),
              child: Text(
                isClaimed ? 'Sudah Diklaim' : 'Klaim Voucher',
                style: AppTextStyles.medium(
                  weight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // CLAIMED VOUCHER CARD (Voucher Saya)
  // ═══════════════════════════════════════
  Widget _buildClaimedVoucherCard(Voucher voucher) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.softOrange,
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              color: AppColors.primaryOrange,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  voucher.title,
                  style: AppTextStyles.small(
                    weight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Kode: ${voucher.code}',
                  style: AppTextStyles.small(
                    color: AppColors.primaryOrange,
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _unclaim(voucher),
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.danger,
              size: 20,
            ),
            tooltip: 'Batalkan klaim',
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // HANDLERS
  // ═══════════════════════════════════════
  void _claim(Voucher voucher) {
    setState(() {
      DummyData.claimVoucher(voucher);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Voucher ${voucher.code} berhasil diklaim',
          style: AppTextStyles.small(color: AppColors.white),
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _unclaim(Voucher voucher) {
    setState(() {
      DummyData.unclaimVoucher(voucher);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Voucher ${voucher.code} dibatalkan',
          style: AppTextStyles.small(color: AppColors.white),
        ),
        backgroundColor: AppColors.textSecondary,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}