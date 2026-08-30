import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/ai_conversation_repository.dart';
import '../../data/services/ai_coach_service.dart';

class ChatMessageItem {
  final String id;
  final String role;
  final String content;
  final DateTime timestamp;
  final List<String> suggestions;

  const ChatMessageItem({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.suggestions = const [],
  });
}

class AiCoachState {
  final List<ChatMessageItem> messages;
  final bool isGenerating;
  final String? activeConversationId;

  const AiCoachState({
    required this.messages,
    this.isGenerating = false,
    this.activeConversationId,
  });

  AiCoachState copyWith({
    List<ChatMessageItem>? messages,
    bool? isGenerating,
    String? activeConversationId,
  }) {
    return AiCoachState(
      messages: messages ?? this.messages,
      isGenerating: isGenerating ?? this.isGenerating,
      activeConversationId:
          activeConversationId ?? this.activeConversationId,
    );
  }
}

class AiCoachNotifier extends StateNotifier<AiCoachState> {
  final AiCoachService _service;
  final AiConversationRepository _repo;

  AiCoachNotifier(this._service, this._repo)
      : super(AiCoachState(
          messages: [
            ChatMessageItem(
              id: 'initial',
              role: 'assistant',
              content: 'Hey! 👋 I\'m your **Gym3D AI Coach**.\n\n'
                  'I can assist you with:\n'
                  '• 🎯 **Form cues & 3D biomechanics analysis**\n'
                  '• 🏋️ **Personalized workout creation**\n'
                  '• 🔄 **Smart exercise substitutions**\n'
                  '• 🔥 **Targeted warm-up & recovery routines**\n\n'
                  'What are we focusing on today?',
              timestamp: DateTime.now(),
              suggestions: const [
                'How do I perform a squat correctly?',
                'Create a beginner workout',
                'What muscles does deadlift work?',
                'How should I warm up?',
              ],
            ),
          ],
        ));

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isGenerating) return;

    final userMsg = ChatMessageItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: trimmed,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isGenerating: true,
    );

    try {
      // Build history for context
      final history = state.messages
          .map((m) => {'role': m.role, 'content': m.content})
          .toList();

      final aiRes = await _service.sendMessage(
        message: trimmed,
        history: history,
      );

      final assistantMsg = ChatMessageItem(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        role: 'assistant',
        content: aiRes.content,
        timestamp: DateTime.now(),
        suggestions: aiRes.suggestions,
      );

      state = state.copyWith(
        messages: [...state.messages, assistantMsg],
        isGenerating: false,
      );

      // Async persist to Supabase if conversation repository allows
      _persistMessageAsync(userMsg, assistantMsg);
    } catch (e) {
      final errorMsg = ChatMessageItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: 'assistant',
        content: 'I had trouble connecting. Please check your network and try again.',
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isGenerating: false,
      );
    }
  }

  Future<void> _persistMessageAsync(
    ChatMessageItem userMsg,
    ChatMessageItem assistantMsg,
  ) async {
    try {
      var convId = state.activeConversationId;
      if (convId == null) {
        final conv = await _repo.createConversation(title: 'Chat Session');
        convId = conv['id'] as String;
        state = state.copyWith(activeConversationId: convId);
      }

      await _repo.addMessage(
        conversationId: convId,
        role: userMsg.role,
        content: userMsg.content,
      );

      await _repo.addMessage(
        conversationId: convId,
        role: assistantMsg.role,
        content: assistantMsg.content,
      );
    } catch (_) {
      // Non-blocking persistence
    }
  }

  void clearChat() {
    state = AiCoachState(
      messages: [
        ChatMessageItem(
          id: 'initial',
          role: 'assistant',
          content: 'Chat cleared! How else can I help your fitness journey today?',
          timestamp: DateTime.now(),
          suggestions: const [
            'Create a beginner workout',
            'How do I squat with proper form?',
            'What is progressive overload?',
          ],
        ),
      ],
    );
  }
}

/// State notifier provider for AI Coach chat state.
final aiCoachStateProvider =
    StateNotifierProvider<AiCoachNotifier, AiCoachState>((ref) {
  final service = ref.watch(aiCoachServiceProvider);
  final repo = ref.watch(aiConversationRepositoryProvider);
  return AiCoachNotifier(service, repo);
});
