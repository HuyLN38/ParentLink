import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:parent_link/utils/process_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../map_service.dart';
import '../model/child.dart';
import '../model/map/geofence_data.dart';
import '../model/map/point_data.dart';
import '../services/ChildrenProvider.dart';

// 'assets/img/child1.png'
// imageData

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  MapboxMap? mapboxMap;
  late PointAnnotationManager pointAnnotationManager;
  late CircleAnnotationManager circleAnnotationManager;
  final double initialLongitude = 105.800886;
  final double initialLatitude = 21.048031;
  late final ChildrenService _childrenService;
  late CameraOptions _cameraOptions;
  List<Child> children = [];
  List<PointData> points = [];
  List<GeofenceData> geofences = [];
  bool _isBarVisible = false;
  bool _isCreatingGeofence = false;
  Point? _selectedLocation;
  double _geofenceRadius = 100.0;
  final TextEditingController _geofenceNameController = TextEditingController();
  late AnimationController _animationController;
  late AnimationController _slideController;
  CircleAnnotation? _previewGeofence;
  PointAnnotation? pointAnnotation;
  @override
  void initState() {
    super.initState();
    _initializeMapbox();
    _setupControllers();
  }

  void _initializeMapbox() {
    _childrenService = ChildrenService(context);
    MapboxOptions.setAccessToken(MapService.accessToken);
    _loadImageData();
    _cameraOptions = CameraOptions(
      center: Point(coordinates: Position(initialLongitude, initialLatitude)),
      zoom: 12.0,
    );
  }

  void _setupControllers() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _slideController.dispose();
    _geofenceNameController.dispose();
    super.dispose();
  }

  void _onMapTap(MapContentGestureContext context) {
    if (_isCreatingGeofence) {
      print("OnTap coordinate: {${context.point.coordinates.lng}, ${context.point.coordinates.lat}}" +
          " point: {x: ${context.touchPosition.x}, y: ${context.touchPosition.y}}");

      setState(() {
        _selectedLocation = context.point;
        _updatePreviewGeofence();
      });
    }
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
    mapboxMap.annotations.createPointAnnotationManager().then((value) async {
      pointAnnotationManager = value;
      _fetchAndDisplayChildren();
    });

    mapboxMap.annotations.createCircleAnnotationManager().then((value) {
      circleAnnotationManager = value;
    });

    // Initialize circle annotation manager
    mapboxMap.annotations.createCircleAnnotationManager().then((value) {
      circleAnnotationManager = value;
    });
  }

  Future<double> _getScaledRadius() async {
    if (mapboxMap == null) return _geofenceRadius;

    // Get the current zoom level asynchronously
    CameraState cameraState = await mapboxMap!.getCameraState();
    double? zoom = cameraState.zoom;

    // Base scale at zoom level 16
    double baseZoom = 19.0;

    // Calculate the scale factor based on zoom difference
    // We use 2 as the base since map scale doubles/halves with each zoom level
    double scaleFactor = pow(2, baseZoom - (zoom ?? 0)).toDouble();

    // Apply the scale factor to the radius
    return _geofenceRadius / scaleFactor;
  }

  void _updatePreviewGeofence() async {
    if (_selectedLocation == null) return;

    double scaledRadius = await _getScaledRadius();

    CircleAnnotationOptions options = CircleAnnotationOptions(
      geometry: _selectedLocation!,
      circleRadius: scaledRadius,
      circleColor: const Color(0xFF4285F4).value,
      circleOpacity: 0.2,
      circleStrokeWidth: 1,
      circleStrokeColor: const Color(0xFF0066CC).value,
    );

    if (_previewGeofence != null) {
      _previewGeofence!.geometry = _selectedLocation!;
      _previewGeofence!.circleRadius = scaledRadius;
      await circleAnnotationManager.update(_previewGeofence!);
    } else {
      _previewGeofence = await circleAnnotationManager.create(options);
    }
  }

  Future<void> _saveGeofence() async {
    if (_selectedLocation == null || _geofenceNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a location and enter a name')),
      );
      return;
    }

    final geofence = GeofenceData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _geofenceNameController.text,
      center: _selectedLocation!,
      radius: _geofenceRadius,
    );

    double scaledRadius = await _getScaledRadius();

    CircleAnnotationOptions options = CircleAnnotationOptions(
      geometry: geofence.center,
      circleRadius: scaledRadius,
      circleColor: const Color(0xFF4285F4).value,
      circleOpacity: 0.5,
      circleStrokeWidth: 2,
      circleStrokeColor: const Color(0xFF0066CC).value,
    );

    geofence.annotation = await circleAnnotationManager.create(options);

    setState(() {
      geofences.add(geofence);
      _isCreatingGeofence = false;
      _clearGeofencePreview();
    });
  }

  void _toggleGeofenceCreation() {
    setState(() {
      _isCreatingGeofence = !_isCreatingGeofence;
      if (!_isCreatingGeofence) {
        _clearGeofencePreview();
      }
    });
  }

  void _clearGeofencePreview() {
    if (_previewGeofence != null) {
      circleAnnotationManager.delete(_previewGeofence!);
      _previewGeofence = null;
    }
    // _selectedLocation = Point(coordinates: Position(0, 0));
    _selectedLocation = null;
    _geofenceRadius = 100.0;
    _geofenceNameController.clear();
    setState(() {
      _isCreatingGeofence = false;
    });
  }

  Widget _buildGeofenceControls() {
    if (!_isCreatingGeofence) return Container();

    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _geofenceNameController,
              decoration: const InputDecoration(
                labelText: 'Geofence Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text('Radius: ${_geofenceRadius.toStringAsFixed(0)} meters'),
            Slider(
              value: _geofenceRadius,
              min: 50,
              max: 1000,
              divisions: 20,
              onChanged: (value) {
                setState(() {
                  _geofenceRadius = value;
                  _updatePreviewGeofence();
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _clearGeofencePreview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _saveGeofence,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Save Geofence'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleBar() {
    setState(() {
      _isBarVisible = !_isBarVisible;
    });
  }

  Widget _buildSwipeDetector({required Widget child}) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          // Swipe left (hide)
          if (details.primaryVelocity! < -300 && _isBarVisible) {
            _toggleBar();
          }
          // Swipe right (show)
          else if (details.primaryVelocity! > 300 && !_isBarVisible) {
            _toggleBar();
          }
        }
      },
      child: child,
    );
  }

  void _flyToChild(Child child) {
    mapboxMap?.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(child.longitude, child.latitude)),
        zoom: 17,
        bearing: 180,
        pitch: 30,
      ),
      MapAnimationOptions(duration: 2000, startDelay: 0),
    );
  }

  Widget _buildChildAvatar(Child child, PointData point) {
    return GestureDetector(
      onTap: () => _flyToChild(child),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.memory(
            point.imageData,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalBar() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      left: _isBarVisible ? 16 : -80,
      // Hide off screen when not visible
      top: 50,
      child: _buildSwipeDetector(
        child: Container(
          width: 70,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(children.length, (index) {
              final child = children[index];
              final point = points[index];
              return _buildChildAvatar(child, point); 
            }),
          )
        ),
      ),
    );
  }

  Widget _buildSwipeIndicator() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      left: _isBarVisible ? -30 : 0,
      top: 50,
      child: GestureDetector(
        onTap: _toggleBar,
        child: Container(
          width: 30,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                const BorderRadius.horizontal(right: Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            _isBarVisible ? Icons.chevron_left : Icons.chevron_right,
            color: Colors.grey,
          ),
        ),
      ),
    );
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

      children = (await _childrenService.fetchChildren(parentId));
      print('Number of children: ${children.length}');
      final directory = await getApplicationDocumentsDirectory();
      points.clear();

      for (var child in children) {
        final file = File('${directory.path}/avatars/${child.childId}.jpg');

        final Point childPoint =
            Point(coordinates: Position(child.longitude, child.latitude));

        Uint8List imageData = file.existsSync()
            ? await file.readAsBytes()
            : await rootBundle.load('assets/img/child1.png').then((data) {
                file.createSync(recursive: true);
                file.writeAsBytesSync(data.buffer.asUint8List());
                return data.buffer.asUint8List();
              });

        imageData = await ImageProcess.processImage(imageData);

        points.add(PointData(
          startPoint: childPoint,
          endPoint: childPoint,
          imageData: imageData,
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
            (await _childrenService.fetchChildren(parentId));

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            MapWidget(
              key: const ValueKey("mapWidget"),
              textureView: true,
              onMapCreated: _onMapCreated,
              cameraOptions: _cameraOptions,
              onTapListener: _onMapTap,
              onCameraChangeListener: _onCameraChangeListener,
            ),
            _buildVerticalBar(),
            _buildSwipeIndicator(),
            _buildGeofenceControls(),
            Positioned(
              top: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: _toggleGeofenceCreation,
                backgroundColor: _isCreatingGeofence ? Colors.red : Colors.blue,
                child: Icon(
                    _isCreatingGeofence ? Icons.close : Icons.add_location),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onCameraChangeListener(CameraChangedEventData data) {
    if (_previewGeofence != null) {
      _updatePreviewGeofence();
    }
    // Update all existing geofences
    for (var geofence in geofences) {
      if (geofence.annotation != null) {
        geofence.annotation!.circleRadius = geofence.radius;
        circleAnnotationManager.update(geofence.annotation!);
      }
    }
  }
}
