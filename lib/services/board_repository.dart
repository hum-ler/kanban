import '../models/board_data.dart';

/// The repository for Kanban board data.
abstract class BoardRepository {
  /// Loads the Kanban board with ID [id].
  Future<BoardData> load(String id);

  /// Saves the Kanban board.
  Future<BoardData> save(BoardData data);

  /// Deletes the Kanban board with ID [id].
  Future<void> delete(String id);
}
