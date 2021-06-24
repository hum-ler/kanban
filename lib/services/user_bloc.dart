import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/user_data.dart';
import 'user_repository.dart';

/// The BLoC that handles user (authentication) events.
class UserBloc extends Bloc<UserEvent, UserData> {
  /// The repository for authentication service.
  final UserRepository repository;

  /// Creates an instance of [UserBloc].
  UserBloc({
    required this.repository,
    required UserData initialState,
  }) : super(initialState);

  @override
  Stream<UserData> mapEventToState(event) async* {
    switch (event) {
      case UserEvent.startup:
        await repository.initRepo();
        final UserData? user = await repository.getCurrentUser();
        if (user != null) yield user;
        break;

      case UserEvent.signIn:
        final UserData? user = await repository.signIn();
        if (user != null) yield user;
        break;

      case UserEvent.signOut:
        await repository.signOut();
        yield UserData();
        break;
    }
  }
}

/// A user (authentication) event.
enum UserEvent {
  /// App startup.
  ///
  /// Checks for cached credentials.
  startup,

  /// User asks to sign in.
  signIn,

  /// User asks to sign out.
  signOut,
}
