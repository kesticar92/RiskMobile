import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/utils/formatters.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String? caseId;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    this.caseId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String? _currentUserId;
  String? _currentUserName;

  void _onMessageChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    _msgCtrl.addListener(_onMessageChanged);
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final auth = ref.read(authServiceProvider);
    _currentUserId = auth.currentUser?.uid;
    if (_currentUserId != null) {
      final u = await auth.getUserData(_currentUserId!);
      setState(() => _currentUserName = u?.name);
    }
  }

  String get _chatId {
    final ids = [_currentUserId ?? '', widget.otherUserId]..sort();
    final base = ids.join('_');
    return widget.caseId != null ? '${base}_${widget.caseId}' : base;
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _currentUserId == null) return;
    if (text.length > AppConstants.chatMessageMaxLength) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'El mensaje no puede superar ${AppConstants.chatMessageMaxLength} caracteres.',
          ),
        ),
      );
      return;
    }

    _msgCtrl.clear();
    await ref.read(firestoreServiceProvider).sendMessage(
      chatId: _chatId,
      senderId: _currentUserId!,
      senderName: _currentUserName ?? 'Usuario',
      content: text,
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _openTemplates() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: AppConstants.advisorChatTemplates.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final tpl = AppConstants.advisorChatTemplates[i];
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
                title: Text(
                  tpl,
                  style: const TextStyle(fontSize: 13),
                ),
                onTap: () => Navigator.of(ctx).pop(tpl),
              );
            },
          ),
        );
      },
    );
    if (selected == null || !mounted) return;
    final current = _msgCtrl.text.trim();
    final nextText = current.isEmpty ? selected : '$current\n$selected';
    if (nextText.length > AppConstants.chatMessageMaxLength) {
      _showTemplateLengthWarning();
      return;
    }
    _msgCtrl.text = nextText;
    _msgCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: _msgCtrl.text.length),
    );
  }

  void _showTemplateLengthWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'La plantilla supera el límite de ${AppConstants.chatMessageMaxLength} caracteres.',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _msgCtrl.removeListener(_onMessageChanged);
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: AppColors.divider),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Center(
                      child: Text(
                        widget.otherUserName.isNotEmpty
                            ? widget.otherUserName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.otherUserName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppColors.riskLow,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text('En línea',
                                style: TextStyle(
                                    fontSize: 11, color: AppColors.riskLow)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Messages
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: ref
                    .read(firestoreServiceProvider)
                    .streamMessages(_chatId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 50, color: AppColors.textLight),
                          const SizedBox(height: 12),
                          Text('Inicia la conversación',
                              style: TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text('Escribe tu primer mensaje',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.textLight)),
                        ],
                      ),
                    );
                  }
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollCtrl.hasClients) {
                      _scrollCtrl
                          .jumpTo(_scrollCtrl.position.maxScrollExtent);
                    }
                  });
                  return ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: docs.length,
                    itemBuilder: (ctx, i) {
                      final data =
                          docs[i].data() as Map<String, dynamic>;
                      final isMe = data['senderId'] == _currentUserId;
                      return _MessageBubble(
                        content: data['content'] ?? '',
                        senderName: data['senderName'] ?? '',
                        timestamp:
                            (data['timestamp'] as Timestamp?)?.toDate() ??
                                DateTime.now(),
                        isMe: isMe,
                        index: i,
                      );
                    },
                  );
                },
              ),
            ),
            // Input
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.divider),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _openTemplates,
                        child: Container(
                          width: 44,
                          height: 44,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_outlined,
                            size: 20,
                            color: AppColors.primaryBlueDark,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCard,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: TextField(
                            controller: _msgCtrl,
                            minLines: 1,
                            maxLines: 4,
                            maxLength: AppConstants.chatMessageMaxLength,
                            buildCounter: (
                              context, {
                              required currentLength,
                              required isFocused,
                              maxLength,
                            }) =>
                                const SizedBox.shrink(),
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              hintText: 'Escribe un mensaje...',
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 12),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.send_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6, right: 58),
                    child: Text(
                      '${_msgCtrl.text.length}/${AppConstants.chatMessageMaxLength}',
                      style: TextStyle(
                        fontSize: 11,
                        color: _msgCtrl.text.length >=
                                AppConstants.chatMessageMaxLength
                            ? AppColors.riskHigh
                            : AppColors.textLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String content;
  final String senderName;
  final DateTime timestamp;
  final bool isMe;
  final int index;

  const _MessageBubble({
    required this.content,
    required this.senderName,
    required this.timestamp,
    required this.isMe,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  senderName.isNotEmpty ? senderName[0].toUpperCase() : '?',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isMe ? AppColors.primaryGradient : null,
                    color: isMe ? null : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                    border: isMe
                        ? null
                        : Border.all(color: AppColors.border, width: 0.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    content,
                    style: TextStyle(
                      color: isMe ? Colors.white : AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  AppFormatters.timeAgo(timestamp),
                  style: TextStyle(
                      fontSize: 10, color: AppColors.textLight),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index < 20 ? index * 30 : 0));
  }
}
