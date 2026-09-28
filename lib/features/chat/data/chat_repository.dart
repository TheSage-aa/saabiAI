import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/network/saabi_ai_client.dart';
import '../../../core/storage/user_id_service.dart';
import '../domain/chat_message.dart';

part 'chat_repository.g.dart';

@riverpod
ChatRepository chatRepository(ChatRepositoryRef ref) {
  return ChatRepository(SaabiAiClient.instance, UserIdService.instance);
}

class ChatRepository {
  ChatRepository(this._client, this._userIdService);

  final SaabiAiClient _client;
  final UserIdService _userIdService;

  /// Send a message to Saabi AI and return the assistant's reply.
  /// Never interprets or filters content — pure passthrough.
  Future<({ChatMessage reply, ApiFailure? error})> sendMessage(
      String message) async {
    try {
      final userId = await _userIdService.getUserId();
      final response = await _client.dio.post(
        '/chat',
        data: {'user_id': userId, 'message': message},
      );

      final replyText = response.data['reply'] as String? ??
          response.data['message'] as String? ??
          '';

      return (
        reply: ChatMessage(
          id: const Uuid().v4(),
          content: replyText,
          role: MessageRole.assistant,
          timestamp: DateTime.now(),
        ),
        error: null,
      );
    } catch (e) {
      final failure = SaabiAiClient.handleError(e);
      return (
        reply: ChatMessage(
          id: const Uuid().v4(),
          content: failure.message,
          role: MessageRole.assistant,
          timestamp: DateTime.now(),
          isError: true,
        ),
        error: failure,
      );
    }
  }
}
