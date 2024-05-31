import 'package:exam_mobile/tickets/SpecifikTicketScreen.dart';
import 'package:exam_mobile/tickets/TicketScanner.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyTicketsScreen extends StatefulWidget {
  @override
  _MyTicketsScreenState createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  late Future<List<Map<String, dynamic>>> _ticketsFuture;
  bool isAdmin = false;


  @override
  void initState() {
    super.initState();
    _ticketsFuture = fetchTickets();
  }

  final user = Supabase.instance.client.auth.currentUser;

  Future<List<Map<String, dynamic>>> fetchTickets() async {
    final response = await Supabase.instance.client
        .from('user_tickets')
        .select('id, ticket_id, purchase_date, tickets(id, event_id, events(id, name))')
        .eq('user_id', user?.id)
        .execute();

    if (response.data == null) {
      return [];
    }

    final List<dynamic>? responseData = response.data;
    if (responseData != null) {
      return List<Map<String, dynamic>>.from(responseData);
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  const Text('Your Tickets'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ticketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final tickets = snapshot.data!;
          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              final eventName = ticket['tickets']?['events']?['name'] ?? 'Unknown Event';
              final purchaseDate = ticket['purchase_date'].toString().substring(0,10);
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.0),
                  leading: const Icon(Icons.event),
                  title: Text(
                    'Ticket for $eventName',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Purchased on $purchaseDate',
                    style: const TextStyle(fontSize: 14.0),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SpecifikTicketScreen(ticket: ticket),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}