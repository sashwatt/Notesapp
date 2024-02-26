
class UserInfoBean{
  String userEmail;
  String uid;

  UserInfoBean({
    required this.userEmail,
    required this.uid
  });

  factory UserInfoBean.fromJson(Map<String,dynamic> json){
    return UserInfoBean(userEmail: json["userEmail"], uid: json["uid"]);
  }
}