import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // flutter map, not mapbox
import 'package:latlong2/latlong.dart';
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';//mapbox, not flutter map XD
//maybe just a model
class MarkerData {
  final LatLng position;
  final String imagePath;

  MarkerData({required this.position, required this.imagePath});
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapController? mapController;
  // // Danh sách dữ liệu marker
  // List<MarkerData> markersData = [
  //   MarkerData(
  //     position: LatLng(21.048196693832384, 105.80171964077277),
  //     imagePath: 'assets/img/child2.png',
  //   ),
  //   MarkerData(
  //     position: LatLng(21.046636636481633, 105.80199521683643),
  //     imagePath: 'assets/img/child3.png',
  //   ),
  //   // Bạn có thể thêm bao nhiêu marker tùy ý vào danh sách này
  // ];
  @override
  Widget build(BuildContext context) {
   return Scaffold(
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: const LatLng(21.048031, 105.800886),
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
            "https://api.mapbox.com/styles/v1/giangguot3/cm291zk5y00e101pi9rhj34ly/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiZ2lhbmdndW90MyIsImEiOiJjbTF5YnZtam4xNWN6MnFxMTdrdGd1bHpjIn0.fCi-Oaqy9w4MG-5LnTv0IA",
            additionalOptions: const {
              'accessToken': 'sk.eyJ1IjoiZ2lhbmdndW90MyIsImEiOiJjbTIyc3RuY2gwYmEyMnRwZ2l0bzR2NDN5In0.xEmo_nTtWds2CM1zfp0hUw',
              'id':'mapbox.mapbox-streets-v8',
            },

          ),
          MarkerLayer(
            markers: [
              Marker(point: LatLng(21.047380, 105.807170),
                  width: 40,
                  height: 40,

                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset('assets/img/child1.png')
                    ],
                  ))
            ],
          )

        ],
      ),
    );
  }
}
