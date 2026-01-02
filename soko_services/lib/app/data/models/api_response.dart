class ApiResponse<T> {
  Status status;
  T? data;
  String? message;
  int? statusCode;

  ApiResponse.success(this.data) : status = Status.success;

  ApiResponse.error(this.message, {this.statusCode}) : status = Status.error;

  ApiResponse.loading() : status = Status.loading;

  @override
  String toString() {
    return "Status : $status \n Message : $message \n Data : $data";
  }
}

enum Status { loading, success, error }
