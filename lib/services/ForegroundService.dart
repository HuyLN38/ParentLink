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
      // Check for battery optimizations
      final NotificationPermission notificationPermission =
      await FlutterForegroundTask.checkNotificationPermission();
      if (notificationPermission != NotificationPermission.granted) {
        await FlutterForegroundTask.requestNotificationPermission();
      }

      if (Platform.isAndroid) {
        // Android 12+, there are restrictions on starting a foreground service.
        //
        // To restart the service on device reboot or unexpected problem, you need to allow below permission.
        if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
          // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
          await FlutterForegroundTask.requestIgnoreBatteryOptimization();
        }

        // Use this utility only if you provide services that require long-term survival,
        // such as exact alarm service, healthcare service, or Bluetooth communication.
        //
        // This utility requires the "android.permission.SCHEDULE_EXACT_ALARM" permission.
        // Using this permission may make app distribution difficult due to Google policy.
        // if (!await FlutterForegroundTask.canScheduleExactAlarms) {
        //   // When you call this function, will be gone to the settings page.
        //   // So you need to explain to the user why set it.
        //   await FlutterForegroundTask.openAlarmsAndRemindersSettings();
        // }
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

  Future<bool> isRunning() async {
    return FlutterForegroundTask.isRunningService;
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