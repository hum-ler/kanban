import 'dart:async';

import 'package:replay_bloc/replay_bloc.dart';

import '../models/board_catalog.dart';
import '../models/board_data.dart';
import '../models/card_data.dart';
import '../models/column_data.dart';
import '../models/label.dart';
import '../models/milestone.dart';
import '../services/board_repository.dart';
import 'board_event.dart';
import 'catalog_bloc.dart';
import 'catalog_event.dart';

/// The BLoC that handles Kanban board events.
class BoardBloc extends ReplayBloc<BoardEvent, BoardData> {
  /// The repository for Kanban board data.
  final BoardRepository repository;

  /// The BLoC for Kanban board catalog.
  final CatalogBloc catalogBloc;

  /// The subscription to [catalogBloc].
  late StreamSubscription<BoardCatalog> _catalogSubscription;

  /// Creates an instance of [BoardBloc].
  BoardBloc({
    required this.repository,
    required this.catalogBloc,
    required BoardData initialState,
  }) : super(initialState) {
    _catalogSubscription = catalogBloc.stream.listen(_catalogChanged);
  }

  /// Handles a change in [catalogBloc.state].
  void _catalogChanged(BoardCatalog catalog) {
    // Load the most recent board.
    if (catalog.recent.length > 0 && catalog.recent[0] != state.id) {
      add(LoadBoardEvent(catalog.recent[0]));
    }

    // If we lose the catalog, unload the current board.
    if (catalog.entries.isEmpty) {
      add(UnloadBoardEvent());
    }
  }

  @override
  Future<void> onTransition(
      covariant Transition<ReplayEvent, BoardData> transition) async {
    super.onTransition(transition);

    // Persist data for undo / redo events.
    if (transition.event.toString() == 'Undo' ||
        transition.event.toString() == 'Redo') {
      await repository.save(transition.nextState);

      catalogBloc.add(
        UpdateEntryEvent(
          CatalogEntry(
            id: transition.nextState.id,
            updated: transition.nextState.updated,
            title: transition.nextState.title,
            color: transition.nextState.theme.appColor,
            totalColumns: transition.nextState.totalColumns,
            totalCards: transition.nextState.totalCards,
          ),
        ),
      );
    }
  }

  @override
  Stream<BoardData> mapEventToState(BoardEvent event) async* {
    if (event is LoadBoardEvent) {
      yield await _loadBoard(event);

      clearHistory();

      catalogBloc.add(UpdateRecentEvent(event.id));
    }

    if (event is UnloadBoardEvent) {
      yield await _unloadBoard(event);

      clearHistory();
    }

    if (event is AddBoardEvent) {
      _addBoard(event);
    }

    if (event is EditBoardEvent) {
      yield* _updateEntry(_editBoard(event));
    }

    if (event is RemoveBoardEvent) {
      _removeBoard(event);
    }

    if (event is AddColumnEvent) {
      yield* _updateEntry(_addColumn(event));
    }

    if (event is EditColumnEvent) {
      yield* _updateEntry(_editColumn(event));
    }

    if (event is MoveColumnEvent) {
      yield* _updateEntry(_moveColumn(event));
    }

    if (event is RemoveColumnEvent) {
      yield* _updateEntry(_removeColumn(event));
    }

    if (event is AddCardEvent) {
      yield* _updateEntry(_addCard(event));
    }

    if (event is EditCardEvent) {
      yield* _updateEntry(_editCard(event));
    }

    if (event is MoveCardEvent) {
      yield* _updateEntry(_moveCard(event));
    }

    if (event is RemoveCardEvent) {
      yield* _updateEntry(_removeCard(event));
    }

    if (event is AddLabelEvent) {
      yield* _updateEntry(_addLabel(event));
    }

    if (event is EditLabelEvent) {
      yield* _updateEntry(_editLabel(event));
    }

    if (event is RemoveLabelEvent) {
      yield* _updateEntry(_removeLabel(event));
    }

    if (event is AddMilestoneEvent) {
      yield* _updateEntry(_addMilestone(event));
    }

    if (event is EditMilestoneEvent) {
      yield* _updateEntry(_editMilestone(event));
    }

    if (event is RemoveMilestoneEvent) {
      yield* _updateEntry(_removeMilestone(event));
    }
  }

