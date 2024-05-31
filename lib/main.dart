import 'package:exam_mobile/event/CreateEventScreen.dart';
import 'package:exam_mobile/tickets/MyTicketsScreen.dart';
import 'package:exam_mobile/user/LoginScreen.dart';
import 'package:exam_mobile/user/RegistrationScreen.dart';
import 'package:exam_mobile/user/ProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'event/EventScreen.dart';

Future<void> main() async {

  await Supabase.initialize(
    url: 'https://jsxodwhfpenvmzhmvsfw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpzeG9kd2hmcGVudm16aG12c2Z3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTcwOTY0MzQsImV4cCI6MjAzMjY3MjQzNH0.Dg56qSf_xDICoHuCAE-VjIJuHHl6Y47_Yf35uzVCbho',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TicketTeller',
      theme: ThemeData(
        primaryColor: const Color(0xFF34495E),
      ),
      home: const LoginPage(),
      routes: {
        '/register': (context) => const RegistrationPage(),
        '/home': (context) => const HomeScreen(),
        '/createEvent': (context) => const CreateEventScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int _pageIndex = 0;

  final List<Widget> _pages = [
    EventScreen(),
    MyTicketsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_pageIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        onTap: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_activity),
            label: 'My Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}