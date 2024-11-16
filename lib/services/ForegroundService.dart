import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:geolocator/geolocator.dart' as geo;

class ForegroundService {
  Timer? _timer;
  final Location _location = Location();
  final Battery _battery = Battery();

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      // Request location permissions
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled don't continue
        // accessing the position and request users of the
        // App to enable the location services.
        return Future.error('Location services are disabled.');
      }

      geo.LocationPermission permission =
      await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) {
          // Permissions are denied, next time you could try
          // requesting permissions again (this is also where
          // Android's shouldShowRequestPermissionRationale
          // returned true. According to Android guidelines
          // your App should show an explanatory UI now.
          return Future.error('Location permissions are denied');
        }
      }

      // Check for battery optimizations
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }

      // Check for exact alarms permissions
      if (!await FlutterForegroundTask.canScheduleExactAlarms) {
        await FlutterForegroundTask.openAlarmsAndRemindersSettings();
      }
    }
  }

  void initService() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'Foreground Service Notification',
        channelDescription: 'Foreground service is running.',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<ServiceRequestResult> startService() async {
    await requestPermissions();
    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        notificationTitle: 'Foreground Service is running',
        notificationText: 'Tap to return to the app',
        callback: startCallback,
      );
    }
  }

  Future<ServiceRequestResult> stopService() async {
    return FlutterForegroundTask.stopService();
  }

  void onReceiveTaskData(Object data) {
    if (data is Map<String, dynamic>) {
      final timestampMillis = data["timestampMillis"];
      if (timestampMillis != null) {
        final timestamp =
        DateTime.fromMillisecondsSinceEpoch(timestampMillis, isUtc: true);
        print('Timestamp: $timestamp');
      }
    }
  }

  void dispose() {
    FlutterForegroundTask.removeTaskDataCallback(onReceiveTaskData);
    // Ensure any timers or subscriptions are cancelled
    _timer?.cancel();
  }
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(FirstTaskHandler());
}

class FirstTaskHandler extends TaskHandler {
  geo.Position? currentPosition;
  geo.Position? lastPosition;
  final geo.LocationSettings locationSettings = geo.LocationSettings(
    accuracy: geo.LocationAccuracy.high,
    distanceFilter: 100,
  );

  StreamSubscription<geo.Position>? positionStream;

  FirstTaskHandler() {
    initPositionStream();
  }

  void initPositionStream() {
    positionStream =
        geo.Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((geo.Position? position) {
          print(position == null
              ? 'Unknown'
              : '${position.latitude.toString()}, ${position.longitude.toString()}');
        });
  }

  final Battery _battery = Battery();


  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('FirstTaskHandler started');
    FlutterForegroundTask.updateService(
      notificationTitle: 'Foreground Task Started',
      notificationText:
      'FirstTask has started successfully at: ${timestamp.toString()}',
    );
  }

  Future<void> _sendDataIfNeed() async {
    currentPosition = await geo.Geolocator.getCurrentPosition(locationSettings: locationSettings);
    if (lastPosition == null) {
      lastPosition = currentPosition;
      _sendData();
      return;
    }
    else if(calDistance(lastPosition, currentPosition) < 15){
      return;
    }
    else {
      lastPosition = currentPosition;
      _sendData();}
  }

  double calDistance(geo.Position? p1, geo.Position? p2){
    double d = geo.Geolocator.distanceBetween(p1!.latitude, p1!.longitude, p2!.latitude, p2!.longitude);
    return d;
  }

  Future<void> _sendData() async {
    try {
      // Update notification to show sending status
      await FlutterForegroundTask.updateService(
        notificationTitle: 'Updating Location',
        notificationText: 'Sending data...',
      );

      // Get stored credentials
      final prefs = await SharedPreferences.getInstance();
      final parentId = prefs.getString('parentId');
      final token = prefs.getString('token');

      // Validate credentials
      if (parentId == null || token == null) {
        throw Exception(
            'Missing authentication data: parentId or token not found');
      }

      // Get location data with timeout
      final locationData = await geo.Geolocator.getCurrentPosition(locationSettings: locationSettings);
      // Validate location data
      if (locationData.latitude == null || locationData.longitude == null) {
        throw Exception('Invalid location data received');
      }

      // Get battery level
      final batteryLevel = await _battery.batteryLevel;

      // Prepare API call
      final url = Uri.parse(
          'https://huyln.info/parentlink/users/$parentId/children/$token');
      final payload = jsonEncode({
        'longitude': locationData.longitude,
        'latitude': locationData.latitude,
        'speed': locationData.speed ?? 0, // Use 0 as default if speed is null
        'battery': batteryLevel,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Send data with timeout
      final response = await http
          .put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: payload,
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('API request timed out'),
      );

      // Handle response
      if (response.statusCode == 200) {
        print('Data sent successfully!');
        print('Location: ${locationData.latitude}, ${locationData.longitude}');
        print('Battery: $batteryLevel%');

        await FlutterForegroundTask.updateService(
          notificationTitle: 'Location Updated',
          notificationText:
          'Last update: ${DateTime.now().toString().substring(11, 16)}',
        );
      } else {
        throw Exception(
            'Server error: ${response.statusCode}\nBody: ${response.body}');
      }
    } catch (e) {
      print('Error sending data: $e');

      // Update notification to show error
      await FlutterForegroundTask.updateService(
        notificationTitle: 'Update Failed',
        notificationText: 'Will retry in next interval',
      );

      // Optional: Store failed update for retry
      await _storeFailedUpdate();
    }
  }

  Future<void> _storeFailedUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final failedUpdates = prefs.getStringList('failedUpdates') ?? [];

      if (failedUpdates.length >= 50) {
        // Limit stored failed updates
        failedUpdates.removeAt(0); // Remove oldest
      }

      failedUpdates.add(DateTime.now().toIso8601String());
      await prefs.setStringList('failedUpdates', failedUpdates);
    } catch (e) {
      print('Error storing failed update: $e');
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    await _sendDataIfNeed(); // Call _sendData periodically
    FlutterForegroundTask.updateService(
      notificationTitle: 'Sending Data',
      notificationText: 'Data sent at: ${timestamp.toString()}',
    );
    FlutterForegroundTask.sendDataToMain({
      "timestampMillis": timestamp.millisecondsSinceEpoch,
    });
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    print('FirstTaskHandler destroyed');
  }
}