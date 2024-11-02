import 'dart:io';

import 'package:parent_link/api/apis.dart';
import 'package:parent_link/helper/my_date_util.dart';
import 'package:parent_link/model/message.dart';
import 'package:flutter/material.dart';

// A MessageBubble for showing a single chat message on the ChatScreen.
class MessageBubble extends StatelessWidget {
  // Create a message bubble which is meant to be the first in the sequence.
  MessageBubble.first({
    super.key,
    // required this.userImage,
    // required this.username,
    required this.message,
    required this.isMe,
  }) : isFirstInSequence = true;

  // Create a amessage bubble that continues the sequence.
  MessageBubble.next({
    super.key,
    required this.message,
    required this.isMe,
  }) : isFirstInSequence = false;
  // userImage = null,
  // username = null;

  // Whether or not this message bubble is the first in a sequence of messages
  // from the same user.
  // Modifies the message bubble slightly for these different cases - only
  // shows user image for the first message from the same user, and changes
  // the shape of the bubble for messages thereafter.
  final bool isFirstInSequence;

  // Image of the user to be displayed next to the bubble.
  // Not required if the message is not the first in a sequence.
  // final String? userImage;

  // Username of the user.
  // Not required if the message is not the first in a sequence.
  // final String? username;
  final Message message;

  // Controls how the MessageBubble will be aligned.
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (message.read!.isEmpty && !isMe) {
      Apis.updateMessageReadStatus(message);
    }

    return Stack(
      children: [
        if (message.userImage != null && isFirstInSequence)
          Positioned(
            top: 15,
            // Align user image to the right, if the message is from me.
            right: isMe ? 0 : null,
            child: CircleAvatar(
              backgroundImage: message.userImage! != 'assets/img/avatar_mom.png'
                  ? FileImage(File(message.userImage!))
                  : const AssetImage('assets/img/avatar_mom.png')
                      as ImageProvider,
              backgroundColor: theme.colorScheme.primary.withAlpha(180),
              radius: 23,
            ),
          ),
        Container(
          // Add some margin to the edges of the messages, to allow space for the
          // user's image.
          margin: const EdgeInsets.symmetric(horizontal: 46),
          child: Row(
            // The side of the chat screen the message should show at.
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // First messages in the sequence provide a visual buffer at
                  // the top.
                  const SizedBox(
                    width: 8,
                  ),
                  if (isFirstInSequence)
                    Text(
                      MyDateUtil.getFormattedTime(
                          context: context, time: message.sent!),
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black54),
                    ),

                  // if (isFirstInSequence) const SizedBox(height: 18),
                  if (message.userName != null && isFirstInSequence)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 13,
                        right: 13,
                      ),
                      child: Text(
                        message.userName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                  // The "speech" box surrounding the message.
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.grey[300]
                              : theme.colorScheme.secondary.withAlpha(200),
                          // Only show the message bubble's "speaking edge" if first in
                          // the chain.
                          // Whether the "speaking edge" is on the left or right depends
                          // on whether or not the message bubble is the current user.
                          borderRadius: BorderRadius.only(
                            topLeft: !isMe && isFirstInSequence
                                ? Radius.zero
                                : const Radius.circular(12),
                            topRight: isMe && isFirstInSequence
                                ? Radius.zero
                                : const Radius.circular(12),
                            bottomLeft: const Radius.circular(12),
                            bottomRight: const Radius.circular(12),
                          ),
                        ),
                        // Set some reasonable constraints on the width of the
                        // message bubble so it can adjust to the amount of text
                        // it should show.
                        constraints: const BoxConstraints(maxWidth: 200),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 14,
                        ),
                        // Margin around the bubble.
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 12,
                        ),
                        child: message.type == Type.text
                            ? Text(
                                message.msg!,
                                style: TextStyle(
                                  // Add a little line spacing to make the text look nicer
                                  // when multilined.
                                  height: 1.3,
                                  color: isMe
                                      ? Colors.black87
                                      : theme.colorScheme.onSecondary,
                                ),
                                softWrap: true,
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  message.msg!,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    } else {
                                      return const CircularProgressIndicator();
                                    }
                                  },
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                      ),
                      if (message.read!.isNotEmpty)
                        Positioned(
                          top: 0,
                          child: Padding(
                            padding: isFirstInSequence
                                ? const EdgeInsets.only(right: 0)
                                : const EdgeInsets.only(right: 70),
                            child: Icon(
                              isMe ? Icons.done_all_rounded : null,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
