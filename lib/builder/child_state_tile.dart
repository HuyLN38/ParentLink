import 'dart:io';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:parent_link/model/child/child_state.dart';
import 'package:parent_link/model/control/control_child_state.dart';
import 'package:parent_link/pages/home/location_page.dart';
import 'package:parent_link/theme/app.theme.dart';

class ChildStateTile extends StatelessWidget {
  final ChildState? childState; // Make childState nullable
  final int index;
  ChildStateTile({super.key, required this.childState, required this.index});

  @override
  Widget build(BuildContext context) {
    if (childState == null) {
      return const Center(
        child: Text(
          'No child available',
          style: TextStyle(fontSize: 20, color: Colors.red),
        ),
      );
    }

    List<Color> backgroundColor = [
      const Color(0xffD6EBE8),
      const Color(0xffFCA92D),
      const Color(0xffE4E7F2),
    ];
    Color background = backgroundColor[index % backgroundColor.length];

    return Positioned(
        top: (150 * index).toDouble(),
        left: 0,
        right: 0,
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LocationPage(childState: childState!),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.7],
                colors: [
                  background.withOpacity(1),
                  background.withOpacity(0.5)
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Apptheme.colors.white,
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, top: 30, bottom: 50),
                  child: Row(
                    children: [
                      // Avatar with circular border
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Apptheme.colors.white,
                            width: 2,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundImage: childState!.avatarPath != null
                              ? FileImage(File(childState!.avatarPath!))
                              : const AssetImage(ChildState.defaultImage)
                                  as ImageProvider,
                        ),
                      ),
                      const SizedBox(width: 35), // Use SizedBox for spacing

                      // Child's info
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            childState!.name,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            childState!.activity,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),

                          // Status indicators
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildStatusContainer(
                                icon: Icons.turn_right,
                                text: "${childState!.distance}m",
                              ),
                              const SizedBox(width: 8),
                              _buildStatusContainer(
                                icon: _getBatteryIcon(childState!.battery),
                                text: "${childState!.battery}%",
                              ),
                              const SizedBox(width: 8),
                              _buildStatusContainer(
                                text: childState!.state,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(10)),
                          ),
                          builder: (BuildContext context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Container(
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade400,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.delete,
                                      color: Colors.red),
                                  title: const Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                  onTap: () async {
                                    Navigator.of(context).pop();
                                    final bool? confirmed = await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Confirm Delete'),
                                          content: const Text(
                                              'Are you sure you want to delete this child?'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: const Text('Cancel',
                                                  style: TextStyle(
                                                      color: Colors.black)),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: const Text('Delete',
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirmed == true) {
                                      try {
                                        await context
                                            .read<ControlChildState>()
                                            .deleteChild(childState!.childId!);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Child deleted successfully')),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Failed to delete child: $e')),
                                        );
                                        print(e);
                                      }
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Icon(Icons.more_horiz),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  // Helper method to build status container
  Widget _buildStatusContainer({IconData? icon, required String text}) {
    return Container(
      color: Apptheme.colors.pale_blue.withRed(230),
      child: Container(
        height: 35,
        decoration: BoxDecoration(
          border: Border.all(
            color: Apptheme.colors.white,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(4), // Add some padding
        child: Row(
          children: [
            if (icon != null) Icon(icon), // Show icon only if provided
            if (icon != null) const SizedBox(width: 4), // Spacing after icon
            Text(text),
          ],
        ),
      ),
    );
  }

  // Helper method to get battery icon based on battery percentage
  IconData _getBatteryIcon(int battery) {
    if (battery >= 90) {
      return Icons.battery_full;
    } else if (battery >= 80) {
      return Icons.battery_6_bar;
    } else if (battery >= 60) {
      return Icons.battery_5_bar;
    } else if (battery >= 40) {
      return Icons.battery_4_bar;
    } else if (battery >= 30) {
      return Icons.battery_3_bar;
    } else if (battery >= 20) {
      return Icons.battery_2_bar;
    } else if (battery >= 10) {
      return Icons.battery_1_bar;
    } else {
      return Icons.battery_0_bar;
    }
  }
}
