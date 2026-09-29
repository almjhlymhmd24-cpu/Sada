import 'dart:ui';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../screens/home_screen.dart';
import '../screens/dictionary_screen.dart';
import '../screens/tts_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/profile_screen.dart';

/// شريط التنقل السفلي العائم فائق الأناقة والزجاجي (مستوحى من تصميم siren.uix العصري)
class SadaBottomNav extends StatelessWidget {
  final int currentIndex;

  const SadaBottomNav({
    super.key,
    required this.currentIndex,
  });

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = const HomeScreen();
        break;
      case 1:
        page = const DictionaryScreen();
        break;
      case 2:
        page = const TtsScreen();
        break;
      case 3:
        page = const ChatScreen();
        break;
      case 4:
        page = const ProfileScreen();
        break;
      default:
        page = const HomeScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 180),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.9),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF183153).withValues(alpha: 0.08),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.06),
                      blurRadius: 14,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 1. الرئيسية
                    _buildNavTab(
                      context: context,
                      index: 0,
                      label: 'الرئيسية',
                      icon: Icons.home_rounded,
                      activeIcon: Icons.home_rounded,
                    ),

                    // 2. القاموس
                    _buildNavTab(
                      context: context,
                      index: 1,
                      label: 'القاموس',
                      icon: Icons.menu_book_outlined,
                      activeIcon: Icons.menu_book_rounded,
                    ),

                    // 3. الزر المركزي المميز (تحويل / نطق)
                    _buildCenterActionButton(context),

                    // 4. المحادثات
                    _buildNavTab(
                      context: context,
                      index: 3,
                      label: 'المحادثات',
                      icon: Icons.chat_bubble_outline_rounded,
                      activeIcon: Icons.chat_bubble_rounded,
                    ),

                    // 5. حسابي
                    _buildNavTab(
                      context: context,
                      index: 4,
                      label: 'حسابي',
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavTab({
    required BuildContext context,
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isActive = index == currentIndex;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onTap(context, index),
          borderRadius: BorderRadius.circular(24),
          splashColor: AppColors.primaryBlue.withValues(alpha: 0.08),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primaryBlue.withValues(alpha: 0.1)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isActive ? activeIcon : icon,
                    size: 22,
                    color: isActive
                        ? AppColors.primaryBlue
                        : AppColors.textMuted.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Baloo_Bhaijaan_2',
                    fontSize: 10.5,
                    height: 1.1,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                    color: isActive
                        ? AppColors.primaryBlue
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterActionButton(BuildContext context) {
    final isActive = currentIndex == 2;

    return Expanded(
      child: Center(
        child: GestureDetector(
          onTap: () => _onTap(context, 2),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // الهالة الضوئية الدائرية في الخلفية (Cradle Radial Glow)
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentCyan.withValues(alpha: 0.28),
                      Colors.transparent,
                    ],
                    stops: const [0.3, 1.0],
                  ),
                ),
              ),

              // الزر الدائري البارز
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.brandGradient,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: AppColors.accentCyan.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Icon(
                  isActive
                      ? Icons.graphic_eq_rounded
                      : Icons.mic_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
