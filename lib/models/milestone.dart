import 'package:json_annotation/json_annotation.dart';

import 'kanban_data.dart';

part 'milestone.g.dart';

/// The model for a milestone.
///
/// The set of all defined milestones for a Kanban board can be found in
/// [BoardData.milestones].
///
/// Each card can be attached to zero or one milestone, in [CardData.milestone].
@JsonSerializable()
class Milestone extends KanbanData implements Comparable<Milestone> {
  /// The name of this milestone.
  final String name;

  /// The date of this milestone.
  final DateTime? date;

  /// Creates an instance of [Milestone].
  Milestone({
    String? id,
    DateTime? updated,
    required this.name,
    this.date,
  }) : super(
          id: id,
          updated: updated,
        );

  factory Milestone.fromJson(Map<String, dynamic> json) =>
      _$MilestoneFromJson(json);
  Map<String, dynamic> toJson() => _$MilestoneToJson(this);

  /// Creates an instance of [Milestone] using this instance as template.
  ///
  /// If an argument is not given (i.e. null), its corresponding value will be
  /// copied from this instance.
  ///
  /// To actually set [Milestone.date] to null, set [clearDate] = true.
  Milestone copyWith({
    String? id,
    DateTime? updated,
    String? name,
    DateTime? date,
    bool clearDate = false,
  }) =>
      Milestone(
        id: id ?? this.id,
        updated: updated ?? this.updated,
        name: name ?? this.name,
        date: clearDate ? null : date ?? this.date,
      );

  @override
  int compareTo(Milestone other) => name.compareTo(other.name);
}
