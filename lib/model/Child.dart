
class Child {
  final String childId;
  final String name;
  final String birthday;
  final String lastModified;
  final String lastSeen;
  final String phone;
  final double longitude;
  final double latitude;
  final int speed;
  final int battery;

  Child({
    required this.childId,
    required this.name,
    required this.birthday,
    required this.lastModified,
    required this.lastSeen,
    required this.phone,
    required this.longitude,
    required this.latitude,
    required this.speed,
    required this.battery,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      childId: json['childId'],
      name: json['name'],
      birthday: json['birthday'],
      lastModified: json['lastModified'],
      lastSeen: json['lastSeen'],
      phone: json['phone'],
      longitude: json['longitude'],
      latitude: json['latitude'],
      speed: json['speed'],
      battery: json['battery'],
    );
  }
}