import 'package:flutter/material.dart';

import '../models/board_theme_data.dart';

/// Injects a Kanban board theme into the widget tree.
class BoardTheme extends InheritedWidget {
  /// The data for this theme.
  final BoardThemeData data;

  /// The child widget tree.
  final Widget child;

  /// Creates an instance of [BoardTheme].
  BoardTheme({
    required this.data,
    required this.child,
    Key? key,
  }) : super(
          key: key,
          child: child,
        );

  /// Finds the closest ancestor instance of [BoardTheme] that encloses the
  /// given context.
  static BoardTheme of(BuildContext context) {
    final BoardTheme? result =
        context.dependOnInheritedWidgetOfExactType<BoardTheme>();

    assert(result != null, 'No BoardTheme found in context');

    return result!;
  }

  @override
  bool updateShouldNotify(covariant BoardTheme oldWidget) {
    return data != oldWidget.data;
  }
}
