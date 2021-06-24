import '../models/board_catalog.dart';

abstract class CatalogEvent {}

class LoadCatalogEvent extends CatalogEvent {}

class UnloadCatalogEvent extends CatalogEvent {}

class UpdateRecentEvent extends CatalogEvent {
  final String id;

  UpdateRecentEvent(this.id);
}

class ClearRecentEvent extends CatalogEvent {}

class UpdateEntryEvent extends CatalogEvent {
  final CatalogEntry entry;

  UpdateEntryEvent(this.entry);
}

class DeleteEntryEvent extends CatalogEvent {
  final String id;

  DeleteEntryEvent(this.id);
}
