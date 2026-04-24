sealed class Failure {
  const Failure(this.message);
  final String message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error. Check your connection.']);
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error. Please try again.']);
}

final class InvalidInputFailure extends Failure {
  const InvalidInputFailure([super.message = 'Invalid Reddit URL.']);
}

final class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Storage error.']);
}

final class ParseFailure extends Failure {
  const ParseFailure([super.message = 'Failed to parse Reddit response.']);
}
