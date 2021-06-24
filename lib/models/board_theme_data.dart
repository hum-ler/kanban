import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../config.dart';
import 'color_converter.dart';

part 'board_theme_data.g.dart';

/// The theme for a Kanban board.
@JsonSerializable()
@ColorConverter()
@NullableColorConverter()
class BoardThemeData extends Equatable {
  /// The primary color in this theme.
  ///
  /// This is used for [ThemeData.primaryColor].
  final Color appColor;

  /// The foreground color in this theme.
  ///
  /// This is the color for text / icons on top of [appColor] background.
  ///
  /// This is usually automatically computed from [appColor].
  final Color appForeground;

  /// The secondary color in this theme.
  ///
  /// This is used for [ThemeData.accentColor].
  final Color appAccent;

  /// The [Brightness] of [appColor].
  ///
  /// This is usually automatically computed from [appColor].
  final Brightness appBrightness;

  /// The background color for this Kanban board.
  ///
  /// This is used for [ThemeData.canvasColor] and [ThemeData.cardColor].
  final Color boardColor;

  /// The foreground color for this Kanban board.
  ///
  /// This is the color for text / icons on top of [boardColor] background.
  ///
  /// This is usually automatically computed from [boardColor].
  final Color boardForeground;

  /// The [Brightness] of [boardColor].
  ///
  /// This is used for [ThemeData.brightness].
  ///
  /// This is usually automatically computed from [boardColor].
  final Brightness boardBrightness;

  /// The background color for columns in this Kanban board.
  final Color columnColor;

  /// The foreground color for columns in this Kanban board.
  ///
  /// This is the color of text / icons on top of [columnColor] background.
  ///
  /// This is usually automatically computed from [columnColor].
  final Color columnForeground;

  /// The [Brightness] of [columnColor].
  ///
  /// This is usually automatically computed from [columnColor].
  final Brightness columnBrightness;

  /// The background color for cards in this Kanban board.
  final Color cardColor;

  /// The foreground color for cards in this Kanban board.
  ///
  /// This is the color of text / icons on top of [cardColor] background.
  ///
  /// This is usually automatically computed from [cardColor].
  final Color cardForeground;

  /// The [Brightness] of [cardColor].
  ///
  /// This is usually automatically computed from [cardColor].
  final Brightness cardBrightness;

  /// Creates an instance of [BoardThemeData].
  BoardThemeData({
    this.appColor = defaultAppColor,
    Color? appForeground,
    this.appAccent = defaultAppAccent,
    Brightness? primaryBrightness,
    this.boardColor = defaultBoardColor,
    Color? boardForeground,
    Brightness? boardBrightness,
    this.columnColor = defaultColumnColor,
    Color? columnForeground,
    Brightness? columnBrightness,
    this.cardColor = defaultCardColor,
    Color? cardForeground,
    Brightness? cardBrightness,
  })  : appForeground = appForeground ?? getForegroundColor(appColor),
        appBrightness = primaryBrightness ?? getBrightness(appColor),
        boardForeground = boardForeground ?? getForegroundColor(boardColor),
        boardBrightness = boardBrightness ?? getBrightness(boardColor),
        columnForeground = columnForeground ?? getForegroundColor(columnColor),
        columnBrightness = columnBrightness ?? getBrightness(columnColor),
        cardForeground = cardForeground ?? getForegroundColor(cardColor),
        cardBrightness = cardBrightness ?? getBrightness(cardColor);

  factory BoardThemeData.fromJson(Map<String, dynamic> json) =>
      _$BoardThemeDataFromJson(json);
  Map<String, dynamic> toJson() => _$BoardThemeDataToJson(this);

