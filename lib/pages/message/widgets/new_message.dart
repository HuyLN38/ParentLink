import 'dart:developer';
import 'dart:io';
import 'package:parent_link/api/apis.dart';
import 'package:parent_link/model/chat_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:parent_link/model/message.dart';
import 'package:image_picker/image_picker.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key, required this.user});

  final ChatUser user;

  @override
  State<NewMessage> createState() {
    return _NewMessageState();
  }
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final enteredMessage = _messageController.text;
    _messageController.clear();
    FocusScope.of(context).unfocus();

    if (enteredMessage.trim().isEmpty) {
      return;
    }

    try {
      // final user = FirebaseAuth.instance.currentUser!;
      final userData =
          await Apis.firestore.collection('users').doc(Apis.user.uid).get();

      // Check if it's the first message by checking if the user exists in 'my_users' collection
      final myUsersSnapshot = await Apis.firestore
          .collection('users')
          .doc(widget.user.id)
          .collection('my_users')
          .doc(Apis.user.uid)
          .get();
      log('First message exists: ${myUsersSnapshot.exists}');

      // await FirebaseFirestore.instance.collection('chat').add({
      //   'text': enteredMessage,
      //   'createdAt': Timestamp.now(),
      //   'userId': user.uid,
      //   'username': userData['username'],
      //   'userImage': userData['image_url'],
      // });

      if (!myUsersSnapshot.exists) {
        // If the user doesn't exist in 'my_users', send the first message
        await Apis.sendFirstMessage(
          widget.user,
          enteredMessage,
          Type.text,
        );
      } else {
        // If the user already exists, send a regular message
        await Apis.sendMessage(
          widget.user,
          enteredMessage,
          Type.text,
          userData['image'],
          userData['name'],
        );
      }
    } catch (error) {
      log('Failed to send message: $error');
      // Show error to user (optional)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 14),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Send a message',
                  hintStyle: TextStyle(color: Colors.blueAccent),
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();

                  final List<XFile> images =
                      await picker.pickMultiImage(imageQuality: 70);

                  for (var i in images) {
                    log('Image Path: ${i.path}');
                    await Apis.sendChatImage(widget.user, File(i.path));
                  }
                },
                icon: const Icon(
                  Icons.image,
                  color: Colors.blueAccent,
                )),
            IconButton(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();

                  final XFile? image = await picker.pickImage(
                      source: ImageSource.camera, imageQuality: 70);

                  await Apis.sendChatImage(widget.user, File(image!.path));
                },
                icon: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.blueAccent,
                )),
            IconButton(
              color: Theme.of(context).colorScheme.primary,
              onPressed: _submitMessage,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
