import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/board_data.dart';
import '../services/board_bloc.dart';
import '../services/board_event.dart';
import '../services/user_bloc.dart';
import '../widgets/board.dart';
import '../widgets/board_creation_list.dart';
import '../widgets/board_selection_list.dart';
import '../widgets/board_theme.dart';
import '../widgets/icon_and_text.dart';
import '../widgets/k_dialog.dart';
import 'about.dart';
import 'edit_board.dart';

/// The app main screen.
class KApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoardBloc, BoardData>(
      builder: (context, data) => BoardTheme(
        data: data.theme,
        child: Theme(
          data: ThemeData(
            primaryColor: data.theme.appColor,
            accentColor: data.theme.appAccent,
            canvasColor: data.theme.boardColor,
            brightness: data.theme.boardBrightness,
            cardColor: data.theme.boardColor,
          ),
          child: Scaffold(
            appBar: AppBar(
              title: Text(data.title),
              actions: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: data.title.isNotEmpty
                      ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditBoard(
                                editTitle: data.title == 'New Board',
                              ),
                            ),
                          )
                      : null,
                ),
                IconButton(
                  icon: Icon(Icons.undo),
                  onPressed: context.read<BoardBloc>().canUndo
                      ? context.read<BoardBloc>().undo
                      : null,
                ),
                IconButton(
                  icon: Icon(Icons.redo),
                  onPressed: context.read<BoardBloc>().canRedo
                      ? context.read<BoardBloc>().redo
                      : null,
                ),
                PopupMenuButton<_MenuChoice>(
                  icon: Icon(Icons.menu),
                  onSelected: (choice) {
                    switch (choice) {
                      case _MenuChoice.load:
                        _showLoadDialog(context, data.theme.appAccent);
                        break;

                      case _MenuChoice.create:
                        _showCreateDialog(context, data.theme.appAccent);
                        break;

                      case _MenuChoice.settings:
                        break;

                      case _MenuChoice.about:
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => About()),
                        );
                        break;

                      case _MenuChoice.signOut:
                        context.read<BoardBloc>().add(UnloadBoardEvent());
                        context.read<UserBloc>().add(UserEvent.signOut);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<_MenuChoice>(
                      value: _MenuChoice.load,
                      child: IconAndText(
                        icon: Icons.cloud_download,
                        label: 'Load board',
                        color: data.theme.appAccent,
                      ),
                    ),
                    PopupMenuItem<_MenuChoice>(
                      value: _MenuChoice.create,
                      child: IconAndText(
                        icon: Icons.library_add,
                        label: 'Create new board',
                        color: data.theme.appAccent,
                      ),
                    ),
                    PopupMenuItem<_MenuChoice>(
                      value: _MenuChoice.settings,
                      child: IconAndText(
                        icon: Icons.settings,
                        label: 'Settings',
                        color: data.theme.appAccent,
                      ),
                    ),
                    PopupMenuItem<_MenuChoice>(
                      value: _MenuChoice.about,
                      child: IconAndText(
                        icon: Icons.help,
                        label: 'About Kanban',
                        color: data.theme.appAccent,
                      ),
                    ),
                    PopupMenuItem<_MenuChoice>(
                      value: _MenuChoice.signOut,
                      child: IconAndText(
                        icon: Icons.account_circle,
                        label: 'Sign out',
                        color: data.theme.appAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            body: data.title.isNotEmpty
                ? Board(data)
                : Center(
                    child: Theme(
                      data: ThemeData(
                        colorScheme: ColorScheme.light().copyWith(
                          primary: data.theme.appAccent,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton.icon(
                            icon: Icon(Icons.cloud_download),
                            label: Text('Load board'),
                            onPressed: () => _showLoadDialog(
                              context,
                              data.theme.appAccent,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text('or'),
                          ),
                          TextButton.icon(
                            icon: Icon(Icons.library_add),
                            label: Text('Create new board'),
                            onPressed: () => _showCreateDialog(
                              context,
                              data.theme.appAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// Shows a dialog for the user to select a Kanban board to load.
  Future<void> _showLoadDialog(BuildContext context, Color dialogColor) {
    return showDialog<void>(
      context: context,
      builder: (context) => KDialog(
        color: dialogColor,
        title: Text('Load Board'),
        content: Container(
          width: 400.0,
          height: 400.0,
          child: BoardSelectionList(
            onSelected: (value) {
              Navigator.pop(context);

              context.read<BoardBloc>().add(LoadBoardEvent(value.id));
            },
          ),
        ),
        actions: [
          TextButton(
            child: Text('CANCEL'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  /// Shows a dialog for the user to select a template from which to create a
  /// new Kanban board.
  Future<void> _showCreateDialog(BuildContext context, Color dialogColor) {
    return showDialog<void>(
      context: context,
      builder: (context) => KDialog(
        color: dialogColor,
        title: Text('Create New Board'),
        content: Container(
          width: 400.0,
          height: 400.0,
          child: BoardCreationList(
            onSelected: (value) {
              Navigator.pop(context);

              context.read<BoardBloc>().add(AddBoardEvent(value));
            },
          ),
        ),
        actions: [
          TextButton(
            child: Text('CANCEL'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

/// The choices on the popup menu.
enum _MenuChoice {
  load,
  create,
  signOut,
  settings,
  about,
}
