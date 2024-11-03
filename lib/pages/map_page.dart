import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:parent_link/model/Child.dart';
import 'package:provider/provider.dart';

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
  List<dynamic> Coordinates = [
    {'id': 1, 'lng': 105.8342, 'lat': 21.0278},
    {'id': 2, 'lng': 106.68028, 'lat': 20.86194},
    {'id': 3, 'lng': 106.31250, 'lat': 20.93972},
    {'id': 4, 'lng': 106.16833, 'lat': 20.42000},
    {'id': 5, 'lng': 106.33750, 'lat': 20.44750},
    {'id': 6, 'lng': 106.05639, 'lat': 21.18528},
  ];
  List<Child> hardcodedChildren = [
    Child(
      childId: '1',
      name: 'Child 1',
      birthday: '2004-08-03T00:00:00Z',
      lastModified: '2024-11-03T02:07:54.969393Z',
      lastSeen: '2024-11-03T04:03:25.238858Z',
      phone: '0886058834',
      longitude: 105.8342,
      latitude: 21.0278,
      speed: 1,
      battery: 0,
    ),
    Child(
      childId: '2',
      name: 'Child 2',
      birthday: '2004-08-03T00:00:00Z',
      lastModified: '2024-11-03T02:07:54.969393Z',
      lastSeen: '2024-11-03T04:03:25.238858Z',
      phone: '0886058834',
      longitude: 106.68028,
      latitude: 20.86194,
      speed: 1,
      battery: 0,
    ),
    // Add more hardcoded children as needed
  ];
  //onMapCreated
  void _onMapCreated(MapboxMap mapboxMap) {
    // mapboxMap.clearData();

    this.mapboxMap = mapboxMap;
    // mapboxMap.loadStyleURI("mapbox://styles/giangguot3/cm291zk5y00e101pi9rhj34ly");
    mapboxMap.loadStyleURI("mapbox://styles/giangguot3/cm2hjmf0s000o01qr9evb4i63");
    // await mapboxMap.loadStyleURI('mapbox://styles/mapbox/light-v10');
    // mapboxMap.loadStyleURI(MapboxStyles.LIGHT);
    //api call
    // _fetchAndDisplayChildren();
    initMarker();
    // _displayChildrenOnMap(hardcodedChildren);
  }
  // void _displayChildrenOnMap(List<Child> children) {
  //   mapboxMap?.annotations.createPointAnnotationManager().then((value) async {
  //     _pointAnnotationManager = value;
  //     for (var child in children) {
  //       final lng = child.longitude;
  //       final lat = child.latitude;
  //
  //       final options = PointAnnotationOptions(
  //         geometry: Point(coordinates: Position(lng, lat)),
  //         iconImage: 'assets/img/child1.png',
  //         iconSize: 2.5,
  //       );
  //
  //       await value.create(options);
  //     }
  //   });
  // }
  // void initMarker() {
  //   mapboxMap?.annotations.createPointAnnotationManager().then((value) async {
  //   _pointAnnotationManager = value;
  //
  //     const lng = 105.800886;
  //     const lat = 21.048031;
  //
  //     final options = PointAnnotationOptions(
  //       geometry: Point(coordinates: Position(lng, lat)),
  //       // iconImage: 'assets/img/child1.png',
  //       iconColor: Colors.pink.value,
  //       iconSize: 3.0,
  //     );
  //
  //
  //     await value.create(options);
  //   });
  // }
  void initMarker() {
    mapboxMap?.annotations.createPointAnnotationManager().then((value) async {
      _pointAnnotationManager = value;
      for (var coordinate in Coordinates) {
        final id = coordinate['id'];
        final lng = coordinate['lng'];
        final lat = coordinate['lat'];

        final options = PointAnnotationOptions(
          geometry: Point(coordinates: Position(lng, lat)),
          iconImage: 'assets/img/child2.png',
          iconSize: 6,
        );

        await value.create(options);
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
  }

  // void _fetchAndDisplayChildren() async {
  //   try {
  //     final children = await _childrenService.fetchChildren('jdZxbcPW7EWIlmAOLgSdAfdV09C3');
  //     // _displayChildrenOnMap(children);
  //   } catch (e) {
  //     print('Error fetching children: $e');
  //   }
  // }
  // void _displayChildrenOnMap(List<Child> children) {
  //   mapboxMap?.annotations.createPointAnnotationManager().then((value) async {
  //     _pointAnnotationManager = value;
  //     for (var child in children) {
  //       final lng = child.longitude;
  //       final lat = child.latitude;
  //
  //       final options = PointAnnotationOptions(
  //         geometry: Point(coordinates: Position(lng, lat)),
  //         iconImage: 'assets/img/child1.png',
  //       );
  //
  //       await value.create(options);
  //     }
  //   });
  // }
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


//old
// @override
// Widget build(BuildContext context) {
//  return Scaffold(
//     body: FlutterMap(
//       mapController: mapController,
//       options: MapOptions(
//         initialCenter: const LatLng(21.048031, 105.800886),
//         initialZoom: 13.0,
//         minZoom: 5.0,
//         maxZoom: 18.0,
//         keepAlive: true,
//         onTap: (tapPosition, point) {
//           print('Tapped at $point');
//         },
//       ),
//       children: [
//         TileLayer(
//           urlTemplate:
//           "https://api.mapbox.com/styles/v1/giangguot3/cm291zk5y00e101pi9rhj34ly/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiZ2lhbmdndW90MyIsImEiOiJjbTF5YnZtam4xNWN6MnFxMTdrdGd1bHpjIn0.fCi-Oaqy9w4MG-5LnTv0IA",
//           additionalOptions: const {
//             'accessToken': 'sk.eyJ1IjoiZ2lhbmdndW90MyIsImEiOiJjbTIyc3RuY2gwYmEyMnRwZ2l0bzR2NDN5In0.xEmo_nTtWds2CM1zfp0hUw',
//             'id':'mapbox.mapbox-streets-v8',
//           },
//
//         ),
//         MarkerLayer(
//           markers: [
//             Marker(point: LatLng(21.047380, 105.807170),
//                 width: 40,
//                 height: 40,
//
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     Image.asset('assets/img/child1.png')
//                   ],
//                 ))
//           ],
//         )
//
//       ],
//     ),
//   );
// }
