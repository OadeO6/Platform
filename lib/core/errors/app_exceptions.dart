/// Base exception class for Platform.
/// All app-specific exceptions extend this.
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// Thrown when Firebase Auth operations fail.
class AuthException extends AppException {
  const AuthException(super.message);

  /// Maps Firebase Auth error codes to user-friendly messages.
  factory AuthException.fromCode(String code) {
    switch (code) {
      case 'user-not-found':
        return const AuthException('No account found with this email.');
      case 'wrong-password':
        return const AuthException('Incorrect password. Please try again.');
      case 'email-already-in-use':
        return const AuthException('An account already exists with this email.');
      case 'invalid-email':
        return const AuthException('Please enter a valid email address.');
      case 'weak-password':
        return const AuthException('Password must be at least 6 characters.');
      case 'network-request-failed':
        return const AuthException('No internet connection. Please try again.');
      case 'too-many-requests':
        return const AuthException('Too many attempts. Please try again later.');
      case 'user-disabled':
        return const AuthException('This account has been disabled.');
      case 'operation-not-allowed':
        return const AuthException('This sign-in method is not enabled.');
      default:
        return const AuthException('Authentication failed. Please try again.');
    }
  }
}

/// Thrown when Firestore read/write operations fail.
class DatabaseException extends AppException {
  const DatabaseException(super.message);
}

/// Thrown when Cloudinary image upload fails.
class StorageException extends AppException {
  const StorageException(super.message);
}

/// Thrown when location services fail or are denied.
class LocationException extends AppException {
  const LocationException(super.message);
}

/// Thrown when a network request fails.
class NetworkException extends AppException {
  const NetworkException([String message = 'No internet connection. Please check your network.'])
      : super(message);
}

/// Thrown when an image exceeds the size limit.
class ImageSizeException extends AppException {
  const ImageSizeException()
      : super('Image is too large. Maximum size is 2MB.');
}

/// Thrown when the user hits the space cap (20 items).
class SpaceCapException extends AppException {
  const SpaceCapException()
      : super("You've reached your 20-item limit. Delete an item to make space.");
}

/// Thrown when the user hits the listing cap (7 active listings).
class ListingCapException extends AppException {
  const ListingCapException()
      : super("You've reached your 7 listing limit. Unlist or sell an item to list another.");
}

/// Thrown when a required WhatsApp number is missing.
class WhatsAppRequiredException extends AppException {
  const WhatsAppRequiredException()
      : super('A WhatsApp number is required to list items.');
}
