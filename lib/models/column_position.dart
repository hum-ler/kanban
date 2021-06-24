/// The relative position of a column within a Kanban board.
///
/// The position can be used as a reference to the column that is currently
/// occupying that spot. However, it is not tied to any specific column, as
/// columns can be added, deleted, or moved.
class ColumnPosition {
  /// The 0-based index of the board.
  final int boardIndex;

  /// The 0-based index of the column.
  final int columnIndex;

  /// Creates an instance of [ColumnPosition].
  ColumnPosition({
    required this.boardIndex,
    required this.columnIndex,
  })   : assert(boardIndex >= 0),
        assert(columnIndex >= 0);
}
