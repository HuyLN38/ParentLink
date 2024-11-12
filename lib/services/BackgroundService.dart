import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:http/http.dart' as http;
import 'package:battery_plus/battery_plus.dart';
import 'dart:convert';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundService {
  final Battery _battery = Battery();
  final Location _location = Location();
  Timer? _timer;
  bool _isRunning = false;

  Future<void> initializeService() async {
    try {
      final service = FlutterBackgroundService();
      await service.configure(
        iosConfiguration: IosConfiguration(
          autoStart: true,
          onForeground: onStart,
          onBackground: onIosBackground,
        ),
        androidConfiguration: AndroidConfiguration(
          onStart: onStart,
          isForegroundMode: true,
          autoStart: true,
          notificationChannelId: 'parent_link_service',
          initialNotificationTitle: 'Parent Link',
          initialNotificationContent: 'Location sharing is active',
          foregroundServiceNotificationId: 888,
        ),
      );
    } catch (e) {
      print('Failed to initialize service: $e');
      rethrow;
    }
  }

  @pragma('vm:entry-point')
  Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  @pragma('vm:entry-point')
  void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();
    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });
      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }
    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        if (service is AndroidServiceInstance) {
          if (await service.isForegroundService()) {
            service.setForegroundNotificationInfo(
                title: "Parent Link", content: "Location sharing is active");
          }
        }
        await _sendData();
        service.invoke('update');
      } catch (e) {
        print('Background service error: $e');
      }
    });
  }

  Future<void> start() async {
    if (_isRunning) return;

    try {
      final hasPermissions = await _requestPermissions();
      if (!hasPermissions) {
        throw Exception('Required permissions not granted');
      }

      await FlutterBackground.initialize();
      await FlutterBackground.enableBackgroundExecution();

      _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
        await _sendData();
      });

      _isRunning = true;
    } catch (e) {
      print('Failed to start service: $e');
      await stop();
      rethrow;
    }
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    try {
      await FlutterBackground.disableBackgroundExecution();
    } catch (e) {
      print('Error stopping background execution: $e');
    }
  }

  Future<bool> _requestPermissions() async {
    try {
      final locationPermission = await _location.requestPermission();

      // Also enable location services if they're disabled
      if (!await _location.serviceEnabled()) {
        final serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          return false;
        }
      }

      return locationPermission == PermissionStatus.granted;
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  Future<void> _sendData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? parentId = prefs.getString('parentId');
      final String? token = prefs.getString('token');

      if (parentId == null || token == null) {
        throw Exception('Missing parentId or token');
      }

      final locationData = await _location.getLocation();
      final batteryLevel = await _battery.batteryLevel;

      final response = await http.put(
        Uri.parse(
            'https://huyln.info/parentlink/users/$parentId/children/$token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'longitude': locationData.longitude,
          'latitude': locationData.latitude,
          'speed': locationData.speed ?? 0,
          'battery': batteryLevel,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('API error: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      print('Error sending data: $e');
    }
  }
}
