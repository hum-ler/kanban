import 'package:equatable/equatable.dart';

/// Represents an end-user of this app.
///
/// Obtained by signing into an authentication service.
class UserData extends Equatable {
  /// The ID of this user.
  final String id;

  /// The name of this user.
  final String name;

  /// The email address of this user.
  final String email;

  /// Indicates whether this user is signed in.
  final bool isSignedIn;

  /// Creates an instance of [UserData].
  const UserData({
    this.id = '',
    this.name = '',
    this.email = '',
    this.isSignedIn = false,
  });

  @override
  List<Object?> get props => [id, email, isSignedIn];
}
