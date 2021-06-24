import 'package:flutter/material.dart';

import '../config.dart';
import '../models/board_theme_data.dart';
import '../models/column_data.dart';
import '../models/column_position.dart';
import '../screens/edit_column.dart';
import 'board_theme.dart';
import 'board_viewer.dart';

/// Draws the header for a Kanban column.
///
/// Can be dragged and dropped onto a [ColumnSpacer] for the purpose of moving
/// the column.
///
/// When tapped, opens [EditColumn] for this column.
class ColumnHeader extends StatelessWidget {
  /// The data for this column.
  final ColumnData data;

  /// The position of this column.
  final ColumnPosition position;

  /// Creates an instance of [ColumnHeader].
  const ColumnHeader({
    required this.data,
    required this.position,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BoardThemeData theme = BoardTheme.of(context).data;

    final Color columnColor = data.color ?? theme.columnColor;
    final Color columnForeground = data.foreground ?? theme.columnForeground;

    // Use a [LongPressDraggable] instead of [Draggable] to avoid competing with
    // [BoardViewer] for the drag gesture.
    return LongPressDraggable<ColumnPosition>(
      data: position,
      dragAnchorStrategy: (draggable, context, position) =>
          pointerDragAnchorStrategy(draggable, context, position),
      child: GestureDetector(
        child: _ColumnHeaderDesign(
          data: data,
          tag: data.id,
          foreground: columnForeground,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditColumn(
              position,
              editTitle: data.title == 'New Column',
            ),
          ),
        ),
      ),
      feedback: Material(
        elevation: 10.0,
        child: Container(
          width: columnHeaderWidth * 0.5,
          child: FittedBox(
            fit: BoxFit.contain,
            child: _ColumnHeaderDesign(
              data: data,
              color: columnColor,
              foreground: columnForeground,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _ColumnHeaderDesign(
          data: data,
          foreground: columnForeground,
        ),
      ),
      onDragUpdate: BoardViewer.of(context).onDragUpdate,
    );
  }
}

/// Draws the header content.
class _ColumnHeaderDesign extends StatelessWidget {
  /// The data for this column.
  final ColumnData data;

  /// The hero tag of the column title.
  final String? tag;

  /// The background color of this header.
  ///
  /// Defaults to [Colors.transparent] to allow the column background color to
  /// filter through.
  final Color? color;

  /// The foreground color of this header.
  final Color foreground;

  /// Creates an instance of [_ColumnHeaderDesign].
  const _ColumnHeaderDesign({
    required this.data,
    this.tag,
    this.color = Colors.transparent,
    required this.foreground,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      alignment: Alignment.centerLeft,
      width: columnHeaderWidth,
      height: columnHeaderHeight,
      color: color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          tag != null
              ? Hero(
                  tag: data.id,
                  child: _ColumnHeaderTitle(
                    title: data.title,
                    color: foreground,
                  ),
                )
              : _ColumnHeaderTitle(
                  title: data.title,
                  color: foreground,
                ),
          Text(
            '${data.cards.length}/${data.limit}',
            style: TextStyle(
              color: data.cards.length >= data.limit
                  ? columnLimitExceededForeground
                  : foreground,
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws the header title.
class _ColumnHeaderTitle extends StatelessWidget {
  /// The title of this list.
  final String title;

  /// The color of this title.
  final Color color;

  /// Creates an instance of [_ColumnHeaderTitle].
  const _ColumnHeaderTitle({
    required this.title,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodyText1!.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
      maxLines: 2,
    );
  }
}
