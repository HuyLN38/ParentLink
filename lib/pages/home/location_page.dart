import 'dart:io';

import 'package:flutter/material.dart';
import 'package:parent_link/builder/child_location_tile.dart';
import 'package:parent_link/model/child/child_state.dart';
import 'package:parent_link/model/control/control_child_location.dart';
import 'package:parent_link/theme/app.theme.dart';
import 'package:provider/provider.dart';

class LocationPage extends StatelessWidget {
  final ChildState childState;

  LocationPage({super.key, required this.childState});

  @override
  Widget build(BuildContext context) {
    //access child' location list
    final childStateList =
        context.watch<ControlChildLocation>().getChildLocationList;
    return Scaffold(
      backgroundColor: Apptheme.colors.white,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      // ),
      body: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/img/map.jpg',
                height: 300,
                fit: BoxFit.fill,
              )),

          //turn back icom
          Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: EdgeInsets.only(top: 18),
                child: IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/main_page');
                  },
                  icon: Icon(Icons.chevron_left),
                  iconSize: 40,
                  color: Apptheme.colors.gray,
                ),
              )),

          //location button
          Positioned(
            top: 200,
            right: 0,
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Apptheme.colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: GestureDetector(
                onTap: () {},
                child: Image.asset(
                  'assets/img/position.png',
                  height: 30,
                ),
              ),
            ),
          ),
          Positioned(
              top: 280,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Apptheme.colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 60,
                    ),
                    //name
                    Text(
                      childState.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                      ),
                    ),
                    //current activity
                    Text(
                      'Located on the Viking',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Apptheme.colors.gray,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    //show more actions
                    Text(
                      'Show previous actions',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Apptheme.colors.orage,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )),
          //avatar
          Positioned(
            top: 230,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Apptheme.colors.white,
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: childState.avatarPath != null
                      ? FileImage(File(childState.avatarPath!))
                      : AssetImage(ChildState.defaultImage) as ImageProvider,
                ),
              ),
            ),
          ),

          //show list of location
          Positioned(
            top: 430,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Column(
                children: childStateList.map((childLocation) {
                  return ChildLocationTile(childLocation: childLocation);
                }).toList(),
              ),
            ),
          ),

          //call and message button
          Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  // call button
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Apptheme.colors.black,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 3,
                          offset: Offset(0, 1), // changes position of shadow
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        //do sth
                      },
                      icon: Icon(Icons.phone),
                      color: Apptheme.colors.white,
                      iconSize: 20,
                    ),
                  ),

                  Spacer(),

                  //send message button
                  Container(
                    decoration: BoxDecoration(
                      color: Apptheme.colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 3,
                          offset: Offset(0, 1), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 60.0, vertical: 15),
                      child: Row(
                        children: [
                          Icon(
                            Icons.mail,
                            color: Apptheme.colors.black,
                            size: 25,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Text(
                            'Send message',
                            style: TextStyle(
                                color: Apptheme.colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          )
                        ],
                      ),
                    ),
                  ),
                  Spacer(),
                ],
              ))
        ],
      ),
    );
  }
}
