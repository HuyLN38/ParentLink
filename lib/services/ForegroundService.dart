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

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }
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
    final prefs = await SharedPreferences.getInstance();
    String? parentId = prefs.getString('parentId');
    String? token = prefs.getString('token');

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

    if (response.statusCode != 200) {
      print("Failed to send data: ${response.body}");
    } else {
      print("Data sent successfully!");
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    try {
      final hasPermissions = await _requestPermissions();
      if (!hasPermissions) {
        throw Exception('Required permissions not granted');
      }
      await _sendData(); // Call _sendData periodically
      FlutterForegroundTask.updateService(
        notificationTitle: 'Sending Data',
        notificationText: 'Data sent at: ${timestamp.toString()}',
      );
      FlutterForegroundTask.sendDataToMain({
        "timestampMillis": timestamp.millisecondsSinceEpoch,
      });
    }
    catch (e) {
      print('Failed to start service: $e');
      rethrow;
    }

  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    print('FirstTaskHandler destroyed');
  }
}
