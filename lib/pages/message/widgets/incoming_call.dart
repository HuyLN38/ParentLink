import 'package:flutter/material.dart';

class IncomingCallDialog extends StatelessWidget {
  final String callerName;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const IncomingCallDialog({
    Key? key,
    required this.callerName,
    required this.onAccept,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Incoming Video Call'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.video_call,
            size: 50,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          Text(
            callerName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text('is calling you...'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onReject,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.call_end),
              SizedBox(width: 8),
              Text('Decline'),
            ],
          ),
        ),
        TextButton(
          onPressed: onAccept,
          style: TextButton.styleFrom(foregroundColor: Colors.green),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.video_call),
              SizedBox(width: 8),
              Text('Accept'),
            ],
          ),
        ),
      ],
    );
  }
}
