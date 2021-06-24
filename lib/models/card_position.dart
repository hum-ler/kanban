/// The relative position of a card within a Kanban board and column.
///
/// The position can be used as a reference to the card that is currently
/// occupying that spot. However, it is not tied to any specific card, as cards
/// can be added, deleted, or moved.
class CardPosition {
  /// The 0-based index of the board.
  final int boardIndex;

  /// The 0-based index of the column.
  final int columnIndex;

  /// The 0-based index of the card.
  final int cardIndex;

  /// Creates an instance of [CardPosition].
  const CardPosition({
    required this.boardIndex,
    required this.columnIndex,
    required this.cardIndex,
  })   : assert(boardIndex >= 0),
        assert(columnIndex >= 0),
        assert(cardIndex >= 0);
}
