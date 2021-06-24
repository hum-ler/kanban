import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../config.dart';
import '../models/board_catalog.dart';
import '../models/user_data.dart';
import 'catalog_event.dart';
import 'catalog_repository.dart';
import 'user_bloc.dart';

/// The BLoC that handles board catalog events.
class CatalogBloc extends Bloc<CatalogEvent, BoardCatalog> {
  /// The repository for the board catalog.
  final CatalogRepository repository;

  /// The BLoC that handles user authentication events.
  final UserBloc userBloc;

  /// The subscription to the [userBloc] stream.
  late StreamSubscription<UserData> _userSubscription;

  /// Indicates whether the board catalog is currently loaded.
  bool _isLoaded = false;

  /// Creates an instance of [CatalogBloc].
  CatalogBloc({
    required this.repository,
    required this.userBloc,
    required BoardCatalog initialState,
  }) : super(initialState) {
    _userSubscription = userBloc.stream.listen(_userChanged);
  }

  /// Reacts to a change in the signed in user.
  void _userChanged(UserData user) {
    // Once the user signs in, proceed to load the board catalog.
    if (user.isSignedIn && !_isLoaded) add(LoadCatalogEvent());

    // Conversely, if the user signs out, unload the catalog.
    if (!user.isSignedIn && _isLoaded) add(UnloadCatalogEvent());
  }

  @override
  Stream<BoardCatalog> mapEventToState(CatalogEvent event) async* {
    if (event is LoadCatalogEvent) {
      yield await repository.load();
      _isLoaded = true;
    }

    if (event is UnloadCatalogEvent) {
      yield BoardCatalog();
      _isLoaded = false;
    }

    if (event is UpdateRecentEvent) {
      assert(_isLoaded);

      if (state.recent.length > 0 && state.recent[0] == event.id) return;

      final List<String> recent = List.of(state.recent)
        ..removeWhere((e) => e == event.id)
        ..insert(0, event.id);

      // Keep the recent list to a reasonable length.
      if (recent.length > maxRecentListLength) {
        recent.length = maxRecentListLength;
      }

      yield await repository.save(state.copyWith(recent: recent));
    }

    if (event is ClearRecentEvent) {
      assert(_isLoaded);

      if (state.recent.isNotEmpty) {
        yield await repository.save(state.copyWith(recent: []));
      }
    }

    if (event is UpdateEntryEvent) {
      assert(_isLoaded);

      if (state.entries.containsKey(event.entry.id) &&
          state.entries[event.entry.id] == event.entry) return;

      final Map<String, CatalogEntry> entries = Map.of(state.entries)
        ..[event.entry.id] = event.entry;

      yield await repository.save(state.copyWith(entries: entries));
    }

    if (event is DeleteEntryEvent) {
      assert(_isLoaded);

      if (state.entries.containsKey(event.id)) {
        final Map<String, CatalogEntry> entries = Map.of(state.entries)
          ..remove(event.id);

        final List<String> recent = List.of(state.recent)
          ..removeWhere((e) => e == event.id);

        yield await repository.save(
          BoardCatalog(
            recent: recent,
            entries: entries,
          ),
        );
      }
    }
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();

    return super.close();
  }
}
