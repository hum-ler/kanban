import 'package:flutter/material.dart';

/// Wraps an [AlertDialog] with an associated color.
class KDialog extends StatelessWidget {
  /// The color of this dialog.
  final Color color;

  /// The title of this dialog.
  final Widget? title;

  /// The content of this dialog.
  final Widget? content;

  /// The actions of this dialog.
  final List<Widget>? actions;

  /// Creates an instance of [KDialog].
  const KDialog({
    required this.color,
    this.title,
    this.content,
    this.actions,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: color,
        colorScheme: ColorScheme.light().copyWith(primary: color),
      ),
      child: AlertDialog(
        title: title,
        content: content,
        actions: actions,
      ),
    );
  }
}
