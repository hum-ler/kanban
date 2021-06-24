import 'package:flutter/material.dart';

import '../models/board_theme_data.dart';

/// Draws a colored circle that reacts to taps.
class ColorCircle extends StatelessWidget {
  /// The color of this circle.
  final Color color;

  /// The radius of this circle.
  ///
  /// Defaults to 24.0.
  final double radius;

  /// The thickness of the border around this circle.
  ///
  /// Defaults to 0.0 i.e. no border.
  final double borderSize;

  /// The color of the border around this circle.
  ///
  /// This is usually automatically computed from [color].
  final Color? borderColor;

  /// An optional icon to draw in the middle of this circle.
  final IconData? icon;

  /// The color of the icon.
  ///
  /// This is usually automatically computed from [color].
  final Color iconColor;

  /// Called when this circle is tapped.
  final void Function()? onTap;

  /// Creates an instance of [ColorCircle].
  ColorCircle({
    required this.color,
    this.radius = 24.0,
    this.borderSize = 0.0,
    this.borderColor,
    this.icon,
    Color? iconColor,
    this.onTap,
    Key? key,
  })  : assert(radius > 0.0),
        assert(borderSize >= 0.0),
        iconColor = iconColor ?? BoardThemeData.getForegroundColor(color),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: borderSize == 0.0
          ? CircleAvatar(
              radius: radius,
              backgroundColor: color,
              child: icon != null
                  ? Icon(
                      icon,
                      size: radius,
                      color: iconColor,
                    )
                  : null,
            )
          : CircleAvatar(
              radius: radius,
              backgroundColor: borderColor ?? iconColor,
              child: CircleAvatar(
                radius: radius - borderSize,
                backgroundColor: color,
                child: icon != null
                    ? Icon(
                        icon,
                        size: radius,
                        color: iconColor,
                      )
                    : null,
              ),
            ),
      onTap: onTap,
    );
  }
}
