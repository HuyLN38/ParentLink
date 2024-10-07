import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

// String ACCESS_TOKEN = "sk.eyJ1IjoiZ2lhbmdndW90MyIsImEiOiJjbTF5b3JiMG4wMGZiMmpzamdqNzJiYmE1In0.R7n0GvDhNY7XXdXDz5S2qA";

class SchedulePage extends StatelessWidget {

  const SchedulePage({super.key});
  @override
  Widget build(BuildContext context) {
    String ACCESS_TOKEN = "sk.eyJ1IjoiZ2lhbmdndW90MyIsImEiOiJjbTF5b3JiMG4wMGZiMmpzamdqNzJiYmE1In0.R7n0GvDhNY7XXdXDz5S2qA";
    MapboxOptions.setAccessToken(ACCESS_TOKEN);
    CameraOptions camera = CameraOptions(
      center: Point(coordinates: Position(-98.0, 39.5)),
      zoom: 2,
      bearing: 0,
      pitch: 0,
    );


    return Scaffold(
      body: Center(
        child: MapWidget(
          cameraOptions: camera,
        )),
    );
  }
}