  /// Creates an instance of [BoardThemeData] using this instance as template.
  ///
  /// If an argument is not given (i.e. null), its corresponding value will be
  /// copied from this instance.
  ///
  /// If [appColor] is given but [appForeground] is not, then
  /// [BoardThemeData.appForeground] will be updated automatically.
  /// If [appColor] is given but [appBrightness] is not, then
  /// [BoardThemeData.appBrightness] will be updated automatically.
  /// Similar updates can occur with the board-, column-, and card- versions of
  /// these properties.
  BoardThemeData copyWith({
    Color? appColor,
    Color? appForeground,
    Color? appAccent,
    Brightness? appBrightness,
    Color? boardColor,
    Color? boardForeground,
    Brightness? boardBrightness,
    Color? columnColor,
    Color? columnForeground,
    Brightness? columnBrightness,
    Color? cardColor,
    Color? cardForeground,
    Brightness? cardBrightness,
  }) =>
      BoardThemeData(
        appColor: appColor ?? this.appColor,
        appForeground:
            appForeground ?? (appColor != null ? null : this.appForeground),
        appAccent: appAccent ?? this.appAccent,
        primaryBrightness:
            appBrightness ?? (appColor != null ? null : this.appBrightness),
        boardColor: boardColor ?? this.boardColor,
        boardForeground: boardForeground ??
            (boardColor != null ? null : this.boardForeground),
        boardBrightness: boardBrightness ??
            (boardColor != null ? null : this.boardBrightness),
        columnColor: columnColor ?? this.columnColor,
        columnForeground: columnForeground ??
            (columnColor != null ? null : this.columnForeground),
        columnBrightness: columnBrightness ??
            (columnColor != null ? null : this.columnBrightness),
        cardColor: cardColor ?? this.cardColor,
        cardForeground:
            cardForeground ?? (cardColor != null ? null : this.cardForeground),
        cardBrightness:
            cardBrightness ?? (cardColor != null ? null : this.cardBrightness),
      );

  @override
  List<Object?> get props => [
        appColor,
        appForeground,
        appAccent,
        appBrightness,
        boardColor,
        boardForeground,
        boardBrightness,
        columnColor,
        columnForeground,
        columnBrightness,
        cardColor,
        cardForeground,
        cardBrightness,
      ];

  /// Computes a suitable foreground color from [backgroundColor].
  static Color getForegroundColor(Color backgroundColor) {
    if (backgroundColor == Colors.transparent) return darkForeground;

    return _foregroundCache[backgroundColor] ??
        (ThemeData.estimateBrightnessForColor(backgroundColor) ==
                Brightness.dark
            ? lightForeground
            : darkForeground);
  }

  /// Computes the [Brightness] of [color].
  static Brightness getBrightness(Color color) {
    if (color == Colors.transparent) return Brightness.light;

    return ThemeData.estimateBrightnessForColor(color);
  }

