import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class GeofenceData {
  String id;
  String name;
  Point center;
  double radius; // in meters
  CircleAnnotation? annotation;

  GeofenceData({
    required this.id,
    required this.name,
    required this.center,
    required this.radius,
    this.annotation,
  });
}
