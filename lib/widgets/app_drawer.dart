import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/home_screen.dart';
import '../screens/dictionary_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/tts_screen.dart';
import '../screens/ai_assistant_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/login_screen.dart';
import '../services/api_service.dart';

class SadaDrawer extends StatelessWidget {
  final int activeIndex;

  const SadaDrawer({super.key, this.activeIndex = 0});

  @override
  Widget build(BuildContext context) {
    final user = ApiService.currentUser;
    final userName = user?.fullName.isNotEmpty == true ? user!.fullName : 'مستخدم صدى';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        backgroundColor: AppColors.bg,
        width: MediaQuery.of(context).size.width * 0.82,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ==============================
              // HEADER
              // ==============================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
                decoration: const BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.graphic_eq_rounded,
                            color: AppColors.primaryPurple,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'صدى | Sada AI',
                              style: TextStyle(
                                fontFamily: 'Baloo_Bhaijaan_2',
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'مساعدك الذكي للتواصل',
                              style: TextStyle(
                                fontFamily: 'Baloo_Bhaijaan_2',
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'مرحباً بك $userName 👋',
                      style: const TextStyle(
                        fontFamily: 'Baloo_Bhaijaan_2',
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'اختر الخدمة أو الأداة المطلوبة',
                      style: TextStyle(
                        fontFamily: 'Baloo_Bhaijaan_2',
                        color: Colors.white70,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ==============================
              // MENU ITEMS
              // ==============================
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  children: [
                    _drawerItem(
                      context,
                      icon: Icons.home_rounded,
                      title: 'الرئيسية',
                      selected: activeIndex == 0,
                      onTap: () {
                        Navigator.pop(context);
                        if (activeIndex != 0) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                            (route) => false,
                          );
                        }
                      },
                    ),
                    _drawerItem(
                      context,
                      icon: Icons.menu_book_rounded,
                      title: 'القاموس الإشاري',
                      selected: activeIndex == 1,
                      onTap: () {
                        Navigator.pop(context);
                        if (activeIndex != 1) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const DictionaryScreen()),
                          );
                        }
                      },
                    ),
                    _drawerItem(
                      context,
                      icon: Icons.record_voice_over_rounded,
                      title: 'تحويل النص إلى كلام',
                      selected: activeIndex == 2,
                      onTap: () {
                        Navigator.pop(context);
                        if (activeIndex != 2) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const TtsScreen()),
                          );
                        }
                      },
                    ),
                    _drawerItem(
                      context,
                      icon: Icons.chat_bubble_rounded,
                      title: 'المحادثات الذكية',
                      selected: activeIndex == 3,
                      onTap: () {
                        Navigator.pop(context);
                        if (activeIndex != 3) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const ChatScreen()),
                          );
                        }
                      },
                    ),
                    _drawerItem(
                      context,
                      icon: Icons.auto_awesome_rounded,
                      title: 'مساعد الذكاء الاصطناعي',
                      selected: activeIndex == 5,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AiAssistantScreen(),
                          ),
                        );
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Divider(color: AppColors.border),
                    ),
                    _drawerItem(
                      context,
                      icon: Icons.person_rounded,
                      title: 'الملف الشخصي',
                      selected: activeIndex == 4,
                      onTap: () {
                        Navigator.pop(context);
                        if (activeIndex != 4) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const ProfileScreen()),
                          );
                        }
                      },
                    ),
                    _drawerItem(
                      context,
                      icon: Icons.info_outline_rounded,
                      title: 'عن تطبيق صدى',
                      onTap: () {
                        Navigator.pop(context);
                        showAboutDialog(
                          context: context,
                          applicationName: 'منصة صدى (Sada)',
                          applicationVersion: '1.0.0',
                          applicationLegalese: 'منصة صدى لدعم التواصل الصوتي والترجمة الإشارية بالذكاء الاصطناعي',
                        );
                      },
                    ),
                  ],
                ),
              ),

              // ==============================
              // LOGOUT
              // ==============================
              Padding(
                padding: const EdgeInsets.all(16),
                child: _drawerItem(
                  context,
                  icon: Icons.logout_rounded,
                  title: 'تسجيل الخروج',
                  danger: true,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: const Text('تسجيل الخروج', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Baloo_Bhaijaan_2', fontWeight: FontWeight.bold)),
                        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Baloo_Bhaijaan_2')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Baloo_Bhaijaan_2', color: AppColors.textMuted)),
                          ),
                          TextButton(
                            onPressed: () {
                              ApiService.currentUser = null;
                              Navigator.pop(ctx);
                              Navigator.pop(context);
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                                (route) => false,
                              );
                            },
                            child: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Baloo_Bhaijaan_2', color: Colors.redAccent, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool selected = false,
    bool danger = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: selected ? AppColors.softPurple : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Icon(
          icon,
          color: danger
              ? Colors.redAccent
              : selected
                  ? AppColors.primaryPurple
                  : AppColors.textMuted,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Baloo_Bhaijaan_2',
            fontSize: 14.5,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: danger
                ? Colors.redAccent
                : selected
                    ? AppColors.primaryPurple
                    : AppColors.textDark,
          ),
        ),
        trailing: selected
            ? const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.primaryPurple,
                size: 20,
              )
            : null,
      ),
    );
  }
}