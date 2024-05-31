import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../tickets/TicketScanner.dart';

class SpecificEventScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  SpecificEventScreen({required this.event});

  @override
  _SpecificEventScreenState createState() => _SpecificEventScreenState();
}

class _SpecificEventScreenState extends State<SpecificEventScreen> {
  bool _isLoading = false;
  String _ticketPrice = '';
  bool _isFetchingPrice = true;
  String _ticketId = '';
  bool isAdmin = false;

  Future<void> checkIfAdmin() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        isAdmin = user.email!.endsWith('@admin.com');
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTicketPrice();
    checkIfAdmin();
  }

  Future<void> _fetchTicketPrice() async {
    setState(() {
      _isFetchingPrice = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('tickets')
          .select('id, price')
          .eq('event_id', widget.event['id'])
          .single()
          .execute();

      if (response.data != null) {
        setState(() {
          _ticketPrice = response.data['price'].toString();
          _ticketId = response.data['id'].toString();
        });
      }
    } catch (error) {
      setState(() {
        _ticketPrice = 'Unavailable';
      });
    } finally {
      setState(() {
        _isFetchingPrice = false;
      });
    }
  }

  Future<void> _orderTicket() async {
    setState(() {
      _isLoading = true;
    });

    final user = Supabase.instance.client.auth.currentUser;
    try {
      await Supabase.instance.client
          .from('user_tickets')
          .insert({
        'ticket_id': int.parse(_ticketId),
        'user_id': user?.id,
      })
          .execute();

      ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text("Ticket ordered successfully.")),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to order ticket.")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isFetchingPrice
            ? const Center(child: CircularProgressIndicator())
            : Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Event Details',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'Name: ${widget.event['name']}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  'Genre: ${widget.event['genre']}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Date: ${widget.event['event_time'].toString().substring(0,10)}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Time: ${widget.event['event_time'].toString().substring(11,19)}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Location: ${widget.event['address']}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Description: ${widget.event['description']}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                 Text(
                  'Ticket Price: \$$_ticketPrice',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _orderTicket,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40.0,
                        vertical: 15.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                        : Text(
                      'Order ticket',
                      style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: isAdmin
        ? FloatingActionButton(
    onPressed: () {
    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (context) => TicketScanner(),
    ));
    },
  child: const Icon(Icons.qr_code),
    ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}