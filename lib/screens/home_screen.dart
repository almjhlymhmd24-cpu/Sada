import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:image_picker/image_picker.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../services/ai_image_service.dart';
import '../theme/app_theme.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';
import 'tts_screen.dart';
import 'dictionary_screen.dart';
import 'ai_assistant_screen.dart';
import 'image_analysis_result_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/sada_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TtsService _ttsService = TtsService();

  List<Category> _categories = ApiService.defaultCategories;
  bool _categoriesLoading = true;
  bool _categoriesError = false;
  bool _isSpeakingDailyPhrase = false;

  static const String voiceIcon = 'assets/icons/voice.svg';
  static const String textIcon = 'assets/icons/text.svg';
  static const String imageIcon = 'assets/icons/image.svg';
  static const String cameraIcon = 'assets/icons/camera.svg';

  static const String logoAsset = 'assets/logo.svg';
  static const String avatarAsset = 'assets/images/profile_avatar.png';
  static const String robootAsset = 'assets/Ai Robot Vector Art.json';

  @override
  void initState() {
    super.initState();

    _ttsService.init();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _categoriesLoading = true;
      _categoriesError = false;
    });

    try {
      final categories = await ApiService.getCategories();

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _categoriesLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _categories = ApiService.defaultCategories;
        _categoriesLoading = false;
        _categoriesError = true;
      });

      debugPrint('Categories loading error: $e');
    }
  }

  Future<void> _speakDailyPhrase(String text) async {
    if (_isSpeakingDailyPhrase) {
      await _ttsService.stop();

      if (mounted) {
        setState(() {
          _isSpeakingDailyPhrase = false;
        });
      }

      return;
    }

    if (!mounted) return;

    setState(() {
      _isSpeakingDailyPhrase = true;
    });

    try {
      await _ttsService.speak(text);
    } catch (e) {
      debugPrint(
        '⚠️ خطأ أثناء نطق العبارة اليومية: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSpeakingDailyPhrase = false;
        });
      }
    }
  }

  void _open(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  // ============================================================
  // فتح الكاميرا مباشرة
  // ============================================================

  Future<void> _openCameraDirectly() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (picked == null) return;

      if (!mounted) return;

      final file = File(picked.path);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.accentCyan,
            ),
          );
        },
      );

      try {
        final result = await AiImageService.analyzeImage(file);

        if (!mounted) return;

        Navigator.of(context).pop();

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ImageAnalysisResultScreen(
              imageFile: file,
              result: result,
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;

        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'تعذر تحليل الصورة، تأكد من الاتصال بالخادم وحاول مجدداً',
              textAlign: TextAlign.right,
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        debugPrint(
          '⚠️ خطأ تحليل صورة الكاميرا: $e',
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذر فتح الكاميرا',
            textAlign: TextAlign.right,
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );

      debugPrint(
        '⚠️ خطأ فتح الكاميرا: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        drawer: const SadaDrawer(
          activeIndex: 0,
        ),
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: AppColors.accentCyan,
            onRefresh: _loadCategories,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    100,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildGreeting(),
                        const SizedBox(height: 18),
                        _buildAiHero(),
                        const SizedBox(height: 28),
                        _buildSectionTitle(
                          'الوصول السريع',
                          'عرض الكل',
                          () {
                            _open(
                              const DictionaryScreen(),
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildCategories(),
                        const SizedBox(height: 28),
                        _buildAiMiniCard(),
                        const SizedBox(height: 28),
                        _buildSectionTitle(
                          'عبارة اليوم',
                        ),
                        const SizedBox(height: 14),
                        _buildPhraseOfTheDay(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const SadaBottomNav(
          currentIndex: 0,
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        Builder(
          builder: (context) {
            return _iconButton(
              Icons.menu_rounded,
              () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        const Spacer(),
        SizedBox(
          width: 38,
          height: 38,
          child: SvgPicture.asset(
            logoAsset,
            fit: BoxFit.contain,
            placeholderBuilder: (_) {
              return const Icon(
                Icons.graphic_eq_rounded,
                color: AppColors.accentCyan,
                size: 28,
              );
            },
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            _open(
              const ProfileScreen(),
            );
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accentCyan.withValues(
                  alpha: 0.35,
                ),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                avatarAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    color: AppColors.softPurple,
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.accentCyan,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _iconButton(
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Icon(
            icon,
            color: AppColors.textDark,
            size: 24,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // GREETING
  // ============================================================

  Widget _buildGreeting() {
    final user = ApiService.currentUser;

    final name = user != null ? '، ${user.fullName.split(' ').first}' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مرحباً بك$name 👋',
          style: const TextStyle(
            fontFamily: 'Baloo_Bhaijaan_2',
            fontSize: 16,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'كيف يمكن لصدى أن يساعدك اليوم؟',
          style: TextStyle(
            fontFamily: 'Baloo_Bhaijaan_2',
            fontSize: 24,
            height: 1.25,
            color: AppColors.textDark,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // AI HERO
  // ============================================================

  Widget _buildAiHero() {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 250,
      ),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF20CFCF),
            Color(0xFF3977BB),
            Color(0xFF6C3CEB),
          ],
          stops: [
            0.0,
            0.70,
            1.0,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentCyan.withValues(
              alpha: 0.25,
            ),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -45,
            left: -25,
            child: _glowCircle(
              140,
              Colors.white.withValues(
                alpha: 0.12,
              ),
            ),
          ),
          Positioned(
            bottom: -65,
            right: -25,
            child: _glowCircle(
              170,
              Colors.white.withValues(
                alpha: 0.08,
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: _buildWaveDecoration(),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.18,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: 0.3,
                          ),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentCyan.withValues(
                              alpha: 0.25,
                            ),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Lottie.asset(
                        robootAsset,
                        fit: BoxFit.contain,
                        repeat: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'صدى AI',
                      style: TextStyle(
                        fontFamily: 'Baloo_Bhaijaan_2',
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'تواصل بطريقتك',
                  style: TextStyle(
                    fontFamily: 'Baloo_Bhaijaan_2',
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'اكتب، تحدث أو شارك صورة وسأساعدك في التعبير عنها.',
                  style: TextStyle(
                    fontFamily: 'Baloo_Bhaijaan_2',
                    color: Colors.white.withValues(
                      alpha: 0.85,
                    ),
                    fontSize: 13.5,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _heroButton(
                        'ابدأ مع صدى',
                        Icons.arrow_back_rounded,
                        () {
                          _open(
                            const AiAssistantScreen(),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    _heroTool(
                      voiceIcon,
                      Icons.mic_rounded,
                      'صوت',
                      () {
                        _open(
                          const TtsScreen(),
                        );
                      },
                    ),
                    const SizedBox(width: 6),
                    _heroTool(
                      textIcon,
                      Icons.keyboard_alt_outlined,
                      'نص',
                      () {
                        _open(
                          const TtsScreen(),
                        );
                      },
                    ),
                    const SizedBox(width: 6),
                    _heroTool(
                      imageIcon,
                      Icons.image_outlined,
                      'صورة',
                      () {
                        _open(
                          const AiAssistantScreen(),
                        );
                      },
                    ),
                    const SizedBox(width: 6),

                    // الكاميرا تفتح مباشرة
                    _heroTool(
                      cameraIcon,
                      Icons.camera_alt_outlined,
                      'كاميرا',
                      _openCameraDirectly,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowCircle(
    double size,
    Color color,
  ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _buildWaveDecoration() {
    return SizedBox(
      width: 90,
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(
          9,
          (i) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 1.5,
                ),
                child: Container(
                  height: 8.0 + ((i * 13) % 26),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.15,
                    ),
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _heroButton(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return SizedBox(
      height: 46,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Baloo_Bhaijaan_2',
                  color: AppColors.accentCyan,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.accentCyan,
                size: 17,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroTool(
    String path,
    IconData fallback,
    String label,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.white.withValues(
        alpha: 0.14,
      ),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: SizedBox(
          width: 42,
          height: 46,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                path,
                width: 17,
                height: 17,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
                placeholderBuilder: (_) {
                  return Icon(
                    fallback,
                    color: Colors.white,
                    size: 17,
                  );
                },
                errorBuilder: (_, __, ___) {
                  return Icon(
                    fallback,
                    color: Colors.white,
                    size: 17,
                  );
                },
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Baloo_Bhaijaan_2',
                  color: Colors.white.withValues(
                    alpha: 0.9,
                  ),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
    String title, [
    String? action,
    VoidCallback? onAction,
  ]) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Baloo_Bhaijaan_2',
            fontSize: 18,
            color: AppColors.textDark,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Row(
              children: [
                Text(
                  action,
                  style: const TextStyle(
                    fontFamily: 'Baloo_Bhaijaan_2',
                    color: AppColors.accentCyan,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.accentCyan,
                  size: 16,
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ============================================================
  // CATEGORIES
  // ============================================================

  Widget _buildCategories() {
    if (_categoriesLoading) {
      return SizedBox(
        height: 110,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, __) {
            return Container(
              width: 104,
              decoration: BoxDecoration(
                color: AppColors.softPurple,
                borderRadius: BorderRadius.circular(20),
              ),
            );
          },
        ),
      );
    }

    if (_categories.isEmpty) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'لا توجد تصنيفات حالياً',
                style: TextStyle(
                  fontFamily: 'Baloo_Bhaijaan_2',
                  color: AppColors.textMuted,
                ),
              ),
              if (_categoriesError)
                TextButton(
                  onPressed: _loadCategories,
                  child: const Text(
                    'إعادة المحاولة',
                  ),
                ),
            ],
          ),
        ),
      );
    }

    final visible = _categories.take(8).toList();

    return SizedBox(
      height: 112,
      child: ListView.separated(
        reverse: true,
        scrollDirection: Axis.horizontal,
        itemCount: visible.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _buildCategoryItem(
            visible[index],
            index,
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(
    Category category,
    int index,
  ) {
    final style = _getCategoryStyle(index);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          _open(
            DictionaryScreen(
              category: category,
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 104,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: style.background,
                  borderRadius: BorderRadius.circular(
                    16,
                  ),
                ),
                child: Icon(
                  style.icon,
                  color: style.color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Baloo_Bhaijaan_2',
                  color: AppColors.textDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _CategoryStyle _getCategoryStyle(
    int index,
  ) {
    const styles = [
      _CategoryStyle(
        Icons.waving_hand_rounded,
        Color(0xFF6C3CEB),
        Color(0xFFF3EEFF),
      ),
      _CategoryStyle(
        Icons.people_alt_rounded,
        Color(0xFF2563EB),
        Color(0xFFEFF6FF),
      ),
      _CategoryStyle(
        Icons.favorite_rounded,
        Color(0xFFDB2777),
        Color(0xFFFDF2F8),
      ),
      _CategoryStyle(
        Icons.restaurant_rounded,
        Color(0xFFEA580C),
        Color(0xFFFFF7ED),
      ),
      _CategoryStyle(
        Icons.business_center_rounded,
        Color(0xFF0D9488),
        Color(0xFFF0FDFA),
      ),
      _CategoryStyle(
        Icons.medical_services_rounded,
        Color(0xFFE11D48),
        Color(0xFFFFF1F2),
      ),
    ];

    return styles[index % styles.length];
  }

  // ============================================================
  // AI MINI CARD
  // ============================================================

  Widget _buildAiMiniCard() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: () {
          _open(
            const ChatScreen(),
          );
        },
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    16,
                  ),
                  color: const Color(0xFFF9FAFA),
                ),
                child: Lottie.asset(
                  'assets/Ai Stars.json',
                  width: 52,
                  height: 52,
                  fit: BoxFit.contain,
                  repeat: true,
                  animate: true,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'مساعد صدى الذكي ✨',
                      style: TextStyle(
                        fontFamily: 'Baloo_Bhaijaan_2',
                        color: AppColors.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'لا تعرف كيف تعبّر؟ دع صدى يقترح لك.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Baloo_Bhaijaan_2',
                        color: AppColors.textMuted,
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8FBFA),
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.accentCyan,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PHRASE OF THE DAY
  // ============================================================

  Widget _buildPhraseOfTheDay() {
    const arabicText = 'شُكْرًا لَكَ';
    const englishText = 'Thank you';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.035,
            ),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8FBFA),
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.accentCyan,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'عبارة اليوم',
                  style: TextStyle(
                    fontFamily: 'Baloo_Bhaijaan_2',
                    color: AppColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F5F7),
                  borderRadius: BorderRadius.circular(
                    20,
                  ),
                ),
                child: const Text(
                  'اليوم',
                  style: TextStyle(
                    fontFamily: 'Baloo_Bhaijaan_2',
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFA),
              borderRadius: BorderRadius.circular(
                20,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      18,
                    ),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      18,
                    ),
                    child: Image.asset(
                      'assets/images/thanks.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        arabicText,
                        style: TextStyle(
                          fontFamily: 'Baloo_Bhaijaan_2',
                          color: AppColors.textDark,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        englishText,
                        style: TextStyle(
                          fontFamily: 'Baloo_Bhaijaan_2',
                          color: AppColors.textMuted.withValues(
                            alpha: 0.9,
                          ),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 32,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.accentCyan,
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: Material(
              color: AppColors.accentCyan,
              borderRadius: BorderRadius.circular(
                14,
              ),
              child: InkWell(
                onTap: () {
                  _speakDailyPhrase(
                    arabicText,
                  );
                },
                borderRadius: BorderRadius.circular(
                  14,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isSpeakingDailyPhrase
                          ? Icons.graphic_eq_rounded
                          : Icons.volume_up_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      _isSpeakingDailyPhrase
                          ? 'جاري النطق...'
                          : 'استمع إلى العبارة',
                      style: const TextStyle(
                        fontFamily: 'Baloo_Bhaijaan_2',
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryStyle {
  final IconData icon;
  final Color color;
  final Color background;

  const _CategoryStyle(
    this.icon,
    this.color,
    this.background,
  );
}
