import 'package:flutter/material.dart';
import 'package:parent_link/model/child/child_location.dart';
import 'package:parent_link/theme/app.theme.dart';

class ChildLocationTile extends StatelessWidget {
  final ChildLocation childLocation;
  final bool isFirstElement;

  const ChildLocationTile({
    super.key,
    required this.childLocation,
    required this.isFirstElement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: isFirstElement
          ? const EdgeInsets.all(12)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(
          color: isFirstElement
              ? Apptheme.colors.black.withOpacity(0.3)
              : Colors.transparent,
          width: 1,
        ),
        boxShadow: [
          if (isFirstElement)
            BoxShadow(
              color: Colors.black.withOpacity(0.24),
              offset: const Offset(0, 3),
              blurRadius: 8,
              spreadRadius: 0,
            ),
        ],
        color: !isFirstElement
            ? Apptheme.colors.pale_blue.withOpacity(0.3)
            : Apptheme.colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Icon location
              Container(
                decoration: BoxDecoration(
                  color: !isFirstElement
                      ? Apptheme.colors.gray_light
                      : Apptheme.colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: !isFirstElement
                        ? Apptheme.colors.gray_light
                        : Apptheme.colors.orage,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.location_on_outlined,
                  color: !isFirstElement
                      ? Apptheme.colors.black
                      : Apptheme.colors.blue,
                ),
              ),
              const SizedBox(width: 10),
              // Location and time
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text(
                      childLocation.location,
                      style: TextStyle(
                        color: !isFirstElement
                            ? Apptheme.colors.gray
                            : Apptheme.colors.black,
                        fontSize: !isFirstElement ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    childLocation.time,
                    style: TextStyle(
                      fontSize: !isFirstElement ? 16 : 18,
                      color: Apptheme.colors.gray,
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
