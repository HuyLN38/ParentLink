import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:parent_link/pages/open_page.dart';
import 'package:parent_link/pages/main_page.dart';
import 'package:parent_link/routes/routes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parent_link/helper/uuid.dart' as globals;

import 'firebase_options.dart';
import 'model/control/control_child_location.dart';
import 'model/control/control_child_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  globals.token = prefs.getString('token');
  runApp(const MyApp());
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'chats', // id
  'High Importance Notifications', // titledescription
  importance: Importance.max,
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkTokenAndRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? role = prefs.getString('role');
    return token != null && role != null;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Transparent status bar
      statusBarIconBrightness: Brightness.dark,
    ));
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ControlChildState()),
        ChangeNotifierProvider(create: (_) => ControlChildLocation()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FutureBuilder<bool>(
          future: _checkTokenAndRole(),
          builder: (context, snapshot) {
            // Check if future is complete
            if (snapshot.connectionState == ConnectionState.waiting) {
              // While waiting for the token/role check, show a loading spinner
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.data == true) {
              // If token and role exist, navigate to MainPage
              return const MainPage();
            } else {
              // If no token/role, show OpenPage
              return const OpenPage();
            }
          },
        ),
        routes: Routes().routes,
      ),
    );
  }
}
