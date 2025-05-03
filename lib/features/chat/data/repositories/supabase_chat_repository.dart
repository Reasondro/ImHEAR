// features/chat/data/repositories/supabase_chat_repository.dart

import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:komunika/features/chat/domain/entities/message.dart';
import 'package:komunika/features/chat/domain/repositories/chat_repository.dart';

class SupabaseChatRepository implements ChatRepository {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  @override
  Future<int> getOrCreateChatRoom({required String subSpaceId}) async {
    try {
      final dynamic response = await _supabaseClient.rpc(
        'get_or_create_room',
        params: {
          'p_sub_space_id':
              subSpaceId, //? parameter name defined in the function
        },
      );
      // ? the function returns the bigint room ID directly
      // ? ensure correct casting from dynamic to int
      if (response == null) {
        throw Exception('get_or_create_room returned null');
      }
      return response as int; // ? cast the result to int
    } on PostgrestException catch (e) {
      print("Supabase Error getOrCreateChatRoom RPC: ${e.message}");
      //? check if the error message came from RAISE EXCEPTION (role check) (via the database rpc function)
      if (e.message.contains('Only deaf_user can create chat rooms')) {
        throw Exception(
          "Permission denied: Only deaf users can initiate chat.",
        );
      }
      throw Exception(
        "Database error (${e.code}): Failed to get/create chat room via RPC.",
      );
    } catch (e) {
      print("Unexpected Error getOrCreateChatRoom RPC: $e");
      throw Exception("Failed to get or create chat room via RPC: $e");
    }
  }

  @override
  Stream<List<Message>> getMessagesStream({required int roomId}) {
    try {
      //? listen to inserts/updates/deletes on 'messages' table for the specific room
      final SupabaseStreamBuilder stream = _supabaseClient
          .from('messages')
          .stream(primaryKey: ['id']) //? specify primary key column(s)
          .eq('room_id', roomId) //? filter for the specific room
          .order(
            'created_at',
            ascending: true,
          ); //? order messages chronologically

      //?  stream emits List<Map<String, dynamic>> representing the current state
      //? map this raw data to  Message entity
      return stream
          .map((List<Map<String, dynamic>> listOfMaps) {
            return listOfMaps
                .map(
                  (Map<String, dynamic> messageMap) =>
                      Message.fromMap(messageMap),
                )
                .toList();
          })
          .handleError((error) {
            //? handle errors occurring within the stream pipeline
            print("Error in messages stream: $error");
            //? depending on desired behavior, could emit empty list or rethrow
            //? rethrowing might terminate the stream in the Bloc/Cubit
            throw Exception("Error listening to messages: $error");
          });
    } catch (e) {
      print("Error setting up messages stream: $e");
      //? return an error stream immediately if setup fails
      return Stream.error(Exception("Failed to get messages stream: $e"));
    }
  }

  @override
  Future<void> sendMessage({
    required int roomId,
    required String content,
  }) async {
    try {
      final String currentUserId = _supabaseClient.auth.currentUser!.id;

      //? insert the new message
      await _supabaseClient.from('messages').insert({
        'room_id': roomId,
        'sender_id': currentUserId,
        'content': content,
        //? 'created_at' defaults to now() in the database
      });
      print("Message sent to room $roomId");
    } on PostgrestException catch (e) {
      //? RLS might deny insert if user isn't a participant (tested via room access check)
      print("Supabase Error sendMessage: ${e.message}");
      throw Exception("Database error (${e.code}): Failed to send message.");
    } catch (e) {
      print("Unexpected Error sendMessage: $e");
      throw Exception("Failed to send message: $e");
    }
  }
}
