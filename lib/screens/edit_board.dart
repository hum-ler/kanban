import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../config.dart';
import '../models/board_data.dart';
import '../models/board_theme_data.dart';
import '../models/label.dart';
import '../models/milestone.dart';
import '../services/board_bloc.dart';
import '../services/board_event.dart';
import '../widgets/color_picker.dart';
import '../widgets/color_selection_grid.dart';
import '../widgets/date_picker.dart';
import '../widgets/k_dialog.dart';
import '../widgets/k_text_field.dart';

/// Edits the details for a Kanban board.
class EditBoard extends StatelessWidget {
  /// Indicates whether the title should be focused and selected for editing
  /// when first loaded.
  final bool editTitle;

  /// Creates an instance of [EditBoard].
  const EditBoard({
    this.editTitle = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoardBloc, BoardData>(
      builder: (context, data) => Theme(
        data: ThemeData(
          primaryColor: data.theme.appColor,
          accentColor: data.theme.appAccent,
          bottomAppBarColor: data.theme.appColor,
        ),
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Text('Editing Board: '),
                Expanded(
                  child: Text(
                    data.title,
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(color: data.theme.appForeground),
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
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
                    title: Text('Delete Board?'),
                    content: Text(
                      'This board and all the content in it (columns, cards) will be deleted. Any associated files will also be purged. This action is irreversible!',
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

                          context.read<BoardBloc>()
                            ..add(UnloadBoardEvent())
                            ..add(RemoveBoardEvent(data.id));
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
                  // BoardData.title
                  KTextField(
                    icon: Icons.title,
                    name: 'Title',
                    value: data.title,
                    minLines: 1,
                    maxLines: 3,
                    autofocus: editTitle,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Board title cannot be empty'
                        : null,
                    onFocusLost: (value) => context.read<BoardBloc>().add(
                          EditBoardEvent(
                            data.copyWith(title: value),
                          ),
                        ),
                  ),

                  // BoardData.description
                  KTextField(
                    icon: Icons.article,
                    name: 'Description',
                    value: data.description,
                    style: TextStyle(fontStyle: FontStyle.italic),
                    minLines: 1,
                    maxLines: 10,
                    onFocusLost: (value) => context.read<BoardBloc>().add(
                          EditBoardEvent(
                            data.copyWith(description: value),
                          ),
                        ),
                  ),

                  // BoardData.labels
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Labels',
                      border: InputBorder.none,
                      icon: Icon(Icons.label),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: kIsWeb ? 4.0 : -8.0,
                        children: [
                          ActionChip(
                            label: Icon(Icons.add),
                            onPressed: () => _editLabel(
                              context,
                              data,
                              Label(
                                label: '',
                                color: data.theme.boardColor,
                              ),
                            ),
                          ),
                          for (final Label label in data.labels)
                            ActionChip(
                              label: Text(label.label),
                              backgroundColor: label.color,
                              labelStyle: ChipTheme.of(context)
                                  .labelStyle
                                  .copyWith(color: label.foreground),
                              onPressed: () => _editLabel(
                                context,
                                data,
                                label,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // BoardData.milestones
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Milestones',
                      border: InputBorder.none,
                      icon: Icon(Icons.flag),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: kIsWeb ? 4.0 : -8.0,
                        children: [
                          ActionChip(
                            label: Icon(Icons.add),
                            onPressed: () => _editMilestone(
                              context,
                              data,
                              Milestone(name: ''),
                            ),
                          ),
                          for (final Milestone milestone in data.milestones)
                            ActionChip(
                              label: Text(milestone.name),
                              onPressed: () => _editMilestone(
                                context,
                                data,
                                milestone,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // BoardData.theme
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Theme',
                      border: InputBorder.none,
                      icon: Icon(Icons.color_lens),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ColorPicker(
                                showClearButton: false,
                                value: data.theme.appColor,
                                dialogColor: data.theme.appAccent,
                                onSelected: (value) {
                                  if (value != data.theme.appColor) {
                                    context.read<BoardBloc>().add(
                                          EditBoardEvent(
                                            data.copyWith(
                                              theme: data.theme
                                                  .copyWith(appColor: value),
                                            ),
                                          ),
                                        );
                                  }
                                },
                              ),
                              SizedBox(width: 8.0),
                              ColorPicker(
                                showClearButton: false,
                                value: data.theme.appAccent,
                                dialogColor: data.theme.appAccent,
                                onSelected: (value) {
                                  if (value != data.theme.appAccent) {
                                    context.read<BoardBloc>().add(
                                          EditBoardEvent(
                                            data.copyWith(
                                              theme: data.theme
                                                  .copyWith(appAccent: value),
                                            ),
                                          ),
                                        );
                                  }
                                },
                              ),
                              SizedBox(width: 8.0),
                              ColorPicker(
                                showClearButton: false,
                                value: data.theme.boardColor,
                                dialogColor: data.theme.appAccent,
                                onSelected: (value) {
                                  if (value != data.theme.boardColor) {
                                    context.read<BoardBloc>().add(
                                          EditBoardEvent(
                                            data.copyWith(
                                              theme: data.theme
                                                  .copyWith(boardColor: value),
                                            ),
                                          ),
                                        );
                                  }
                                },
                              ),
                              SizedBox(width: 8.0),
                              ColorPicker(
                                showClearButton: false,
                                value: data.theme.columnColor,
                                dialogColor: data.theme.appAccent,
                                onSelected: (value) {
                                  if (value != data.theme.columnColor) {
                                    context.read<BoardBloc>().add(
                                          EditBoardEvent(
                                            data.copyWith(
                                              theme: data.theme
                                                  .copyWith(columnColor: value),
                                            ),
                                          ),
                                        );
                                  }
                                },
                              ),
                              SizedBox(width: 8.0),
                              ColorPicker(
                                showClearButton: false,
                                value: data.theme.cardColor,
                                dialogColor: data.theme.appAccent,
                                onSelected: (value) {
                                  if (value != data.theme.cardColor) {
                                    context.read<BoardBloc>().add(
                                          EditBoardEvent(
                                            data.copyWith(
                                              theme: data.theme
                                                  .copyWith(cardColor: value),
                                            ),
                                          ),
                                        );
                                  }
                                },
                              ),
                              SizedBox(width: 8.0),
                              SizedBox(
                                width: 48.0,
                                height: 48.0,
                                child: PopupMenuButton<BoardThemeData>(
                                  itemBuilder: (context) => [
                                    for (final BoardThemeData theme
                                        in BoardThemes.themes)
                                      PopupMenuItem<BoardThemeData>(
                                        value: theme,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 36.0,
                                              height: 36.0,
                                              color: theme.appColor,
                                            ),
                                            Container(
                                              width: 36.0,
                                              height: 36.0,
                                              color: theme.appAccent,
                                            ),
                                            Container(
                                              width: 36.0,
                                              height: 36.0,
                                              color: theme.boardColor,
                                            ),
                                            Container(
                                              width: 36.0,
                                              height: 36.0,
                                              color: theme.columnColor,
                                            ),
                                            Container(
                                              width: 36.0,
                                              height: 36.0,
                                              color: theme.cardColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                  icon: Icon(Icons.arrow_drop_down),
                                  onSelected: (value) {
                                    if (value != data.theme) {
                                      context.read<BoardBloc>().add(
                                            EditBoardEvent(
                                              data.copyWith(theme: value),
                                            ),
                                          );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 48.0,
                                alignment: Alignment.center,
                                child: Text(
                                  'App',
                                  style: TextStyle(fontSize: 12.0),
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Container(
                                width: 48.0,
                                alignment: Alignment.center,
                                child: Text(
                                  'Accent',
                                  style: TextStyle(fontSize: 12.0),
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Container(
                                width: 48.0,
                                alignment: Alignment.center,
                                child: Text(
                                  'Board',
                                  style: TextStyle(fontSize: 12.0),
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Container(
                                width: 48.0,
                                alignment: Alignment.center,
                                child: Text(
                                  'Column',
                                  style: TextStyle(fontSize: 12.0),
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Container(
                                width: 48.0,
                                alignment: Alignment.center,
                                child: Text(
                                  'Card',
                                  style: TextStyle(fontSize: 12.0),
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Container(
                                width: 48.0,
                                alignment: Alignment.center,
                                child: Text(
                                  'Presets',
                                  style: TextStyle(fontSize: 12.0),
                                ),
                              ),
                            ],
                          ),
                        ],
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
                'Updated: ' + DateFormat(dateTimeFormat).format(data.updated),
                style: TextStyle(color: data.theme.appForeground),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Shows a dialog for the user to edit (or delete) a label.
  void _editLabel(
    BuildContext context,
    BoardData data,
    Label label,
  ) {
    String newLabel = label.label;
    Color newColor = label.color;

    showDialog(
      context: context,
      builder: (context) => KDialog(
        color: data.theme.appAccent,
        content: Container(
          width: 330.0,
          height: 440.0,
          child: Center(
            child: ListView(
              shrinkWrap: true,
              children: [
                // Label.label
                KTextField(
                  icon: Icons.label,
                  name: 'Label',
                  value: label.label,
                  onChanged: (value) => newLabel = value,
                ),

                // Label.color
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Color',
                    border: InputBorder.none,
                    icon: Icon(Icons.color_lens),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ColorSelectionGrid(
                      value: label.color,
                      onSelected: (value) => newColor = value,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: Text('CANCEL'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('DELETE'),
            onPressed: () async {
              final bool? removeLabel = await showDialog<bool>(
                context: context,
                builder: (context) => KDialog(
                  color: data.theme.appAccent,
                  title: Text('Delete Label?'),
                  content: Text(
                    'The label will be deleted from this board, and from every card that has this label.',
                  ),
                  actions: [
                    TextButton(
                      child: Text('CANCEL'),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    TextButton(
                      child: Text('CONFIRM'),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ],
                ),
              );

              if (removeLabel != null && removeLabel) {
                Navigator.pop(context);

                context.read<BoardBloc>().add(RemoveLabelEvent(label));
              }
            },
          ),
          TextButton(
            child: Text('CONFIRM'),
            onPressed: () {
              Navigator.pop(context);

              if (label.label != newLabel || label.color != newColor) {
                context.read<BoardBloc>().add(
                      EditLabelEvent(
                        label.copyWith(
                          label: newLabel,
                          color: newColor,
                        ),
                      ),
                    );
              }
            },
          ),
        ],
      ),
    );
  }

  /// Shows a dialog for the user to edit (or delete) a milestone.
  void _editMilestone(
    BuildContext context,
    BoardData data,
    Milestone milestone,
  ) {
    String newName = milestone.name;
    DateTime? newDate = milestone.date;

    showDialog(
      context: context,
      builder: (context) => KDialog(
        color: data.theme.appAccent,
        content: Container(
          width: 330.0,
          height: 160.0,
          child: Center(
            child: ListView(
              shrinkWrap: true,
              children: [
                // Milestone.name
                KTextField(
                  icon: Icons.flag,
                  name: 'Name',
                  value: milestone.name,
                  onChanged: (value) => newName = value,
                ),

                // Milestone.date
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    border: InputBorder.none,
                    icon: Icon(Icons.hourglass_full),
                  ),
                  isEmpty: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: DatePicker(
                      color: data.theme.appAccent,
                      value: newDate,
                      firstDate: DateTime.parse('2000-01-01'),
                      lastDate: DateTime.parse('2999-12-31'),
                      childWhenEmpty: Text('Pick a date'),
                      onCleared: () => newDate = null,
                      onSelected: (value) => newDate = value,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: Text('CANCEL'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('DELETE'),
            onPressed: () async {
              final bool? removeMilestone = await showDialog<bool>(
                context: context,
                builder: (context) => KDialog(
                  color: data.theme.appAccent,
                  title: Text('Delete Milestone?'),
                  content: Text(
                    'The milestone will be deleted from this board, and from every card that has this milestone.',
                  ),
                  actions: [
                    TextButton(
                      child: Text('CANCEL'),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    TextButton(
                      child: Text('CONFIRM'),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ],
                ),
              );

              if (removeMilestone != null && removeMilestone) {
                Navigator.pop(context);

                context.read<BoardBloc>().add(RemoveMilestoneEvent(milestone));
              }
            },
          ),
          TextButton(
            child: Text('CONFIRM'),
            onPressed: () {
              Navigator.pop(context);

              if (milestone.name != newName || milestone.date != newDate) {
                context.read<BoardBloc>().add(
                      EditMilestoneEvent(
                        milestone.copyWith(
                          name: newName,
                          date: newDate,
                          clearDate: newDate == null,
                        ),
                      ),
                    );
              }
            },
          ),
        ],
      ),
    );
  }
}