  /// Cache the foreground colors for Material colors.
  static Map<Color, Color> _foregroundCache = {
    // Red
    Colors.red.shade50: darkForeground,
    Colors.red.shade100: darkForeground,
    Colors.red.shade200: darkForeground,
    Colors.red.shade300: lightForeground,
    Colors.red.shade400: lightForeground,
    Colors.red.shade500: lightForeground,
    Colors.red.shade600: lightForeground,
    Colors.red.shade700: lightForeground,
    Colors.red.shade800: lightForeground,
    Colors.red.shade900: lightForeground,
    Colors.redAccent.shade100: darkForeground,
    Colors.redAccent.shade200: lightForeground,
    Colors.redAccent.shade400: lightForeground,
    Colors.redAccent.shade700: lightForeground,

    // Pink
    Colors.pink.shade50: darkForeground,
    Colors.pink.shade100: darkForeground,
    Colors.pink.shade200: darkForeground,
    Colors.pink.shade300: lightForeground,
    Colors.pink.shade400: lightForeground,
    Colors.pink.shade500: lightForeground,
    Colors.pink.shade600: lightForeground,
    Colors.pink.shade700: lightForeground,
    Colors.pink.shade800: lightForeground,
    Colors.pink.shade900: lightForeground,
    Colors.pinkAccent.shade100: darkForeground,
    Colors.pinkAccent.shade200: lightForeground,
    Colors.pinkAccent.shade400: lightForeground,
    Colors.pinkAccent.shade700: lightForeground,

    // Purple
    Colors.purple.shade50: darkForeground,
    Colors.purple.shade100: darkForeground,
    Colors.purple.shade200: darkForeground,
    Colors.purple.shade300: lightForeground,
    Colors.purple.shade400: lightForeground,
    Colors.purple.shade500: lightForeground,
    Colors.purple.shade600: lightForeground,
    Colors.purple.shade700: lightForeground,
    Colors.purple.shade800: lightForeground,
    Colors.purple.shade900: lightForeground,
    Colors.purpleAccent.shade100: darkForeground,
    Colors.purpleAccent.shade200: lightForeground,
    Colors.purpleAccent.shade400: lightForeground,
    Colors.purpleAccent.shade700: lightForeground,

    // Deep purple
    Colors.deepPurple.shade50: darkForeground,
    Colors.deepPurple.shade100: darkForeground,
    Colors.deepPurple.shade200: darkForeground,
    Colors.deepPurple.shade300: lightForeground,
    Colors.deepPurple.shade400: lightForeground,
    Colors.deepPurple.shade500: lightForeground,
    Colors.deepPurple.shade600: lightForeground,
    Colors.deepPurple.shade700: lightForeground,
    Colors.deepPurple.shade800: lightForeground,
    Colors.deepPurple.shade900: lightForeground,
    Colors.deepPurpleAccent.shade100: darkForeground,
    Colors.deepPurpleAccent.shade200: lightForeground,
    Colors.deepPurpleAccent.shade400: lightForeground,
    Colors.deepPurpleAccent.shade700: lightForeground,

    // Indigo
    Colors.indigo.shade50: darkForeground,
    Colors.indigo.shade100: darkForeground,
    Colors.indigo.shade200: darkForeground,
    Colors.indigo.shade300: lightForeground,
    Colors.indigo.shade400: lightForeground,
    Colors.indigo.shade500: lightForeground,
    Colors.indigo.shade600: lightForeground,
    Colors.indigo.shade700: lightForeground,
    Colors.indigo.shade800: lightForeground,
    Colors.indigo.shade900: lightForeground,
    Colors.indigoAccent.shade100: darkForeground,
    Colors.indigoAccent.shade200: lightForeground,
    Colors.indigoAccent.shade400: lightForeground,
    Colors.indigoAccent.shade700: lightForeground,

    // Blue
    Colors.blue.shade50: darkForeground,
    Colors.blue.shade100: darkForeground,
    Colors.blue.shade200: darkForeground,
    Colors.blue.shade300: darkForeground,
    Colors.blue.shade400: darkForeground,
    Colors.blue.shade500: lightForeground,
    Colors.blue.shade600: lightForeground,
    Colors.blue.shade700: lightForeground,
    Colors.blue.shade800: lightForeground,
    Colors.blue.shade900: lightForeground,
    Colors.blueAccent.shade100: darkForeground,
    Colors.blueAccent.shade200: lightForeground,
    Colors.blueAccent.shade400: lightForeground,
    Colors.blueAccent.shade700: lightForeground,

    // Light blue
    Colors.lightBlue.shade50: darkForeground,
    Colors.lightBlue.shade100: darkForeground,
    Colors.lightBlue.shade200: darkForeground,
    Colors.lightBlue.shade300: darkForeground,
    Colors.lightBlue.shade400: darkForeground,
    Colors.lightBlue.shade500: darkForeground,
    Colors.lightBlue.shade600: lightForeground,
    Colors.lightBlue.shade700: lightForeground,
    Colors.lightBlue.shade800: lightForeground,
    Colors.lightBlue.shade900: lightForeground,
    Colors.lightBlueAccent.shade100: darkForeground,
    Colors.lightBlueAccent.shade200: darkForeground,
    Colors.lightBlueAccent.shade400: darkForeground,
    Colors.lightBlueAccent.shade700: lightForeground,

    // Cyan
    Colors.cyan.shade50: darkForeground,
    Colors.cyan.shade100: darkForeground,
    Colors.cyan.shade200: darkForeground,
    Colors.cyan.shade300: darkForeground,
    Colors.cyan.shade400: darkForeground,
    Colors.cyan.shade500: darkForeground,
    Colors.cyan.shade600: lightForeground,
    Colors.cyan.shade700: lightForeground,
    Colors.cyan.shade800: lightForeground,
    Colors.cyan.shade900: lightForeground,
    Colors.cyanAccent.shade100: darkForeground,
    Colors.cyanAccent.shade200: darkForeground,
    Colors.cyanAccent.shade400: darkForeground,
    Colors.cyanAccent.shade700: darkForeground,

    // Teal
    Colors.teal.shade50: darkForeground,
    Colors.teal.shade100: darkForeground,
    Colors.teal.shade200: darkForeground,
    Colors.teal.shade300: darkForeground,
    Colors.teal.shade400: lightForeground,
    Colors.teal.shade500: lightForeground,
    Colors.teal.shade600: lightForeground,
    Colors.teal.shade700: lightForeground,
    Colors.teal.shade800: lightForeground,
    Colors.teal.shade900: lightForeground,
    Colors.tealAccent.shade100: darkForeground,
    Colors.tealAccent.shade200: darkForeground,
    Colors.tealAccent.shade400: darkForeground,
    Colors.tealAccent.shade700: darkForeground,

    // Green
    Colors.green.shade50: darkForeground,
    Colors.green.shade100: darkForeground,
    Colors.green.shade200: darkForeground,
    Colors.green.shade300: darkForeground,
    Colors.green.shade400: darkForeground,
    Colors.green.shade500: lightForeground,
    Colors.green.shade600: lightForeground,
    Colors.green.shade700: lightForeground,
    Colors.green.shade800: lightForeground,
    Colors.green.shade900: lightForeground,
    Colors.greenAccent.shade100: darkForeground,
    Colors.greenAccent.shade200: darkForeground,
    Colors.greenAccent.shade400: darkForeground,
    Colors.greenAccent.shade700: darkForeground,

    // Light green
    Colors.lightGreen.shade50: darkForeground,
    Colors.lightGreen.shade100: darkForeground,
    Colors.lightGreen.shade200: darkForeground,
    Colors.lightGreen.shade300: darkForeground,
    Colors.lightGreen.shade400: darkForeground,
    Colors.lightGreen.shade500: darkForeground,
    Colors.lightGreen.shade600: darkForeground,
    Colors.lightGreen.shade700: lightForeground,
    Colors.lightGreen.shade800: lightForeground,
    Colors.lightGreen.shade900: lightForeground,
    Colors.lightGreenAccent.shade100: darkForeground,
    Colors.lightGreenAccent.shade200: darkForeground,
    Colors.lightGreenAccent.shade400: darkForeground,
    Colors.lightGreenAccent.shade700: darkForeground,

    // Lime
    Colors.lime.shade50: darkForeground,
    Colors.lime.shade100: darkForeground,
    Colors.lime.shade200: darkForeground,
    Colors.lime.shade300: darkForeground,
    Colors.lime.shade400: darkForeground,
    Colors.lime.shade500: darkForeground,
    Colors.lime.shade600: darkForeground,
    Colors.lime.shade700: darkForeground,
    Colors.lime.shade800: lightForeground,
    Colors.lime.shade900: lightForeground,
    Colors.limeAccent.shade100: darkForeground,
    Colors.limeAccent.shade200: darkForeground,
    Colors.limeAccent.shade400: darkForeground,
    Colors.limeAccent.shade700: darkForeground,

    // Yellow
    Colors.yellow.shade50: darkForeground,
    Colors.yellow.shade100: darkForeground,
    Colors.yellow.shade200: darkForeground,
    Colors.yellow.shade300: darkForeground,
    Colors.yellow.shade400: darkForeground,
    Colors.yellow.shade500: darkForeground,
    Colors.yellow.shade600: darkForeground,
    Colors.yellow.shade700: darkForeground,
    Colors.yellow.shade800: darkForeground,
    Colors.yellow.shade900: darkForeground,
    Colors.yellowAccent.shade100: darkForeground,
    Colors.yellowAccent.shade200: darkForeground,
    Colors.yellowAccent.shade400: darkForeground,
    Colors.yellowAccent.shade700: darkForeground,

    // Amber
    Colors.amber.shade50: darkForeground,
    Colors.amber.shade100: darkForeground,
    Colors.amber.shade200: darkForeground,
    Colors.amber.shade300: darkForeground,
    Colors.amber.shade400: darkForeground,
    Colors.amber.shade500: darkForeground,
    Colors.amber.shade600: darkForeground,
    Colors.amber.shade700: darkForeground,
    Colors.amber.shade800: darkForeground,
    Colors.amber.shade900: lightForeground,
    Colors.amberAccent.shade100: darkForeground,
    Colors.amberAccent.shade200: darkForeground,
    Colors.amberAccent.shade400: darkForeground,
    Colors.amberAccent.shade700: darkForeground,

    // Orange
    Colors.orange.shade50: darkForeground,
    Colors.orange.shade100: darkForeground,
    Colors.orange.shade200: darkForeground,
    Colors.orange.shade300: darkForeground,
    Colors.orange.shade400: darkForeground,
    Colors.orange.shade500: darkForeground,
    Colors.orange.shade600: darkForeground,
    Colors.orange.shade700: darkForeground,
    Colors.orange.shade800: lightForeground,
    Colors.orange.shade900: lightForeground,
    Colors.orangeAccent.shade100: darkForeground,
    Colors.orangeAccent.shade200: darkForeground,
    Colors.orangeAccent.shade400: darkForeground,
    Colors.orangeAccent.shade700: lightForeground,

    // Deep orange
    Colors.deepOrange.shade50: darkForeground,
    Colors.deepOrange.shade100: darkForeground,
    Colors.deepOrange.shade200: darkForeground,
    Colors.deepOrange.shade300: darkForeground,
    Colors.deepOrange.shade400: lightForeground,
    Colors.deepOrange.shade500: lightForeground,
    Colors.deepOrange.shade600: lightForeground,
    Colors.deepOrange.shade700: lightForeground,
    Colors.deepOrange.shade800: lightForeground,
    Colors.deepOrange.shade900: lightForeground,
    Colors.deepOrangeAccent.shade100: darkForeground,
    Colors.deepOrangeAccent.shade200: lightForeground,
    Colors.deepOrangeAccent.shade400: lightForeground,
    Colors.deepOrangeAccent.shade700: lightForeground,

    // Brown
    Colors.brown.shade50: darkForeground,
    Colors.brown.shade100: darkForeground,
    Colors.brown.shade200: darkForeground,
    Colors.brown.shade300: lightForeground,
    Colors.brown.shade400: lightForeground,
    Colors.brown.shade500: lightForeground,
    Colors.brown.shade600: lightForeground,
    Colors.brown.shade700: lightForeground,
    Colors.brown.shade800: lightForeground,
    Colors.brown.shade900: lightForeground,

    // Grey
    Colors.grey.shade50: darkForeground,
    Colors.grey.shade100: darkForeground,
    Colors.grey.shade200: darkForeground,
    Colors.grey.shade300: darkForeground,
    Colors.grey.shade400: darkForeground,
    Colors.grey.shade500: darkForeground,
    Colors.grey.shade600: lightForeground,
    Colors.grey.shade700: lightForeground,
    Colors.grey.shade800: lightForeground,
    Colors.grey.shade900: lightForeground,

    // Blue grey
    Colors.blueGrey.shade50: darkForeground,
    Colors.blueGrey.shade100: darkForeground,
    Colors.blueGrey.shade200: darkForeground,
    Colors.blueGrey.shade300: darkForeground,
    Colors.blueGrey.shade400: lightForeground,
    Colors.blueGrey.shade500: lightForeground,
    Colors.blueGrey.shade600: lightForeground,
    Colors.blueGrey.shade700: lightForeground,
    Colors.blueGrey.shade800: lightForeground,
    Colors.blueGrey.shade900: lightForeground,

    // Additional colors.
    Colors.black: lightForeground,
    Colors.white: darkForeground,
  };
}

