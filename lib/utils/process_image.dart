import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

class ImageProcess {
  static Future<Uint8List> processImage(Uint8List imageData) async {
    final codec = await ui.instantiateImageCodec(imageData,
        targetWidth: 88, targetHeight: 88);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();
    const size =
        Size(100, 100); // Increase the canvas size to accommodate the border

    // Draw colored border circle
    paint.color = const Color(0xFF000000);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 36 + 4, paint);

    // Draw white border circle
    paint.color = const Color(0xFFFFFFFF);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 36, paint);

    // Draw the image inside the white circle
    paint.blendMode = BlendMode.srcIn;
    canvas.drawImage(
        image, const Offset(4, 4), paint); // Adjust the image position

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }
}
