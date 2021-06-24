import '../models/board_data.dart';
import 'board_repository.dart';

/// The mock repository for Kanban board data.
///
/// There is no persistence for any changes.
class MockBoardRepository implements BoardRepository {
  @override
  Future<BoardData> load(String id) async => _boards[id]!;

  @override
  Future<BoardData> save(BoardData data) async {
    _boards[data.id] = data;

    return data;
  }

  @override
  Future<void> delete(String id) async => _boards.remove(id);

  static Map<String, BoardData> _boards = {};
}
