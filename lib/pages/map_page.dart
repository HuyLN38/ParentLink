import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapController? mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: const LatLng(51.5, -0.09),
          initialZoom: 13.0,
          minZoom: 5.0,
          maxZoom: 18.0,
          keepAlive: true,
          onTap: (tapPosition, point) {
            print('Tapped at $point');
          },
        ),
        children: [
          TileLayer(
            urlTemplate:
            "https://api.mapbox.com/styles/v1/giangguot3/cm22ra5pw008t01qv37439di3/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiZ2lhbmdndW90MyIsImEiOiJjbTF5YnZtam4xNWN6MnFxMTdrdGd1bHpjIn0.fCi-Oaqy9w4MG-5LnTv0IA",
            additionalOptions: const {
              'accessToken': 'sk.eyJ1IjoiZ2lhbmdndW90MyIsImEiOiJjbTIyc3RuY2gwYmEyMnRwZ2l0bzR2NDN5In0.xEmo_nTtWds2CM1zfp0hUw',
              'id':'mapbox.mapbox-streets-v8',
            },

          ),
        ],
      ),
    );
  }
}
