import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';//mapbox, not flutter map XD
import 'dart:io';
class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  State createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late CameraOptions _cameraOptions;
  MapboxMap? mapboxMap;
  late String styleJson;

  //onMapCreated
  void _onMapCreated(MapboxMap mapboxMap) {
    // mapboxMap.clearData();

    this.mapboxMap = mapboxMap;
    mapboxMap.style;

    styleJson = rootBundle.loadString('assets/style.json') as String;
    mapboxMap.loadStyleJson(styleJson);
    // mapboxMap.loadStyleURI("mapbox://styles/giangguot3/cm291zk5y00e101pi9rhj34ly");
    // mapboxMap.loadStyleURI("mapbox://styles/giangguot3/cm2hjmf0s000o01qr9evb4i63");
    // await mapboxMap.loadStyleURI('mapbox://styles/mapbox/light-v10');
    // mapboxMap.loadStyleURI(MapboxStyles.LIGHT);


  }
  @override
  void initState() {
    super.initState();

    //old access token
    // String accessToken = "sk.eyJ1IjoiZ2lhbmdndW90MyIsImEiOiJjbTIyc3RuY2gwYmEyMnRwZ2l0bzR2NDN5In0.xEmo_nTtWds2CM1zfp0hUw";
    //new access token with all permissions applied
    String accessToken = 'sk.eyJ1IjoiZ2lhbmdndW90MyIsImEiOiJjbTJoajk4ZGkwOXZ4MmxzZGs1ZTRscGptIn0.fTc_YMFgc3OmZA0rP7RIBg';
    MapboxOptions.setAccessToken(accessToken);



    //camera option
    _cameraOptions = CameraOptions(
      //long-lat not lat-long
      //location of Hà Nội
      center: Point(coordinates: Position(105.800886,21.048031)),
      zoom: 12.0,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapWidget(
        key: const ValueKey("mapWidget"),
        // styleUri: MapboxStyles.MAPBOX_STREETS,

        textureView: true,
        onMapCreated: _onMapCreated,
        cameraOptions: _cameraOptions,
        //if above _onMapCreated an URI has already been set, there is no need to set it here


        // styleUri: MapboxStyles.DARK,


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
