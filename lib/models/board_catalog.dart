import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'color_converter.dart';

part 'board_catalog.g.dart';

/// The catalog of all Kanban boards.
@JsonSerializable()
class BoardCatalog extends Equatable {
  /// The list of recently loaded Kanban board IDs.
  ///
  /// The most recently loaded is at index 0.
  final List<String> recent;

  /// The collection of Kanban board metadata.
  final Map<String, CatalogEntry> entries;

  /// Creates an instance of [BoardCatalog].
  BoardCatalog({
    List<String>? recent,
    Map<String, CatalogEntry>? entries,
  })  : recent = recent ?? [],
        entries = entries ?? {};

  factory BoardCatalog.fromJson(Map<String, dynamic> json) =>
      _$BoardCatalogFromJson(json);
  Map<String, dynamic> toJson() => _$BoardCatalogToJson(this);

  /// Creates an instance of [BoardCatalog] using this instance as a template.
  ///
  /// If an argument is not given (i.e. null), its corresponding value will be
  /// copied from this instance.
  BoardCatalog copyWith({
    List<String>? recent,
    Map<String, CatalogEntry>? entries,
  }) =>
      BoardCatalog(
        recent: recent ?? this.recent,
        entries: entries ?? this.entries,
      );

  @override
  List<Object?> get props => [recent, entries];
}

/// An entry on the catalog i.e. the metadata for a Kanban board.
@JsonSerializable()
@ColorConverter()
class CatalogEntry extends Equatable {
  /// The ID of this Kanban board.
  final String id;

  /// Records when this Kanban board is last updated.
  final DateTime updated;

  /// The title of this Kanban board.
  final String title;

  /// The main color of this Kanban board.
  final Color color;

  /// The total number of columns on this Kanban board.
  final int totalColumns;

  /// The total number of cards on this Kanban board.
  final int totalCards;

  /// Creates an instance of [CatalogEntry].
  CatalogEntry({
    required this.id,
    required this.updated,
    required this.title,
    required this.color,
    required this.totalColumns,
    required this.totalCards,
  });

  factory CatalogEntry.fromJson(Map<String, dynamic> json) =>
      _$CatalogEntryFromJson(json);
  Map<String, dynamic> toJson() => _$CatalogEntryToJson(this);

  /// Creates an instance of [CatalogEntry] using this instance as a template.
  ///
  /// If an argument is not given (i.e. null), its corresponding value will be
  /// copied from this instance.
  CatalogEntry copyWith({
    String? id,
    DateTime? updated,
    String? title,
    Color? color,
    int? totalColumns,
    int? totalCards,
  }) =>
      CatalogEntry(
        id: id ?? this.id,
        updated: updated ?? this.updated,
        title: title ?? this.title,
        color: color ?? this.color,
        totalColumns: totalColumns ?? this.totalColumns,
        totalCards: totalCards ?? this.totalCards,
      );

  @override
  List<Object?> get props => [
        id,
        updated,
        title,
        color,
        totalColumns,
        totalCards,
      ];
}
