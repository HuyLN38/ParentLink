import 'package:parent_link/api/apis.dart';
import 'package:parent_link/model/chat_user.dart';
import 'package:parent_link/model/message.dart';
import 'package:flutter/material.dart';
import 'package:parent_link/pages/message/screens/chat.dart';
import 'package:parent_link/theme/app.theme.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() {
    return _ChatUserCardState();
  }
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      color: Theme.of(context).colorScheme.onPrimary,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  user: widget.user,
                ),
              ),
            );
          },
          child: StreamBuilder(
            stream: Apis.getLastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) message = list[0];

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: widget.user.image != null
                      ? NetworkImage(widget.user.image!)
                      : null,
                  child: widget.user.image != null
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
                          : message!.msg!
                      : widget.user.about ?? 'Hey there! I am using Chat.',
                  style: TextStyle(color: Apptheme.colors.black),
                  maxLines: 1,
                ),
                trailing: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: widget.user.isOnline == true
                        ? Colors.greenAccent.shade400
                        : null,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // trailing: const Text(
                //   '12:00 AM',
                //   style: TextStyle(color: Colors.black54),
                // ),
              );
            },
          )),
    );
  }
}
