import 'dart:math';

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'dart:async';

class MapService {
  static const String accessToken =
      "sk.eyJ1IjoiZ2lhbmdndW90MyIsImEiOiJjbTJoajk4ZGkwOXZ4MmxzZGs1ZTRscGptIn0.fTc_YMFgc3OmZA0rP7RIBg";
  static const double initialLongitude = 105.800886;
  static const double initialLatitude = 21.048031;

  static CameraOptions getInitialCamera() {
    return CameraOptions(
      center: Point(coordinates: Position(initialLongitude, initialLatitude)),
      zoom: 12.0,
    );
  }

  static void flyToLocation(
      MapboxMap mapboxMap, double longitude, double latitude) {
    mapboxMap.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(longitude, latitude)),
        zoom: 17,
        bearing: 180,
        pitch: 30,
      ),
      MapAnimationOptions(duration: 2000, startDelay: 0),
    );
  }

  static Future<double> getScaledRadius(
      MapboxMap? mapboxMap, double baseRadius) async {
    if (mapboxMap == null) return baseRadius;

    CameraState cameraState = await mapboxMap.getCameraState();
    double? zoom = cameraState.zoom;
    double baseZoom = 16.0;
    double scaleFactor = pow(2, baseZoom - (zoom ?? 0)).toDouble();
    return baseRadius / scaleFactor;
  }
}
