import '../models/user_data.dart';

/// The repository for authentication service.
abstract class UserRepository {
  /// Initializes the repository.
  ///
  /// Must be called before using any other methods.
  ///
  /// Use [getCurrentUser()] after calling this method to retrieve any cached
  /// credentials, if available.
  Future<void> initRepo();

  /// Gets the current signed-in user, if available.
  Future<UserData?> getCurrentUser();

  /// Signs in the current user.
  Future<UserData?> signIn();

  /// Signs out any currently signed-in user.
  Future<void> signOut();
}
