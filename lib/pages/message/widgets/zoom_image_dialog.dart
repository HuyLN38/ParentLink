import 'package:flutter/material.dart';

class ImageDialog extends StatelessWidget {
  const ImageDialog({super.key, required this.messageImage});

  final String messageImage;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(20),
        minScale: 0.5,
        maxScale: 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.network(
            messageImage,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
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
    );
  }
}
