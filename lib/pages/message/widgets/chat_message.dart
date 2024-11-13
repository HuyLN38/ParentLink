import 'package:parent_link/api/apis.dart';
import 'package:parent_link/model/chat/chat_user.dart';
import 'package:parent_link/model/chat/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:parent_link/helper/uuid.dart' as globals;
import 'package:parent_link/pages/message/widgets/meassage_bubble.dart';

class ChatMessages extends StatefulWidget {
  const ChatMessages({super.key, required this.user});

  final ChatUser user;

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  void setupPushNotification() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();

    fcm.subscribeToTopic('chat');
  }

  // @override
  // void initState() {
  //   super.initState();

  //   setupPushNotification();
  // }

  @override
  Widget build(BuildContext context) {
    List<Message> _list = [];

    return StreamBuilder(
      stream: Apis.getAllMessages(widget.user),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No Message Found!'),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Something go wrong!'),
          );
        }

        final loadedMessage = snapshot.data!.docs;
        _list = loadedMessage.map(
              (e) {
                return Message.fromJson(e.data());
              },
            ).toList() ??
            [];

        return ListView.builder(
          padding: const EdgeInsets.only(
            bottom: 40,
            left: 13,
            right: 13,
          ),
          reverse: true,
          itemCount: _list.length,
          itemBuilder: (context, index) {
            final chatMessage = _list[index];
            final nextChatMessage =
                index + 1 < _list.length ? _list[index + 1] : null;

            final currentMessageUserId = chatMessage.fromId;
            final nextMessageUserId = nextChatMessage?.fromId;

            final nextUserIsSame = nextMessageUserId == currentMessageUserId;

            if (nextUserIsSame) {
              return MessageBubble.next(
                message: chatMessage,
                isMe: globals.token == currentMessageUserId,
              );
            } else {
              return MessageBubble.first(
                // userImage: chatMessage['userImage'],
                // username: chatMessage['username'],
                message: chatMessage,
                isMe: globals.token == currentMessageUserId,
              );
            }
          },
        );
      },
    );
  }
}
