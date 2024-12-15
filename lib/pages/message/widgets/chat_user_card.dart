import 'dart:io';

import 'package:parent_link/api/apis.dart';
import 'package:parent_link/model/chat/chat_user.dart';
import 'package:parent_link/model/chat/message.dart';
import 'package:flutter/material.dart';
import 'package:parent_link/pages/message/screens/chat.dart';
import 'package:parent_link/theme/app.theme.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      color: Theme.of(context).colorScheme.onPrimary,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChatScreen(user: widget.user),
            ),
          );
        },
        child: StreamBuilder(
          stream: Apis.getLastMessage(widget.user),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading messages'));
            }

            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
            if (list.isNotEmpty) message = list[0];

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: widget.user.image != null &&
                    widget.user.image!.isNotEmpty &&
                    widget.user.image != 'assets/img/avatar_mom.png'
                    ? FileImage(File(widget.user.image!))
                    : const AssetImage('assets/img/avatar_mom.png')
                as ImageProvider,
                child: widget.user.image != null &&
                    widget.user.image!.isNotEmpty &&
                    widget.user.image != 'assets/img/avatar_mom.png'
                    ? null
                    : const Icon(Icons.person_3_sharp),
              ),
              title: Text(
                widget.user.name ?? 'No Name',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Apptheme.colors.black,
                ),
              ),
              subtitle: Text(
                message != null
                    ? message!.type == Type.image
                    ? 'Image'
                    : message!.msg ?? ''
                    : widget.user.about ?? 'Hey there! I am using Chat.',
                style: TextStyle(color: Apptheme.colors.black),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: widget.user.isOnline == true
                  ? Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  color: Colors.greenAccent.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              )
                  : null,
            );
          },
        ),
      ),
    );
  }
}
