import 'package:supabase_flutter/supabase_flutter.dart';

class EventService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchEvents() async {
    final response = await supabase
        .rpc('get_all_events')
        .execute();

    // If the response is successful, extract the data
    final List<dynamic>? responseData = response.data;
    if (responseData != null) {
      return List<Map<String, dynamic>>.from(responseData);
    } else {
      // Handle null response data
      return []; // Return an empty list or throw an exception
    }
  }
}