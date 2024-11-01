 enum Type {text, image}

class Message {
  String? toId;
  String? msg;
  String? read;
  Type? type;
  String? fromId;
  String? sent;
  String? userImage;
  String? userName;

  Message({this.toId, this.msg, this.read, this.type, this.fromId, this.sent, this.userImage, this.userName});

  Message.fromJson(Map<String, dynamic> json) {
    toId = json['toId'];
    msg = json['msg'];
    read = json['read'];
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
    fromId = json['fromId'];
    sent = json['sent'];
    userImage = json['userImage'];
    userName = json['userName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['toId'] = this.toId;
    data['msg'] = this.msg;
    data['read'] = this.read;
    data['type'] = this.type!.name;
    data['fromId'] = this.fromId;
    data['sent'] = this.sent;
    data['userImage'] = this.userImage;
    data['userName'] = this.userName;
    return data;
  }
}