import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:parent_link/api/apis.dart';
import 'package:parent_link/components/bottom_bar.dart';
import 'package:parent_link/pages/home/home_page.dart';
import 'package:parent_link/pages/message/screens/home.dart';
import 'package:parent_link/pages/profile/profile_page.dart';
import 'package:parent_link/pages/map_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parent_link/helper/uuid.dart' as globals;
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../services/ForegroundService.dart'; // background service

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  //this selected index is to control the bottom nav bar
  int _selectedIndex = 0;
  bool _isForegroundServiceRunning = false;

  late Future<List<Widget>> _pagesFuture;
  String? _role;
  final ForegroundService _foregroundService =
      ForegroundService(); // Initialize the background service

  @override
  void initState() {
    super.initState();
    _pagesFuture = loadPages();
    Apis.getFirebaseMessagingToken(); // get token for message

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeApp();
      await _checkForegroundServiceStatus();
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

  Future<void> _initializeApp() async {
    _pagesFuture = loadPages();
    Apis.getFirebaseMessagingToken();
    await _requestLocationPermission();
    await _startForegroundServiceIfNeeded();
  }

  Future<void> _startForegroundServiceIfNeeded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');
    if (role == 'children') {
      await _foregroundService.requestPermissions();
      FlutterForegroundTask.initCommunicationPort();
      WidgetsFlutterBinding.ensureInitialized();
      print("Role is children. Attempting to start foreground service.");
      _foregroundService.initService();
      // print("Foreground service start result: $result");
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
            floatingActionButton: (_role == 'children')
                ? FloatingActionButton(
                    backgroundColor:
                        _isForegroundServiceRunning ? Colors.red : Colors.blue,
                    onPressed: () async {
                      bool locationServiceEnabled =
                          await _checkLocationEnable();
                      if (!locationServiceEnabled) return;
                      setState(() {
                        if (_isForegroundServiceRunning) {
                          _foregroundService.stopService();
                          print('Foreground Service Stopped');
                        } else {
                          _foregroundService.startService();
                          print('Foreground Service Started');
                        }
                        _isForegroundServiceRunning =
                            !_isForegroundServiceRunning;
                      });
                    },
                    child: Icon(
                      _isForegroundServiceRunning
                          ? Icons.stop
                          : Icons.play_arrow,
                      color: Colors.white,
                    ),
                  )
                : null,
          );
        }
      },
    );
  }

  Future<bool> _checkLocationEnable() async {
    bool serviceEnabled;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Location Services Disabled'),
            content: Text(
                'Location services are disabled. Please enable them in your device settings.'),
            actions: [
              TextButton(
                onPressed: () {
                  Geolocator.openLocationSettings();
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return false;
    } else {
      return true;
    }
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission;

    // Test if location services are enabled.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  Future<void> _checkForegroundServiceStatus() async {
    bool isRunning = await _foregroundService.isRunning();
    setState(() {
      _isForegroundServiceRunning = isRunning;
    });
  }
}
