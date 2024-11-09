 import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:parent_link/model/Child.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/ChildrenProvider.dart';
import '../services/ChildrenService.dart'; //mapbox, not flutter map XD

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  State createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late CameraOptions _cameraOptions;
  MapboxMap? mapboxMap;
  late String styleJson;
  PointAnnotationManager? _pointAnnotationManager;
  CircleAnnotationManager? _circleAnnotationManager;
  late final ChildrenService _childrenService;
  List<Child> children = [];
  Timer? _timer;
  void _displayRippleEffect(double lat, double lng) {
    mapboxMap?.annotations.createCircleAnnotationManager().then((manager) async {
      _circleAnnotationManager = manager;

      Timer.periodic(const Duration(milliseconds: 100), (timer) async {
        for (var child in children) {
          final circleOptions = CircleAnnotationOptions(
            geometry: Point(coordinates: Position(lng, lat)),
            circleRadius: timer.tick % 20 + 5,
            circleStrokeColor: Colors.red.value,
            circleStrokeWidth: 2.0,
            circleColor: Colors.transparent.value, // Để rỗng bên trong
          );

          await manager.create(circleOptions);

        }
      });
    });
  }
  //onMapCreated
  void _onMapCreated(MapboxMap mapboxMap) {
    // mapboxMap.clearData();

    this.mapboxMap = mapboxMap;
    // mapboxMap.loadStyleURI("mapbox://styles/giangguot3/cm291zk5y00e101pi9rhj34ly");
    // mapboxMap.loadStyleURI("mapbox://styles/giangguot3/cm2hjmf0s000o01qr9evb4i63");
    // await mapboxMap.loadStyleURI('mapbox://styles/mapbox/light-v10');
    // mapboxMap.loadStyleURI(MapboxStyles.LIGHT);
    //api call
    // _fetchAndDisplayChildren();
    // initMarker();
    //
    mapboxMap.loadStyleURI("mapbox://styles/giangguot3/cm2hjmf0s000o01qr9evb4i63").then((_) {
      _fetchAndDisplayChildren();
    }).catchError((e) {
      print('Error loading style: $e');
    });
  }
  void _displayChildrenOnMap(List<Child> children) {
    mapboxMap?.annotations.createPointAnnotationManager().then((value) async {
      _pointAnnotationManager = value;
      for (var child in children) {
        final lng = child.longitude;
        final lat = child.latitude;
        final ByteData bytes = await rootBundle.load('assets/img/child1.png');
        final Uint8List imageData = bytes.buffer.asUint8List();
        final options = PointAnnotationOptions(
          geometry: Point(coordinates: Position(lng, lat)),
          image: imageData,
          iconSize: 1,
        );

        await value.create(options);
        _displayRippleEffect(lat, lng);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    //old access token
    // String accessToken = "sk.eyJ1IjoiZ2lhbmdndW90MyIsImEiOiJjbTIyc3RuY2gwYmEyMnRwZ2l0bzR2NDN5In0.xEmo_nTtWds2CM1zfp0hUw";
    //new access token with all permissions applied
    String accessToken =
        'sk.eyJ1IjoiZ2lhbmdndW90MyIsImEiOiJjbTJoajk4ZGkwOXZ4MmxzZGs1ZTRscGptIn0.fTc_YMFgc3OmZA0rP7RIBg';
    MapboxOptions.setAccessToken(accessToken);
    _childrenService = ChildrenService(context);
    //camera option
    _cameraOptions = CameraOptions(
      //long-lat not lat-long
      //location of Hà Nội
      center: Point(coordinates: Position(105.800886, 21.048031)),
      zoom: 12.0,
    );
    // _fetchAndDisplayChildren();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _fetchAndDisplayChildren();
    });
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  void _fetchAndDisplayChildren() async {
    try {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      String parentId = sharedPreferences.getString('token') ?? '';
      // children = await _childrenService.fetchChildren('yuHoQl6tnnXQgLTJ6yK2C6ut1iY2');
      children = await _childrenService.fetchChildren(parentId);
      print(children);

      _displayChildrenOnMap(children);
    } catch (e) {
      print('Error fetching children: $e');
    }
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

