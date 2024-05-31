import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  bool _isLoading = false;
  final _eventName = TextEditingController();
  final _eventDescription = TextEditingController();
  final _eventAddress = TextEditingController();
  DateTime? _eventDateTime;
  final _ticketPrice = TextEditingController();
  final _genre = TextEditingController();

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (pickedDateTime != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _eventDateTime = DateTime(
            pickedDateTime.year,
            pickedDateTime.month,
            pickedDateTime.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _createEvent() async {
    final eventName = _eventName.text;
    final eventDescription = _eventDescription.text;
    final eventAddress = _eventAddress.text;
    final ticketPrice = double.tryParse(_ticketPrice.text);
    final genre = _genre.text;

    if (_eventDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a time for the event")));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('events')
          .insert({
            'name': eventName,
            'description': eventDescription,
            'address': eventAddress,
            'event_time': _eventDateTime!.toIso8601String(),
            'genre': genre,
          })
          .select('id')
          .single()
          .execute();

      final eventId = response.data['id'];

      await Supabase.instance.client.from('tickets').insert({
        'event_id': eventId,
        'price': ticketPrice,
      }).execute();

      Navigator.of(context).pushReplacementNamed("/home");
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to create the event")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _eventName.dispose();
    _eventDescription.dispose();
    _eventAddress.dispose();
    _ticketPrice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create a new event')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        children: [
          TextFormField(
            controller: _eventName,
            decoration: InputDecoration(
                labelText: 'Event Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                )),
            keyboardType: TextInputType.text,
          ),
          const SizedBox(width: 16, height: 16),
          TextFormField(
            controller: _eventDescription,
            decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                )),
            keyboardType: TextInputType.text,
          ),
          const SizedBox(width: 16, height: 16),
          TextFormField(
            controller: _eventAddress,
            decoration: InputDecoration(
                labelText: 'Venue address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                )),
            keyboardType: TextInputType.streetAddress,
          ),
          const SizedBox(width: 16, height: 16),
          TextFormField(
            controller: _genre,
            decoration: InputDecoration(
                labelText: 'Genre of the event',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                )),
            keyboardType: TextInputType.text,
          ),
          const SizedBox(width: 16, height: 16),
          TextFormField(
            controller: _ticketPrice,
            decoration: InputDecoration(
                labelText: 'Ticket Price',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                )),
            keyboardType: TextInputType.number,
          ),
          ListTile(
            title: Text(
              _eventDateTime == null
                  ? 'Select Date and Time'
                  : '${_eventDateTime!.year}-${_eventDateTime!.month}-${_eventDateTime!.day} '
                      '${_eventDateTime!.hour}:${_eventDateTime!.minute}',
            ),
            onTap: () => _selectDateTime(context),
          ),
          const SizedBox(width: 16, height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _createEvent,
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
                    'Create the new event',
                    style: TextStyle(
                        fontSize: 18, color: Theme.of(context).primaryColor),
                  ),
          ),
        ],
      ),
    );
  }
}
