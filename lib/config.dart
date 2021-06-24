import 'package:flutter/material.dart';

/// The width of a card.
const double cardWidth = 300.0;

/// The height of a card.
const double cardHeight = 150.0;

/// The height of a card spacer when it is not expanded.
const double cardSpacerHeight = 20.0;

/// The height of a card spacer when it is expanded.
const double cardSpacerExpandedHeight = 100.0;

/// The width of a column.
const double columnWidth = 340.0;

/// The default WIP limit for a column.
const int defaultColumnLimit = 12;

/// The column foreground color when its WIP limit is reached or exceeded.
const Color columnLimitExceededForeground =
    Color(0xFFF44336); // Colors.red[500]

/// The width of a column header.
const double columnHeaderWidth = 300.0;

/// The height of a column header.
const double columnHeaderHeight = 50.0;

/// The width of a column spacer when it is not expanded.
const double columnSpacerWidth = 20.0;

/// The width of a column spacer when it is expanded.
const double columnSpacerExpandedWidth = 100.0;

/// The margin within which the pointer will trigger board viewer panning.
const EdgeInsets viewerActivationMargin = EdgeInsets.all(60.0);

/// The resistance of board viewer panning.
const int viewerInertia = 3;

/// The default app color.
///
/// Used as theme primary color.
const Color defaultAppColor = Color(0xFF3949AB); // Colors.indigo[600]

/// The default app accent color.
///
/// Used as theme accent color.
const Color defaultAppAccent = Color(0xFF283593); // Colors.indigo[800]

/// The default board background color.
///
/// Used as theme card and canvas color.
const Color defaultBoardColor = Color(0xFFE8EAF6); // Colors.indigo[50]

/// The default column background color.
const Color defaultColumnColor = Color(0xFF9FA8DA); // Colors.indigo[200]

/// The default card background color.
const Color defaultCardColor = Color(0xFF5C6BC0); // Colors.indigo[400]

/// The foreground color against a dark background.
const Color lightForeground =
    Color(0xFFFFFFFF); // ThemeData.dark().textTheme.bodyText1!.color

/// The foreground color against a light background.
const Color darkForeground =
    Color(0xDD000000); // ThemeData.light().textTheme.bodyText1!.color

/// The chip foreground color against a dark background.
const Color lightChipForeground =
    Color(0xDEFFFFFF); // ThemeData.dark().chipTheme.labelStyle.color

/// The chip foreground color against a light background.
const Color darkChipForeground =
    Color(0xDE000000); // ThemeData.light().chipTheme.labelStyle.color

/// The string format for a date.
const String dateFormat = 'd MMM yyyy';

/// The string format for a date with time.
const String dateTimeFormat = dateFormat + ' h:mm a';

/// The maximum length of the recently loaded boards list.
const int maxRecentListLength = 5;
