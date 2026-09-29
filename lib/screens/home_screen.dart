import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:image_picker/image_picker.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../services/ai_image_service.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';
import 'tts_screen.dart';
import 'dictionary_screen.dart';
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
  final ImagePicker _imagePicker = ImagePicker();

  List<Category> _categories = ApiService.defaultCategories;
  List<Phrase> _phrases = ApiService.defaultPhrases;

  bool _isLoading = true;
  int? _speakingPhraseId;
  String _selectedFilter = 'الكل';

  static const String robootAsset = 'assets/robot.json';

  @override
  void initState() {
    super.initState();
    _ttsService.init();
    _loadData();
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final categoriesFuture = ApiService.getCategories();
      final phrasesFuture = ApiService.getPhrases();

      final results = await Future.wait([categoriesFuture, phrasesFuture]);

      if (!mounted) return;
      setState(() {
        final c = results[0] as List<Category>;
        final p = results[1] as List<Phrase>;
        if (c.isNotEmpty) _categories = c;
        if (p.isNotEmpty) _phrases = p;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      debugPrint('Data loading error: $e');
    }
  }

  Future<void> _speak(Phrase phrase) async {
    if (_speakingPhraseId == phrase.phraseId) {
      await _ttsService.stop();
      if (mounted) setState(() => _speakingPhraseId = null);
      return;
    }

    setState(() => _speakingPhraseId = phrase.phraseId);
    await _ttsService.speak(phrase.text);
    if (mounted) setState(() => _speakingPhraseId = null);
  }

  void _open(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Future<void> _openCameraDirectly() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 65,
        maxWidth: 900,
        maxHeight: 900,
      );
      if (picked == null || !mounted) return;

      final file = File(picked.path);
      _analyzeImage(file);
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  Future<void> _openGalleryDirectly() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 65,
        maxWidth: 900,
        maxHeight: 900,
      );
      if (picked == null || !mounted) return;

      final file = File(picked.path);
      _analyzeImage(file);
    } catch (e) {
      debugPrint('Gallery error: $e');
    }
  }

  Future<void> _analyzeImage(File file) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.accentCyan),
      ),
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
        const SnackBar(
          content: Text(
            'تعذر تحليل الصورة، يرجى المحاولة ثانية',
            textAlign: TextAlign.right,
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showSignImageDialog(Phrase phrase) {
    String? imageUrl = phrase.signImageUrl;

    if (imageUrl == null || imageUrl.isEmpty) {
      final t = phrase.text.toLowerCase();
      if (t.contains('سلام') || t.contains('مرحب') || t.contains('صباح')) {
        imageUrl = 'assets/images/hello.png';
      } else if (t.contains('شكر')) {
        imageUrl = 'assets/images/thanks.png';
      } else if (t.contains('نعم') || t.contains('أحتاج') || t.contains('ماء')) {
        imageUrl = 'assets/images/yes.png';
      } else if (t.contains('لا') || t.contains('استريح')) {
        imageUrl = 'assets/images/no.png';
      } else if (t.contains('عذر') || t.contains('ألم') || t.contains('طبيب') || t.contains('أبطأ')) {
        imageUrl = 'assets/images/sorry.png';
      } else {
        imageUrl = 'assets/images/robot.png';
      }
    }

    final isNetwork = imageUrl.startsWith('http://') || imageUrl.startsWith('https://');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      phrase.text,
                      style: const TextStyle(
                        fontFamily: 'Baloo_Bhaijaan_2',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded, color: AppColors.primaryBlue),
                    onPressed: () => _speak(phrase),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 240,
                decoration: BoxDecoration(
                  color: AppColors.softPurple,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: isNetwork
                      ? Image.network(
                          imageUrl!,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(color: AppColors.primaryBlue),
                            );
                          },
                          errorBuilder: (_, __, ___) => _buildFallbackSignView(),
                        )
                      : Image.asset(
                          imageUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => _buildFallbackSignView(),
                        ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.back_hand_rounded, color: AppColors.accentCyan, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'إشارة: ${phrase.categoryName ?? "عام"}',
                    style: const TextStyle(
                      fontFamily: 'Baloo_Bhaijaan_2',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text(
                    'تم وفهمت الإشارة',
                    style: TextStyle(
                      fontFamily: 'Baloo_Bhaijaan_2',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
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

  Widget _buildFallbackSignView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.back_hand_rounded, size: 64, color: AppColors.primaryBlue.withValues(alpha: 0.5)),
        const SizedBox(height: 10),
        const Text(
          'حركة الإشارة موضحة ومعتمدة',
          style: TextStyle(
            fontFamily: 'Baloo_Bhaijaan_2',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  void _showAddPhraseSheet() {
    final controller = TextEditingController();
    Category selectedCat = _categories.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setModalState) => Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'إضافة عبارة تواصل جديدة',
                    style: TextStyle(
                      fontFamily: 'Baloo_Bhaijaan_2',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: controller,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'اكتب نص العبارة...',
                      filled: true,
                      fillColor: AppColors.softPurple,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final text = controller.text.trim();
                      if (text.isEmpty) return;
                      Navigator.pop(sheetContext);

                      final messenger = ScaffoldMessenger.of(context);
                      final success = await ApiService.createPhrase(
                        text: text,
                        userId: ApiService.currentUser?.userId ?? 1,
                        categoryId: selectedCat.categoryId,
                      );

                      if (!mounted) return;
                      if (success) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'تمت إضافة العبارة بنجاح 🎉',
                              textAlign: TextAlign.right,
                            ),
                            backgroundColor: AppColors.primaryPurple,
                          ),
                        );
                        _loadData();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'حفظ العبارة',
                      style: TextStyle(
                        fontFamily: 'Baloo_Bhaijaan_2',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        endDrawer: const SadaDrawer(activeIndex: 0),
        body: Stack(
          children: [
            // خلفية سماوية هادئة وانسيابية تريح النظر
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 260,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFE8F1FC),
                      Color(0xFFF3F7FD),
                      AppColors.bg,
                    ],
                    stops: [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),

            SafeArea(
              bottom: false,
              child: RefreshIndicator(
                color: AppColors.primaryPurple,
                onRefresh: _loadData,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            // 1. الشريط العلوي الأنيق والهادئ
                            _buildTopAppBar(),

                            const SizedBox(height: 22),

                            // 2. بطاقة صدى AI الهيرو المريحة للنظر بأنيميشن الروبوت
                            _buildAiHeroBanner(),

                            const SizedBox(height: 26),

                            // 3. عنوان قسم التصنيفات
                            _buildCategoriesHeader(),

                            const SizedBox(height: 12),

                            // 4. بطاقة التصنيفات البيضاء النقية الواسعة (مطابقة للصورة الأولى بمساحات مريحة)
                            _buildCategoriesCard(),

                            const SizedBox(height: 28),

                            // 5. رأس قائمة العبارات والتواصل
                            _buildFeedHeader(),

                            const SizedBox(height: 14),

                            // 6. أزرار الفلاتر السريعة المريحة
                            _buildPillFilters(),

                            const SizedBox(height: 18),

                            // 7. قائمة عبارات التواصل المتصلة بالـ API
                            ..._buildFeedList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const SadaBottomNav(currentIndex: 0),
      ),
    );
  }

  // ============================================================
  // 1. TOP APP BAR (مستوحى من تصميم siren.uix)
  // ============================================================
  Widget _buildTopAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // الشعار واسم صدى
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.12),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SvgPicture.asset(
                'assets/logo.svg',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'صدى.',
              style: TextStyle(
                fontFamily: 'Baloo_Bhaijaan_2',
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),

        // أزرار البحث والإشعارات والقائمة الزجاجية
        Row(
          children: [
            // زر البحث الزجاجي
            _buildFrostedIconButton(
              icon: Icons.search_rounded,
              onTap: () => _open(const DictionaryScreen()),
            ),
            const SizedBox(width: 8),

            // زر الإشعارات مع النقطة الحمراء
            Stack(
              clipBehavior: Clip.none,
              children: [
                _buildFrostedIconButton(
                  icon: Icons.notifications_none_rounded,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('لديك 3 تنبيهات جديدة لمساعد صدى', textAlign: TextAlign.right),
                        backgroundColor: AppColors.primaryBlue,
                      ),
                    );
                  },
                ),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFA3E3E),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        fontFamily: 'Baloo_Bhaijaan_2',
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),

            // زر الدرج الجانبي
            Builder(
              builder: (ctx) => _buildFrostedIconButton(
                icon: Icons.menu_rounded,
                onTap: () => Scaffold.of(ctx).openEndDrawer(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFrostedIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.8),
              width: 1.2,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Icon(
                icon,
                color: AppColors.textDark,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 3. PILL ACTION FILTERS
  // ============================================================
  Widget _buildPillFilters() {
    final filters = [
      {'label': '+ إضافة', 'isAction': true},
      {'label': 'الكل', 'isAction': false},
      {'label': 'تحويل فوري', 'isAction': false},
      {'label': 'القاموس', 'isAction': false},
      {'label': 'محادثة ذكية', 'isAction': false},
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final f = filters[index];
          final isAction = f['isAction'] == true;
          final isSelected = _selectedFilter == f['label'];

          return Material(
            color: isAction
                ? AppColors.primaryBlue
                : isSelected
                    ? AppColors.primaryBlue.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                if (isAction) {
                  _showAddPhraseSheet();
                } else {
                  setState(() => _selectedFilter = f['label'] as String);
                  if (f['label'] == 'تحويل فوري') _open(const TtsScreen());
                  if (f['label'] == 'القاموس') _open(const DictionaryScreen());
                  if (f['label'] == 'محادثة ذكية') _open(const ChatScreen());
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isAction
                        ? AppColors.primaryBlue
                        : isSelected
                            ? AppColors.primaryBlue
                            : AppColors.border,
                  ),
                ),
                child: Center(
                  child: Text(
                    f['label'] as String,
                    style: TextStyle(
                      fontFamily: 'Baloo_Bhaijaan_2',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: isAction
                          ? Colors.white
                          : isSelected
                              ? AppColors.primaryBlue
                              : AppColors.textDark,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // 2. CATEGORIES GRID CARD (مطابقة للصورة الأولى بدقة تامة)
  // ============================================================
  Widget _buildCategoriesCard() {
    // نأخذ أول 7 تصنيفات قادمة من الـ API (أو الافتراضية) والعنصر الثامن هو "المزيد"
    final displayCategories = _categories.take(7).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // الصف الأول: 4 تصنيفات
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < 4; i++)
                Expanded(
                  child: i < displayCategories.length
                      ? _buildCategoryItem(displayCategories[i], i)
                      : const SizedBox(),
                ),
            ],
          ),
          const SizedBox(height: 18),
          // الصف الثاني: 3 تصنيفات + زر "المزيد" (Lainnya) مثل الصورة تماماً
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 4; i < 7; i++)
                Expanded(
                  child: i < displayCategories.length
                      ? _buildCategoryItem(displayCategories[i], i)
                      : const SizedBox(),
                ),
              // العنصر الثامن: المزيد
              Expanded(
                child: _buildMoreCategoryItem(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Category cat, int index) {
    return GestureDetector(
      onTap: () => _open(DictionaryScreen(category: cat)),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // الدائرة ذات الهالة السماوية الناعمة (مطابقة للصورة الأولى)
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFE8F3FE),
                  const Color(0xFFD6EAFC).withValues(alpha: 0.7),
                  const Color(0xFFCCE4FC).withValues(alpha: 0.35),
                ],
                radius: 0.85,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E88E5).withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: _buildCategoryIconWidget(cat.name, index),
            ),
          ),
          const SizedBox(height: 8),
          // عنوان التصنيف
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              cat.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Baloo_Bhaijaan_2',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreCategoryItem() {
    return GestureDetector(
      onTap: () => _open(const DictionaryScreen()),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // الدائرة الثلاثية النقاط (Lainnya من الصورة الأولى)
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFE8F3FE),
                  const Color(0xFFD6EAFC).withValues(alpha: 0.7),
                  const Color(0xFFCCE4FC).withValues(alpha: 0.35),
                ],
                radius: 0.85,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E88E5).withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 5.5,
                    height: 5.5,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 5.5,
                    height: 5.5,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 5.5,
                    height: 5.5,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              'المزيد',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Baloo_Bhaijaan_2',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIconWidget(String name, int index) {
    final t = name.toLowerCase();

    // 1. الروتين اليومي: بطاقة تقويم زرقاء مع ساعة وشمس دافئة
    if (t.contains('روتين') || t.contains('يومي') || t.contains('صباح') || t.contains('مساء')) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.schedule_rounded, color: Color(0xFF1976D2), size: 22),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wb_sunny_rounded, color: Color(0xFFFFA000), size: 12),
            ),
          ),
        ],
      );
    }

    // 2. العائلة والمنزل: منزل بنفسجي مع قلب دافئ
    if (t.contains('عائل') || t.contains('منزل') || t.contains('بيت') || t.contains('أسرة')) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF7C4DFF).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.cottage_rounded, color: Color(0xFF651FFF), size: 22),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_rounded, color: Color(0xFFFF5252), size: 12),
            ),
          ),
        ],
      );
    }

    // 3. التحيات والترحيب: يد تلوّح ذهبية مع نجوم الترحيب
    if (t.contains('تحي') || t.contains('ترحيب') || t.contains('سلام') || t.contains('مرحب')) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB300).withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.waving_hand_rounded, color: Color(0xFFFFA000), size: 21),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(1.5),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF00BCD4), size: 11),
            ),
          ),
        ],
      );
    }

    // 4. الصحة والعلاج: درع حماية وصليب طبي زمردي
    if (t.contains('صح') || t.contains('علاج') || t.contains('طبيب') || t.contains('دواء') || t.contains('مستشفى')) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF00E676).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.health_and_safety_rounded, color: Color(0xFF00C853), size: 23),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(1.5),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_circle_rounded, color: Color(0xFFD50000), size: 12),
            ),
          ),
        ],
      );
    }

    // 5. المجتمع والعمل: حقيبة عمل أنيقة كحلية مع شارة ذهبية
    if (t.contains('عمل') || t.contains('مجتمع') || t.contains('وظيفة') || t.contains('مكتب') || t.contains('شركة')) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.business_center_rounded, color: Color(0xFF1565C0), size: 22),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(1.5),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.stars_rounded, color: Color(0xFFFFB300), size: 12),
            ),
          ),
        ],
      );
    }

    // 6. المطعم والتسوق: أطباق طعام ومشتريات برتقالية زاهية
    if (t.contains('مطعم') || t.contains('تسوق') || t.contains('طعام') || t.contains('أكل') || t.contains('شراء')) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6D00).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.restaurant_rounded, color: Color(0xFFFF6D00), size: 22),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(1.5),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_bag_rounded, color: Color(0xFF29B6F6), size: 12),
            ),
          ),
        ],
      );
    }

    // 7. الطوارئ والمساعدة: جرس إنذار وصاعقة حمراء
    if (t.contains('طوارئ') || t.contains('مساعد') || t.contains('نجدة') || t.contains('خطر')) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFF1744).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.crisis_alert_rounded, color: Color(0xFFD50000), size: 22),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(1.5),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.flash_on_rounded, color: Color(0xFFFFD600), size: 12),
            ),
          ),
        ],
      );
    }

    // افتراضي لأي تصنيف إضافي من الـ API
    final colors = [
      const Color(0xFF1E88E5),
      const Color(0xFF8E24AA),
      const Color(0xFF00897B),
      const Color(0xFFE65100),
      const Color(0xFF3949AB),
    ];
    final color = colors[index % colors.length];

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.category_rounded, color: color, size: 22),
    );
  }

  // ============================================================
  // 3. CATEGORIES SECTION HEADER
  // ============================================================
  Widget _buildCategoriesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'التصنيفات والخدمات',
          style: TextStyle(
            fontFamily: 'Baloo_Bhaijaan_2',
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        GestureDetector(
          onTap: () => _open(const DictionaryScreen()),
          child: const Text(
            'عرض الكل',
            style: TextStyle(
              fontFamily: 'Baloo_Bhaijaan_2',
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryPurple,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 5. AI HERO BANNER
  // ============================================================
  Widget _buildAiHeroBanner() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: AppColors.heroGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // الأنيميشن المتحرك لخلفية المربع الأول
          Positioned.fill(
            child: Opacity(
              opacity: 0.40,
              child: Lottie.asset(
                'assets/Background gradient.json',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                Container(
                  width: 56,
                  height: 56,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                  child: Lottie.asset(robootAsset, fit: BoxFit.contain),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مساعد صدى الذكي ✨',
                        style: TextStyle(
                          fontFamily: 'Baloo_Bhaijaan_2',
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'تحدث أو التقط صورة لنطقها وترجمتها فوراً',
                        style: TextStyle(
                          fontFamily: 'Baloo_Bhaijaan_2',
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildHeroBtn(
                    label: 'كاميرا',
                    icon: Icons.camera_alt_outlined,
                    onTap: _openCameraDirectly,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildHeroBtn(
                    label: 'صورة',
                    icon: Icons.image_outlined,
                    onTap: _openGalleryDirectly,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildHeroBtn(
                    label: 'نص',
                    icon: Icons.edit_note_rounded,
                    onTap: () => _open(const TtsScreen()),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildHeroBtn(
                    label: 'صوت',
                    icon: Icons.mic_rounded,
                    onTap: () => _open(const TtsScreen()),
                  ),
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

  Widget _buildHeroBtn({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Baloo_Bhaijaan_2',
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 6. ALL FEEDS HEADER
  // ============================================================
  Widget _buildFeedHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'آخر العبارات والتواصل (Feeds)',
          style: TextStyle(
            fontFamily: 'Baloo_Bhaijaan_2',
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        GestureDetector(
          onTap: () => _open(const DictionaryScreen()),
          child: const Text(
            'عرض الكل',
            style: TextStyle(
              fontFamily: 'Baloo_Bhaijaan_2',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 7. FEED LIST ITEMS
  // ============================================================
  List<Widget> _buildFeedList() {
    if (_isLoading) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(30),
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          ),
        )
      ];
    }

    return _phrases.map((phrase) {
      final isSpeaking = _speakingPhraseId == phrase.phraseId;

      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSpeaking ? AppColors.accentCyan : AppColors.border,
            width: isSpeaking ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSpeaking
                  ? AppColors.primaryBlue.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رأس المنشور (Author Header)
            Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.softPurple,
                  child: Icon(
                    Icons.face_rounded,
                    color: AppColors.primaryBlue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text(
                            'صدى AI',
                            style: TextStyle(
                              fontFamily: 'Baloo_Bhaijaan_2',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.verified_rounded,
                            color: AppColors.primaryBlue,
                            size: 14,
                          ),
                        ],
                      ),
                      Text(
                        phrase.categoryName ?? 'عبارات عامة',
                        style: const TextStyle(
                          fontFamily: 'Baloo_Bhaijaan_2',
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                // زر النطق الصوتي الفوري
                ElevatedButton.icon(
                  onPressed: () => _speak(phrase),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSpeaking
                        ? AppColors.accentCyan
                        : AppColors.softPurple,
                    foregroundColor: isSpeaking
                        ? Colors.white
                        : AppColors.primaryBlue,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(
                    isSpeaking
                        ? Icons.graphic_eq_rounded
                        : Icons.volume_up_rounded,
                    size: 16,
                  ),
                  label: Text(
                    isSpeaking ? 'ينطق...' : 'استماع',
                    style: const TextStyle(
                      fontFamily: 'Baloo_Bhaijaan_2',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // نص العبارة الأساسي
            Text(
              phrase.text,
              style: const TextStyle(
                fontFamily: 'Baloo_Bhaijaan_2',
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
                height: 1.35,
              ),
            ),

            const SizedBox(height: 12),

            // تذييل الإجراءات (الإشارة ومشاركة العبارة)
            Row(
              children: [
                InkWell(
                  onTap: () => _showSignImageDialog(phrase),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.softPurple,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.6)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.back_hand_rounded,
                          color: AppColors.primaryBlue,
                          size: 14,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'عرض الإشارة 🤟',
                          style: TextStyle(
                            fontFamily: 'Baloo_Bhaijaan_2',
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.favorite_border_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(
                    Icons.share_outlined,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }
}
