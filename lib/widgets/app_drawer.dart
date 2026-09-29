import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';

import '../screens/home_screen.dart';
import '../screens/dictionary_screen.dart';
import '../screens/tts_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/profile_screen.dart';

class SadaDrawer extends StatelessWidget {
  final int activeIndex;

  const SadaDrawer({
    super.key,
    required this.activeIndex,
  });

  static const String logoAsset = 'assets/logo.svg';

  void _navigate(
    BuildContext context,
    Widget page,
  ) {
    Navigator.pop(context);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ApiService.currentUser;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        width: MediaQuery.of(context).size.width * 0.82,
        backgroundColor: AppColors.bg,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            bottomLeft: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // =================================================
              // HEADER
              // =================================================

              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(
                  12,
                  12,
                  12,
                  0,
                ),
                padding: const EdgeInsets.fromLTRB(
                  18,
                  20,
                  18,
                  18,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xFF34C9D5),
                      Color(0xFF2D84E2),
                      Color(0xFF2949D7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(
                        alpha: 0.15,
                      ),
                      blurRadius: 22,
                      offset: const Offset(
                        0,
                        9,
                      ),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // الشعار
                    Container(
                      width: 62,
                      height: 62,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.16,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: 0.28,
                          ),
                          width: 1.5,
                        ),
                      ),
                      child: SvgPicture.asset(
                        'assets/logo.svg',
                        fit: BoxFit.contain,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                        placeholderBuilder: (_) {
                          return const Icon(
                            Icons.graphic_eq_rounded,
                            color: Colors.white,
                            size: 30,
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'صدى',
                            style: TextStyle(
                              fontFamily: 'Baloo_Bhaijaan_2',
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            user?.fullName ?? 'مستخدم صدى',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Baloo_Bhaijaan_2',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? 'مرحباً بك في صدى',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Baloo_Bhaijaan_2',
                              fontSize: 11.5,
                              color: Colors.white.withValues(
                                alpha: 0.82,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // =================================================
              // MENU
              // =================================================

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  children: [
                    _drawerItem(
                      context,
                      index: 0,
                      icon: Icons.home_rounded,
                      title: 'الرئيسية',
                      subtitle: 'العودة إلى الصفحة الرئيسية',
                      page: const HomeScreen(),
                    ),
                    _drawerItem(
                      context,
                      index: 1,
                      icon: Icons.menu_book_rounded,
                      title: 'القاموس',
                      subtitle: 'العبارات والإشارات',
                      page: const DictionaryScreen(),
                    ),
                    _drawerItem(
                      context,
                      index: 2,
                      icon: Icons.record_voice_over_rounded,
                      title: 'التحويل',
                      subtitle: 'تحويل النص والصوت',
                      page: const TtsScreen(),
                    ),
                    _drawerItem(
                      context,
                      index: 3,
                      icon: Icons.auto_awesome_rounded,
                      title: 'المساعد الذكي',
                      subtitle: 'تحدث مع صدى AI',
                      page: const ChatScreen(),
                    ),
                    _drawerItem(
                      context,
                      index: 4,
                      icon: Icons.person_rounded,
                      title: 'الملف الشخصي',
                      subtitle: 'بيانات حسابك',
                      page: const ProfileScreen(),
                    ),
                  ],
                ),
              ),

              // =================================================
              // BOTTOM CARD
              // =================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  14,
                  8,
                  14,
                  10,
                ),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.softCyan,
                    borderRadius: BorderRadius.circular(
                      18,
                    ),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.graphic_eq_rounded,
                        color: AppColors.primaryBlue,
                        size: 25,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'صدى يساعدك على التواصل بوضوح وسهولة',
                          style: TextStyle(
                            fontFamily: 'Baloo_Bhaijaan_2',
                            color: AppColors.textDark,
                            fontSize: 11.5,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  14,
                  0,
                  14,
                  14,
                ),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    16,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                      16,
                    ),
                    onTap: () {
                      Navigator.pop(context);

                      // هنا نربط تسجيل الخروج الحقيقي لاحقاً
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          16,
                        ),
                        border: Border.all(
                          color: AppColors.border,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: AppColors.danger,
                            size: 21,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'تسجيل الخروج',
                            style: TextStyle(
                              fontFamily: 'Baloo_Bhaijaan_2',
                              color: AppColors.danger,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textMuted,
                            size: 13,
                          ),
                        ],
                      ),
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

  // ============================================================
  // DRAWER ITEM
  // ============================================================

  Widget _drawerItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget page,
  }) {
    final active = activeIndex == index;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 7,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(
          18,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(
            18,
          ),
          onTap: () {
            _navigate(
              context,
              page,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 220,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              gradient: active
                  ? const LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        AppColors.softCyan,
                        AppColors.softBlue,
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(
                18,
              ),
              border: Border.all(
                color: active
                    ? AppColors.primaryBlue.withValues(
                        alpha: 0.16,
                      )
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: active ? AppColors.navActiveGradient : null,
                    color: active ? null : Colors.white,
                    borderRadius: BorderRadius.circular(
                      13,
                    ),
                    border: active
                        ? null
                        : Border.all(
                            color: AppColors.border,
                          ),
                  ),
                  child: Icon(
                    icon,
                    size: 21,
                    color: active ? Colors.white : AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Baloo_Bhaijaan_2',
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: active
                              ? AppColors.primaryBlue
                              : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: 'Baloo_Bhaijaan_2',
                          fontSize: 10.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 13,
                  color: active ? AppColors.primaryBlue : AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
