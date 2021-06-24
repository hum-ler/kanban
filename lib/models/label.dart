import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'board_theme_data.dart';
import 'color_converter.dart';
import 'kanban_data.dart';

part 'label.g.dart';

/// The model for a label.
///
/// Labels (or tags) are used to annotate cards.
///
/// The set of all defined labels for a Kanban board can be found in
/// [BoardData.labels].
///
/// For each card, the set of labels that are attached to that card can be found
/// in [CardData.labels].
@JsonSerializable()
@ColorConverter()
@NullableColorConverter()
class Label extends KanbanData implements Comparable<Label> {
  /// The text of this label.
  final String label;

  /// The background color of this label.
  final Color color;

  /// The foreground color of this label.
  ///
  /// This is the color of text / icons on top of [color] background.
  ///
  /// This is usually automatically computed from [color].
  final Color foreground;

  /// Creates an instance of [Label].
  Label({
    String? id,
    DateTime? updated,
    required this.label,
    required this.color,
    Color? foreground,
  })  : foreground = foreground ?? BoardThemeData.getForegroundColor(color),
        super(
          id: id,
          updated: updated,
        );

  factory Label.fromJson(Map<String, dynamic> json) => _$LabelFromJson(json);
  Map<String, dynamic> toJson() => _$LabelToJson(this);

  /// Creates an instance of [Label] using this instance as template.
  ///
  /// If [color] is given but [foreground] is not, then [Label.foreground] will
  /// be updated automatically.
  Label copyWith({
    String? id,
    DateTime? updated,
    String? label,
    Color? color,
    Color? foreground,
  }) =>
      Label(
        id: id ?? this.id,
        updated: updated ?? this.updated,
        label: label ?? this.label,
        color: color ?? this.color,
        foreground: foreground ?? (color != null ? null : this.foreground),
      );

  @override
  int compareTo(other) => label.compareTo(other.label);
}
