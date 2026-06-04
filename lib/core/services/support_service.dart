import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupportService {
  final _supabase = Supabase.instance.client;

  /// Check if the current user is the support admin
  bool get isSupportAdmin => _supabase.auth.currentUser?.email == 'abcd@gmail.com';

  /// Real-time stream for tickets
  Stream<List<Map<String, dynamic>>> streamTickets() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    if (isSupportAdmin) {
      // Admin sees everything
      return _supabase
          .from('support_tickets')
          .stream(primaryKey: ['id'])
          .order('updated_at', ascending: false);
    } else {
      // User sees only their own
      return _supabase
          .from('support_tickets')
          .stream(primaryKey: ['id'])
          .eq('user_id', userId)
          .order('updated_at', ascending: false);
    }
  }

  /// Fetch full ticket details (used for one-time display of names)
  Future<List<Map<String, dynamic>>> getTickets() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      var query = _supabase.from('support_tickets').select('*, profiles(full_name, avatar_url)');
      
      if (!isSupportAdmin) {
        query = query.eq('user_id', userId);
      }

      final response = await query.order('updated_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("SupportService: Error fetching tickets: $e");
      return [];
    }
  }

  /// Create a new support ticket and send the initial message
  Future<String?> createTicket(String subject, String message) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final ticketResponse = await _supabase.from('support_tickets').insert({
        'user_id': userId,
        'subject': subject,
        'last_message': message,
        'status': 'open',
      }).select('id').single();

      final ticketId = ticketResponse['id'];

      // Send the first message automatically
      await sendMessage(ticketId, message);

      return ticketId;
    } catch (e) {
      debugPrint("SupportService: Error creating ticket: $e");
      return null;
    }
  }

  /// Send a message within a ticket
  Future<void> sendMessage(String ticketId, String message) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.from('support_messages').insert({
        'ticket_id': ticketId,
        'sender_id': userId,
        'message': message,
        'is_from_support': isSupportAdmin,
      });

      // Update the ticket summary
      await _supabase.from('support_tickets').update({
        'last_message': message,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', ticketId);
    } catch (e) {
      debugPrint("SupportService: Error sending message: $e");
    }
  }

  /// Real-time stream for chat messages
  Stream<List<Map<String, dynamic>>> streamMessages(String ticketId) {
    return _supabase
        .from('support_messages')
        .stream(primaryKey: ['id'])
        .eq('ticket_id', ticketId)
        .order('created_at'); // Default is ascending: true
  }

  /// Mark a ticket as resolved
  Future<void> closeTicket(String ticketId) async {
    try {
      await _supabase
          .from('support_tickets')
          .update({'status': 'closed'})
          .eq('id', ticketId);
    } catch (e) {
      debugPrint("SupportService: Error closing ticket: $e");
    }
  }
}