  @override
  Future<void> close() {
    _catalogSubscription.cancel();

    return super.close();
  }

  /// Calls [catalogBloc] to update the board catalog when a new Kanban board
  /// state is ready.
  Stream<BoardData> _updateEntry(Future<BoardData> data) async* {
    final BoardData newState = await data;

    yield newState;

    catalogBloc.add(
      UpdateEntryEvent(
        CatalogEntry(
          id: newState.id,
          updated: newState.updated,
          title: newState.title,
          color: newState.theme.appColor,
          totalColumns: newState.totalColumns,
          totalCards: newState.totalCards,
        ),
      ),
    );
  }

  /// Loads a Kanban board.
  Future<BoardData> _loadBoard(LoadBoardEvent event) =>
      repository.load(event.id);

  /// Unloads this Kanban board.
  ///
  /// Returns a new empty board.
  Future<BoardData> _unloadBoard(UnloadBoardEvent event) async => BoardData();

  /// Add a new Kanban board.
  Future<void> _addBoard(AddBoardEvent event) async {
    final DateTime updated = DateTime.now();

    await repository.save(event.data.copyWith(updated: updated));

    catalogBloc
      ..add(
        UpdateEntryEvent(
          CatalogEntry(
            id: event.data.id,
            updated: updated,
            title: event.data.title,
            color: event.data.theme.appColor,
            totalColumns: event.data.totalColumns,
            totalCards: event.data.totalCards,
          ),
        ),
      )
      ..add(UpdateRecentEvent(event.data.id));
  }

  /// Edits this Kanban board.
  Future<BoardData> _editBoard(EditBoardEvent event) {
    assert(event.data.id == state.id);

    final BoardData data = event.data.copyWith(
      updated: DateTime.now(),
      columns: List.of(state.columns),
    );

    return repository.save(data);
  }

  /// Removes a Kanban board.
  Future<void> _removeBoard(RemoveBoardEvent event) async {
    await repository.delete(event.id);

    catalogBloc.add(DeleteEntryEvent(event.id));
  }

  /// Adds a column to this Kanban board.
  Future<BoardData> _addColumn(AddColumnEvent event) {
    final BoardData data = state.copyWith(
      updated: DateTime.now(),
      columns: List.of(state.columns)
        ..add(event.data.copyWith(updated: DateTime.now())),
    );

    return repository.save(data);
  }

  /// Edits a column on this Kanban board.
  Future<BoardData> _editColumn(EditColumnEvent event) {
    final ColumnData column = event.data.copyWith(updated: DateTime.now());
    final List<ColumnData> columns = List.of(state.columns)
      ..[event.position.columnIndex] = column;
    final BoardData data = state.copyWith(
      updated: DateTime.now(),
      columns: columns,
    );

    return repository.save(data);
  }

  /// Moves a column on this Kanban board.
  Future<BoardData> _moveColumn(MoveColumnEvent event) {
    assert(event.from.boardIndex == event.to.boardIndex);

    final List<ColumnData> columns = List.of(state.columns);
    final ColumnData column = columns.removeAt(event.from.columnIndex);
    if (event.from.columnIndex < event.to.columnIndex) {
      columns.insert(event.to.columnIndex - 1, column);
    } else {
      columns.insert(event.to.columnIndex, column);
    }
    final BoardData data = state.copyWith(
      updated: DateTime.now(),
      columns: columns,
    );

    return repository.save(data);
  }

  /// Removes a column from this Kanban board.
  Future<BoardData> _removeColumn(RemoveColumnEvent event) {
    final List<ColumnData> columns = List.of(state.columns)
      ..removeAt(event.position.columnIndex);
    final BoardData data = state.copyWith(
      updated: DateTime.now(),
      columns: columns,
    );

    return repository.save(data);
  }

  /// Adds a card to this Kanban board.
  Future<BoardData> _addCard(AddCardEvent event) {
    final List<CardData> cards =
        List.of(state.columns[event.position.columnIndex].cards)
          ..add(event.data.copyWith(updated: DateTime.now()));
    final ColumnData column =
        state.columns[event.position.columnIndex].copyWith(
      updated: DateTime.now(),
      cards: cards,
    );
    final List<ColumnData> columns = List.of(state.columns)
      ..[event.position.columnIndex] = column;
    final BoardData data = state.copyWith(
      updated: DateTime.now(),
      columns: columns,
    );

    return repository.save(data);
  }