/// The collection of predefined themes.
abstract class BoardThemes {
  static BoardThemeData get red => BoardThemeData(
        appColor: Colors.red.shade600,
        appAccent: Colors.red.shade800,
        boardColor: Colors.red.shade50,
        columnColor: Colors.red.shade200,
        cardColor: Colors.red.shade400,
      );

  static BoardThemeData get pink => BoardThemeData(
        appColor: Colors.pink.shade600,
        appAccent: Colors.pink.shade800,
        boardColor: Colors.pink.shade50,
        columnColor: Colors.pink.shade200,
        cardColor: Colors.pink.shade400,
      );

  static BoardThemeData get purple => BoardThemeData(
        appColor: Colors.purple.shade600,
        appAccent: Colors.purple.shade800,
        boardColor: Colors.purple.shade50,
        columnColor: Colors.purple.shade200,
        cardColor: Colors.purple.shade400,
      );

  static BoardThemeData get deepPurple => BoardThemeData(
        appColor: Colors.deepPurple.shade600,
        appAccent: Colors.deepPurple.shade800,
        boardColor: Colors.deepPurple.shade50,
        columnColor: Colors.deepPurple.shade200,
        cardColor: Colors.deepPurple.shade400,
      );

  static BoardThemeData get indigo => BoardThemeData(
        appColor: Colors.indigo.shade600,
        appAccent: Colors.indigo.shade800,
        boardColor: Colors.indigo.shade50,
        columnColor: Colors.indigo.shade200,
        cardColor: Colors.indigo.shade400,
      );

