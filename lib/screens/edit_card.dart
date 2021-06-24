import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../config.dart';
import '../models/board_data.dart';
import '../models/card_data.dart';
import '../models/card_position.dart';
import '../models/label.dart';
import '../models/milestone.dart';
import '../services/board_bloc.dart';
import '../services/board_event.dart';
import '../widgets/color_picker.dart';
import '../widgets/date_picker.dart';
import '../widgets/k_dialog.dart';
import '../widgets/k_text_field.dart';
import '../widgets/notes_editor.dart';

/// Edits the details of a Kanban card.
class EditCard extends StatelessWidget {
  /// The position of this card.
  final CardPosition position;

  /// Indicates whether the title should be focused and selected for editing
  /// when first loaded.
  final bool editTitle;

  /// Creates an instance of [EditCard].
  const EditCard(
    this.position, {
    this.editTitle = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoardBloc, BoardData>(
      builder: (context, data) {
        // Get the card data.
        //
        // In the case where the user taps the delete action in the app bar to
        // delete this card, we shall end up loading the next card in the column
        // for a brief moment, at least until we can safely pop this screen. If
        // the deleted card happens to be the very last one, load an empty card
        // instead.
        final CardData card =
            data.columns[position.columnIndex].cards.length > position.cardIndex
                ? data.columns[position.columnIndex].cards[position.cardIndex]
                : CardData();

        final Color cardColor = card.color ?? data.theme.cardColor;
        final Color cardForeground =
            card.foreground ?? data.theme.cardForeground;

        // Controller for the "Add a new task" field.
        final TextEditingController textEditingController =
            TextEditingController();

        // Controller for the main [ListView] and embedded [Markdown] widget.
        final ScrollController scrollController = ScrollController();

        return Theme(
          data: ThemeData(
            primaryColor: cardColor,
            accentColor: cardColor,
            bottomAppBarColor: cardColor,
          ),
          child: Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Text('Editing Card: '),
                  Expanded(
                    child: Hero(
                      tag: card.id,
                      child: Text(
                        card.title,
                        style: Theme.of(context)
                            .textTheme
                            .headline6!
                            .copyWith(color: cardForeground),
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
                      title: Text('Delete Card?'),
                      content: Text(
                        'This card will be deleted. Any associated files will also be purged.',
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
                                .add(RemoveCardEvent(position));
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
                  controller: scrollController,
                  children: [
                    // CardData.title
                    KTextField(
                      icon: Icons.title,
                      name: 'Title',
                      value: card.title,
                      minLines: 1,
                      maxLines: 3,
                      autofocus: editTitle,
                      onFocusLost: (value) => context.read<BoardBloc>().add(
                            EditCardEvent(
                              position,
                              card.copyWith(title: value),
                            ),
                          ),
                    ),

                    // CardData.description
                    KTextField(
                      icon: Icons.article,
                      name: 'Description',
                      value: card.description,
                      style: TextStyle(fontStyle: FontStyle.italic),
                      minLines: 1,
                      maxLines: 10,
                      onFocusLost: (value) => context.read<BoardBloc>().add(
                            EditCardEvent(
                              position,
                              card.copyWith(description: value),
                            ),
                          ),
                    ),

                    // CardData.color
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
                          selectClearButton: card.color == null,
                          value: cardColor,
                          dialogColor: data.theme.appAccent,
                          onCleared: () {
                            if (card.color != null) {
                              context.read<BoardBloc>().add(
                                    EditCardEvent(
                                      position,
                                      card.copyWith(clearColors: true),
                                    ),
                                  );
                            }
                          },
                          onSelected: (value) {
                            if (card.color == null || card.color != value) {
                              if (value == data.theme.cardColor) {
                                // Matches the theme, so clear the custom color.
                                context.read<BoardBloc>().add(
                                      EditCardEvent(
                                        position,
                                        card.copyWith(clearColors: true),
                                      ),
                                    );
                              } else {
                                context.read<BoardBloc>().add(
                                      EditCardEvent(
                                        position,
                                        card.copyWith(color: value),
                                      ),
                                    );
                              }
                            }
                          },
                        ),
                      ),
                    ),

                    // CardData.labels
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Labels',
                        border: InputBorder.none,
                        icon: Icon(Icons.label),
                      ),
                      isEmpty: data.labels.isEmpty,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: kIsWeb ? 4.0 : -8.0,
                          children: [
                            for (final Label label in data.labels)
                              FilterChip(
                                label: Text(label.label),
                                selected: card.labels.contains(label),
                                onSelected: (value) {
                                  Set<Label> labels = card.labels;
                                  if (value) {
                                    labels.add(label);
                                  } else {
                                    labels.remove(label);
                                  }

                                  context.read<BoardBloc>().add(
                                        EditCardEvent(
                                          position,
                                          card.copyWith(labels: labels),
                                        ),
                                      );
                                },
                                selectedColor: label.color,
                                labelStyle: card.labels.contains(label)
                                    ? ChipTheme.of(context)
                                        .labelStyle
                                        .copyWith(color: label.foreground)
                                    : null,
                                checkmarkColor: card.labels.contains(label)
                                    ? label.foreground
                                    : null,
                              ),
                          ],
                        ),
                      ),
                    ),

                    // CardData.milestone
                    InputDecorator(
                      decoration: InputDecoration(
                        hintText: 'Milestone',
                        labelText: 'Milestone',
                        border: InputBorder.none,
                        icon: Icon(Icons.flag),
                      ),
                      isEmpty: data.milestones.isEmpty,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: kIsWeb ? 4.0 : -8.0,
                          children: [
                            if (data.milestones.isNotEmpty)
                              ChoiceChip(
                                label: Icon(Icons.cancel),
                                selected: card.milestone == null,
                                onSelected: (_) {
                                  if (card.milestone != null) {
                                    context.read<BoardBloc>().add(
                                          EditCardEvent(
                                            position,
                                            card.copyWith(clearMilestone: true),
                                          ),
                                        );
                                  }
                                },
                              ),
                            for (final Milestone milestone in data.milestones)
                              ChoiceChip(
                                label: Text(milestone.name),
                                selected: card.milestone == milestone,
                                onSelected: (value) {
                                  context.read<BoardBloc>().add(
                                        EditCardEvent(
                                          position,
                                          card.copyWith(milestone: milestone),
                                        ),
                                      );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),

                    // CardData.dueDate
                    InputDecorator(
                      decoration: InputDecoration(
                        hintText: 'Due Date',
                        labelText: 'Due Date',
                        border: InputBorder.none,
                        icon: Icon(Icons.hourglass_full),
                      ),
                      isEmpty: card.dueDate == null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: DatePicker(
                          color: cardColor,
                          value: card.dueDate,
                          firstDate: DateTime.parse('2000-01-01'),
                          lastDate: DateTime.parse('2999-12-31'),
                          onCleared: () {
                            if (card.dueDate != null) {
                              context.read<BoardBloc>().add(
                                    EditCardEvent(
                                      position,
                                      card.copyWith(clearDueDate: true),
                                    ),
                                  );
                            }
                          },
                          onSelected: (value) {
                            if (value != card.dueDate) {
                              context.read<BoardBloc>().add(
                                    EditCardEvent(
                                      position,
                                      card.copyWith(dueDate: value),
                                    ),
                                  );
                            }
                          },
                        ),
                      ),
                    ),

                    // TODO: File attachements.
                    InputDecorator(
                      decoration: InputDecoration(
                        hintText: 'File Attachments',
                        labelText: 'File Attachments',
                        border: InputBorder.none,
                        icon: Icon(Icons.insert_drive_file),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 4.0),
                      ),
                      isEmpty: true,
                    ),

                    // CardData.tasks
                    InputDecorator(
                      decoration: InputDecoration(
                        hintText: 'Tasks',
                        labelText: 'Tasks',
                        border: InputBorder.none,
                        icon: Icon(Icons.assignment),
                      ),
                      child: Column(
                        children: [
                          for (final Task task in card.tasks)
                            SizedBox(
                              height: 40.0, // limit the height of each row
                              child: Row(
                                children: [
                                  ChoiceChip(
                                    label: Icon(Icons.cancel),
                                    selected: false,
                                    onSelected: (_) {
                                      context.read<BoardBloc>().add(
                                            EditCardEvent(
                                              position,
                                              card.copyWith(
                                                tasks: card.tasks..remove(task),
                                              ),
                                            ),
                                          );
                                    },
                                  ),
                                  SizedBox(width: 4.0),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => _toggleTask(
                                        context,
                                        card,
                                        task,
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          Checkbox(
                                            value: task.isDone,
                                            onChanged: (_) => _toggleTask(
                                              context,
                                              card,
                                              task,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(task.name),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          TextFormField(
                            controller: textEditingController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              hintText: 'Add a new task',
                            ),
                            onFieldSubmitted: (value) {
                              textEditingController.clear();
                              context.read<BoardBloc>().add(
                                    EditCardEvent(
                                      position,
                                      card.copyWith(
                                        tasks: card.tasks
                                          ..add(
                                            Task(
                                              name: value,
                                              isDone: false,
                                            ),
                                          ),
                                      ),
                                    ),
                                  );
                            },
                          ),
                        ],
                      ),
                    ),

                    // CardData.notes
                    InputDecorator(
                      decoration: InputDecoration(
                        hintText: 'Notes',
                        labelText: 'Notes',
                        border: InputBorder.none,
                        icon: Icon(Icons.book),
                      ),
                      isEmpty: card.notes.isEmpty,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: NotesEditor(
                          controller: scrollController,
                          value: card.notes,
                          color: cardColor,
                          onCleared: () {
                            if (card.notes.isNotEmpty) {
                              context.read<BoardBloc>().add(
                                    EditCardEvent(
                                      position,
                                      card.copyWith(notes: ''),
                                    ),
                                  );
                            }
                          },
                          onSaved: (value) => context.read<BoardBloc>().add(
                                EditCardEvent(
                                  position,
                                  card.copyWith(notes: value),
                                ),
                              ),
                        ),
                      ),
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
                  'Updated: ' + DateFormat(dateTimeFormat).format(card.updated),
                  style: TextStyle(color: cardForeground),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Toggles the [Task.isDone] property in [task].
  void _toggleTask(BuildContext context, CardData card, Task task) {
    Set<Task> tasks = card.tasks
      ..remove(task)
      ..add(task.copyWith(isDone: !task.isDone));

    context.read<BoardBloc>().add(
          EditCardEvent(
            position,
            card.copyWith(tasks: tasks),
          ),
        );
  }
}
