import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/sada_bottom_nav.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool embedded;
  const ProfileScreen({super.key, this.embedded = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double _defaultSpeechRate = 1.0;
  bool _enableHaptics = true;
  bool _enableAutoListen = false;

  @override
  Widget build(BuildContext context) {
    final user = ApiService.currentUser;
    final userName = user?.fullName.isNotEmpty == true ? user!.fullName : 'مستخدم صدى';
    final userEmail = user?.email.isNotEmpty == true ? user!.email : 'user@sada.app';
    final userPhone = user?.phoneNumber?.isNotEmpty == true ? user!.phoneNumber! : '770000000';

    final body = Directionality(
      textDirection: TextDirection.rtl,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 110),
        children: [
          // ==========================================
          // 1. HEADER PROFILE CARD
          // ==========================================
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.brandGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryPurple.withValues(alpha: 0.28),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/profile_avatar.png',
                          width: 86,
                          height: 86,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => CircleAvatar(
                            radius: 43,
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
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.accentCyan,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  userName,
                  style: const TextStyle(
                    fontFamily: 'Baloo_Bhaijaan_2',
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  userEmail,
                  style: const TextStyle(
                    fontFamily: 'Baloo_Bhaijaan_2',
                    fontSize: 13.5,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.softPurple,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.15)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded, color: AppColors.primaryPurple, size: 15),
                      SizedBox(width: 6),
                      Text(
                        'عضو نشط في مجتمع صدى ✨',
                        style: TextStyle(
                          fontFamily: 'Baloo_Bhaijaan_2',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ==========================================
          // 2. QUICK STATS ROW
          // ==========================================
          Row(
            children: [
              _buildStatCard('العبارات', '24', Icons.auto_stories_rounded, AppColors.primaryPurple),
              const SizedBox(width: 12),
              _buildStatCard('المحادثات', '18', Icons.chat_bubble_rounded, AppColors.accentCyan),
              const SizedBox(width: 12),
              _buildStatCard('أيام نشاط', '9 🔥', Icons.bolt_rounded, Colors.orangeAccent),
            ],
          ),

          const SizedBox(height: 24),

          // ==========================================
          // 3. ACCOUNT INFO GROUP
          // ==========================================
          _buildSectionHeader('معلومات الحساب'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.person_rounded,
                  title: 'الاسم الكامل',
                  value: userName,
                  isFirst: true,
                ),
                const Divider(height: 1, indent: 60, endIndent: 20),
                _buildInfoRow(
                  icon: Icons.email_rounded,
                  title: 'البريد الإلكتروني',
                  value: userEmail,
                ),
                const Divider(height: 1, indent: 60, endIndent: 20),
                _buildInfoRow(
                  icon: Icons.phone_rounded,
                  title: 'رقم الهاتف',
                  value: userPhone,
                  isLast: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ==========================================
          // 4. PREFERENCES GROUP
          // ==========================================
          _buildSectionHeader('تفضيلات النطق والتطبيق'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.softPurple,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.speed_rounded, color: AppColors.primaryPurple, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'سرعة النطق المفضلة',
                          style: TextStyle(
                            fontFamily: 'Baloo_Bhaijaan_2',
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${_defaultSpeechRate.toStringAsFixed(1)}x',
                      style: const TextStyle(
                        fontFamily: 'Baloo_Bhaijaan_2',
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryPurple,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [0.75, 1.0, 1.25, 1.5].map((rate) {
                    final isSelected = _defaultSpeechRate == rate;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _defaultSpeechRate = rate;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryPurple : AppColors.bg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryPurple : AppColors.border,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${rate}x',
                              style: TextStyle(
                                fontFamily: 'Baloo_Bhaijaan_2',
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isSelected ? Colors.white : AppColors.textDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                // Haptics toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accentCyan.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.vibration_rounded, color: AppColors.accentCyan, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'الاهتزاز والتفاعل اللمسي',
                          style: TextStyle(
                            fontFamily: 'Baloo_Bhaijaan_2',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    Switch.adaptive(
                      value: _enableHaptics,
                      activeThumbColor: AppColors.primaryPurple,
                      onChanged: (val) {
                        setState(() {
                          _enableHaptics = val;
                        });
                      },
                    ),
                  ],
                ),
                const Divider(height: 1),
                const SizedBox(height: 12),
                // Auto listen toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.softPurple,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.mic_none_rounded, color: AppColors.primaryPurple, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'الاستماع التلقائي للمساعد الذكي',
                          style: TextStyle(
                            fontFamily: 'Baloo_Bhaijaan_2',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    Switch.adaptive(
                      value: _enableAutoListen,
                      activeThumbColor: AppColors.primaryPurple,
                      onChanged: (val) {
                        setState(() {
                          _enableAutoListen = val;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ==========================================
          // 5. SUPPORT & INFO GROUP
          // ==========================================
          _buildSectionHeader('المساعدة والمعلومات'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildActionRow(
                  icon: Icons.info_outline_rounded,
                  title: 'عن تطبيق صدى',
                  subtitle: 'الإصدار 1.0.0 - منصة التواصل الشامل',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'صدى | Sada',
                      applicationVersion: '1.0.0',
                      applicationLegalese:
                          'مشروع صدى لدعم وتسهيل التواصل الصوتي والإشاري بالذكاء الاصطناعي وخدمة الصم والبكم.',
                    );
                  },
                  isFirst: true,
                ),
                const Divider(height: 1, indent: 60, endIndent: 20),
                _buildActionRow(
                  icon: Icons.share_rounded,
                  title: 'مشاركة التطبيق',
                  subtitle: 'انشر رسالة التواصل وشارك صدى مع أصدقائك',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'شكراً لمشاركتك تطبيق صدى ودعمك لمجتمع الصم والبكم 💜',
                          textAlign: TextAlign.right,
                        ),
                        backgroundColor: AppColors.primaryPurple,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  isLast: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ==========================================
          // 6. LOGOUT BUTTON
          // ==========================================
          Container(
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.red.shade50,
              border: Border.all(color: Colors.red.shade100),
            ),
            child: TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => Directionality(
                    textDirection: TextDirection.rtl,
                    child: AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      title: const Row(
                        children: [
                          Icon(Icons.logout_rounded, color: Colors.redAccent),
                          SizedBox(width: 8),
                          Text(
                            'تسجيل الخروج',
                            style: TextStyle(
                              fontFamily: 'Baloo_Bhaijaan_2',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      content: const Text(
                        'هل أنت متأكد من رغبتك في تسجيل الخروج من حسابك في صدى؟',
                        style: TextStyle(fontFamily: 'Baloo_Bhaijaan_2', fontSize: 14.5),
                      ),
                      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text(
                            'إلغاء',
                            style: TextStyle(
                              fontFamily: 'Baloo_Bhaijaan_2',
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ApiService.currentUser = null;
                            Navigator.pop(ctx);
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'نعم، خروج',
                            style: TextStyle(
                              fontFamily: 'Baloo_Bhaijaan_2',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
              label: const Text(
                'تسجيل الخروج من الحساب',
                style: TextStyle(
                  fontFamily: 'Baloo_Bhaijaan_2',
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );

    if (widget.embedded) return SafeArea(child: body);

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

  // ==========================================
  // WIDGET HELPERS
  // ==========================================

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Baloo_Bhaijaan_2',
          fontSize: 15.5,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Baloo_Bhaijaan_2',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Baloo_Bhaijaan_2',
                fontSize: 11.5,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.softPurple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryPurple, size: 19),
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
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Baloo_Bhaijaan_2',
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
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

  Widget _buildActionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(22) : Radius.zero,
        bottom: isLast ? const Radius.circular(22) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: AppColors.accentCyan.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primaryPurple, size: 19),
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
