import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class SmartBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const SmartBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<SmartBottomNav> createState() => _SmartBottomNavState();
}

class _SmartBottomNavState extends State<SmartBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Beranda'),
    _NavItem(icon: Icons.receipt_long_rounded, label: 'Aktivitas'),
    _NavItem(icon: Icons.build_circle_rounded, label: 'Servis'),
    _NavItem(icon: Icons.local_offer_rounded, label: 'Promo'),
    _NavItem(icon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void didUpdateWidget(covariant SmartBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    if (index == widget.currentIndex) return;
    HapticFeedback.lightImpact();
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              return _buildNavItem(i);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isActive = widget.currentIndex == index;
    final item = _items[index];

    return Expanded(
      child: GestureDetector(
        onTap: () => _handleTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon dengan animasi
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(
                    horizontal: isActive ? 16 : 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.softOrange
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey('icon_$index'),
                    tween: Tween(
                      begin: isActive ? 0.8 : 1.0,
                      end: 1.0,
                    ),
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.elasticOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: isActive ? scale : 1.0,
                        child: Icon(
                          item.icon,
                          size: isActive ? 24 : 22,
                          color: isActive
                              ? AppColors.primaryOrange
                              : AppColors.textHint,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 2),
                // Label dengan fade + slide
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  child: isActive
                      ? Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            item.label,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryOrange,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}