  /// Edits a card on this Kanban board.
  Future<BoardData> _editCard(EditCardEvent event) {
    final List<CardData> cards =
        List.of(state.columns[event.position.columnIndex].cards)
          ..[event.position.cardIndex] =
              event.data.copyWith(updated: DateTime.now());
    final ColumnData column =
        state.columns[event.position.columnIndex].copyWith(
      updated: DateTime.now(),
      cards: cards,
    );
    final List<ColumnData> columns = List.of(state.columns)
      ..[event.position.columnIndex] = column;
    final BoardData data = state.copyWith(
      updated: DateTime.now(),
      columns: columns,
    );

    return repository.save(data);
  }

  /// Moves a card on this Kanban board.
  Future<BoardData> _moveCard(MoveCardEvent event) {
    assert(event.from.boardIndex == event.to.boardIndex);

    if (event.from.columnIndex == event.to.columnIndex) {
      // Changing the index of the card within the same column.
      final List<CardData> cards =
          List.of(state.columns[event.from.columnIndex].cards);
      final CardData card = cards.removeAt(event.from.cardIndex);
      if (event.from.cardIndex < event.to.cardIndex) {
        cards.insert(event.to.cardIndex - 1, card);
      } else {
        cards.insert(event.to.cardIndex, card);
      }

      final ColumnData column = state.columns[event.from.columnIndex]
          .copyWith(updated: DateTime.now(), cards: cards);
      final List<ColumnData> columns = List.of(state.columns)
        ..[event.from.columnIndex] = column;
      final BoardData data = state.copyWith(
        updated: DateTime.now(),
        columns: columns,
      );

      return repository.save(data);
    } else {
      // Moving the card from one column to another.
      final List<CardData> fromCards =
          List.of(state.columns[event.from.columnIndex].cards);
      final CardData card = fromCards.removeAt(event.from.cardIndex);
      final ColumnData fromColumn =
          state.columns[event.from.columnIndex].copyWith(
        updated: DateTime.now(),
        cards: fromCards,
      );

      final List<CardData> toCards =
          List.of(state.columns[event.to.columnIndex].cards)
            ..insert(event.to.cardIndex, card);
      final ColumnData toColumn = state.columns[event.to.columnIndex].copyWith(
        updated: DateTime.now(),
        cards: toCards,
      );

      final List<ColumnData> columns = List.of(state.columns)
        ..[event.from.columnIndex] = fromColumn
        ..[event.to.columnIndex] = toColumn;
      final BoardData data = state.copyWith(
        updated: DateTime.now(),
        columns: columns,
      );

      return repository.save(data);
    }
  }

  /// Removes a card from this Kanban board.
  Future<BoardData> _removeCard(RemoveCardEvent event) {
    final List<CardData> cards =
        List.of(state.columns[event.position.columnIndex].cards)
          ..removeAt(event.position.cardIndex);
    final ColumnData column = state.columns[event.position.columnIndex]
        .copyWith(updated: DateTime.now(), cards: cards);
    final List<ColumnData> columns = List.of(state.columns)
      ..[event.position.columnIndex] = column;
    final BoardData data = state.copyWith(
      updated: DateTime.now(),
      columns: columns,
    );

    return repository.save(data);
  }

  /// Adds a label to this Kanban board.
  Future<BoardData> _addLabel(AddLabelEvent event) {
    final Set<Label> labels = Set.of(state.labels)
      ..add(event.data.copyWith(updated: DateTime.now()));
    final BoardData data = state.copyWith(
      updated: DateTime.now(),
      labels: labels,
    );

    return repository.save(data);
  }

