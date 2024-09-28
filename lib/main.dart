import 'package:flutter/material.dart';
import 'package:parent_link/model/control/control_child_location.dart';
import 'package:parent_link/model/control/control_child_state.dart';
import 'package:parent_link/routes/routes.dart';
import 'package:provider/provider.dart'; 
import 'package:parent_link/pages/open_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ControlChildState()),
        ChangeNotifierProvider(create: (_) => ControlChildLocation()),

      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: OpenPage(),
        routes: Routes().routes,
      ),
    );
  }
}
