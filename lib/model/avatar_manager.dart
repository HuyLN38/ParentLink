import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class AvatarManager {
  static const String _lastModifiedPrefix = 'avatar_last_modified_';
  static const String _avatarPathPrefix = 'avatar_path_';

  // Get the local storage directory
  static Future<Directory> get _localDir async {
    final directory = await getApplicationDocumentsDirectory();
    final avatarDir = Directory('${directory.path}/avatars');
    if (!await avatarDir.exists()) {
      await avatarDir.create(recursive: true);
    }
    return avatarDir;
  }

  // Save avatar metadata to SharedPreferences
  static Future<void> _saveAvatarMetadata(
      String childId, String lastModified) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_lastModifiedPrefix$childId', lastModified);
  }

  // Get last modified timestamp for a child's avatar
  static Future<String?> _getLastModified(String childId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_lastModifiedPrefix$childId');
  }

  // Save avatar path to SharedPreferences
  static Future<void> _saveAvatarPath(String childId, String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_avatarPathPrefix$childId', path);
  }

  // Get avatar path from SharedPreferences
  static Future<String?> getAvatarPath(String childId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_avatarPathPrefix$childId');
  }

  // Compare timestamps to check if update is needed
  static bool _needsUpdate(String storedTimestamp, String newTimestamp) {
    final stored = DateTime.parse(storedTimestamp);
    final new_ = DateTime.parse(newTimestamp);
    return new_.isAfter(stored);
  }

  // Download and save avatar
  static Future<String> _downloadAndSaveAvatar(
      String url, String childId) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to download avatar');
    }

    // Extract avatar from response body
    final Map<String, dynamic> responseBody = jsonDecode(response.body);
    final String avatarBase64 = responseBody['avatar'];

    final directory = await _localDir;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '${directory.path}/$childId.jpg';

    // Decode base64 data
    List<int> imageBytes;
    try {
      imageBytes = base64Decode(avatarBase64);
    } catch (e) {
      throw Exception('Failed to decode base64 image: $e');
    }

    // Process and compress the image
    Uint8List uint8ImageBytes = Uint8List.fromList(imageBytes);

    img.Image? image = img.decodeJpg(uint8ImageBytes);
    if (image == null) {
      throw Exception('Failed to decode downloaded image');
    }

    // Resize if necessary
    img.Image processedImage = image;
    if (image.width > 1024 || image.height > 1024) {
      processedImage = img.copyResize(
        image,
        width: image.width > image.height ? 1024 : null,
        height: image.height >= image.width ? 1024 : null,
      );
    }

    // Compress and save
    final compressedBytes = img.encodeJpg(processedImage, quality: 85);

    final file = File(path);
    await file.writeAsBytes(compressedBytes);

    return path;
  }

  // Main function to manage avatar updates
  static Future<String> getOrUpdateAvatar(
    String childId,
    String avatarUrl,
    String lastModified,
  ) async {
    try {
      // Check if we have a stored timestamp
      final storedTimestamp = await _getLastModified(childId);
      final currentPath = await getAvatarPath(childId);

      // If we have no stored avatar or timestamp is newer, update
      if (storedTimestamp == null ||
          currentPath == null ||
          !File(currentPath).existsSync() ||
          _needsUpdate(storedTimestamp, lastModified)) {
        // Download and save new avatar
        final newPath = await _downloadAndSaveAvatar(avatarUrl, childId);

        // Update metadata
        await _saveAvatarPath(childId, newPath);
        await _saveAvatarMetadata(childId, lastModified);

        // Delete old avatar if it exists
        if (currentPath != null && currentPath != newPath) {
          try {
            await File(currentPath).delete();
          } catch (e) {
            print('Error deleting old avatar: $e');
          }
        }

        return newPath;
      }

      // Return existing avatar path if no update needed
      return currentPath;
    } catch (e) {
      print('Error managing avatar: $e');
      rethrow;
    }
  }
}
