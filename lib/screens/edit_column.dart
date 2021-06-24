import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../config.dart';
import '../models/board_data.dart';
import '../models/column_data.dart';
import '../models/column_position.dart';
import '../services/board_bloc.dart';
import '../services/board_event.dart';
import '../widgets/color_picker.dart';
import '../widgets/k_dialog.dart';
import '../widgets/k_text_field.dart';
import '../widgets/numeric_text_field.dart';

/// Edits the details for a Kanban column.
class EditColumn extends StatelessWidget {
  /// The position of this column.
  final ColumnPosition position;

  /// Indicates whether the title should be focused and selected for editing
  /// when first loaded.
  final bool editTitle;

  /// Creates an instance of [EditColumn].
  const EditColumn(
    this.position, {
    this.editTitle = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoardBloc, BoardData>(
      builder: (context, data) {
        // Get the column data.
        //
        // In the case where the user taps the delete action in the app bar to
        // delete this column, we shall end up loading the next column on the
        // board for a brief moment, at least until we can safely pop this
        // screen. If the deleted column happens to be the very last one, load
        // an empty column instead.
        final ColumnData column = data.columns.length > position.columnIndex
            ? data.columns[position.columnIndex]
            : ColumnData();

        final Color columnColor = column.color ?? data.theme.columnColor;
        final Color columnForeground =
            column.foreground ?? data.theme.columnForeground;

        return Theme(
          data: ThemeData(
            primaryColor: columnColor,
            accentColor: columnColor,
            bottomAppBarColor: columnColor,
          ),
          child: Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Text('Editing Column: '),
                  Expanded(
                    child: Hero(
                      tag: column.id,
                      child: Text(
                        column.title,
                        style: Theme.of(context)
                            .textTheme
                            .headline6!
                            .copyWith(color: columnForeground),
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => KDialog(
                      color: data.theme.appAccent,
                      title: Text('Delete Column?'),
                      content: Text(
                        'This column and all the cards in it will be deleted. Any associated files will also be purged.',
                      ),
                      actions: [
                        TextButton(
                          child: Text('CANCEL'),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton(
                          child: Text('CONFIRM'),
                          onPressed: () {
                            // Double-pop: the dialog plus the edit screen.
                            Navigator.pop(context);
                            Navigator.pop(context);

                            context
                                .read<BoardBloc>()
                                .add(RemoveColumnEvent(position));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: ListView(
                  children: [
                    // ColumnData.title
                    KTextField(
                      icon: Icons.title,
                      name: 'Title',
                      value: column.title,
                      minLines: 1,
                      maxLines: 3,
                      autofocus: editTitle,
                      onFocusLost: (value) => context.read<BoardBloc>().add(
                            EditColumnEvent(
                              position,
                              column.copyWith(title: value),
                            ),
                          ),
                    ),

                    // ColumnData.description
                    KTextField(
                      icon: Icons.article,
                      name: 'Description',
                      value: column.description,
                      style: TextStyle(fontStyle: FontStyle.italic),
                      minLines: 1,
                      maxLines: 10,
                      onFocusLost: (value) => context.read<BoardBloc>().add(
                            EditColumnEvent(
                              position,
                              column.copyWith(description: value),
                            ),
                          ),
                    ),

                    // ColumnData.color
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Color',
                        border: InputBorder.none,
                        icon: Icon(Icons.color_lens),
                      ),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ColorPicker(
                          selectClearButton: column.color == null,
                          value: columnColor,
                          dialogColor: data.theme.appAccent,
                          onCleared: () => context.read<BoardBloc>().add(
                                EditColumnEvent(
                                  position,
                                  column.copyWith(clearColors: true),
                                ),
                              ),
                          onSelected: (value) {
                            if (column.color == null || column.color != value) {
                              if (value == data.theme.columnColor) {
                                // Matches the theme, so clear the custom color.
                                context.read<BoardBloc>().add(
                                      EditColumnEvent(
                                        position,
                                        column.copyWith(clearColors: true),
                                      ),
                                    );
                              } else {
                                context.read<BoardBloc>().add(
                                      EditColumnEvent(
                                        position,
                                        column.copyWith(color: value),
                                      ),
                                    );
                              }
                            }
                          },
                        ),
                      ),
                    ),

                    // ColumnData.limit
                    NumericTextField(
                      icon: Icons.cut,
                      name: 'WIP limit',
                      value: column.limit,
                      minValue: 1,
                      maxValue: 50,
                      style: TextStyle(fontStyle: FontStyle.italic),
                      onFocusLost: (value) {
                        if (value != null) {
                          context.read<BoardBloc>().add(
                                EditColumnEvent(
                                  position,
                                  column.copyWith(limit: value),
                                ),
                              );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              child: Container(
                height: 32.0,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                alignment: Alignment.centerRight,
                child: Text(
                  'Updated: ' +
                      DateFormat(dateTimeFormat).format(column.updated),
                  style: TextStyle(color: columnForeground),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
