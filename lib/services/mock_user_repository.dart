import '../models/user_data.dart';
import 'user_repository.dart';

/// The mock repository for authenticated service.
///
/// No actual authentication takes place.
class MockUserRepository implements UserRepository {
  @override
  Future<void> initRepo() async {}

  @override
  Future<UserData?> getCurrentUser() => signIn();

  @override
  Future<UserData> signIn() async => UserData(
        id: 'foo',
        name: 'Foo',
        email: 'foo@bar.baz',
        isSignedIn: true,
      );

  @override
  Future<void> signOut() async {}
}
