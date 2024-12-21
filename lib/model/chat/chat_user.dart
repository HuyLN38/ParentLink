class ChatUser {
  String? image;
  String? about;
  String? name;
  String? createdAt;
  bool? isOnline;
  String? lastActive;
  String? id;
  String? pushToken;
  String? email;

  ChatUser(
      {this.image,
      this.name,
      this.createdAt,
      this.isOnline,
      this.lastActive,
      this.id,
      this.pushToken});

  ChatUser.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    name = json['name'];
    createdAt = json['created_at'];
    isOnline = json['is_online'];
    lastActive = json['last_active'];
    id = json['localId'];
    pushToken = json['push_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['image'] = image;
    data['name'] = name;
    data['created_at'] = createdAt;
    data['is_online'] = isOnline;
    data['last_active'] = lastActive;
    data['localId'] = id;
    data['push_token'] = pushToken;
    return data;
  }
}
