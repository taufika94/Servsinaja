import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/smart_bottom_nav.dart';
import 'home_screen.dart';
import 'activity_screen.dart';
import 'multi_vehicle_booking_screen.dart';
import 'promo_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    ActivityScreen(),
    MultiVehicleBookingScreen(showBackButton: false),
    PromoScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,   // ← WAJIB: background, bukan primaryOrange
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: SmartBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}