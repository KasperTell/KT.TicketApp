import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SpecifikTicketScreen extends StatelessWidget {
  final Map<String, dynamic> ticket;

  SpecifikTicketScreen({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display ticket information here
            QrImageView(
              data: '${ticket['id']}',
              version: QrVersions.auto,
              size: 200.0,
            ),
          ],
        ),
      ),
    );
  }
}