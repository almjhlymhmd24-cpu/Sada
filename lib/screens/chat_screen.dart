import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
      text: 'السلام عليكم ورحمة الله، أنا صدى مساعدك الذكي للتواصل. كيف يمكنني دعمك اليوم؟',
      isUser: false,
      time: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ChatMessage(
      text: 'أهلاً صدى، أريد عبارات مناسبة لطلب المساعدة في متجر أو مطعم.',
      isUser: true,
      time: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
    ChatMessage(
      text: 'إليك بعض العبارات المفيدة:\n• "لو سمحت، أريد الاستفسار عن هذا المنتج"\n• "هل يمكنني الحصول على قائمة الطعام من فضلك؟"\n• "كم يبلغ سعر هذا؟"',
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
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage([String? textToSend]) {
    final text = (textToSend ?? _controller.text).trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _controller.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    // محاكاة رد الذكاء الاصطناعي التفاعلي الذكي
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;

      String aiResponse = 'يسعدني مساعدتك! ';
      if (text.contains('ترجم') || text.contains('ترجمة')) {
        aiResponse = 'تم تحويل العبارة وتجهيز الإشارات التعبيرية المناسبة لها في القاموس الإشاري.';
      } else if (text.contains('رد') || text.contains('اقترح')) {
        aiResponse = 'إليك الرد المقترح:\n"شكراً جزيلاً لتعاونكم، أقدّر مساعدتكم وسعيد جداً بالتواصل معكم."';
      } else if (text.contains('طبيب') || text.contains('صحة') || text.contains('ألم')) {
        aiResponse = 'عبارة موصى بها للطبيب:\n"أشعر بألم في هذا الموضع، وأحتاج لتشخيص بسيط من فضلك."';
      } else {
        aiResponse = 'أنا هنا دائماً لدعمك. يمكنك استخدام ميزة نطق العبارة صوتياً، أو البحث في القاموس الإشاري، أو مشاركة صورة لتحليلها.';
      }

      setState(() {
        _messages.add(ChatMessage(text: aiResponse, isUser: false));
        _isTyping = false;
      });
      _scrollToBottom();
    });
  }

  Future<void> _speakMessage(int index, String text) async {
    if (_speakingIndex == index) {
      await _tts.stop();
      if (mounted) setState(() => _speakingIndex = null);
      return;
    }

    if (!mounted) return;
    setState(() => _speakingIndex = index);
    try {
      await _tts.speak(text);
    } catch (e) {
      debugPrint('⚠️ خطأ أثناء نطق الرسالة: $e');
    } finally {
      if (mounted) {
        setState(() => _speakingIndex = null);
      }
    }
  }

  Future<void> _pickImageForChat() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      if (!mounted) return;
      final file = File(picked.path);
      setState(() {
        _messages.add(ChatMessage(text: '📷 تم إرسال صورة للتحليل...', isUser: true));
        _isTyping = true;
      });
      _scrollToBottom();

      final result = await AiImageService.analyzeImage(file);

      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          text: '🤖 نتيجة تحليل الصورة:\n$result',
          isUser: false,
        ));
        _isTyping = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isTyping = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر تحليل الصورة، يرجى المحاولة ثانية', textAlign: TextAlign.right),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('مسح المحادثة', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Baloo_Bhaijaan_2', fontWeight: FontWeight.bold)),
        content: const Text('هل ترغب في مسح جميع رسائل المحادثة الحالية؟', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Baloo_Bhaijaan_2')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Baloo_Bhaijaan_2', color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _messages.clear();
                _messages.add(ChatMessage(
                  text: 'مرحباً بك مجدداً، كيف يمكنني مساعدتك في التواصل اليوم؟',
                  isUser: false,
                ));
              });
            },
            child: const Text('مسح', style: TextStyle(fontFamily: 'Baloo_Bhaijaan_2', color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        drawer: const SadaDrawer(activeIndex: 3),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppColors.textDark),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
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
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textMuted),
              tooltip: 'مسح المحادثة',
              onPressed: _clearChat,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // قائمة الرسائل
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isTyping) {
                      return _buildTypingIndicator();
                    }
                    final msg = _messages[index];
                    return _buildMessageBubble(msg, index);
                  },
                ),
              ),

              // اقتراحات الردود الذكية
              _buildSuggestionsBar(),

              // حقل كتابة الرسائل
              _buildComposer(),
            ],
          ),
        ),
        bottomNavigationBar: const SadaBottomNav(currentIndex: 3),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, int index) {
    final isSpeaking = _speakingIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            msg.isUser ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isUser)
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(left: 8),
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
              constraints: const BoxConstraints(maxWidth: 480),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: msg.isUser ? AppColors.brandGradient : null,
                color: msg.isUser ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(msg.isUser ? 20 : 4),
                  bottomRight: Radius.circular(msg.isUser ? 4 : 20),
                ),
                border: msg.isUser ? null : Border.all(color: AppColors.border),
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
                          color: msg.isUser ? Colors.white70 : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _speakMessage(index, msg.text),
                        child: Icon(
                          isSpeaking
                              ? Icons.graphic_eq_rounded
                              : Icons.volume_up_rounded,
                          size: 16,
                          color: msg.isUser ? Colors.white : AppColors.primaryPurple,
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
              margin: const EdgeInsets.only(right: 8),
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

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
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

  Widget _buildSuggestionsBar() {
    return Container(
      height: 42,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quickSuggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final s = _quickSuggestions[index];
          return ActionChip(
            label: Text(s),
            onPressed: () => _sendMessage(s),
            backgroundColor: Colors.white,
            side: const BorderSide(color: AppColors.border),
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

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _pickImageForChat,
            icon: const Icon(
              Icons.camera_alt_outlined,
              color: AppColors.primaryPurple,
              size: 24,
            ),
            tooltip: 'إرفاق صورة للتحليل',
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              textAlign: TextAlign.right,
              onSubmitted: (_) => _sendMessage(),
              style: const TextStyle(
                fontFamily: 'Baloo_Bhaijaan_2',
                fontSize: 14.5,
              ),
              decoration: InputDecoration(
                hintText: 'اكتب رسالتك أو سؤالك هنا...',
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
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.brandGradient,
            ),
            child: IconButton(
              onPressed: _sendMessage,
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
