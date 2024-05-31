import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _userNameController = TextEditingController();
  bool _isLoading = true;
  late bool isAdmin;
  late String? userEmail;
  late String userName;

  @override
  void initState() {
    super.initState();
    checkUserDetails();
  }

  Future<void> checkUserDetails() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('username')
          .eq('id', user.id)
          .single()
          .execute();

      setState(() {
        userName = response.data['username'] as String;
        userEmail = user.email!;
        isAdmin = userEmail!.endsWith('@admin.com');
        _isLoading = false;
        _userNameController.text = userName;
      });
    }
  }

  void updateUserDetails(String newName) async {
    final user = Supabase.instance.client.auth.currentUser;

    await Supabase.instance.client
        .from('profiles')
        .update({'username': newName})
        .eq('id', user?.id)
        .execute();

    setState(() {
      userName = newName;
      _userNameController.text = newName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: userEmail,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            TextFormField(
              controller: _userNameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                updateUserDetails(_userNameController.text);
              },
              child: const Text('Update username'),
            ),
          ],
        ),
      ),
    );
  }
}