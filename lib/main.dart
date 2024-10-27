import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:parent_link/firebase_options.dart';
import 'package:parent_link/model/control/control_child_location.dart';
import 'package:parent_link/model/control/control_child_state.dart';
import 'package:parent_link/routes/routes.dart';
import 'package:provider/provider.dart';
import 'package:parent_link/pages/open_page.dart';
import 'package:parent_link/pages/main_page.dart'; // Import your MainPage
import 'package:shared_preferences/shared_preferences.dart'; // Add this import for SharedPreferences

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

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
