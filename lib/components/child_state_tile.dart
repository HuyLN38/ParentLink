import 'package:flutter/material.dart';
import 'package:parent_link/theme/app.theme.dart';

class ChildStateTile extends StatelessWidget {
  const ChildStateTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Container(
        decoration: BoxDecoration(
          color: Apptheme.colors.pale_blue,
          borderRadius: BorderRadius.circular(18)
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 20, bottom: 20),
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
                    child: const CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage('lib/img/child1.png'),
                    ),
                  ),
                  const SizedBox(width: 35), // Use SizedBox for spacing
                  // Child's info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Lesilie",
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "On the math lesson",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
              
                      // Status indicators
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildStatusContainer(
                            icon: Icons.turn_right,
                            text: "652m",
                          ),
                          const SizedBox(width: 8),
                          _buildStatusContainer(
                            icon: Icons.battery_3_bar_sharp,
                            text: "50%",
                          ),
                          const SizedBox(width: 8),
                          _buildStatusContainer(
                            text: "Idle",
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.more_horiz),
                onPressed: () {
                },
              ),
            ),
          ],
        ),
      ),
    );
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
}
