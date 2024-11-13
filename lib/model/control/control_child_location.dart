import 'package:flutter/material.dart';
import 'package:parent_link/model/child/child_location.dart';

class ControlChildLocation extends ChangeNotifier {
  List<ChildLocation> childLocationList = [
    ChildLocation('Viking', '13:00', 'null', 'active'),
    ChildLocation('School', '8:00', '12:00', 'null'),
    ChildLocation('On Road', '7:00', ' 7:30', 'null'),
    ChildLocation('Home', '0:00', ' 7:30', 'null'),
    ChildLocation('School', '8:00', '12:00', 'null'),
    ChildLocation('On Road', '7:00', ' 7:30', 'null'),
    ChildLocation('Home', '0:00', ' 7:30', 'null'),
    ChildLocation('School', '8:00', '12:00', 'null'),
    ChildLocation('On Road', '7:00', ' 7:30', 'null'),
    ChildLocation('Home', '0:00', ' 7:30', 'null'),
  ];
  List<ChildLocation> get getChildLocationList => childLocationList;
}
