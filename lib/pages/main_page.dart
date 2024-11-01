import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:parent_link/api/apis.dart';
import 'package:parent_link/components/bottom_bar.dart';
import 'package:parent_link/pages/home/home_page.dart';
import 'package:parent_link/pages/message/message_page.dart';
import 'package:parent_link/pages/message/screens/home.dart';
import 'package:parent_link/pages/profile/profile_page.dart';
import 'package:parent_link/pages/map_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/BackgroundService.dart'; // Import the background service

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  //this selected index is to control the bottome nav bar
  int _selectedIndex = 0;

  // this method will update our selected index
  // when the user tags on the bottom bar
  void navigateBottom(int index) {
    if (Apis.auth.currentUser != null) {
      log(Apis.auth.currentUser!.uid);
    } else {
      log('No user logged in');
    }

  late Future<List<Widget>> _pagesFuture;
  String? _role;
  final BackgroundService _backgroundService =
      BackgroundService(); // Initialize the background service

  @override
  void initState() {
    super.initState();
    _pagesFuture = _loadPages();
    _startBackgroundServiceIfNeeded(); // Start the background service if needed
  }

  Future<List<Widget>> _loadPages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _role = prefs.getString('role');
    if (_role == 'parent') {
      return [
        const HomePage(),
        const MapPage(),
        const MessagePage(),
        const ProfilePage(),
      ];
    } else {
      return [
        const MessagePage(),
        const ProfilePage(),
      ];
    }
  }

  void _startBackgroundServiceIfNeeded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');
    if (role == 'children') {
      await _backgroundService.start();
    }
  }

  void navigateBottom(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Widget>>(
      future: _pagesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading pages'));
        } else {
          final List<Widget> pages = snapshot.data!;
          return Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar: BottomBar(
              currentIndex: _selectedIndex,
              onTap: navigateBottom,
              role: _role,
            ),
            body: pages[_selectedIndex],
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _backgroundService
        .stop(); // Stop the background service when the widget is disposed
    super.dispose();
  }
}
