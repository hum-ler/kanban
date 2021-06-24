import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'board_theme_data.dart';
import 'color_converter.dart';
import 'column_data.dart';
import 'kanban_data.dart';
import 'label.dart';
import 'milestone.dart';

part 'board_data.g.dart';

/// The model for the Kanban board data.
///
/// Conceptually, a Kanban board contains a set of columns, which in turn
/// contains a set of cards.
///
/// This class describes the board itself. The column is described by
/// [ColumnData] and the card is by [CardData].
@JsonSerializable()
@ColorConverter()
class BoardData extends KanbanData {
  /// The title of this board.
  final String title;

  /// The description of this board.
  final String description;

  /// The theme of this board.
  final BoardThemeData theme;

  /// The list of columns on this board.
  final List<ColumnData> columns;

  /// The set of labels on this board.
  final SplayTreeSet<Label> labels;

  /// The set of milestones on this board.
  final SplayTreeSet<Milestone> milestones;

  /// The total number of columns on this board.
  int get totalColumns => columns.length;

  /// The total number of cards on this board.
  int get totalCards =>
      columns.fold<int>(0, (prev, e) => prev + e.cards.length);

  /// Creates an instance of [BoardData].
  BoardData({
    String? id,
    DateTime? updated,
    this.title = '',
    this.description = '',
    BoardThemeData? theme,
    List<ColumnData>? columns,
    Set<Label>? labels,
    Set<Milestone>? milestones,
  })  : theme = theme ?? BoardThemeData(),
        columns = columns ?? [],
        labels = SplayTreeSet<Label>.of(labels ?? {}),
        milestones = SplayTreeSet<Milestone>.of(milestones ?? {}),
        super(
          id: id,
          updated: updated,
        );

  factory BoardData.fromJson(Map<String, dynamic> json) =>
      _$BoardDataFromJson(json);
  Map<String, dynamic> toJson() => _$BoardDataToJson(this);

  /// Creates an instance of [BoardData] using this instance as template.
  ///
  /// If an argument is not given (i.e. null), its corresponding value will be
  /// copied from this instance.
  BoardData copyWith({
    String? id,
    DateTime? updated,
    String? title,
    String? description,
    Color? color,
    BoardThemeData? theme,
    List<ColumnData>? columns,
    Set<Label>? labels,
    Set<Milestone>? milestones,
  }) =>
      BoardData(
        id: id ?? this.id,
        updated: updated ?? this.updated,
        title: title ?? this.title,
        description: description ?? this.description,
        theme: theme ?? this.theme,
        columns: columns ?? this.columns,
        labels: labels ?? this.labels,
        milestones: milestones ?? this.milestones,
      );
}