  static BoardThemeData get blue => BoardThemeData(
        appColor: Colors.blue.shade600,
        appAccent: Colors.blue.shade800,
        boardColor: Colors.blue.shade50,
        columnColor: Colors.blue.shade200,
        cardColor: Colors.blue.shade400,
      );

  static BoardThemeData get lightBlue => BoardThemeData(
        appColor: Colors.lightBlue.shade600,
        appAccent: Colors.lightBlue.shade800,
        boardColor: Colors.lightBlue.shade50,
        columnColor: Colors.lightBlue.shade200,
        cardColor: Colors.lightBlue.shade400,
      );

  static BoardThemeData get cyan => BoardThemeData(
        appColor: Colors.cyan.shade600,
        appAccent: Colors.cyan.shade800,
        boardColor: Colors.cyan.shade50,
        columnColor: Colors.cyan.shade200,
        cardColor: Colors.cyan.shade400,
      );

  static BoardThemeData get teal => BoardThemeData(
        appColor: Colors.teal.shade600,
        appAccent: Colors.teal.shade800,
        boardColor: Colors.teal.shade50,
        columnColor: Colors.teal.shade200,
        cardColor: Colors.teal.shade400,
      );

  static BoardThemeData get green => BoardThemeData(
        appColor: Colors.green.shade600,
        appAccent: Colors.green.shade800,
        boardColor: Colors.green.shade50,
        columnColor: Colors.green.shade200,
        cardColor: Colors.green.shade400,
      );

