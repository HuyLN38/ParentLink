import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/Child.dart';
import '../services/ChildrenProvider.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State createState() => _MapPageState();
}

class PointData {
  PointAnnotation? annotation;
  Point startPoint;
  Point endPoint;
  Uint8List imageData;
  Child child; // Add reference to child data

  PointData({
    this.annotation,
    required this.startPoint,
    required this.endPoint,
    required this.imageData,
    required this.child,
  });
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  late CameraOptions _cameraOptions;
  MapboxMap? mapboxMap;
  late PointAnnotationManager pointAnnotationManager;
  late final ChildrenService _childrenService;
  List<Child> children = [];
  List<PointData> points = [];

  final double initialLongitude = 105.800886;
  final double initialLatitude = 21.048031;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _loadImageData();
    _childrenService = ChildrenService(context);
    String accessToken =
        "sk.eyJ1IjoiZ2lhbmdndW90MyIsImEiOiJjbTJoajk4ZGkwOXZ4MmxzZGs1ZTRscGptIn0.fTc_YMFgc3OmZA0rP7RIBg";
    MapboxOptions.setAccessToken(accessToken);
    _cameraOptions = CameraOptions(
      center: Point(coordinates: Position(initialLongitude, initialLatitude)),
      zoom: 12.0,
    );
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadImageData() async {
    final ByteData defaultData = await rootBundle.load('assets/img/child1.png');
    setState(() {
      points = [];
    });
  }

  Future<void> _fetchAndDisplayChildren() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String parentId = sharedPreferences.getString('token') ?? '';
      print(parentId);

      children = await _childrenService.fetchChildren(parentId);
      points.clear();

      for (var child in children) {
        final ByteData imageData =
            await rootBundle.load('assets/img/child1.png');

        final Point childPoint =
            Point(coordinates: Position(child.longitude, child.latitude));

        points.add(PointData(
          startPoint: childPoint,
          endPoint: childPoint,
          imageData: imageData.buffer.asUint8List(),
          child: child,
        ));
      }
      if (pointAnnotationManager != null) {
        for (var point in points) {
          PointAnnotationOptions pointAnnotationOptions =
              PointAnnotationOptions(
            geometry: point.startPoint,
            image: point.imageData,
            iconSize: 1.25,
          );

          point.annotation =
              await pointAnnotationManager.create(pointAnnotationOptions);
        }

        if (children.isNotEmpty) {
          _startChildrenUpdates();
        }
      }
    } catch (e) {
      print('Error fetching children: $e');
    }
  }

  void _startChildrenUpdates() async {
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        String parentId = sharedPreferences.getString('token') ?? '';

        List<Child> updatedChildren =
            await _childrenService.fetchChildren(parentId);

        // Update positions for existing points
        for (var point in points) {
          // Find corresponding updated child
          var updatedChild = updatedChildren.firstWhere(
            (child) => child.childId == point.child.childId,
            orElse: () => point.child,
          );

          // Update start and end points
          point.startPoint = point.annotation!.geometry;
          point.endPoint = Point(
              coordinates:
                  Position(updatedChild.longitude, updatedChild.latitude));

          // Update child data
          point.child = updatedChild;
        }

        // Animate all points to their new positions
        await Future.wait(
          points.map((point) => animatePointAnnotation(point)),
        );
      } catch (e) {
        print('Error updating children positions: $e');
      }
    });
  }

  Future<void> animatePointAnnotation(PointData point) async {
    if (point.startPoint.coordinates.lat == point.endPoint.coordinates.lat &&
        point.startPoint.coordinates.lng == point.endPoint.coordinates.lng) {
      return; // Skip animation if position hasn't changed
    }

    _animationController.stop();
    _animationController.reset();
    final animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    final completer = Completer<void>();

    void animationListener() {
      final newLat = point.startPoint.coordinates.lat +
          (point.endPoint.coordinates.lat - point.startPoint.coordinates.lat) *
              animation.value;
      final newLon = point.startPoint.coordinates.lng +
          (point.endPoint.coordinates.lng - point.startPoint.coordinates.lng) *
              animation.value;

      setState(() {
        point.annotation!.geometry =
            Point(coordinates: Position(newLon, newLat));
        pointAnnotationManager.update(point.annotation!);
      });

      if (animation.isCompleted && !completer.isCompleted) {
        completer.complete();
        animation.removeListener(animationListener);
      }
    }

    animation.addListener(animationListener);

    _animationController.forward(from: 0.0).whenComplete(() {
      if (!completer.isCompleted) {
        completer.complete();
        animation.removeListener(animationListener);
      }
    });

    await completer.future;
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
    mapboxMap.annotations.createPointAnnotationManager().then((value) async {
      pointAnnotationManager = value;
      _fetchAndDisplayChildren(); // Fetch and display children once map is ready
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: MapWidget(
          key: const ValueKey("mapWidget"),
          textureView: true,
          onMapCreated: _onMapCreated,
          cameraOptions: _cameraOptions,
        ),
      ),
    );
  }
}
