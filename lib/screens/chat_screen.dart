import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../services/ai_image_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/sada_bottom_nav.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TtsService _tts = TtsService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isTyping = false;
  int? _speakingIndex;

  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          'السلام عليكم ورحمة الله، أنا صدى مساعدك الذكي للتواصل. كيف يمكنني دعمك اليوم؟',
      isUser: false,
      time: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ChatMessage(
      text: 'أهلاً صدى، أريد عبارات مناسبة لطلب المساعدة في متجر أو مطعم.',
      isUser: true,
      time: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
    ChatMessage(
      text: 'إليك بعض العبارات المفيدة:\n'
          '• "لو سمحت، أريد الاستفسار عن هذا المنتج"\n'
          '• "هل يمكنني الحصول على قائمة الطعام من فضلك؟"\n'
          '• "كم يبلغ سعر هذا؟"',
      isUser: false,
      time: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
  ];

  final List<String> _quickSuggestions = [
    'اقترح لي رداً مناسباً',
    'ترجم هذه الجملة إلى الإشارة',
    'صغ لي رسالة اعتذار لطيفة',
    'عبارات للتعامل مع الطبيب',
  ];

  @override
  void initState() {
    super.initState();
    _tts.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _tts.stop();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // ============================================================
  // إرسال الرسالة إلى API / Gemini
  // ============================================================

  Future<void> _sendMessage([String? textToSend]) async {
    if (_isTyping) return;

    final text = (textToSend ?? _controller.text).trim();

    if (text.isEmpty) return;

    if (!mounted) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
        ),
      );

      _controller.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      debugPrint('========== CHAT REQUEST ==========');
      debugPrint('Message: $text');

      final reply = await ApiService.sendChatMessage(text);

      if (!mounted) return;

      setState(() {
        _messages.add(
          ChatMessage(
            text: reply,
            isUser: false,
          ),
        );

        _isTyping = false;
      });

      _scrollToBottom();

      debugPrint('========== CHAT SUCCESS ==========');
    } catch (e) {
      debugPrint('❌ Chat error: $e');

      if (!mounted) return;

      setState(() {
        _messages.add(
          ChatMessage(
            text: 'عذراً، لم أتمكن من الحصول على رد الآن.\n\n'
                'تأكدي من أن Sada API يعمل وأن الجهاز متصل بالخادم.',
            isUser: false,
          ),
        );

        _isTyping = false;
      });

      _scrollToBottom();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _getChatErrorMessage(e),
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Baloo_Bhaijaan_2',
            ),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  String _getChatErrorMessage(Object error) {
    final message = error.toString();

    if (message.contains('استغرق الذكاء الاصطناعي')) {
      return 'الذكاء الاصطناعي استغرق وقتاً طويلاً للرد.';
    }

    if (message.contains('تعذر الاتصال بالخادم')) {
      return 'تعذر الاتصال بخادم Sada API.';
    }

    if (message.contains('HTTP 502')) {
      return 'تعذر الاتصال بخدمة الذكاء الاصطناعي.';
    }

    if (message.contains('HTTP 500')) {
      return 'حدث خطأ داخل الخادم أثناء معالجة الرسالة.';
    }

    return 'حدث خطأ أثناء إرسال الرسالة.';
  }

  // ============================================================
  // TTS
  // ============================================================

  Future<void> _speakMessage(
    int index,
    String text,
  ) async {
    if (_speakingIndex == index) {
      await _tts.stop();

      if (mounted) {
        setState(() {
          _speakingIndex = null;
        });
      }

      return;
    }

    if (!mounted) return;

    setState(() {
      _speakingIndex = index;
    });

    try {
      await _tts.speak(text);
    } catch (e) {
      debugPrint('⚠️ خطأ أثناء نطق الرسالة: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذر نطق الرسالة.',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Baloo_Bhaijaan_2',
            ),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      _speakingIndex = null;
    });
  }

  // ============================================================
  // تحليل الصورة
  // ============================================================

  Future<void> _pickImageForChat() async {
    if (_isTyping) return;

    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (picked == null) return;

      if (!mounted) return;

      final file = File(picked.path);

      setState(() {
        _messages.add(
          ChatMessage(
            text: '📷 تم إرسال صورة للتحليل...',
            isUser: true,
          ),
        );

        _isTyping = true;
      });

      _scrollToBottom();

      final result = await AiImageService.analyzeImage(file);

      if (!mounted) return;

      setState(() {
        _messages.add(
          ChatMessage(
            text: '🤖 نتيجة تحليل الصورة:\n$result',
            isUser: false,
          ),
        );

        _isTyping = false;
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint('❌ Image analysis error: $e');

      if (!mounted) return;

      setState(() {
        _isTyping = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذر تحليل الصورة، يرجى المحاولة مرة ثانية.',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Baloo_Bhaijaan_2',
            ),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // مسح المحادثة
  // ============================================================

  void _clearChat() {
    if (_isTyping) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'مسح المحادثة',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'Baloo_Bhaijaan_2',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'هل ترغب في مسح جميع رسائل المحادثة الحالية؟',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'Baloo_Bhaijaan_2',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: 'Baloo_Bhaijaan_2',
                color: AppColors.textMuted,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);

              if (!mounted) return;

              setState(() {
                _messages.clear();

                _messages.add(
                  ChatMessage(
                    text:
                        'مرحباً بك مجدداً، كيف يمكنني مساعدتك في التواصل اليوم؟',
                    isUser: false,
                  ),
                );
              });

              _scrollToBottom();
            },
            child: const Text(
              'مسح',
              style: TextStyle(
                fontFamily: 'Baloo_Bhaijaan_2',
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        drawer: const SadaDrawer(
          activeIndex: 3,
        ),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(
                  Icons.menu_rounded,
                  color: AppColors.textDark,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.aiGradient,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'مساعد صدى الذكي',
                style: TextStyle(
                  fontFamily: 'Baloo_Bhaijaan_2',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.textMuted,
              ),
              tooltip: 'مسح المحادثة',
              onPressed: _clearChat,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    10,
                    16,
                    16,
                  ),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isTyping) {
                      return _buildTypingIndicator();
                    }

                    final msg = _messages[index];

                    return _buildMessageBubble(
                      msg,
                      index,
                    );
                  },
                ),
              ),
              _buildSuggestionsBar(),
              _buildComposer(),
            ],
          ),
        ),
        bottomNavigationBar: const SadaBottomNav(
          currentIndex: 3,
        ),
      ),
    );
  }

  // ============================================================
  // Message Bubble
  // ============================================================

  Widget _buildMessageBubble(
    ChatMessage msg,
    int index,
  ) {
    final isSpeaking = _speakingIndex == index;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        mainAxisAlignment:
            msg.isUser ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isUser)
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(
                left: 8,
              ),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.aiGradient,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 480,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                gradient: msg.isUser ? AppColors.brandGradient : null,
                color: msg.isUser ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(
                    msg.isUser ? 20 : 4,
                  ),
                  bottomRight: Radius.circular(
                    msg.isUser ? 4 : 20,
                  ),
                ),
                border: msg.isUser
                    ? null
                    : Border.all(
                        color: AppColors.border,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: msg.isUser
                        ? AppColors.primaryPurple.withValues(alpha: 0.18)
                        : Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.text,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Baloo_Bhaijaan_2',
                      fontSize: 14.5,
                      height: 1.45,
                      color: msg.isUser ? Colors.white : AppColors.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontFamily: 'Baloo_Bhaijaan_2',
                          fontSize: 10.5,
                          color:
                              msg.isUser ? Colors.white70 : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          _speakMessage(
                            index,
                            msg.text,
                          );
                        },
                        child: Icon(
                          isSpeaking
                              ? Icons.graphic_eq_rounded
                              : Icons.volume_up_rounded,
                          size: 16,
                          color: msg.isUser
                              ? Colors.white
                              : AppColors.primaryPurple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (msg.isUser)
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(
                right: 8,
              ),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.softPurple,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.primaryPurple,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // Typing Indicator
  // ============================================================

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryPurple,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'صدى يفكر ويقترح...',
                  style: TextStyle(
                    fontFamily: 'Baloo_Bhaijaan_2',
                    fontSize: 12,
                    color: AppColors.textMuted,
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
  // Quick Suggestions
  // ============================================================

  Widget _buildSuggestionsBar() {
    return Container(
      height: 42,
      margin: const EdgeInsets.only(
        bottom: 8,
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        reverse: true,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        itemCount: _quickSuggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final suggestion = _quickSuggestions[index];

          return ActionChip(
            label: Text(
              suggestion,
            ),
            onPressed: _isTyping
                ? null
                : () {
                    _sendMessage(
                      suggestion,
                    );
                  },
            backgroundColor: Colors.white,
            disabledColor: Colors.white.withValues(
              alpha: 0.6,
            ),
            side: const BorderSide(
              color: AppColors.border,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            labelStyle: const TextStyle(
              fontFamily: 'Baloo_Bhaijaan_2',
              fontSize: 12,
              color: AppColors.primaryPurple,
              fontWeight: FontWeight.w700,
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // Composer
  // ============================================================

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        14,
        8,
        14,
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _isTyping ? null : _pickImageForChat,
            icon: Icon(
              Icons.camera_alt_outlined,
              color: _isTyping ? AppColors.textMuted : AppColors.primaryPurple,
              size: 24,
            ),
            tooltip: 'إرفاق صورة للتحليل',
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              enabled: !_isTyping,
              onSubmitted: (_) {
                if (!_isTyping) {
                  _sendMessage();
                }
              },
              style: const TextStyle(
                fontFamily: 'Baloo_Bhaijaan_2',
                fontSize: 14.5,
              ),
              decoration: InputDecoration(
                hintText: _isTyping
                    ? 'صدى يكتب الرد...'
                    : 'اكتب رسالتك أو سؤالك هنا...',
                hintStyle: const TextStyle(
                  fontFamily: 'Baloo_Bhaijaan_2',
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
                filled: true,
                fillColor: AppColors.bg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _isTyping
                  ? const LinearGradient(
                      colors: [
                        AppColors.textMuted,
                        AppColors.textMuted,
                      ],
                    )
                  : AppColors.brandGradient,
            ),
            child: IconButton(
              onPressed: _isTyping ? null : _sendMessage,
              icon: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
              tooltip: 'إرسال',
            ),
          ),
        ],
      ),
    );
  }
}
