import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../data/chat_repository.dart';
import '../domain/chat_message.dart';

part 'chat_screen.g.dart';

@riverpod
class ChatNotifier extends _$ChatNotifier {
  @override
  List<ChatMessage> build() {
    // Greeting message shown on first load
    return [
      ChatMessage(
        id: 'greeting',
        content:
            "Hi there! 👋 I'm Saabi, your AI health assistant. Ask me anything about health topics you're curious about. I'll do my best to give you trusted, accurate information.",
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
      ),
    ];
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: const Uuid().v4(),
      content: text.trim(),
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );
    state = [...state, userMsg];

    // Typing placeholder
    const typingId = '__typing__';
    state = [...state, ChatMessage(id: typingId, content: '', role: MessageRole.assistant, timestamp: DateTime.now())];

    final repo = ref.read(chatRepositoryProvider);
    final result = await repo.sendMessage(text.trim());

    state = state.where((m) => m.id != typingId).toList();
    state = [...state, result.reply];
  }
}

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text;
    if (text.trim().isEmpty || _sending) return;
    _controller.clear();
    setState(() => _sending = true);
    await ref.read(chatNotifierProvider.notifier).sendMessage(text);
    setState(() => _sending = false);
    _scrollToBottom();
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

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatNotifierProvider);

    return Scaffold(
      backgroundColor: SaabiColors.surface,
      appBar: AppBar(
        backgroundColor: SaabiColors.surface,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: const BoxDecoration(
                  color: SaabiColors.green, shape: BoxShape.circle),
              child: const Icon(Icons.sentiment_satisfied_alt,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: SaabiSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ask Saabi',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: SaabiColors.textPrimary)),
                Text('AI Health Assistant',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: SaabiColors.textSecondary)),
              ],
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                  horizontal: SaabiSpacing.md, vertical: SaabiSpacing.md),
              itemCount: messages.length,
              itemBuilder: (_, i) => _MessageBubble(message: messages[i]),
            ),
          ),

          // Disclaimer banner (matches Figma yellow strip)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: SaabiSpacing.md, vertical: SaabiSpacing.sm),
            color: SaabiColors.disclaimerBg,
            child: Text(
              'Disclaimer: I provide general health info. Always consult a healthcare provider.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SaabiColors.disclaimerText,
                    fontSize: 12,
                  ),
              textAlign: TextAlign.center,
            ),
          ),

          // Input bar
          _InputBar(
            controller: _controller,
            onSend: _send,
            sending: _sending,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final ChatMessage message;

  bool get isUser => message.role == MessageRole.user;
  bool get isTyping => message.id == '__typing__';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SaabiSpacing.md),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 36, height: 36,
              decoration: const BoxDecoration(
                  color: SaabiColors.green, shape: BoxShape.circle),
              child: const Icon(Icons.sentiment_satisfied_alt,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: SaabiSpacing.sm),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75),
              padding: const EdgeInsets.symmetric(
                  horizontal: SaabiSpacing.md, vertical: SaabiSpacing.md),
              decoration: BoxDecoration(
                color: isUser ? SaabiColors.userBubble : SaabiColors.aiBubble,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(SaabiRadius.lg),
                  topRight: const Radius.circular(SaabiRadius.lg),
                  bottomLeft: Radius.circular(isUser ? SaabiRadius.lg : 4),
                  bottomRight: Radius.circular(isUser ? 4 : SaabiRadius.lg),
                ),
              ),
              child: isTyping
                  ? const TypingIndicator()
                  : Text(
                      message.content,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isUser
                                ? SaabiColors.userBubbleText
                                : message.isError
                                    ? SaabiColors.error
                                    : SaabiColors.aiBubbleText,
                          ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller, required this.onSend, required this.sending});
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool sending;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: SaabiSpacing.md,
        right: SaabiSpacing.md,
        top: SaabiSpacing.sm,
        bottom: MediaQuery.of(context).viewInsets.bottom + SaabiSpacing.md,
      ),
      color: SaabiColors.surface,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: 4,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Ask a health question...',
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: SaabiSpacing.sm),
          // Navy circular send button (matches Figma)
          GestureDetector(
            onTap: sending ? null : onSend,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: sending ? SaabiColors.textHint : SaabiColors.primary,
                shape: BoxShape.circle,
              ),
              child: sending
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
