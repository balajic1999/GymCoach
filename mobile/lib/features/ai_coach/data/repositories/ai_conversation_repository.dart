import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';

/// Repository for AI chat conversations and messages.
class AiConversationRepository {
  final SupabaseClient _client;

  AiConversationRepository(this._client);

  /// Get all conversations for the current user.
  Future<List<Map<String, dynamic>>> getConversations() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('ai_conversations')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Create a new conversation.
  Future<Map<String, dynamic>> createConversation({String? title}) async {
    final userId = _client.auth.currentUser!.id;

    final response = await _client
        .from('ai_conversations')
        .insert({
          'user_id': userId,
          'title': title ?? 'New Chat',
        })
        .select()
        .single();

    return response;
  }

  /// Get messages for a conversation.
  Future<List<Map<String, dynamic>>> getMessages(String conversationId) async {
    final response = await _client
        .from('ai_messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at');

    return List<Map<String, dynamic>>.from(response);
  }

  /// Add a message to a conversation.
  Future<Map<String, dynamic>> addMessage({
    required String conversationId,
    required String role,
    required String content,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await _client
        .from('ai_messages')
        .insert({
          'conversation_id': conversationId,
          'role': role,
          'content': content,
          'metadata': metadata,
        })
        .select()
        .single();

    // Update conversation timestamp
    await _client
        .from('ai_conversations')
        .update({'updated_at': DateTime.now().toIso8601String()})
        .eq('id', conversationId);

    return response;
  }

  /// Delete a conversation and all its messages.
  Future<void> deleteConversation(String conversationId) async {
    await _client
        .from('ai_conversations')
        .delete()
        .eq('id', conversationId);
  }
}

/// Provider for AiConversationRepository.
final aiConversationRepositoryProvider = Provider<AiConversationRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AiConversationRepository(client);
});
