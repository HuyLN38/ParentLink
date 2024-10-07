import 'package:flutter/material.dart';
import 'package:parent_link/theme/app.theme.dart';

class WidgetItemMessage extends StatelessWidget {
  final VoidCallback onPressed;
  final String avatar;
  final String chatName;
  final String currentText;
  final String time;
  final bool active;
  final bool seen;

  const WidgetItemMessage({
    Key? key,
    required this.onPressed,
    required this.avatar,
    required this.chatName,
    required this.currentText,
    required this.time,
    required this.active,
    required this.seen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, 
        elevation: 0, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, 
          side: BorderSide.none, 
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // Avatar user
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage(avatar),
                    ),
                    // Active status
                    if (active)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12, // Size of the green dot
                          height: 12,
                          decoration: BoxDecoration(
                            color: Apptheme.colors.green_active, // Active indicator color
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white, // Border active
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User name
                    Text(
                      chatName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Apptheme.colors.black
                      ),
                    ),
                    Row(
                      children: [
                        //current text
                        Text(
                          currentText,
                          style: TextStyle(
                            color: Apptheme.colors.black
                          ),
                          ),
                        const SizedBox(width: 6),
                        //time
                        Text(
                          time,
                          style: TextStyle(
                            color: Apptheme.colors.gray,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
            // Seen or not
            seen
                ? CircleAvatar(
                    radius: 10,
                    backgroundImage: AssetImage(avatar),
                  )
                : Container(
                    height: 12,
                    width: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Apptheme.colors.blue,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}