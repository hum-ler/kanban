import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../config.dart';
import '../models/card_position.dart';
import '../services/board_bloc.dart';
import '../services/board_event.dart';
import 'board_viewer.dart';

/// Draws an expandable spacer between Kanban cards.
///
/// Acts as [DragTarget] that accepts certain [CardPosition] data. Typically
/// this is the payload from a [KCard] (via [LongPressDraggable.data]).
///
/// When acceptable data is over this spacer, the height is increased, creating
/// the visual effect of a gap opening between two adjacent [KCard]s.
///
/// [CardSpacer.position] is the "destination" position for the accepted data
/// (it being the "source" position).
class CardSpacer extends StatefulWidget {
  /// The position of this spacer.
  final CardPosition position;

  /// The collapsed height of this spacer.
  final double? height;

  /// The expanded height of this spacer.
  final double? expandedHeight;

  /// Indicates whether this spacer is allowed to expand.
  final bool canExpand;

  /// Creates an instance of [CardSpacer].
  const CardSpacer({
    required this.position,
    this.height,
    this.expandedHeight,
    this.canExpand = true,
    Key? key,
  }) : super(key: key);

  @override
  _CardSpacerState createState() => _CardSpacerState();
}

class _CardSpacerState extends State<CardSpacer> {
  /// The current height of this spacer.
  double _height = cardSpacerHeight;

  @override
  void initState() {
    super.initState();

    _height = widget.height ?? cardSpacerHeight;
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<CardPosition>(
      builder: (context, _, __) => AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: _height,
        width: cardWidth,
      ),
      onWillAccept: _onWillAccept,
      onMove: (details) {
        if (widget.canExpand && _onWillAccept(details.data)) {
          setState(() {
            _height = widget.expandedHeight ?? cardSpacerExpandedHeight;
          });
        }
      },
      onLeave: (_) {
        setState(() {
          _height = widget.height ?? cardSpacerHeight;
        });
      },
      onAccept: (data) {
        BoardViewer.of(context).stop();

        setState(() {
          _height = widget.height ?? cardSpacerHeight;
        });

        context.read<BoardBloc>().add(MoveCardEvent(data, widget.position));
      },
    );
  }

  /// Checks whether [data] will be accepted by this spacer.
  bool _onWillAccept(CardPosition? data) {
    if (data == null) return false;

    // For now, reject if the card is from a different board.
    if (data.boardIndex != widget.position.boardIndex) return false;

    // Reject if the card is just above or below the spacer i.e. no move.
    if (data.columnIndex == widget.position.columnIndex) {
      if (data.cardIndex == widget.position.cardIndex ||
          data.cardIndex == widget.position.cardIndex - 1) return false;
    }

    return true;
  }
}
