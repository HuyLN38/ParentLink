import 'dart:io';

import 'package:parent_link/api/apis.dart';
import 'package:parent_link/helper/my_date_util.dart';
import 'package:parent_link/model/chat/chat_user.dart';
import 'package:flutter/material.dart';
import 'package:parent_link/pages/message/widgets/chat_message.dart';
import 'package:parent_link/pages/message/widgets/new_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.user});

  final ChatUser user;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: _appBar(),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatMessages(
              user: widget.user,
            ),
          ),
          NewMessage(
            user: widget.user,
          ),
        ],
      ),
    );
  }

  Widget _appBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: StreamBuilder(
        stream: Apis.getUserInfo(widget.user),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.docs;
          final list = data
              .map(
                (e) => ChatUser.fromJson(e.data()),
          )
              .toList();

          final userImage = widget.user.image;

          return Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios_new),
              ),
              CircleAvatar(
                backgroundImage: userImage != null && userImage.isNotEmpty
                    ? FileImage(File(userImage))
                    : const AssetImage('assets/img/avatar_mom.png')
                as ImageProvider,
                child: userImage != null && userImage.isNotEmpty
                    ? null
                    : const Icon(Icons.person_3_sharp),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.name ?? 'Unknown User',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    list.isNotEmpty
                        ? list[0].isOnline!
                        ? 'Online'
                        : MyDateUtil.getLastActiveTime(
                        context: context,
                        lastActive: list[0].lastActive!)
                        : MyDateUtil.getLastActiveTime(
                        context: context,
                        lastActive: widget.user.lastActive!),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              )
            ],
          );
        },
      ),
    );
  }
}
