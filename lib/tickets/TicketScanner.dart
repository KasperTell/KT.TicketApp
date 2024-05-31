import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TicketScanner extends StatefulWidget {
  @override
  _TicketScannerState createState() => _TicketScannerState();
}

class _TicketScannerState extends State<TicketScanner> {
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  QRViewController? _qrViewController;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(_cameras[0], ResolutionPreset.max);
    await _cameraController.initialize();
    if (mounted) {
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _qrViewController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return CircularProgressIndicator();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
      ),
      body: Stack(
        children: [
          CameraPreview(_cameraController),
          Positioned.fill(
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      _qrViewController = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      if (scanData.code != null) {
        _qrViewController?.pauseCamera();
        final validationStatus = await _getValidation(scanData.code);
        _showPopup(context, scanData.code, validationStatus);
      }
    });
  }

  Future<void> _changeValidation(String qrCode) async {
    await Supabase.instance.client
        .from('user_tickets')
        .update({'qr_code': 'Already used'})
        .eq('id', int.parse(qrCode))
        .execute();
  }

  Future<String> _getValidation(String? qrCode) async {
    final response = await Supabase.instance.client
        .from('user_tickets')
        .select('*')
        .eq('id', int.parse(qrCode!))
        .execute();

    return response.data[0]['qr_code'];
  }

  void _showPopup(BuildContext context, String? qrCode,
      String? validationStatus) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ticket Scanned'),
          content: Text('Ticket: ${validationStatus ?? 'Not found'}'),
          actions: [
            TextButton(
              onPressed: () async {
                if (qrCode != null && validationStatus != null) {
                  await _changeValidation(qrCode);
                }
                Navigator.pop(context);
                _qrViewController
                    ?.resumeCamera();
              },
              child: const Text('Mark as used'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _qrViewController
                    ?.resumeCamera();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}