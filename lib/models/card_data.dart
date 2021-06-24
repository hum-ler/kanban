import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import 'board_theme_data.dart';
import 'color_converter.dart';
import 'kanban_data.dart';
import 'label.dart';
import 'milestone.dart';

part 'card_data.g.dart';

/// The model for the Kanban card data.
@JsonSerializable()
@ColorConverter()
@NullableColorConverter()
class CardData extends KanbanData {
  /// The title of this card.
  final String title;

  /// The description of this card.
  final String description;

  /// The background color of this card.
  final Color? color;

  /// The foreground color of this card.
  ///
  /// This is usually automatically computed from [color].
  final Color? foreground;

  /// The [Brightness] of [color].
  ///
  /// This is usually automatically computed from [color].
  final Brightness? brightness;

  /// The set of [Label]s that are attached to this card.
  ///
  /// The entire set of all [Label]s that are defined can be found in
  /// [BoardData.labels].
  final SplayTreeSet<Label> labels;

  /// The milestone that is attached to this card.
  ///
  /// The entire set of all [Milestone]s that are defined can be found in
  /// [BoardData.milestones].
  final Milestone? milestone;

  /// The notes of this card.
  final String notes;

  /// The due date of this card.
  final DateTime? dueDate;

  /// The subtasks for this card.
  final SplayTreeSet<Task> tasks;

  /// Creates an instance of [CardData].
  CardData({
    String? id,
    DateTime? updated,
    this.title = '',
    this.description = '',
    this.color,
    Color? foreground,
    Brightness? brightness,
    Set<Label>? labels,
    this.milestone,
    this.notes = '',
    this.dueDate,
    Set<Task>? tasks,
  })  : foreground = foreground ??
            (color != null ? BoardThemeData.getForegroundColor(color) : null),
        brightness = brightness ??
            (color != null ? BoardThemeData.getBrightness(color) : null),
        labels = SplayTreeSet<Label>.of(labels ?? {}),
        tasks = SplayTreeSet<Task>.of(tasks ?? []),
        super(
          id: id,
          updated: updated,
        );

  factory CardData.fromJson(Map<String, dynamic> json) =>
      _$CardDataFromJson(json);
  Map<String, dynamic> toJson() => _$CardDataToJson(this);

  /// Creates an instance of [CardData] using this instance as template.
  ///
  /// If an argument is not given (i.e. null), its corresponding value will be
  /// copied from this instance.
  ///
  /// To actually set [CardData.color], [CardData.foreground] and
  /// [CardData.brightness] to null, set [clearColors] = true.
  /// To actually set [CardData.milestone] to null, set [clearMilestone] = true.
  /// To actually set [CardData.dueDate] to null, set [clearDueDate] = true.
  ///
  /// If [color] is given but [foreground] is not, then [CardData.foreground]
  /// will be updated automatically.
  /// If [color] is given but [brightness] is not, then [CardData.brightness]
  /// will be updated automatically.
  CardData copyWith({
    String? id,
    DateTime? updated,
    bool? isDeleted,
    String? title,
    String? description,
    Color? color,
    Color? foreground,
    Brightness? brightness,
    Set<Label>? labels,
    Milestone? milestone,
    String? notes,
    DateTime? dueDate,
    Set<Task>? tasks,
    bool clearColors = false,
    bool clearMilestone = false,
    bool clearDueDate = false,
  }) =>
      CardData(
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
        labels: labels ?? this.labels,
        milestone: clearMilestone ? null : milestone ?? this.milestone,
        notes: notes ?? this.notes,
        dueDate: clearDueDate ? null : dueDate ?? this.dueDate,
        tasks: tasks ?? this.tasks,
      );
}

/// A subtask in a Kanban card.
@JsonSerializable()
class Task implements Comparable<Task> {
  /// The ID of this task.
  final String id;

  /// Indicates whether this task is completed.
  final bool isDone;

  /// The name of this task.
  final String name;

  /// Creates an instance of [Task].
  Task({
    String? id,
    this.isDone = false,
    required this.name,
  }) : id = id ?? Uuid().v4();

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);

  /// Creates an instance of [Task] using this instance as template.
  ///
  /// If an argument is not given (i.e. null), its corresponding value will be
  /// copied from this instance.
  Task copyWith({
    String? id,
    bool? isDone,
    String? name,
  }) =>
      Task(
        id: id ?? this.id,
        isDone: isDone ?? this.isDone,
        name: name ?? this.name,
      );

  @override
  int compareTo(Task other) => name.compareTo(other.name);
}
