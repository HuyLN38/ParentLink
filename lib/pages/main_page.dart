import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:parent_link/api/apis.dart';
import 'package:parent_link/components/bottom_bar.dart';
import 'package:parent_link/pages/home/home_page.dart';
import 'package:parent_link/pages/message/screens/home.dart';
import 'package:parent_link/pages/profile/profile_page.dart';
import 'package:parent_link/pages/map_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/BackgroundService.dart'; // Import the
import 'package:parent_link/helper/uuid.dart' as globals;
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../services/ForegroundService.dart';// background service

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  //this selected index is to control the bottom nav bar
  int _selectedIndex = 0;

  late Future<List<Widget>> _pagesFuture;
  String? _role;
  final ForegroundService _foregroundService =
      ForegroundService(); // Initialize the background service

  @override
  void initState() {
    super.initState();
    _pagesFuture = loadPages();
    _startForegroundServiceIfNeeded(); // Start the background service if needed
    Apis.getFirebaseMessagingToken(); // get token for message

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? role = prefs.getString('role');
      if (role == 'children') {
        // Add the callback to receive task data from the foreground service
        FlutterForegroundTask.addTaskDataCallback(_foregroundService.onReceiveTaskData);

        // Request permissions and initialize the foreground service
        await _foregroundService.requestPermissions();
        _foregroundService.initService();
      }
    });
  }

  Future<List<Widget>> loadPages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _role = prefs.getString('role');
    if (_role == 'parent') {
      return [
        const HomePage(),
        const MapPage(),
        const HomeScreen(),
        const ProfilePage(),
      ];
    } else {
      return [
        const HomeScreen(),
        const ProfilePage(),
      ];
    }
  }

  void _startForegroundServiceIfNeeded() async {
    FlutterForegroundTask.initCommunicationPort();
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');
    if (role == 'children') {
      print("Role is children. Attempting to start foreground service.");
      await _foregroundService.requestPermissions();
      _foregroundService.initService();
      var result = await FlutterForegroundTask.startService(
        notificationTitle: 'Parent Link',
        notificationText: 'Location is being shared',
        callback: startCallback,
      );
      print("Foreground service start result: $result");
    } else {
      print("Role is not children; service not started.");
    }
  }


  // this method will update our selected index
  // when the user tags on the bottom bar
  void navigateBottom(int index) {
    if (globals.token != null) {
      log(globals.token!);
    } else {
      log('No user logged in');
    }

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
    _foregroundService.stopService();  // Stop the background service when the widget is disposed
    super.dispose();
  }

}
