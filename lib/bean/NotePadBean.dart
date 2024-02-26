import 'dart:ffi';

class NotePadBean{
  int id;
  String title;
  String content;
  String createtime;
  String type;
  int uid;

  NotePadBean({
    required this.id,
    required this.title,
    required this.content,
    required this.createtime,
    required this.type,
    required this.uid
  });

  factory NotePadBean.fromJson(Map<String, dynamic> json) {
    return NotePadBean(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createtime: json['createtime'],
      type: json['type'],
      uid: json['uid'],
    );
  }
}