class CustomException implements Exception {
  String message;
  String? code;
  bool shouldBeShownToUser;

  CustomException(this.message, {this.code, this.shouldBeShownToUser = false}) {
    print(toDebugString());
  }

  @override
  String toString() => message;
  String toDebugString() => "Error msg : $message and code : $code";
}
