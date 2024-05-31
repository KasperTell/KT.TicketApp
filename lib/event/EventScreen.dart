import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/EventService.dart';
import 'SpecificEventScreen.dart';

class EventScreen extends StatefulWidget {
  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  late Future<List<Map<String, dynamic>>> _eventsFuture;
  final EventService _eventService = EventService();
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _eventService.fetchEvents();
    checkIfAdmin();
  }

  Future<void> checkIfAdmin() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        isAdmin = user.email!.endsWith('@admin.com');
      });
    }
  }

  Future<void> _deleteEvent(int eventId) async {
    try {
      final ticketResponse = await Supabase.instance.client
          .from('tickets')
          .select('id')
          .eq('event_id', eventId)
          .execute();

      final tickets = ticketResponse.data as List<dynamic>;
      if (tickets.isNotEmpty) {
        for (var ticket in tickets) {
          final ticketId = ticket['id'];
          await Supabase.instance.client
              .from('user_tickets')
              .delete()
              .eq('ticket_id', ticketId)
              .execute();
        }

        await Supabase.instance.client
            .from('tickets')
            .delete()
            .eq('event_id', eventId)
            .execute();
      }

      final eventResponse = await Supabase.instance.client
          .from('events')
          .delete()
          .eq('id', eventId)
          .execute();

      if (eventResponse.data != null) {
        setState(() {
          _eventsFuture = _eventService.fetchEvents();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event deleted successfully')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete the event")));
    }
  }

  void _showDeleteDialog(int eventId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Event'),
          content: Text('Are you sure you want to delete this event?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteEvent(eventId);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final events = snapshot.data!;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: Theme.of(context).primaryColor, width: 1),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.0),
                  leading: Icon(Icons.event),
                  title: Text(
                    event['name'],
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    event['genre'],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SpecificEventScreen(event: event),
                      ),
                    );
                  },
                  onLongPress: isAdmin
                      ? () {
                    _showDeleteDialog(event['id']);
                  }
                      : null,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/createEvent');
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
