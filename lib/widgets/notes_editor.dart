import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'k_dialog.dart';

/// Shows a dialog for the user to edit [CardData.notes].
///
/// Embeds a [Markdown] widget to display the rendered notes.
class NotesEditor extends StatelessWidget {
  /// Indicates whether to show a "clear" button.
  ///
  /// When the button is tapped, [onCleared] will be called.
  ///
  /// Defaults to true.
  final bool showClearButton;

  /// Indicates whether the "clear" button is selected.
  ///
  /// Defaults to false.
  final bool selectClearButton;

  /// The value of [CardData.notes].
  final String value;

  /// The optional widget to display when [value.isEmpty] is true.
  final Widget? childWhenEmpty;

  /// The color for the editor dialog itself.
  final Color color;

  /// Called when the "clear" button is tapped.
  final void Function()? onCleared;

  /// Called when the "CANCEL" option is tapped.
  final void Function()? onCanceled;

  /// Called when the "SAVE" option is tapped.
  final void Function(String value)? onSaved;

  /// The [ScrollController] for this widget.
  ///
  /// Useful when this widget is embedded inside another [Scrollable].
  final ScrollController? controller;

  /// Indicates whether to show the embedded Markdown widget.
  final bool showMarkdown;

  NotesEditor({
    this.showClearButton = true,
    this.selectClearButton = false,
    required this.value,
    this.childWhenEmpty,
    required this.color,
    this.onCleared,
    this.onCanceled,
    this.onSaved,
    this.controller,
    this.showMarkdown = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Theme(
          data: ThemeData(
            colorScheme: ColorScheme.light().copyWith(primary: color),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showClearButton && value.isNotEmpty)
                ChoiceChip(
                  label: Icon(Icons.cancel),
                  selected: selectClearButton,
                  onSelected: (_) {
                    if (onCleared != null) onCleared!();
                  },
                ),
              if (showClearButton && value.isNotEmpty) SizedBox(width: 8.0),
              TextButton(
                child: value.isNotEmpty
                    ? Text('Edit notes')
                    : childWhenEmpty ??
                        Container(
                          // Make this big enough to tap.
                          width: 100.0,
                          height: 16.0,
                        ),
                onPressed: () => _showDialog(context),
              ),
            ],
          ),
        ),
        if (showMarkdown && value.isNotEmpty) SizedBox(height: 4.0),
        if (showMarkdown && value.isNotEmpty)
          Markdown(
            data: value,
            shrinkWrap: true,
            padding: const EdgeInsets.all(0.0),
            controller: controller,
          ),
      ],
    );
  }

  /// Shows the actual notes editor dialog.
  Future<void> _showDialog(
    BuildContext context,
  ) async {
    final TextEditingController controller = TextEditingController(text: value);

    showDialog(
      context: context,
      builder: (context) => KDialog(
        color: color,
        content: Container(
          width: 400,
          height: 400,
          alignment: Alignment.center,
          child: TextFormField(
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Edit notes (in plain text or Markdown syntax)',
            ),
            controller: controller,
            minLines: 20,
            maxLines: 20,
          ),
        ),
        actions: [
          TextButton(
            child: Text('CANCEL'),
            onPressed: () {
              Navigator.of(context).pop();

              if (onCanceled != null) onCanceled!();
            },
          ),
          TextButton(
            child: Text('SAVE'),
            onPressed: () {
              Navigator.of(context).pop();

              if (onSaved != null) onSaved!(controller.text);
            },
          ),
        ],
      ),
    );
  }
}
