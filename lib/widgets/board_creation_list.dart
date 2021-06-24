import 'package:flutter/material.dart';

import '../models/board_data.dart';
import '../models/board_templates.dart';

/// Shows a list of Kanban board templates available.
class BoardCreationList extends StatelessWidget {
  /// Called when a template is selected.
  final void Function(BoardData value)? onSelected;

  /// Creates an instance of [BoardCreationList].
  const BoardCreationList({
    this.onSelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text('Default'),
        ListTile(
          dense: true,
          title: Text('Empty board'),
          onTap: () {
            if (onSelected != null) onSelected!(BoardTemplates.empty);
          },
        ),
        SizedBox(height: 8.0),
        Text('Other templates'),
        ListTile(
          dense: true,
          title: Text('Software Project'),
          subtitle: Text('To Do, Doing, Done'),
          onTap: () {
            if (onSelected != null) onSelected!(BoardTemplates.software);
          },
        ),
        ListTile(
          dense: true,
          title: Text('Weekly Plan'),
          subtitle: Text('Monday, Tuesday, Wednesday, …'),
          onTap: () {
            if (onSelected != null) onSelected!(BoardTemplates.weekly);
          },
        ),
        ListTile(
          dense: true,
          title: Text('Quarterly Plan'),
          subtitle: Text('Q1, Q2, Q3, Q4'),
          onTap: () {
            if (onSelected != null) onSelected!(BoardTemplates.quarterly);
          },
        ),
      ],
    );
  }
}
