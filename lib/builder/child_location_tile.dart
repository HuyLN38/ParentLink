import 'package:flutter/material.dart';
import 'package:parent_link/model/child_location.dart';
import 'package:parent_link/theme/app.theme.dart';

class ChildLocationTile extends StatelessWidget {
  final ChildLocation childLocation;
  const ChildLocationTile({super.key, required this.childLocation});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: childLocation.active != 'null' ? Apptheme.colors.black.withOpacity(0.3) : Colors.transparent,
          width: 1,
        ),
      boxShadow: [ 
        if(childLocation.active != 'null')   
        BoxShadow(
          color: Colors.black.withOpacity(0.24), 
          offset: Offset(0, 3), 
          blurRadius: 8, 
          spreadRadius: 0, 
        ),
        
      ],
      color: childLocation.active == 'null' ? Apptheme.colors.gray_light: Apptheme.colors.white,
        borderRadius: BorderRadius.circular(8)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: [
          Row(
            children: [
              // Icon location
              Container(
                decoration: BoxDecoration(
                  color: childLocation.active == 'null' ? Apptheme.colors.gray:Apptheme.colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: childLocation.active == 'null' ? Apptheme.colors.gray:Apptheme.colors.orage, 
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(8), 
                child: Icon(
                  Icons.location_on_outlined,
                  color:childLocation.active == 'null' ? Apptheme.colors.black: Apptheme.colors.blue,
                ),
              ),
              const SizedBox(width: 10),
              // Location and time
              Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Text(
                    childLocation.location,
                    style: TextStyle(
                      color: childLocation.active == 'null' ? Apptheme.colors.gray: Apptheme.colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${childLocation.timeStart} - ${childLocation.active == 'null' ? childLocation.timeEnd : childLocation.active}',
                    style: TextStyle(
                      fontSize: 16,
                      color: childLocation.active == 'null' ?Apptheme.colors.black: Apptheme.colors.gray,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Icon arrow_forward
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.arrow_forward_ios,
              color: Apptheme.colors.gray,
            ),
          ),
        ],
      ),
    );
  }
}
