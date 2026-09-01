import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/home_screen.dart';
import '../screens/dictionary_screen.dart';
import '../screens/tts_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/profile_screen.dart';

/// شريط التنقل السفلي الموحد لتطبيق صدى
class SadaBottomNav extends StatelessWidget {
  final int currentIndex;

  const SadaBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavItem(Icons.home_rounded, 'الرئيسية'),
      _NavItem(Icons.menu_book_rounded, 'القاموس'),
      _NavItem(Icons.record_voice_over_rounded, 'تحويل'),
      _NavItem(Icons.chat_bubble_rounded, 'المحادثات'),
      _NavItem(Icons.person_rounded, 'حسابي'),
    ];

    return Directionality(
      // مهم: تثبيت اتجاه شريط التنقل حتى لا ينعكس
      // بسبب Directionality الموجود في الشاشة.
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPurple.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: List.generate(
              items.length,
              (index) {
                final selected = index == currentIndex;

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _handleNavigation(context, index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.softPurple
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedScale(
                            scale: selected ? 1.08 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              items[index].icon,
                              size: 22,
                              color: selected
                                  ? AppColors.primaryPurple
                                  : AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            items[index].label,
                            style: TextStyle(
                              fontFamily: 'Baloo_Bhaijaan_2',
                              fontSize: 11,
                              color: selected
                                  ? AppColors.primaryPurple
                                  : AppColors.textMuted,
                              fontWeight:
                                  selected ? FontWeight.w800 : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _handleNavigation(
    BuildContext context,
    int index,
  ) {
    if (index == currentIndex) return;

    final Widget destination;

    switch (index) {
      case 0:
        destination = const HomeScreen();
        break;

      case 1:
        destination = const DictionaryScreen();
        break;

      case 2:
        destination = const TtsScreen();
        break;

      case 3:
        destination = const ChatScreen();
        break;

      case 4:
        destination = const ProfileScreen();
        break;

      default:
        destination = const HomeScreen();
    }

    if (index == 0) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => destination,
        ),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => destination,
          transitionDuration: const Duration(
            milliseconds: 150,
          ),
          transitionsBuilder: (
            _,
            animation,
            __,
            child,
          ) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    }
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem(
    this.icon,
    this.label,
  );
}
