import '../models/board_catalog.dart';
import 'catalog_repository.dart';

/// The mock repository for Kanban board catalog.
class MockCatalogRepository implements CatalogRepository {
  @override
  Future<BoardCatalog> load() async => _catalog;

  @override
  Future<BoardCatalog> save(BoardCatalog catalog) async {
    _catalog = catalog;

    return catalog;
  }

  static BoardCatalog _catalog = BoardCatalog();
}
