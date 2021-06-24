import 'package:replay_bloc/replay_bloc.dart';

import '../models/board_data.dart';
import '../models/card_data.dart';
import '../models/card_position.dart';
import '../models/column_data.dart';
import '../models/column_position.dart';
import '../models/label.dart';
import '../models/milestone.dart';

/// A Kanban board event.
abstract class BoardEvent extends ReplayEvent {}

/// Adds a new Kanban board.
class AddBoardEvent extends BoardEvent {
  final BoardData data;

  AddBoardEvent(this.data);
}

/// Loads the Kanban board with ID [id].
class LoadBoardEvent extends BoardEvent {
  final String id;

  LoadBoardEvent(this.id);
}

/// Edits the current Kanban board.
class EditBoardEvent extends BoardEvent {
  final BoardData data;

  EditBoardEvent(this.data);
}

/// Unloads the current Kanban board.
class UnloadBoardEvent extends BoardEvent {}

/// Removes the Kanban board with ID [id].
class RemoveBoardEvent extends BoardEvent {
  final String id;

  RemoveBoardEvent(this.id);
}

/// Adds a new column.
class AddColumnEvent extends BoardEvent {
  final ColumnData data;

  AddColumnEvent(this.data);
}

/// Edits the column at [position].
class EditColumnEvent extends BoardEvent {
  final ColumnPosition position;

  final ColumnData data;

  EditColumnEvent(this.position, this.data);
}

/// Moves the column at [from] to [to].
class MoveColumnEvent extends BoardEvent {
  final ColumnPosition from;

  final ColumnPosition to;

  MoveColumnEvent(this.from, this.to);
}

/// Removes the column at [position].
class RemoveColumnEvent extends BoardEvent {
  final ColumnPosition position;

  RemoveColumnEvent(this.position);
}

/// Adds a new card to the column at [position].
class AddCardEvent extends BoardEvent {
  final ColumnPosition position;

  final CardData data;

  AddCardEvent(this.position, this.data);
}

/// Edits the card at [position].
class EditCardEvent extends BoardEvent {
  final CardPosition position;

  final CardData data;

  EditCardEvent(this.position, this.data);
}

/// Moves the card at [from] to [to].
class MoveCardEvent extends BoardEvent {
  final CardPosition from;

  final CardPosition to;

  MoveCardEvent(this.from, this.to);
}

/// Removes the card at [position].
class RemoveCardEvent extends BoardEvent {
  final CardPosition position;

  RemoveCardEvent(this.position);
}

/// Adds a new label.
class AddLabelEvent extends BoardEvent {
  final Label data;

  AddLabelEvent(this.data);
}

/// Edits the label with ID [data.id].
class EditLabelEvent extends BoardEvent {
  final Label data;

  EditLabelEvent(this.data);
}

/// Removes the label with ID [label.id].
class RemoveLabelEvent extends BoardEvent {
  final Label data;

  RemoveLabelEvent(this.data);
}

/// Adds a new milestone.
class AddMilestoneEvent extends BoardEvent {
  final Milestone data;

  AddMilestoneEvent(this.data);
}

/// Edits the milestone with ID [data.id].
class EditMilestoneEvent extends BoardEvent {
  final Milestone data;

  EditMilestoneEvent(this.data);
}

/// Removes the milestone with ID [data.id].
class RemoveMilestoneEvent extends BoardEvent {
  final Milestone data;

  RemoveMilestoneEvent(this.data);
}
