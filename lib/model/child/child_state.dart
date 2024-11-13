import '../../helper/avatar_manager.dart';

class ChildState {
  final String name;
  final String activity;
  final int distance;
  final int battery;
  final String state;
  String? avatarPath; // Correctly marked as nullable
  final String lastModified;
  final String childId;
  static const String defaultImage = 'assets/img/child1.png';

  ChildState({
    required this.name,
    required this.activity,
    required this.distance,
    required this.battery,
    required this.state,
    required this.lastModified,
    required this.childId,
    this.avatarPath,
  });

  // Factory constructor to safely create from JSON
  factory ChildState.fromJson(Map<String, dynamic> json) {
    return ChildState(
      name: json['name'] ?? 'Unknown',
      activity: 'Unknown Activity',
      distance: 0,
      battery: json['battery'] ?? 0,
      state: 'Unknown State',
      lastModified: json['lastModified'] ?? DateTime.now().toIso8601String(),
      childId: json['childId']?.toString() ?? '',
    );
  }

  Future<void> updateAvatar(String avatarUrl) async {
    try {
      avatarPath = await AvatarManager.getOrUpdateAvatar(
          childId, avatarUrl, lastModified);
    } catch (e) {
      print('Error updating avatar: $e');
    }
  }
}
