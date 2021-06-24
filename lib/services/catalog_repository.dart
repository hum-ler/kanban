import '../models/board_catalog.dart';

/// The repository for Kanban board catalog.
abstract class CatalogRepository {
  /// Loads the catalog from the repository.
  Future<BoardCatalog> load();

  /// Saves the catalog to the repository.
  Future<BoardCatalog> save(BoardCatalog catalog);
}
