import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../config.dart';
import '../models/board_theme_data.dart';
import '../models/card_data.dart';
import '../models/card_position.dart';
import '../models/column_data.dart';
import '../models/column_position.dart';
import '../services/board_bloc.dart';
import '../services/board_event.dart';
import 'board_theme.dart';
import 'card_spacer.dart';
import 'column_header.dart';
import 'k_card.dart';

/// Lays out a Kanban column.
///
/// From a high-level view, the column is essentially a series of spacers and
/// cards, where the spacers serve as drop targets for reordering cards.
class KColumn extends StatelessWidget {
  // The data for this column.
  final ColumnData data;

  /// The position of this column.
  final ColumnPosition position;

  /// Creates an instance of [KColumn].
  KColumn({
    required this.data,
    required this.position,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BoardThemeData theme = BoardTheme.of(context).data;

    final Color columnColor = data.color ?? theme.columnColor;
    final Color columnForeground = data.foreground ?? theme.columnForeground;
    final Brightness columnBrightness =
        data.brightness ?? theme.columnBrightness;

    return Theme(
      data: ThemeData(
        primaryColor: columnColor,
        brightness: columnBrightness,
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // The background color.
          Ink(
            width: columnWidth,
            color: columnColor,
          ),

          // The list header.
          ColumnHeader(
            data: data,
            position: position,
          ),

          // The colunm itself.
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // If the column is empty, create a fixed-size spacer that covers
              // the entire column header.
              if (data.cards.isEmpty)
                CardSpacer(
                  position: CardPosition(
                    boardIndex: position.boardIndex,
                    columnIndex: position.columnIndex,
                    cardIndex: 0,
                  ),
                  height: columnHeaderHeight,
                  canExpand: false,
                ),
              // Alternating spacers and cards.
              for (int i = 0; i < data.cards.length; i++)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CardSpacer(
                      position: CardPosition(
                        boardIndex: position.boardIndex,
                        columnIndex: position.columnIndex,
                        cardIndex: i,
                      ),
                      // The first spacer should cover the entire column header.
                      height: i == 0 ? columnHeaderHeight : null,
                    ),
                    KCard(
                      data: data.cards[i],
                      position: CardPosition(
                        boardIndex: position.boardIndex,
                        columnIndex: position.columnIndex,
                        cardIndex: i,
                      ),
                    ),
                  ],
                ),

              // Allow the last spacer to take up any remaining space.
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.passthrough,
                  children: [
                    Positioned(
                      top: cardSpacerHeight,
                      child: IconButton(
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: data.cards.length >= data.limit
                              ? columnLimitExceededForeground
                              : columnForeground,
                        ),
                        onPressed: () => context.read<BoardBloc>().add(
                              AddCardEvent(
                                position,
                                CardData(title: 'New Card'),
                              ),
                            ),
                      ),
                    ),
                    CardSpacer(
                      position: CardPosition(
                        boardIndex: position.boardIndex,
                        columnIndex: position.columnIndex,
                        cardIndex: data.cards.length,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
