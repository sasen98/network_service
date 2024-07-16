class FailureState {
  FailureState({this.message, this.statusCode, this.data});

  FailureState.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    statusCode = json['status_code'];
    data = json['data'];
  }
  String? message;
  int? statusCode;
  dynamic data;

  Map<String, dynamic> toJson() {
    return {
      "message": message,
      "status_code": statusCode,
      "data": data,
    };
  }

  FailureState copyWith({
    String? message,
    int? statusCode,
    dynamic data,
  }) {
    return FailureState(
        data: data ?? this.data,
        message: message ?? this.message,
        statusCode: statusCode ?? this.statusCode);
  }
}
