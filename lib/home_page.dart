import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Session Expired!"),
          backgroundColor: Colors.black,
        ),
      );
      // ignore: use_build_context_synchronously
      _redirectToLogin();
      return;
    }
    // Include the token in the headers of the API request
    Map<String, String> headers = {'Authorization': 'Bearer $token'};

    // Make your API request with the headers
    final http.Response response = await http.get(
      Uri.parse(
          'https://schoolmanagement.fliqr.site/wp-json/jwt-auth/v1/token/validate'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      // Handle the successful response
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      // Process the data as needed
      print('API Response: $jsonResponse');
    } else {
      // Handle API request error
      print('API Request failed with status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to the Home Page!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchData,
              child: const Text('Fetch Data'),
            ),
          ],
        ),
      ),
    );
  }

  void _redirectToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _logout() async {
    // Clear the stored token
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('jwtToken');

    // Redirect to the login page
    _redirectToLogin();
  }
}
