import 'package:flutter/material.dart';

import 'color_circle.dart';
import 'color_selection_grid.dart';
import 'k_dialog.dart';

/// Shows a dialog for the user to select a Material color.
class ColorPicker extends StatelessWidget {
  /// Indicates whether to show a "clear" button.
  ///
  /// The usual scenario where this button is useful is to allow the user to
  /// clear a color that was saved previously.
  ///
  /// When the button is tapped, [onCleared] will be called.
  ///
  /// Defaults to true.
  final bool showClearButton;

  /// Indicates whether to select the "clear" button.
  ///
  /// Defaults to true.
  final bool selectClearButton;

  /// The value of this widget.
  final Color value;

  /// The color of the picker dialog itself.
  final Color dialogColor;

  /// Indicates whether the user can select between different shades of a
  /// Material color.
  ///
  /// If set to true, color selection becomes a two-step process: first, the
  /// user selects a main color, and then, second, selects a shade of the main
  /// color.
  ///
  /// Defaults to true.
  final bool selectShade;

  /// Called when the "clear" button is tapped.
  final void Function()? onCleared;

  /// Called when the "CANCEL" option is tapped.
  final void Function()? onCanceled;

  /// Called when the "OK" option is tapped.
  final void Function(Color value)? onSelected;

  // Creates an instance of [ColorPicker].
  const ColorPicker({
    this.showClearButton = true,
    this.selectClearButton = true,
    required this.value,
    required this.dialogColor,
    this.selectShade = true,
    this.onCleared,
    this.onCanceled,
    this.onSelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color selectedColor = value;

    return Row(
      children: [
        if (showClearButton)
          ChoiceChip(
            label: Icon(Icons.cancel),
            selected: selectClearButton,
            onSelected: (_) {
              if (onCleared != null) onCleared!();
            },
          ),
        if (showClearButton) SizedBox(width: 8.0),
        ColorCircle(
          color: value,
          onTap: () => showDialog(
            context: context,
            builder: (context) => KDialog(
              color: dialogColor,
              content: Container(
                width: 300,
                height: 250,
                alignment: Alignment.center,
                child: ColorSelectionGrid(
                  value: value,
                  selectShade: selectShade,
                  onSelected: (value) => selectedColor = value,
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
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();

                    if (onSelected != null) onSelected!(selectedColor);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
