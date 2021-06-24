import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/board_catalog.dart';
import '../services/catalog_bloc.dart';
import 'color_circle.dart';

/// Shows a list of Kanban boards available to the currently signed in user.
///
/// The list is displayed as two sublists: "Recent" and "Other boards".
class BoardSelectionList extends StatelessWidget {
  /// Called when a board is selected.
  final void Function(CatalogEntry value)? onSelected;

  /// Creates an instance of [BoardSelectionList].
  const BoardSelectionList({
    this.onSelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogBloc, BoardCatalog>(
      builder: (context, catalog) {
        final Map<String, CatalogEntry> entries = Map.of(catalog.entries);
        final Iterable<CatalogEntry> recent =
            catalog.recent.map<CatalogEntry>((e) => entries.remove(e)!);
        final Iterable<CatalogEntry> other = entries.values;

        return ListView(
          children: [
            Text('Recent'),
            for (final CatalogEntry entry in recent)
              _EntryListTile(
                entry: entry,
                onTap: onSelected,
              ),
            SizedBox(height: 8.0),
            Text('Other boards'),
            for (final CatalogEntry entry in other)
              _EntryListTile(
                entry: entry,
                onTap: onSelected,
              ),
          ],
        );
      },
    );
  }
}

/// Displays a [CatalogEntry] using a [ListTile].
class _EntryListTile extends StatelessWidget {
  /// The data for this entry.
  final CatalogEntry entry;

  /// Called when this tile is tapped.
  final void Function(CatalogEntry value)? onTap;

  /// Creates an instance of [_EntryListTile].
  const _EntryListTile({
    required this.entry,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Row(
        children: [
          ColorCircle(
            color: entry.color,
            radius: 6.0,
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              entry.title,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      subtitle: Text(
        '${entry.totalColumns} columns, ${entry.totalCards} cards, updated ${_describePastDateTime(entry.updated)}',
      ),
      onTap: () {
        if (onTap != null) onTap!(entry);
      },
    );
  }

  /// Describes a past [DateTime] with a "x days/hours/minutes/seconds ago"
  /// statement.
  String _describePastDateTime(DateTime dateTime) {
    final Duration duration = DateTime.now().difference(dateTime);

    assert(!duration.isNegative);

    if (duration.inDays >= 1) return '${duration.inDays} days ago';
    if (duration.inHours >= 1) return '${duration.inHours} hours ago';
    if (duration.inMinutes >= 1) return '${duration.inMinutes} minutes ago';
    return '${duration.inSeconds} seconds ago';
  }
}
