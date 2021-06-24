import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../config.dart';
import '../models/board_theme_data.dart';
import '../models/card_data.dart';
import '../models/card_position.dart';
import '../models/label.dart';
import '../screens/edit_card.dart';
import 'board_theme.dart';
import 'board_viewer.dart';

/// Draws a Kanban card.
///
/// Can be dragged and dropped onto a [CardSpacer] for the purpose of moving the
/// card.
///
/// When tapped, opens the [EditCard] for this card.
class KCard extends StatelessWidget {
  /// The data for this card.
  final CardData data;

  /// The position of this card.
  final CardPosition position;

  /// Creates an instance of [KCard].
  const KCard({
    required this.data,
    required this.position,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BoardThemeData theme = BoardTheme.of(context).data;

    // Use a [LongPressDraggable] instead of [Draggable] to avoid competing with
    // [BoardViewer] for the drag gesture.
    return LongPressDraggable<CardPosition>(
      data: position,
      dragAnchorStrategy: (draggable, context, position) =>
          pointerDragAnchorStrategy(draggable, context, position),
      child: GestureDetector(
        child: _CardDesign(
          data: data,
          tag: data.id,
          theme: theme,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditCard(
              position,
              editTitle: data.title == 'New Card',
            ),
          ),
        ),
      ),
      feedback: Material(
        elevation: 10.0,
        child: Container(
          width: cardWidth * 0.5,
          child: FittedBox(
            fit: BoxFit.contain,
            child: _CardDesign(
              data: data,
              theme: theme,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.6,
        child: _CardDesign(
          data: data,
          theme: theme,
        ),
      ),
      onDragUpdate: BoardViewer.of(context).onDragUpdate,
    );
  }
}

/// Draws the card content.
class _CardDesign extends StatelessWidget {
  /// The data for this card.
  final CardData data;

  /// The hero tag for the card title.
  final String? tag;

  /// The theme for this Kanban board.
  final BoardThemeData theme;

  /// Creates an instance of [_CardDesign].
  const _CardDesign({
    required this.data,
    this.tag,
    required this.theme,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color cardColor = data.color ?? theme.cardColor;
    final Color cardForeground = data.foreground ?? theme.cardForeground;
    final Brightness cardBrightness = data.brightness ?? theme.cardBrightness;

    return Theme(
      data: ThemeData(
        primaryColor: cardColor,
        brightness: cardBrightness,
      ),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.topLeft,
        width: cardWidth,
        height: cardHeight,
        color: cardColor,
        child: Column(
          children: [
            ClipRect(
              child: SizedOverflowBox(
                size: Size(
                  cardWidth,
                  cardHeight - 34.0, // 16 padding, 18 size of bottom row
                ),
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CardData.title
                    tag != null
                        ? Hero(
                            tag: tag!,
                            child: _CardTitle(
                              title: data.title,
                              color: cardForeground,
                            ),
                          )
                        : _CardTitle(
                            title: data.title,
                            color: cardForeground,
                          ),

                    // CardData.description
                    if (data.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          data.description,
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w300,
                                    color: cardForeground,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    // CardData.labels
                    if (data.labels.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Wrap(
                          spacing: 4.0,
                          runSpacing: kIsWeb ? 4.0 : -8.0,
                          children: [
                            for (final Label label in data.labels)
                              Chip(
                                visualDensity: VisualDensity.compact,
                                label: Text(label.label),
                                backgroundColor: label.color,
                                labelStyle: ChipTheme.of(context)
                                    .labelStyle
                                    .copyWith(color: label.foreground),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bottom left -- CardData.milestone
                Row(
                  children: [
                    if (data.milestone != null)
                      Row(
                        children: [
                          Icon(
                            Icons.flag,
                            size: 18.0,
                          ),
                          Text(
                            data.milestone!.name,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(color: cardForeground),
                          ),
                        ],
                      )
                  ],
                ),

                // Bottom right -- indicator icons.
                Row(
                  children: [
                    // CardData.notes
                    if (data.notes.isNotEmpty)
                      Icon(
                        Icons.book,
                        size: 18.0,
                      ),

                    // CardData.tasks -- when there are tasks available.
                    if (data.tasks.isNotEmpty &&
                        data.tasks.any((e) => !e.isDone))
                      Icon(
                        Icons.assignment,
                        size: 18.0,
                      ),

                    // CardData.tasks -- when there are tasks and all of them
                    // are done.
                    if (data.tasks.isNotEmpty &&
                        data.tasks.every((e) => e.isDone))
                      Icon(
                        Icons.assignment_turned_in,
                        size: 18.0,
                      ),

                    // // TODO: File attachments
                    // Icon(
                    //   Icons.insert_drive_file,
                    //   size: 18.0,
                    // ),

                    // CardData.dueDate
                    if (data.dueDate != null)
                      Icon(
                        Icons.hourglass_full,
                        size: 18.0,
                      ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

/// Draws the card title.
class _CardTitle extends StatelessWidget {
  /// The title of this card.
  final String title;

  /// The color of this title.
  final Color color;

  /// Creates an instance of [_CardTitle].
  const _CardTitle({
    required this.title,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodyText1!.copyWith(
            fontWeight: FontWeight.w500,
            color: color,
          ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
