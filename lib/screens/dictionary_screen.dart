import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/sada_bottom_nav.dart';
import '../widgets/sada_states.dart';

class DictionaryScreen extends StatefulWidget {
  final Category? category;
  final bool embedded;

  const DictionaryScreen({
    super.key,
    this.category,
    this.embedded = false,
  });

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TtsService _tts = TtsService();
  final TextEditingController _searchCtrl = TextEditingController();

  List<Category> _categories = ApiService.defaultCategories;
  List<Phrase> _phrases = ApiService.defaultPhrases;
  List<Phrase> _filtered = ApiService.defaultPhrases;

  Category? _selectedCategory;

  bool _isLoading = true;
  bool _hasError = false;

  final Set<int> _favorites = {};
  int? _speakingPhraseId;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.category;
    _tts.init();
    _loadData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tts.stop();
    super.dispose();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final categoriesFuture = ApiService.getCategories();
      final phrasesFuture = ApiService.getPhrases();

      final results = await Future.wait([
        categoriesFuture,
        phrasesFuture,
      ]);

      if (!mounted) return;

      final categories = results[0] as List<Category>;
      final phrases = results[1] as List<Phrase>;

      setState(() {
        if (categories.isNotEmpty) {
          _categories = categories;
        }

        if (phrases.isNotEmpty) {
          _phrases = phrases;
        }

        _isLoading = false;
      });

      if (!mounted) return;
      _applyFilter();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  // ============================================================
  // FILTER
  // ============================================================

  void _applyFilter() {
    if (!mounted) return;

    final query = _searchCtrl.text.trim().toLowerCase();

    final filtered = _phrases.where((p) {
      final matchesCategory = _selectedCategory == null ||
          p.categoryId == _selectedCategory!.categoryId;

      final matchesQuery = query.isEmpty ||
          p.text.toLowerCase().contains(query) ||
          (p.categoryName?.toLowerCase().contains(query) ?? false);

      return matchesCategory && matchesQuery;
    }).toList();

    setState(() {
      _filtered = filtered;
    });
  }

  // ============================================================
  // TEXT TO SPEECH
  // ============================================================

