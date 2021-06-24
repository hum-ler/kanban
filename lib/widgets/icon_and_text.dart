import 'package:flutter/material.dart';

import '../config.dart';

/// Draws a leading icon and text label in the style of a [TextButton].
///
/// For an alternative, consider using [ListTile].
class IconAndText extends StatelessWidget {
  /// The icon of this widget.
  final IconData icon;

  /// The label of this widget.
  final String label;

  /// The foreground color of this widget.
  final Color color;

  /// Creates an instance of [IconAndText].
  const IconAndText({
    required this.icon,
    required this.label,
    Color? color,
    Key? key,
  })  : color = color ?? defaultAppColor,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
          ),
          SizedBox(width: 8.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
