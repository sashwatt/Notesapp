import 'dart:convert';

class Base64Utils{


  /// Base64 解密
  static String decrypt(String value) {
    List<int> bytes = base64.decode(value);
    return utf8.decode(bytes);
  }


  /// Base64 加密
  static String encryption(String value){
    return base64Encode(utf8.encode(value));
  }
}