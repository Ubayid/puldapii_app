class ApiResponse<T> {
  final bool success;
  final String message;
  final T data;

  ApiResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    required T Function(dynamic dataJson) parseData,
  }) {
    return ApiResponse<T>(
      success: (json['success'] ?? false) as bool,
      message: (json['message'] ?? '') as String,
      data: parseData(json['data']),
    );
  }
}
