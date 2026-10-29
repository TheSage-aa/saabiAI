import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/network/saabi_ai_client.dart';
import '../../../core/storage/user_id_service.dart';
import '../domain/chat_message.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(SaabiAiClient.instance, UserIdService.instance);
});

class ChatRepository {
  ChatRepository(this._client, this._userIdService);

  final SaabiAiClient _client;
  final UserIdService _userIdService;

  // ─── Verified Health Knowledge Base (Instant fallback if cloud is offline) ───

  static const _knowledgeBase = [
    (
      keywords: ['hiv', 'what is hiv', 'aids', 'virus'],
      answer:
          'HIV stands for Human Immunodeficiency Virus. It affects the body\'s immune defenses. With daily antiretroviral treatment (ART), people with HIV stay healthy and cannot pass the virus to sexual partners (U=U: Undetectable = Untransmittable). Testing is fast, free, and confidential at public health centers across Nigeria.',
    ),
    (
      keywords: ['u=u', 'undetectable', 'untransmittable'],
      answer:
          'U=U means Undetectable = Untransmittable. When a person takes their HIV medication consistently and the virus becomes undetectable in blood tests, they cannot transmit HIV through sex. It is backed by UNAIDS, WHO, and Nigeria NACA.',
    ),
    (
      keywords: ['transmit', 'catch', 'spread', 'mosquito', 'kissing'],
      answer:
          'HIV can only be passed through specific fluids: blood, semen, vaginal fluids, and breast milk. You CANNOT get HIV from kissing, hugging, sharing food or cups, toilet seats, or mosquito bites.',
    ),
    (
      keywords: ['test', 'testing', 'where to test', 'screening'],
      answer:
          'You can get tested for HIV and STIs confidentially at primary healthcare centers, youth clinics, and through rapid self-test kits available at registered pharmacies. Results take only 15–20 minutes.',
    ),
    (
      keywords: ['prep', 'pep', 'prevention'],
      answer:
          'PrEP (Pre-Exposure Prophylaxis) is a daily pill that prevents HIV before exposure. PEP (Post-Exposure Prophylaxis) is emergency medication taken within 72 hours after possible exposure. Both are available at designated health clinics.',
    ),
    (
      keywords: ['mental', 'stress', 'sad', 'depressed', 'anxious'],
      answer:
          'Your mental health is just as important as physical health. If you are feeling overwhelmed, remember to take deep breaths, speak with someone you trust, or reach out to a certified counselor.',
    ),
  ];

  /// Send a message to Saabi AI and return the assistant's reply.
  Future<({ChatMessage reply, ApiFailure? error})> sendMessage(
      String message) async {
    final cleanMsg = message.trim().toLowerCase();

    try {
      final userId = await _userIdService.getUserId();
      final response = await _client.dio.post(
        '/chat',
        data: {'user_id': userId, 'message': message},
      );

      final replyText = response.data['reply'] as String? ??
          response.data['message'] as String? ??
          '';

      if (replyText.isNotEmpty) {
        return (
          reply: ChatMessage(
            id: const Uuid().v4(),
            content: replyText,
            role: MessageRole.assistant,
            timestamp: DateTime.now(),
          ),
          error: null,
        );
      }
    } catch (_) {
      // Backend is offline or localhost unreachable on Cloudflare Pages
    }

    // Match with verified health knowledge base
    for (final entry in _knowledgeBase) {
      if (entry.keywords.any((kw) => cleanMsg.contains(kw))) {
        return (
          reply: ChatMessage(
            id: const Uuid().v4(),
            content: entry.answer,
            role: MessageRole.assistant,
            timestamp: DateTime.now(),
          ),
          error: null,
        );
      }
    }

    // Friendly fallback response
    return (
      reply: ChatMessage(
        id: const Uuid().v4(),
        content:
            "Thank you for asking! I'm here to provide trusted health literacy information on HIV, reproductive health, mental wellness, and clinic access. Feel free to ask about testing, prevention, U=U, or explore our interactive courses in the Learn tab!",
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
      ),
      error: null,
    );
  }
}
