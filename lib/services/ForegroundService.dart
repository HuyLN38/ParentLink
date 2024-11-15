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

class ForegroundService {
  Timer? _timer;
  final Location _location = Location();
  final Battery _battery = Battery();

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      // Request location permissions
      final locationPermission = await _location.requestPermission();
      if (locationPermission != PermissionStatus.granted) {
        print('Location permission not granted');
        return;
      }

      // Ensure location services are enabled
      final serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        final serviceRequested = await _location.requestService();
        if (!serviceRequested) {
          print('Location service not enabled');
          return;
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
  final Location _location = Location();
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
        throw Exception('Missing authentication data: parentId or token not found');
      }

      // Get location data with timeout
      final locationData = await _location.getLocation().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Location request timed out'),
      );

      // Validate location data
      if (locationData.latitude == null || locationData.longitude == null) {
        throw Exception('Invalid location data received');
      }

      // Get battery level
      final batteryLevel = await _battery.batteryLevel;

      // Prepare API call
      final url = Uri.parse('https://huyln.info/parentlink/users/$parentId/children/$token');
      final payload = jsonEncode({
        'longitude': locationData.longitude,
        'latitude': locationData.latitude,
        'speed': locationData.speed ?? 0,  // Use 0 as default if speed is null
        'battery': batteryLevel,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Send data with timeout
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: payload,
      ).timeout(
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
          notificationText: 'Last update: ${DateTime.now().toString().substring(11, 16)}',
        );
      } else {
        throw Exception('Server error: ${response.statusCode}\nBody: ${response.body}');
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

      if (failedUpdates.length >= 50) {  // Limit stored failed updates
        failedUpdates.removeAt(0);  // Remove oldest
      }

      failedUpdates.add(DateTime.now().toIso8601String());
      await prefs.setStringList('failedUpdates', failedUpdates);
    } catch (e) {
      print('Error storing failed update: $e');
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    await _sendData(); // Call _sendData periodically
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
