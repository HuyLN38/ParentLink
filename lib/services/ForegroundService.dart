import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ForegroundService {
  Timer? _timer;

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
  geo.Position? stopPossition;
  bool initStop = true;
  bool isInGeoFen = true;
  double stopSpeed = 2;
  double geoFenRadius = 50;
  double currentSpeed = 0;

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
    try {
      // Fetch the current position
      currentPosition = await geo.Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      if (lastPosition == null) {
        print('lastPosition is null, initializing with currentPosition.');
        lastPosition = currentPosition;
        stopPossition = currentPosition;
        await _sendData(lastPosition);
        return;
      }
      print('currentPosition: $currentPosition');
      print('lastPosition: $lastPosition');
      print('stoptPosition: $stopPossition');

      // Convert speed to km/h

      // final double currentSpeed = lowPassFilter(
      //     speedConvertToKm(lastPosition?.speed ?? 0),
      //     speedConvertToKm(currentPosition?.speed ?? 0),
      //     0.2);

      currentSpeed = speedConvertToKm(currentPosition?.speed ?? 0);
      final double distanceMoved = calDistance(lastPosition, currentPosition);

      // Check and update geo-fence and movement state
      checkInGeoFen();
      updateInitStopState();

      //check for the init possition
      print(
          'Before check: initStop=$initStop, currentSpeed=$currentSpeed, isInGeoFen=$isInGeoFen');

      if (!initStop && currentSpeed < stopSpeed) {
        if (stopPossition != currentPosition) {
          // Check if stop position is new
          initStop = true;
          stopPossition = currentPosition;
          _sendStopData(stopPossition);
          print("ca 1");
          _sendData(currentPosition);
        }
        return;
      }

      if (!initStop && currentSpeed > stopSpeed) {
        if (distanceMoved < 15) {
          await _logSpeedAndUpdateNotification(
              currentSpeed, 'Location does not change');
          return;
        } else {
          lastPosition = currentPosition;
          await _sendData(lastPosition);
          return;
        }
      }

      //Get out of the geofence and being moving dont make new stop point
      if (initStop && currentSpeed > stopSpeed && !isInGeoFen) {
        lastPosition = currentPosition;
        await _sendData(lastPosition);
        return;
      }

      //get out the geofence and stop => mk new stop point
      if (initStop && currentSpeed < stopSpeed && !isInGeoFen) {
        print("ca 2");
        stopPossition = currentPosition;
        _sendStopData(stopPossition);
        _sendData(currentPosition);
        // TODO: Add function to send the stop point
        return;
      }

      //the stop point was inited and child in geoFen => dont care speed just send data
      if (initStop && isInGeoFen) {
        if (distanceMoved < 15) {
          await _logSpeedAndUpdateNotification(
              currentSpeed, 'Location does not change');
          return;
        } else {
          lastPosition = currentPosition;
          await _sendData(lastPosition);
          return;
        }
      }
      // Update last position and send data if movement is detected
      lastPosition = currentPosition;
      await _sendData(lastPosition);
    } catch (e) {
      print('Error in _sendDataIfNeed: $e');
    }
  }

  void updateInitStopState() {
    if (!isInGeoFen && initStop) {
      initStop = false; // Only reset when actually needed
    } else {
      initStop = true;
    }
  }

  Future<void> _logSpeedAndUpdateNotification(
      double speed, String message) async {
    // await _writeSpeedToFile(speed);
    await FlutterForegroundTask.updateService(
      notificationTitle: message,
      notificationText: '$speed km/h',
    );
  }

  double lowPassFilter(double oldValue, double newValue, double alpha) {
    return oldValue * (1 - alpha) + newValue * alpha;
  }

  void checkInGeoFen() {
    if (lastPosition == null) {
      isInGeoFen = false;
      return;
    }
    if (calDistance(currentPosition, stopPossition) > geoFenRadius) {
      isInGeoFen = false;
    } else {
      isInGeoFen = true;
    }
  }

  // void checkMovingState() {
  //   if (currentPosition == null) {
  //     isMoving = true;
  //   }
  //   if (speedConvertToKm(currentPosition!.speed) < stopSpeed) {
  //     isMoving = false;
  //   } else {
  //     isMoving = true;
  //   }
  // }

  double calDistance(geo.Position? p1, geo.Position? p2) {
    double d = geo.Geolocator.distanceBetween(
        p1!.latitude, p1!.longitude, p2!.latitude, p2!.longitude);
    return d;
  }

  double calDistanceWithFilter(geo.Position? p1, geo.Position? p2) {
    if (p1 == null || p2 == null) {
      throw ArgumentError("Positions p1 and p2 cannot be null.");
    }

    // Apply a low-pass filter to latitude and longitude
    double filteredLatitude = lowPassFilter(p1.latitude, p2.latitude, 0.1);
    double filteredLongitude = lowPassFilter(p1.longitude, p2.longitude, 0.1);

    // Calculate distance between filtered positions
    double distance = geo.Geolocator.distanceBetween(
      filteredLatitude,
      filteredLongitude,
      p2.latitude,
      p2.longitude,
    );
    return distance;
  }

  Future<void> _sendData(geo.Position? locationData) async {
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
      // Get battery level
      final batteryLevel = await _battery.batteryLevel;

      // Prepare API call
      final url = Uri.parse(
          'https://huyln.info/parentlink/users/$parentId/children/$token');
      final payload = jsonEncode({
        'longitude': locationData!.longitude,
        'latitude': locationData.latitude,
        'speed': speedConvertToKm(
            locationData.speed), // Use 0 as default if speed is null
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
        print(
            'Location: ${locationData.latitude}, ${locationData.longitude},${speedConvertToKm(locationData.speed)}');
        print('Battery: $batteryLevel%');

        await FlutterForegroundTask.updateService(
          notificationTitle: 'Location Updated',
          notificationText:
              'Location: ${locationData.latitude}, ${locationData.longitude},${speedConvertToKm(locationData.speed)}' +
                  'Last update: ${DateTime.now().toString().substring(11, 16)}',
        );
      } else {
        print(
            'Location: ${locationData.latitude}, ${locationData.longitude},${speedConvertToKm(locationData.speed)}');
        throw Exception(
            'Server error: ${response.statusCode}\nBody: ${response.body}');
      }
    } catch (e) {
      print('Error sending data: $e');

      // Update notification to show error
      await FlutterForegroundTask.updateService(
        notificationTitle: 'Update Failed',
        notificationText: '$e',
      );

      // Optional: Store failed update for retry
      await _storeFailedUpdate();
    }
  }

  Future<void> _sendStopData(geo.Position? locationData) async {
    try {
      // Update notification to show sending status
      await FlutterForegroundTask.updateService(
        notificationTitle: 'Updating stop Location',
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
      // Get battery level
      final batteryLevel = await _battery.batteryLevel;

      // Prepare API call
      // change stop uri api
      final url = Uri.parse(
          'https://huyln.info/parentlink/users/children-location/$token');
      final payload = jsonEncode({
        'longitude': locationData!.longitude,
        'latitude': locationData.latitude,
        'speed': speedConvertToKm(locationData.speed) ??
            0, // Use 0 as default if speed is null
        'battery': batteryLevel,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Send data with timeout
      // change stop request
      final response = await http
          .post(
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
        print('Stop Data sent successfully!');
        print(
            'Location: ${locationData.latitude}, ${locationData.longitude},${speedConvertToKm(locationData.speed)}');
        print('Battery: $batteryLevel%');

        await FlutterForegroundTask.updateService(
          notificationTitle: 'Location Updated',
          notificationText:
              'Location: ${locationData.latitude}, ${locationData.longitude},${speedConvertToKm(locationData.speed)}' +
                  'Last update: ${DateTime.now().toString().substring(11, 16)}',
        );
      } else {
        print(
            'Location: ${locationData.latitude}, ${locationData.longitude},${speedConvertToKm(locationData.speed)}');
        throw Exception(
            'Server error: ${response.statusCode}\nBody: ${response.body} stop error');
      }
    } catch (e) {
      print('Error sending stop data: $e');

      // Update notification to show error
      await FlutterForegroundTask.updateService(
        notificationTitle: 'Update Failed',
        notificationText: '$e',
      );

      // Optional: Store failed update for retry
      await _storeFailedUpdate();
    }
  }

  double speedConvertToKm(double? speed) {
    if (speed == null || speed.isNaN || speed.isInfinite) return 1;
    return speed * 3.6; // Convert m/s to km/h
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
    // FlutterForegroundTask.updateService(
    //   notificationTitle: 'Sending Data',
    //   notificationText: 'Data sent at: ${timestamp.toString()}',
    // );
    // FlutterForegroundTask.sendDataToMain({
    //   "timestampMillis": timestamp.millisecondsSinceEpoch,
    // });
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    print('FirstTaskHandler destroyed');
  }
}
