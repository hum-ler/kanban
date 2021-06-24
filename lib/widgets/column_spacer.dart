import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../config.dart';
import '../models/column_position.dart';
import '../services/board_bloc.dart';
import '../services/board_event.dart';
import 'board_viewer.dart';

/// Draws an expandable spacer between Kanban columns.
///
/// Acts as [DragTarget] that accepts certain [ColumnPosition] data. Typically
/// this is the payload from a [ColumnHeader] (via [LongPressDraggable.data]).
///
/// When acceptable data is over this spacer, the width is increased, creating
/// the visual effect of a gap opening between two adjacent [KColumn]s.
///
/// [ColumnSpacer.position] is the "destination" position for the accepted data
/// (it being the "source" position).
class ColumnSpacer extends StatefulWidget {
  /// The position of this spacer.
  final ColumnPosition position;

  /// The collapsed width of this spacer.
  final double? width;

  /// The expanded width of this spacer.
  final double? expandedWidth;

  /// Indicates whether this spacer is allowed to expand.
  final bool canExpand;

  /// Creates an instance of [ColumnSpacer].
  const ColumnSpacer({
    required this.position,
    this.width,
    this.expandedWidth,
    this.canExpand = true,
    Key? key,
  }) : super(key: key);

  @override
  _ColumnSpacerState createState() => _ColumnSpacerState();
}

class _ColumnSpacerState extends State<ColumnSpacer> {
  /// The current width of the spacer.
  double _width = columnSpacerWidth;

  @override
  void initState() {
    super.initState();

    _width = widget.width ?? columnSpacerWidth;
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<ColumnPosition>(
      builder: (context, _, __) => AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: _width,
      ),
      onWillAccept: _onWillAccept,
      onMove: (details) {
        if (widget.canExpand && _onWillAccept(details.data)) {
          setState(() {
            _width = widget.expandedWidth ?? columnSpacerExpandedWidth;
          });
        }
      },
      onLeave: (_) {
        setState(() {
          _width = widget.width ?? columnSpacerWidth;
        });
      },
      onAccept: (data) {
        BoardViewer.of(context).stop();

        setState(() {
          _width = widget.width ?? columnSpacerWidth;
        });

        context.read<BoardBloc>().add(MoveColumnEvent(data, widget.position));
      },
    );
  }

  /// Checks whether [data] will be accepted by this spacer.
  bool _onWillAccept(ColumnPosition? data) {
    if (data == null) return false;

    // For now, reject if the list is from a different board.
    if (data.boardIndex != widget.position.boardIndex) return false;

    // Reject if the column is just to the left or right of the spacer i.e. no
    // move.
    if (data.columnIndex == widget.position.columnIndex ||
        data.columnIndex == widget.position.columnIndex - 1) return false;

    return true;
  }
}
