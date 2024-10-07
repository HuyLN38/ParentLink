import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
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
// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Pass your access token to MapboxOptions so you can load a map
//   String ACCESS_TOKEN = 'sk.eyJ1IjoiZ2lhbmdndW90MyIsImEiOiJjbTF5b3JiMG4wMGZiMmpzamdqNzJiYmE1In0.R7n0GvDhNY7XXdXDz5S2qA';
//   MapboxOptions.setAccessToken(ACCESS_TOKEN);
//
//   // Define options for your camera
//   CameraOptions camera = CameraOptions(
//       center: Point(coordinates: Position(-98.0, 39.5)),
//       zoom: 2,
//       bearing: 0,
//       pitch: 0);
//
//   // Run your application, passing your CameraOptions to the MapWidget
//   runApp(MaterialApp(home: MapWidget(
//     cameraOptions: camera,
//   )));
// }