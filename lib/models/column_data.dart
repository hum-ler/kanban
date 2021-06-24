import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../config.dart';
import 'board_theme_data.dart';
import 'card_data.dart';
import 'color_converter.dart';
import 'kanban_data.dart';

part 'column_data.g.dart';

/// The model for the Kanban column data.
@JsonSerializable()
@ColorConverter()
@NullableColorConverter()
class ColumnData extends KanbanData {
  /// The title of this column.
  final String title;

  /// The description of this column.
  final String description;

  /// The background color of this column.
  final Color? color;

  /// The foreground color of this column.
  ///
  /// This is usually automatically computed from [color].
  final Color? foreground;

  /// The [Brightness] of [color].
  ///
  /// This is usually automatically computed from [color].
  final Brightness? brightness;

  /// The WIP limit of this column.
  ///
  /// Must be >= 1.
  final int limit;

  /// The list of cards in this column.
  final List<CardData> cards;

  /// Creates an instance of [ColumnData].
  ColumnData({
    String? id,
    DateTime? updated,
    this.title = '',
    this.description = '',
    this.color,
    Color? foreground,
    Brightness? brightness,
    this.limit = defaultColumnLimit,
    List<CardData>? cards,
  })  : assert(limit >= 1),
        foreground = foreground ??
            (color != null ? BoardThemeData.getForegroundColor(color) : null),
        brightness = brightness ??
            (color != null ? BoardThemeData.getBrightness(color) : null),
        cards = cards ?? [],
        super(
          id: id,
          updated: updated,
        );

  factory ColumnData.fromJson(Map<String, dynamic> json) =>
      _$ColumnDataFromJson(json);
  Map<String, dynamic> toJson() => _$ColumnDataToJson(this);

  /// Creates an instance of [ColumnData] using this instance as template.
  ///
  /// To actually set [ColumnData.color], [ColumnData.foreground]
  /// and [ColumnData.brightness] to null, set [clearColors] = true.
  ///
  /// If [color] is given but [foreground] is not, then [ColumnData.foreground]
  /// will be updated automatically.
  /// If [color] is given but [brightness] is not, then [ColumnData.brightness]
  /// will be updated automatically.
  ColumnData copyWith({
    String? id,
    DateTime? updated,
    String? title,
    String? description,
    Color? color,
    Color? foreground,
    Brightness? brightness,
    int? limit,
    List<CardData>? cards,
    bool clearColors = false,
  }) =>
      ColumnData(
        id: id ?? this.id,
        updated: updated ?? this.updated,
        title: title ?? this.title,
        description: description ?? this.description,
        color: clearColors ? null : color ?? this.color,
        foreground: clearColors
            ? null
            : foreground ?? (color != null ? null : this.foreground),
        brightness: clearColors
            ? null
            : brightness ?? (color != null ? null : this.brightness),
        limit: limit ?? this.limit,
        cards: cards ?? this.cards,
      );
}
