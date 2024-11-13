import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'dart:typed_data';
import '../child.dart';

class PointData {
  PointAnnotation? annotation;
  Point startPoint;
  Point endPoint;
  Uint8List imageData;
  Child child;

  PointData({
    this.annotation,
    required this.startPoint,
    required this.endPoint,
    required this.imageData,
    required this.child,
  });
}
