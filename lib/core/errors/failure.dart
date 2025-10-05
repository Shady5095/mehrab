abstract class Failure {
  final String errorMessage;
  final dynamic errorDetails;

  const Failure(this.errorMessage, {this.errorDetails});
}
