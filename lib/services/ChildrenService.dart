import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:parent_link/model/Child.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  State createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late CameraOptions _cameraOptions;
  MapboxMap? mapboxMap;
  PointAnnotationManager? _pointManager;
  CircleAnnotationManager? _rippleManager;
  final Map<String, Child> _children = {};
  final Map<String, Position> _targetPositions = {};
  final Map<String, Position> _currentPositions = {};
  Timer? _animationTimer;
  Timer? _targetUpdateTimer;
  bool _isDisposed = false;
  final math.Random _random = math.Random();
  Uint8List? _cachedImageData;

  // Constants for smoother animation
  final double _movementRadius = 0.002; // Increased range
  final int _fps = 60;
  final int _targetUpdateInterval = 5000; // New target every 5 seconds
  final double _speedFactor = 3.0; // Adjust this to change movement speed

  void _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
    mapboxMap
        .loadStyleURI("mapbox://styles/giangguot3/cm2hjmf0s000o01qr9evb4i63")
        .then((_) => _initializeManagers())
        .catchError((e) => print('Error loading style: $e'));
  }

  Future<void> _initializeManagers() async {
    _pointManager = await mapboxMap?.annotations.createPointAnnotationManager();
    _rippleManager =
        await mapboxMap?.annotations.createCircleAnnotationManager();

    final ByteData bytes = await rootBundle.load('assets/img/child1.png');
    _cachedImageData = bytes.buffer.asUint8List();

    _initializeTestData();
    _startAnimations();
  }

  void _initializeTestData() {
    // Create test children at different positions around Hanoi
    final List<Map<String, dynamic>> testData = [
      {'id': 'child1', 'base_lat': 21.048031, 'base_lng': 105.800886},
      {'id': 'child2', 'base_lat': 21.046000, 'base_lng': 105.802000},
      {'id': 'child3', 'base_lat': 21.050000, 'base_lng': 105.798000},
    ];

    for (var data in testData) {
      String id = data['id'];
      double baseLat = data['base_lat'];
      double baseLng = data['base_lng'];

      // Create child object
      _children[id] = Child(
        childId: id,
        name: "Test Child ${id.substring(5)}",
        birthday: "2010-01-01",
        lastModified: DateTime.now().toString(),
        lastSeen: DateTime.now().toString(),
        phone: "1234567890",
        latitude: baseLat,
        longitude: baseLng,
      );

      // Set initial positions
      _currentPositions[id] = Position(baseLng, baseLat);
      _targetPositions[id] = _getNewTargetPosition(Position(baseLng, baseLat));
    }
  }

  Position _getNewTargetPosition(Position currentPos) {
    double angle = _random.nextDouble() * 2 * math.pi;
    double distance = _movementRadius * (0.5 + _random.nextDouble() * 0.5);

    return Position(currentPos.lng + distance * math.cos(angle),
        currentPos.lat + distance * math.sin(angle));
  }

  void _startAnimations() {
    _animationTimer?.cancel();
    _targetUpdateTimer?.cancel();

    // Smooth movement animation at 60 FPS
    _animationTimer = Timer.periodic(Duration(milliseconds: 1000 ~/ _fps), (_) {
      if (!_isDisposed) _updatePositions();
    });

    // Update targets periodically
    _targetUpdateTimer =
        Timer.periodic(Duration(milliseconds: _targetUpdateInterval), (_) {
      if (!_isDisposed) _updateTargets();
    });
  }

  void _updateTargets() {
    _children.forEach((id, _) {
      _targetPositions[id] = _getNewTargetPosition(_currentPositions[id]!);
    });
  }

  void _updatePositions() {
    bool needsUpdate = false;

    _children.forEach((id, child) {
      Position current = _currentPositions[id]!;
      Position target = _targetPositions[id]!;

      // Calculate step size based on distance and speed
      double stepSize = _speedFactor / _fps;

      // Move towards target
      double newLng =
          _moveTowards(current.lng.toDouble(), target.lng.toDouble(), stepSize);
      double newLat =
          _moveTowards(current.lat.toDouble(), target.lat.toDouble(), stepSize);

      if (newLng != current.lng || newLat != current.lat) {
        _currentPositions[id] = Position(newLng, newLat);
        needsUpdate = true;
      }
    });

    if (needsUpdate) {
      _updateAnnotations();
    }
  }

  double _moveTowards(double current, double target, double stepSize) {
    double diff = target - current;
    if (diff.abs() < stepSize) {
      return target;
    }
    return current + stepSize * diff.sign;
  }

  void _updateAnnotations() async {
    if (_pointManager == null || _cachedImageData == null) return;

    // Update points
    await _pointManager!.deleteAll();
    List<PointAnnotationOptions> pointOptions = [];

    _children.forEach((id, child) {
      Position pos = _currentPositions[id]!;
      pointOptions.add(PointAnnotationOptions(
        geometry: Point(coordinates: pos),
        image: _cachedImageData!,
        iconSize: 1,
      ));
    });

    await _pointManager!.createMulti(pointOptions);

    // Update ripples
    await _rippleManager!.deleteAll();
    List<CircleAnnotationOptions> rippleOptions = [];

    final double progress =
        (DateTime.now().millisecondsSinceEpoch / 2000) % 1.0;

    _children.forEach((id, child) {
      Position pos = _currentPositions[id]!;
      for (int i = 0; i < 2; i++) {
        double phase = i * 0.5;
        double currentProgress = (progress + phase) % 1.0;
        double fadeOut = math.sin(currentProgress * math.pi);

        rippleOptions.add(CircleAnnotationOptions(
          geometry: Point(coordinates: pos),
          circleRadius: 12.0 * currentProgress + 3,
          circleStrokeColor: Colors.blue.withOpacity(0.4).value,
          circleStrokeWidth: 1.0 * fadeOut,
          circleColor: Colors.transparent.value,
          circleOpacity: 0.3 * fadeOut,
        ));
      }
    });

    if (rippleOptions.isNotEmpty) {
      await _rippleManager!.createMulti(rippleOptions);
    }
  }

  @override
  void initState() {
    super.initState();
    String accessToken =
        'sk.eyJ1IjoiZ2lhbmdndW90MyIsImEiOiJjbTJoajk4ZGkwOXZ4MmxzZGs1ZTRscGptIn0.fTc_YMFgc3OmZA0rP7RIBg';
    MapboxOptions.setAccessToken(accessToken);
    _cameraOptions = CameraOptions(
      center: Point(coordinates: Position(105.800886, 21.048031)),
      zoom: 12.0,
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _animationTimer?.cancel();
    _targetUpdateTimer?.cancel();
    _pointManager?.deleteAll();
    _rippleManager?.deleteAll();
    super.dispose();
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
