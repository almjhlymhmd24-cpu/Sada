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
  // ADD PHRASE
  // ============================================================

  void _showAddPhraseDialog() {
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

    Category selectedCat = _selectedCategory ?? _categories.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(modalContext).viewInsets.bottom,
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Handle
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

                      // Title
                      const Text(
                        'إضافة عبارة جديدة',
                        style: TextStyle(
                          fontFamily: 'Baloo_Bhaijaan_2',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Text
                      TextField(
                        controller: textController,
                        textAlign: TextAlign.right,
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
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Category title
                      const Text(
                        'اختر الفئة:',
                        style: TextStyle(
                          fontFamily: 'Baloo_Bhaijaan_2',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Category dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.border,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Category>(
                            value: selectedCat,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                            ),
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
                            onChanged: (cat) {
                              if (cat == null) return;

                              setModalState(() {
                                selectedCat = cat;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Save button
                      ElevatedButton(
                        onPressed: () async {
                          final text = textController.text.trim();

                          if (text.isEmpty) {
                            return;
                          }

                          // Close the sheet first.
                          Navigator.of(sheetContext).pop();

                          // Make sure State is still alive.
                          if (!mounted) return;

                          setState(() {
                            _isLoading = true;
                          });

                          final success = await ApiService.createPhrase(
                            text: text,
                            userId: ApiService.currentUser?.userId ?? 1,
                            categoryId: selectedCat.categoryId,
                          );

                          // IMPORTANT:
                          // The State may have been disposed
                          // while waiting for the API.
                          if (!mounted) return;

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'تمت إضافة العبارة بنجاح 🎉',
                                  textAlign: TextAlign.right,
                                ),
                                backgroundColor: AppColors.primaryPurple,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );

                            // Reload data.
                            await _loadData();
                          } else {
                            if (!mounted) return;

                            setState(() {
                              _isLoading = false;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'تعذر إضافة العبارة، حاول مجدداً',
                                  textAlign: TextAlign.right,
                                ),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'حفظ العبارة',
                          style: TextStyle(
                            fontFamily: 'Baloo_Bhaijaan_2',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      textController.dispose();
    });
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
          Expanded(
            child: _isLoading
                ? const SadaLoadingView(
                    message: 'جاري تحميل القاموس الإشاري...',
                  )
                : _hasError
                    ? SadaErrorView(
                        message:
                            'تعذر تحميل بيانات القاموس، يرجى المحاولة ثانية',
                        onRetry: _loadData,
                      )
                    : RefreshIndicator(
                        color: AppColors.primaryPurple,
                        onRefresh: _loadData,
                        child: _filtered.isEmpty
                            ? const SadaEmptyView(
                                title: 'لا توجد عبارات مطابقة',
                                subtitle:
                                    'جرب البحث بكلمات أخرى أو اختر فئة مختلفة',
                                icon: Icons.search_off_rounded,
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  18,
                                  8,
                                  18,
                                  100,
                                ),
                                itemCount: _filtered.length,
                                itemBuilder: (_, i) {
                                  return _buildPhraseCard(
                                    _filtered[i],
                                  );
                                },
                              ),
                      ),
          ),
        ],
      ),
    );

    // Embedded version
    if (widget.embedded) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: content,
        ),
      );
    }

    // Full page version
    return Scaffold(
      backgroundColor: AppColors.bg,
      drawer: const SadaDrawer(
        activeIndex: 1,
      ),
      appBar: AppBar(
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
              icon: const Icon(
                Icons.menu_rounded,
                color: AppColors.textDark,
              ),
              onPressed: () {
                Scaffold.of(drawerContext).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.primaryPurple,
            ),
            tooltip: 'تحديث',
            onPressed: _loadData,
          ),
        ],
      ),
      body: SafeArea(
        child: content,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPhraseDialog,
        backgroundColor: AppColors.primaryPurple,
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      bottomNavigationBar: const SadaBottomNav(
        currentIndex: 1,
      ),
    );
  }

  // ============================================================
  // SEARCH + FILTERS
  // ============================================================

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            18,
            8,
            18,
            10,
          ),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.02,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: _searchCtrl,
              textAlign: TextAlign.right,
              onChanged: (_) {
                _applyFilter();
              },
              style: const TextStyle(
                fontFamily: 'Baloo_Bhaijaan_2',
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'ابحث عن كلمة أو عبارة...',
                hintStyle: const TextStyle(
                  fontFamily: 'Baloo_Bhaijaan_2',
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.primaryPurple,
                ),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchCtrl.clear();
                          _applyFilter();
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 14,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
            ),
            children: [
              _buildCategoryChip(
                'الكل',
                null,
              ),
              ..._categories.map(
                (c) => _buildCategoryChip(
                  c.name,
                  c,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  // ============================================================
  // CATEGORY CHIP
  // ============================================================

  Widget _buildCategoryChip(
    String text,
    Category? c,
  ) {
    final active = c == null
        ? _selectedCategory == null
        : _selectedCategory?.categoryId == c.categoryId;

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Text(text),
        selected: active,
        onSelected: (_) {
          setState(() {
            _selectedCategory = c;
          });

          _applyFilter();
        },
        selectedColor: AppColors.primaryPurple,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          fontFamily: 'Baloo_Bhaijaan_2',
          color: active ? Colors.white : AppColors.textDark,
          fontWeight: active ? FontWeight.bold : FontWeight.w600,
          fontSize: 12.5,
        ),
        side: BorderSide(
          color: active ? AppColors.primaryPurple : AppColors.border,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        showCheckmark: false,
      ),
    );
  }

  // ============================================================
  // PHRASE CARD
  // ============================================================

  Widget _buildPhraseCard(
    Phrase phrase,
  ) {
    final isSpeaking = _speakingPhraseId == phrase.phraseId;

    final isFav = _favorites.contains(
      phrase.phraseId,
    );

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
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
                ? AppColors.primaryPurple.withValues(
                    alpha: 0.12,
                  )
                : Colors.black.withValues(
                    alpha: 0.02,
                  ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ====================================================
          // CONTROL BUTTONS
          // ====================================================

          Column(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    if (isFav) {
                      _favorites.remove(
                        phrase.phraseId,
                      );
                    } else {
                      _favorites.add(
                        phrase.phraseId,
                      );
                    }
                  });
                },
                icon: Icon(
                  isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFav ? Colors.redAccent : AppColors.textMuted,
                  size: 22,
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isSpeaking
                      ? AppColors.aiGradient
                      : AppColors.brandGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withValues(
                        alpha: 0.25,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => _speakPhrase(
                    phrase,
                  ),
                  icon: Icon(
                    isSpeaking
                        ? Icons.graphic_eq_rounded
                        : Icons.volume_up_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 14),

          // ====================================================
          // PHRASE DETAILS
          // ====================================================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phrase.text,
                  style: const TextStyle(
                    fontFamily: 'Baloo_Bhaijaan_2',
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.softPurple,
                    borderRadius: BorderRadius.circular(
                      8,
                    ),
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                        border: Border.all(
                          color: AppColors.border,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.back_hand_rounded,
                            color: AppColors.primaryPurple,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'الإشارة متاحة',
                            style: TextStyle(
                              fontFamily: 'Baloo_Bhaijaan_2',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
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
}