  /// Edits a label on this Kanban board.
  ///
  /// Besides editing the [Label] itself, we also need to find and update every
  /// [CardData] that has this [Label] attached.
  Future<BoardData> _editLabel(EditLabelEvent event) {
    final Label label = event.data.copyWith(updated: DateTime.now());
    final Set<Label> labels = Set.of(state.labels)
      ..removeWhere((e) => e.id == label.id)
      ..add(label);
    final List<ColumnData> columns = state.columns
        .map<ColumnData>((e) => e.copyWith(cards: List.of(e.cards)))
        .toList();
    columns.forEach((column) {
      for (int i = 0; i < column.cards.length; i++) {
        if (column.cards[i].labels.where((e) => e.id == label.id).isNotEmpty) {
          column.cards[i] = column.cards[i].copyWith(
            updated: DateTime.now(),
            labels: Set.of(column.cards[i].labels)
              ..removeWhere((e) => e.id == label.id)
              ..add(label),
          );
        }
      }
    });
    final BoardData data = state.copyWith(
      updated: DateTime.now(),
      columns: columns,
      labels: labels,
    );

    return repository.save(data);
  }

  /// Removes a label from this Kanban board.
  ///
  /// Besides removing the [Label] itself, we also need to find and update every
  /// [CardData] that has this [Label] attached.
  Future<BoardData> _removeLabel(RemoveLabelEvent event) {
    final Set<Label> labels = Set.of(state.labels)
      ..removeWhere((e) => e.id == event.data.id);
    final List<ColumnData> columns = state.columns
        .map<ColumnData>((e) => e.copyWith(cards: List.of(e.cards)))
        .toList();
    columns.forEach((column) {
      for (int i = 0; i < column.cards.length; i++) {
        if (column.cards[i].labels
            .where((e) => e.id == event.data.id)
            .isNotEmpty) {
          column.cards[i] = column.cards[i].copyWith(
            updated: DateTime.now(),
            labels: Set.of(column.cards[i].labels)
              ..removeWhere((e) => e.id == event.data.id),
          );
        }
      }
    });
    final BoardData data = state.copyWith(
      updated: DateTime.now(),
      columns: columns,
      labels: labels,
    );

    return repository.save(data);
  }

  /// Adds a milestone to this Kanban board.
  Future<BoardData> _addMilestone(AddMilestoneEvent event) {
    final Set<Milestone> milestones = Set.of(state.milestones)
      ..add(event.data.copyWith(updated: DateTime.now()));
    final BoardData data = state.copyWith(
      updated: DateTime.now(),
      milestones: milestones,
    );

    return repository.save(data);
  }

  /// Edits a milestone on this Kanban board.
  ///
  /// Besides editing the [Milestone] itself, we also need to find and update
  /// every [CardData] that has this [Milestone] attached.
  Future<BoardData> _editMilestone(EditMilestoneEvent event) {
    final Milestone milestone = event.data.copyWith(updated: DateTime.now());
    final Set<Milestone> milestones = Set.of(state.milestones)
      ..removeWhere((e) => e.id == milestone.id)
      ..add(milestone);
    final List<ColumnData> columns = state.columns
        .map<ColumnData>((e) => e.copyWith(cards: List.of(e.cards)))
        .toList();
    columns.forEach((column) {
      for (int i = 0; i < column.cards.length; i++) {
        if (column.cards[i].milestone != null &&
            column.cards[i].milestone!.id == milestone.id) {
          column.cards[i] = column.cards[i].copyWith(
            updated: DateTime.now(),
            milestone: milestone,
          );
        }
      }
    });
    final BoardData data = state.copyWith(
      updated: DateTime.now(),
      columns: columns,
      milestones: milestones,
    );

    return repository.save(data);
  }

  /// Removes a milestone from this Kanban board.
  ///
  /// Besides removing the [Milestone] itself, we also need to find and update
  /// every [CardData] that has this [Milestone] attached.
  Future<BoardData> _removeMilestone(RemoveMilestoneEvent event) {
    final Set<Milestone> milestones = Set.of(state.milestones)
      ..removeWhere((e) => e.id == event.data.id);
    final List<ColumnData> columns = state.columns
        .map<ColumnData>((e) => e.copyWith(cards: List.of(e.cards)))
        .toList();
    columns.forEach((column) {
      for (int i = 0; i < column.cards.length; i++) {
        if (column.cards[i].milestone != null &&
            column.cards[i].milestone!.id == event.data.id) {
          column.cards[i] = column.cards[i].copyWith(
            updated: DateTime.now(),
            clearMilestone: true,
          );
        }
      }
    });
    final BoardData data = state.copyWith(
      updated: DateTime.now(),
      columns: columns,
      milestones: milestones,
    );

    return repository.save(data);
  }
}
