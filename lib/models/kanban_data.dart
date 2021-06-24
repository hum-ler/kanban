import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Represents a data object in a Kanban board.
abstract class KanbanData extends Equatable {
  /// The ID of this data object.
  final String id;

  /// Records when this data object is last updated.
  final DateTime updated;

  /// Creates an instance of [KanbanData].
  KanbanData({
    String? id,
    DateTime? updated,
  })  : id = id ?? Uuid().v4(),
        updated = updated ?? DateTime.now();

  @override
  List<Object> get props => [id, updated];
}
