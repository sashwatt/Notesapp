class ServiceResponse{
  int code;
  dynamic data;
  String msg;

  ServiceResponse({
    required this.code,
    required this.data,
    required this.msg,
  });

  factory ServiceResponse.fromJson(Map<String, dynamic> json1) {
    return ServiceResponse(
        code: json1['code'] as int,
        data:json1['data'],
        msg: json1['msg']);
  }
}