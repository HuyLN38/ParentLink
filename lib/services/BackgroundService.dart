import 'dart:async';
import 'package:flutter_background/flutter_background.dart';
import 'package:http/http.dart' as http;
import 'package:battery_plus/battery_plus.dart';
import 'dart:convert';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundService {
  final Battery _battery = Battery();
  final Location _location = Location();
  Timer? _timer;

  Future<void> start() async {
    final hasPermissions = await _requestPermissions();
    if (!hasPermissions) return;

    await FlutterBackground.initialize();
    await FlutterBackground.enableBackgroundExecution();

    _timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      await _sendData();
    });
  }

  Future<void> stop() async {
    _timer?.cancel();
    await FlutterBackground.disableBackgroundExecution();
  }

  Future<bool> _requestPermissions() async {
    final locationPermission = await _location.requestPermission();

    return locationPermission == PermissionStatus.granted;
  }

  Future<void> _sendData() async {
    final prefs = await SharedPreferences.getInstance();
    String? parentId = await prefs.getString('parentId');
    String? token = await prefs.getString('token');

    final locationData = await _location.getLocation();
    final batteryLevel = await _battery.batteryLevel;

    final response = await http.put(
      Uri.parse(
          'https://huyln.info/parentlink/users/$parentId/children/$token'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'longitude': locationData.longitude,
        'latitude': locationData.latitude,
        'speed': 1,
        'battery': batteryLevel,
      }),
    );

    print('https://huyln.info/parentlink/users/$parentId/children/$token');
    print(locationData.latitude?.toString());
    print(locationData.longitude?.toString());
    print(locationData.speed?.toString());
    print(batteryLevel.toString());

    if (response.statusCode != 200) {
      print(response.body);
      print("ERRORROROROROOROROR");
    } else {
      print("SUCCESS, YAYYYY");
    }
  }
}
