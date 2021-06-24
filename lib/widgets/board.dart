import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../config.dart';
import '../models/board_data.dart';
import '../models/column_data.dart';
import '../models/column_position.dart';
import '../services/board_bloc.dart';
import '../services/board_event.dart';
import 'board_viewer.dart';
import 'column_spacer.dart';
import 'k_column.dart';

/// Lays out a Kanban board.
///
/// From a high-level view, the board is essentially a row of alternating
/// spacers and columns. The spacers serve as drop targets for reordering
/// columns. Similarly, each column consists of spacers and cards, in which
/// case, the spacers are drop targets for reordering cards.
///
/// The size of the board has to be pre-calculated and passed to the
/// [BoardViewer]. Unfortunately, this means that the column, card, and spacer
/// sizes have to be fixed beforehand, losing the flexibility of variable sizing
/// of columns and cards.
///
/// For now, we are only dealing with one board at a time, so
/// [ColumnPosition.boardIndex] and [CardPosition.boardIndex] is always 0.
class Board extends StatelessWidget {
  /// The data for this board.
  final BoardData data;

  /// Creates an instance of [Board].
  const Board(
    this.data, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BoardViewer(
      childSize: Size(
        // Calculate the maximum width based on layout (n spacers, n columns,
        // and 1 expanded spacer).
        data.columns.length * (columnSpacerWidth + columnWidth) +
            columnSpacerExpandedWidth,
        // Calculate the maximum height based on layout (1 column header,
        // n - 1 spacers, n cards, and 1 expanded spacer, where n is the length
        // of the longest column).
        columnHeaderHeight +
            (_getMaxColumnLength(data) - 1) * cardSpacerHeight +
            _getMaxColumnLength(data) * cardHeight +
            cardSpacerExpandedHeight,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < data.columns.length; i++)
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ColumnSpacer(
                  position: ColumnPosition(
                    boardIndex: 0,
                    columnIndex: i,
                  ),
                ),
                KColumn(
                  data: data.columns[i],
                  position: ColumnPosition(
                    boardIndex: 0,
                    columnIndex: i,
                  ),
                ),
              ],
            ),

          // Allow the last spacer to take up any remaining space.
          Expanded(
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                Positioned(
                  left: columnSpacerWidth,
                  child: Container(
                    height: columnHeaderHeight,
                    child: IconButton(
                      icon: Icon(Icons.add_box_outlined),
                      onPressed: () => context.read<BoardBloc>().add(
                            AddColumnEvent(
                              ColumnData(title: 'New Column'),
                            ),
                          ),
                    ),
                  ),
                ),
                ColumnSpacer(
                  position: ColumnPosition(
                    boardIndex: 0,
                    columnIndex: data.columns.length,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Finds the number of cards in the column with the most cards.
  int _getMaxColumnLength(BoardData data) => data.columns
      .map<int>((e) => e.cards.length)
      .fold<int>(0, (v, e) => v > e ? v : e);
}