  static BoardThemeData get lightGreen => BoardThemeData(
        appColor: Colors.lightGreen.shade600,
        appAccent: Colors.lightGreen.shade800,
        boardColor: Colors.lightGreen.shade50,
        columnColor: Colors.lightGreen.shade200,
        cardColor: Colors.lightGreen.shade400,
      );

  static BoardThemeData get lime => BoardThemeData(
        appColor: Colors.lime.shade600,
        appAccent: Colors.lime.shade800,
        boardColor: Colors.lime.shade50,
        columnColor: Colors.lime.shade200,
        cardColor: Colors.lime.shade400,
      );

  static BoardThemeData get yellow => BoardThemeData(
        appColor: Colors.yellow.shade600,
        appAccent: Colors.yellow.shade800,
        boardColor: Colors.yellow.shade50,
        columnColor: Colors.yellow.shade200,
        cardColor: Colors.yellow.shade400,
      );

  static BoardThemeData get amber => BoardThemeData(
        appColor: Colors.amber.shade600,
        appAccent: Colors.amber.shade800,
        boardColor: Colors.amber.shade50,
        columnColor: Colors.amber.shade200,
        cardColor: Colors.amber.shade400,
      );

  static BoardThemeData get orange => BoardThemeData(
        appColor: Colors.orange.shade600,
        appAccent: Colors.orange.shade800,
        boardColor: Colors.orange.shade50,
        columnColor: Colors.orange.shade200,
        cardColor: Colors.orange.shade400,
      );

  static BoardThemeData get deepOrange => BoardThemeData(
        appColor: Colors.deepOrange.shade600,
        appAccent: Colors.deepOrange.shade800,
        boardColor: Colors.deepOrange.shade50,
        columnColor: Colors.deepOrange.shade200,
        cardColor: Colors.deepOrange.shade400,
      );

  static BoardThemeData get brown => BoardThemeData(
        appColor: Colors.brown.shade600,
        appAccent: Colors.brown.shade800,
        boardColor: Colors.brown.shade50,
        columnColor: Colors.brown.shade200,
        cardColor: Colors.brown.shade400,
      );

  static BoardThemeData get grey => BoardThemeData(
        appColor: Colors.grey.shade600,
        appAccent: Colors.grey.shade800,
        boardColor: Colors.grey.shade50,
        columnColor: Colors.grey.shade200,
        cardColor: Colors.grey.shade400,
      );

  static BoardThemeData get blueGrey => BoardThemeData(
        appColor: Colors.blueGrey.shade600,
        appAccent: Colors.blueGrey.shade800,
        boardColor: Colors.blueGrey.shade50,
        columnColor: Colors.blueGrey.shade200,
        cardColor: Colors.blueGrey.shade400,
      );

  static List<BoardThemeData> get themes => [
        red,
        pink,
        purple,
        deepPurple,
        indigo,
        blue,
        lightBlue,
        cyan,
        teal,
        green,
        lightGreen,
        lime,
        yellow,
        amber,
        orange,
        deepOrange,
        brown,
        grey,
        blueGrey,
      ];
}
