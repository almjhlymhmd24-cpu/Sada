import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/sada_bottom_nav.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final bool embedded;
  const ProfileScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final user = ApiService.currentUser;
    final userName = user?.fullName.isNotEmpty == true ? user!.fullName : 'مستخدم صدى';
    final userEmail = user?.email.isNotEmpty == true ? user!.email : 'user@sada.app';
    final userPhone = user?.phoneNumber ?? 'غير محدد';

    final body = Directionality(
      textDirection: TextDirection.rtl,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          // بطاقة رأس الملف الشخصي
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.brandGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPurple.withValues(alpha: 0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/profile_avatar.png',
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => CircleAvatar(
                        radius: 45,
                        backgroundColor: AppColors.softPurple,
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'ص',
                          style: const TextStyle(
                            fontFamily: 'Baloo_Bhaijaan_2',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.accentCyan,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Center(
            child: Text(
              userName,
              style: const TextStyle(
                fontFamily: 'Baloo_Bhaijaan_2',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
          Center(
            child: Text(
              userEmail,
              style: const TextStyle(
                fontFamily: 'Baloo_Bhaijaan_2',
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // بطاقة معلومات الحساب
          const Text(
            'معلومات الحساب',
            style: TextStyle(
              fontFamily: 'Baloo_Bhaijaan_2',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),

          _profileTile(Icons.person_outline_rounded, 'الاسم الكامل', userName),
          _profileTile(Icons.mail_outline_rounded, 'البريد الإلكتروني', userEmail),
          _profileTile(Icons.phone_outlined, 'رقم الجوال', userPhone),

          const SizedBox(height: 24),

          // إعدادات وتفضيلات
          const Text(
            'التفضيلات والمعلومات',
            style: TextStyle(
              fontFamily: 'Baloo_Bhaijaan_2',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),

          _actionTile(
            icon: Icons.info_outline_rounded,
            title: 'عن تطبيق صدى',
            subtitle: 'الإصدار 1.0.0 - تطبيق مساعد التواصل الذكي',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'صدى | Sada',
                applicationVersion: '1.0.0',
                applicationLegalese: 'مشروع صدى لدعم وتسهيل التواصل الصوتي والإشاري بالذكاء الاصطناعي',
              );
            },
          ),

          const SizedBox(height: 32),

          // زر تسجيل الخروج
          Container(
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.redAccent.withValues(alpha: 0.1),
            ),
            child: TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Text('تسجيل الخروج', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Baloo_Bhaijaan_2', fontWeight: FontWeight.bold)),
                    content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج من صدى؟', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Baloo_Bhaijaan_2')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('إلغاء', style: TextStyle(fontFamily: 'Baloo_Bhaijaan_2', color: AppColors.textMuted)),
                      ),
                      TextButton(
                        onPressed: () {
                          ApiService.currentUser = null;
                          Navigator.pop(ctx);
                          Navigator.of(context).pushAndRemoveUntil(
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
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              label: const Text(
                'تسجيل الخروج',
                style: TextStyle(
                  fontFamily: 'Baloo_Bhaijaan_2',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (embedded) return SafeArea(child: body);

    return Scaffold(
      backgroundColor: AppColors.bg,
      drawer: const SadaDrawer(activeIndex: 4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.textDark),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'الملف الشخصي',
          style: TextStyle(
            fontFamily: 'Baloo_Bhaijaan_2',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(child: body),
      bottomNavigationBar: const SadaBottomNav(currentIndex: 4),
    );
  }

  Widget _profileTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.softPurple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryPurple, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Baloo_Bhaijaan_2',
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Baloo_Bhaijaan_2',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accentCyan.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primaryPurple, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Baloo_Bhaijaan_2',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Baloo_Bhaijaan_2',
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