  Future<void> _speakPhrase(Phrase phrase) async {
    if (_speakingPhraseId == phrase.phraseId) {
      await _tts.stop();
      if (!mounted) return;
      setState(() {
        _speakingPhraseId = null;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _speakingPhraseId = phrase.phraseId;
    });

    try {
      await _tts.speak(phrase.text);
    } catch (e) {
      debugPrint('⚠️ خطأ أثناء نطق العبارة: $e');
    } finally {
      if (mounted) {
        setState(() {
          _speakingPhraseId = null;
        });
      }
    }
  }

  // ============================================================
  // SIGN IMAGE MODAL DIALOG
  // ============================================================

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
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.softPurple,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.sign_language_rounded,
                      color: AppColors.primaryPurple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          phrase.text,
                          style: const TextStyle(
                            fontFamily: 'Baloo_Bhaijaan_2',
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          phrase.categoryName ?? 'عام',
                          style: const TextStyle(
                            fontFamily: 'Baloo_Bhaijaan_2',
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => _speakPhrase(phrase),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.softPurple,
                      foregroundColor: AppColors.primaryPurple,
                    ),
                    icon: const Icon(Icons.volume_up_rounded, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.softPurple.withValues(alpha: 0.6),
                      Colors.white,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: isNetwork
                      ? Image.network(
                          imageUrl!,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(color: AppColors.primaryPurple),
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
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.primaryPurple, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'الحركة معتمدة وفق القاموس الإشاري الموحد',
                      style: TextStyle(
                        fontFamily: 'Baloo_Bhaijaan_2',
                        fontSize: 13,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 20),
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
        Icon(Icons.back_hand_rounded, size: 64, color: AppColors.primaryPurple.withValues(alpha: 0.4)),
        const SizedBox(height: 12),
        const Text(
          'حركة الإشارة معتمدة وموضحة',
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

  // ============================================================
  // ADD PHRASE
  // ============================================================

  Future<void> _showAddPhraseDialog() async {
    if (_categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'لا توجد فئات متاحة لإضافة العبارة',
            textAlign: TextAlign.right,
          ),
        ),
      );
      return;
    }

    final textController = TextEditingController();

    Category selectedCat = _categories.firstWhere(
      (c) => c.categoryId == _selectedCategory?.categoryId,
      orElse: () => _categories.first,
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(modalContext).viewInsets.bottom,
                  ),
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Container(
                      padding: const EdgeInsets.all(26),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
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
                            'إضافة عبارة جديدة للقاموس',
                            style: TextStyle(
                              fontFamily: 'Baloo_Bhaijaan_2',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'أدخل نص العبارة وحدد التصنيف المناسب لها',
                            style: TextStyle(
                              fontFamily: 'Baloo_Bhaijaan_2',
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 18),
                          TextField(
                            controller: textController,
                            textAlign: TextAlign.right,
                            enabled: !isSaving,
                            maxLines: 3,
                            minLines: 2,
                            style: const TextStyle(
                              fontFamily: 'Baloo_Bhaijaan_2',
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                              hintText: 'اكتب نص العبارة هنا...',
                              hintStyle: const TextStyle(
                                fontFamily: 'Baloo_Bhaijaan_2',
                                color: AppColors.textMuted,
                              ),
                              filled: true,
                              fillColor: AppColors.bg,
                              contentPadding: const EdgeInsets.all(16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(color: AppColors.primaryPurple, width: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'التصنيف:',
                            style: TextStyle(
                              fontFamily: 'Baloo_Bhaijaan_2',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.bg,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<Category>(
                                value: selectedCat,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryPurple),
                                items: _categories.map((c) {
                                  return DropdownMenuItem<Category>(
                                    value: c,
                                    child: Text(
                                      c.name,
                                      style: const TextStyle(
                                        fontFamily: 'Baloo_Bhaijaan_2',
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: isSaving
                                    ? null
                                    : (cat) {
                                        if (cat == null) return;
                                        setModalState(() {
                                          selectedCat = cat;
                                        });
                                      },
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: isSaving
                                  ? null
                                  : () async {
                                      final text = textController.text.trim();
                                      if (text.isEmpty) {
                                        ScaffoldMessenger.of(modalContext).showSnackBar(
                                          const SnackBar(
                                            content: Text('اكتب نص العبارة أولاً', textAlign: TextAlign.right),
                                          ),
                                        );
                                        return;
                                      }

                                      FocusScope.of(modalContext).unfocus();
                                      setModalState(() {
                                        isSaving = true;
                                      });

                                      final success = await ApiService.createPhrase(
                                        text: text,
                                        userId: ApiService.currentUser?.userId ?? 1,
                                        categoryId: selectedCat.categoryId,
                                      );

                                      if (!modalContext.mounted) return;

                                      if (success) {
                                        Navigator.of(modalContext).pop(true);
                                      } else {
                                        setModalState(() {
                                          isSaving = false;
                                        });
                                        ScaffoldMessenger.of(modalContext).showSnackBar(
                                          const SnackBar(
                                            content: Text('تعذر إضافة العبارة، حاول مجدداً', textAlign: TextAlign.right),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryPurple,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: isSaving
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                    )
                                  : const Text(
                                      'حفظ العبارة في القاموس',
                                      style: TextStyle(
                                        fontFamily: 'Baloo_Bhaijaan_2',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((result) async {
      if (result == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'تمت إضافة العبارة بنجاح 🎉',
              textAlign: TextAlign.right,
            ),
            backgroundColor: AppColors.primaryPurple,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        await _loadData();
      }
    });

    textController.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final content = Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          _buildSearchAndFilters(),
          _buildCountInfoBar(),
          Expanded(
            child: _isLoading
                ? const SadaLoadingView(
                    message: 'جاري تحميل القاموس الإشاري...',
                  )
                : _hasError
                    ? SadaErrorView(
                        message: 'تعذر تحميل بيانات القاموس، يرجى المحاولة ثانية',
                        onRetry: _loadData,
                      )
                    : RefreshIndicator(
                        color: AppColors.primaryPurple,
                        onRefresh: _loadData,
                        child: _filtered.isEmpty
                            ? const SadaEmptyView(
                                title: 'لا توجد عبارات مطابقة',
                                subtitle: 'جرب البحث بكلمات أخرى أو اختر فئة مختلفة',
                                icon: Icons.search_off_rounded,
                              )
                            : ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                                itemCount: _filtered.length,
                                itemBuilder: (_, i) {
                                  return _buildPhraseCard(_filtered[i]);
                                },
                              ),
                      ),
          ),
        ],
      ),
    );

    if (widget.embedded) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(child: content),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      drawer: const SadaDrawer(activeIndex: 1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'القاموس الإشاري',
          style: TextStyle(
            fontFamily: 'Baloo_Bhaijaan_2',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (drawerContext) {
            return IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppColors.textDark),
              onPressed: () => Scaffold.of(drawerContext).openDrawer(),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.refresh_rounded, color: AppColors.primaryPurple, size: 20),
            ),
            tooltip: 'تحديث',
            onPressed: _loadData,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(child: content),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPhraseDialog,
        backgroundColor: AppColors.primaryPurple,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'إضافة عبارة',
          style: TextStyle(
            fontFamily: 'Baloo_Bhaijaan_2',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ),
      bottomNavigationBar: const SadaBottomNav(currentIndex: 1),
    );
  }

  // ============================================================
  // SEARCH + FILTERS
  // ============================================================

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchCtrl,
              textAlign: TextAlign.right,
              onChanged: (_) => _applyFilter(),
              style: const TextStyle(
                fontFamily: 'Baloo_Bhaijaan_2',
                fontSize: 14.5,
              ),
              decoration: InputDecoration(
                hintText: 'ابحث عن كلمة أو عبارة إشارية...',
                hintStyle: const TextStyle(
                  fontFamily: 'Baloo_Bhaijaan_2',
                  color: AppColors.textMuted,
                  fontSize: 13.5,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.primaryPurple,
                  size: 22,
                ),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchCtrl.clear();
                          _applyFilter();
                        },
                        icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildCategoryChip('الكل', null),
              ..._categories.map((c) => _buildCategoryChip(c.name, c)),
            ],
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _buildCountInfoBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'النتائج: ${_filtered.length} عبارة',
            style: const TextStyle(
              fontFamily: 'Baloo_Bhaijaan_2',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
            ),
          ),
          if (_selectedCategory != null)
            InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = null;
                });
                _applyFilter();
              },
              borderRadius: BorderRadius.circular(12),
              child: const Row(
                children: [
                  Icon(Icons.close_rounded, size: 14, color: AppColors.primaryPurple),
                  SizedBox(width: 4),
                  Text(
                    'مسح التصفية',
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
    );
  }

  // ============================================================
  // CATEGORY CHIP
  // ============================================================

  Widget _buildCategoryChip(String text, Category? c) {
    final active = c == null
        ? _selectedCategory == null
        : _selectedCategory?.categoryId == c.categoryId;

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCategory = c;
          });
          _applyFilter();
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.primaryPurple : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active ? AppColors.primaryPurple : AppColors.border,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.primaryPurple.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Baloo_Bhaijaan_2',
              color: active ? Colors.white : AppColors.textDark,
              fontWeight: active ? FontWeight.bold : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PHRASE CARD
  // ============================================================

  Widget _buildPhraseCard(Phrase phrase) {
    final isSpeaking = _speakingPhraseId == phrase.phraseId;
    final isFav = _favorites.contains(phrase.phraseId);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
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
                ? AppColors.primaryPurple.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header of card: Category Tag + Favorite
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.softPurple,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  phrase.categoryName ?? 'عام',
                  style: const TextStyle(
                    fontFamily: 'Baloo_Bhaijaan_2',
                    color: AppColors.primaryPurple,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() {
                    if (isFav) {
                      _favorites.remove(phrase.phraseId);
                    } else {
                      _favorites.add(phrase.phraseId);
                    }
                  });
                },
                icon: Icon(
                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFav ? Colors.redAccent : AppColors.textMuted.withValues(alpha: 0.6),
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Phrase text
          Text(
            phrase.text,
            style: const TextStyle(
              fontFamily: 'Baloo_Bhaijaan_2',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),
          // Action Buttons: Speak + Sign Preview
          Row(
            children: [
              // Listen / Speak
              InkWell(
                onTap: () => _speakPhrase(phrase),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSpeaking ? AppColors.aiGradient : null,
                    color: isSpeaking ? null : AppColors.softPurple,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSpeaking ? Icons.graphic_eq_rounded : Icons.volume_up_rounded,
                        color: isSpeaking ? Colors.white : AppColors.primaryPurple,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isSpeaking ? 'جاري النطق...' : 'استمع',
                        style: TextStyle(
                          fontFamily: 'Baloo_Bhaijaan_2',
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: isSpeaking ? Colors.white : AppColors.primaryPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Sign language preview
              InkWell(
                onTap: () => _showSignImageDialog(phrase),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.accentCyan.withValues(alpha: 0.6),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sign_language_rounded,
                        color: AppColors.accentCyan,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'عرض الإشارة 🤟',
                        style: TextStyle(
                          fontFamily: 'Baloo_Bhaijaan_2',
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
