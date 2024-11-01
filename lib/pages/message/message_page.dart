import 'package:flutter/material.dart';
import 'package:parent_link/pages/message/widget_item_message.dart';
import 'package:parent_link/theme/app.theme.dart';

class MessagePage extends StatelessWidget {
  const MessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Apptheme.colors.blue,
      body: SafeArea(
        child: Stack(
          children: [
            // Top bar
            Positioned(
              top: 40,
              left: 30,
              right: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 25,
                        backgroundImage:
                            AssetImage('assets/img/avatar_mom.png'),
                      ),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Good morning",
                              style: TextStyle(
                                color: Apptheme.colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              "Sarah",
                              style: TextStyle(
                                color: Apptheme.colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Search button
                  Container(
                    decoration: BoxDecoration(
                      color: Apptheme.colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(
                      height: 40,
                      width: 40,
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.search,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Chats - Manage bar
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
                decoration: BoxDecoration(
                  color: Apptheme.colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Chats",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    Text(
                      "Manage",
                      style: TextStyle(
                        color: Apptheme.colors.gray,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Scroll chats
            Positioned(
              top: 180,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Apptheme.colors.white,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      WidgetItemMessage(
                        onPressed: () {},
                        avatar: 'assets/img/child1.png',
                        chatName: 'Design team',
                        currentText: 'Awesome',
                        time: ' • 14h20',
                        active: true,
                        seen: true,
                      ),
                      WidgetItemMessage(
                        onPressed: () {},
                        avatar: 'assets/img/child2.png',
                        chatName: 'Design team',
                        currentText: 'Awesome',
                        time: ' • 14h20',
                        active: true,
                        seen: false,
                      ),
                      WidgetItemMessage(
                        onPressed: () {},
                        avatar: 'assets/img/child3.png',
                        chatName: 'Design team',
                        currentText: 'Awesome',
                        time: ' • 14h20',
                        active: false,
                        seen: true,
                      ),
                      // Additional chats for testing scroll
                      WidgetItemMessage(
                        onPressed: () {},
                        avatar: 'assets/img/child1.png',
                        chatName: 'Design team',
                        currentText: 'Awesome',
                        time: ' • 14h20',
                        active: true,
                        seen: true,
                      ),
                      WidgetItemMessage(
                        onPressed: () {},
                        avatar: 'assets/img/child2.png',
                        chatName: 'Design team',
                        currentText: 'Awesome',
                        time: ' • 14h20',
                        active: true,
                        seen: false,
                      ),
                      WidgetItemMessage(
                        onPressed: () {},
                        avatar: 'assets/img/child3.png',
                        chatName: 'Design team',
                        currentText: 'Awesome',
                        time: ' • 14h20',
                        active: false,
                        seen: true,
                      ),
                      WidgetItemMessage(
                        onPressed: () {},
                        avatar: 'assets/img/child1.png',
                        chatName: 'Design team',
                        currentText: 'Awesome',
                        time: ' • 14h20',
                        active: true,
                        seen: true,
                      ),
                      WidgetItemMessage(
                        onPressed: () {},
                        avatar: 'assets/img/child2.png',
                        chatName: 'Design team',
                        currentText: 'Awesome',
                        time: ' • 14h20',
                        active: true,
                        seen: false,
                      ),
                      WidgetItemMessage(
                        onPressed: () {},
                        avatar: 'assets/img/child3.png',
                        chatName: 'Design team',
                        currentText: 'Awesome',
                        time: ' • 14h20',
                        active: false,
                        seen: true,
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
