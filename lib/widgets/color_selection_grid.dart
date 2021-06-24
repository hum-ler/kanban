import 'package:flutter/material.dart';

import 'color_circle.dart';

/// Displays a grid of [ColorCircle]s for Material colors.
class ColorSelectionGrid extends StatefulWidget {
  /// The radius of each [ColorCircle].
  final double radius;

  /// The spacing between adjacent [ColorCircle]s.
  final double spacing;

  /// Indicates whether the user can select between different shades of a
  /// Material color.
  ///
  /// If set to true, color selection becomes a two-step process: first, the
  /// user selects a main color, and then, second, selects a shade of the main
  /// color.
  ///
  /// Defaults to true.
  final bool selectShade;

  /// The value of this widget.
  final Color value;

  /// Called when a color is selected.
  final void Function(Color value)? onSelected;

  /// Creates an instance of [ColorSelectionGrid].
  const ColorSelectionGrid({
    this.radius = 24.0,
    this.spacing = 8.0,
    this.selectShade = true,
    required this.value,
    this.onSelected,
    Key? key,
  }) : super(key: key);

  @override
  _ColorSelectionGridState createState() => _ColorSelectionGridState();
}

class _ColorSelectionGridState extends State<ColorSelectionGrid> {
  /// The color that has been selected.
  late Color _selection;

  /// The main color that has been selected.
  ///
  /// This is used to determine which set of shades to display.
  late Color _mainColorSelection;

  /// The page that we are currently on.
  _SelectionPage _page = _SelectionPage.mainColor;

  @override
  void initState() {
    super.initState();

    _selection = widget.value;
    _mainColorSelection = Colors.red.shade500;
    _page = _SelectionPage.mainColor;
  }

  @override
  Widget build(BuildContext context) {
    /// The list of [ColorCircles] to be displayed.
    List<ColorCircle> circles;

    switch (_page) {
      case _SelectionPage.mainColor:
        circles = _colors.keys.map<ColorCircle>((e) {
          return ColorCircle(
            color: e,
            icon: e == _selection
                ? Icons.check
                : _colors[e]!.contains(_selection)
                    ? Icons.arrow_forward
                    : null,

            // The white circle needs a border.
            borderSize: e == Colors.white ? 2.0 : 0.0,
            borderColor: Colors.grey.shade500,

            onTap: () {
              if (widget.selectShade && _colors[e]!.length > 0) {
                // Proceed to select the color shade.
                setState(() {
                  _mainColorSelection = e;
                  _page = _SelectionPage.colorShade;
                });
              } else {
                // Record the selection.
                setState(() {
                  _mainColorSelection = e;
                  _selection = e;
                });

                if (widget.onSelected != null) widget.onSelected!(_selection);
              }
            },
          );
        }).toList();
        break;

      case _SelectionPage.colorShade:
        circles = _colors[_mainColorSelection]!.map<ColorCircle>((e) {
          return ColorCircle(
            color: e,
            icon: e == _selection ? Icons.check : null,
            onTap: () {
              setState(() {
                _selection = e;
              });

              if (widget.onSelected != null) widget.onSelected!(_selection);
            },
          );
        }).toList();

        // Insert a "back button" at the front.
        circles.insert(
          0,
          ColorCircle(
            color: Colors.transparent,
            icon: Icons.arrow_back,
            onTap: () {
              setState(() {
                _page = _SelectionPage.mainColor;
              });
            },
          ),
        );
        break;
    }

    return Wrap(
      runSpacing: widget.spacing,
      spacing: widget.spacing,
      children: circles,
    );
  }

  /// The set of all selectable colors.
  ///
  /// This is a map of main color (key) to a list of color shades (value).
  static Map<Color, List<Color>> _colors = {
    // Red
    Colors.red.shade500: [
      Colors.red.shade50,
      Colors.red.shade100,
      Colors.red.shade200,
      Colors.red.shade300,
      Colors.red.shade400,
      Colors.red.shade500,
      Colors.red.shade600,
      Colors.red.shade700,
      Colors.red.shade800,
      Colors.red.shade900,
      Colors.redAccent.shade100,
      Colors.redAccent.shade200,
      Colors.redAccent.shade400,
      Colors.redAccent.shade700,
    ],

    // Pink
    Colors.pink.shade500: [
      Colors.pink.shade50,
      Colors.pink.shade100,
      Colors.pink.shade200,
      Colors.pink.shade300,
      Colors.pink.shade400,
      Colors.pink.shade500,
      Colors.pink.shade600,
      Colors.pink.shade700,
      Colors.pink.shade800,
      Colors.pink.shade900,
      Colors.pinkAccent.shade100,
      Colors.pinkAccent.shade200,
      Colors.pinkAccent.shade400,
      Colors.pinkAccent.shade700,
    ],

    // Purple
    Colors.purple.shade500: [
      Colors.purple.shade50,
      Colors.purple.shade100,
      Colors.purple.shade200,
      Colors.purple.shade300,
      Colors.purple.shade400,
      Colors.purple.shade500,
      Colors.purple.shade600,
      Colors.purple.shade700,
      Colors.purple.shade800,
      Colors.purple.shade900,
      Colors.purpleAccent.shade100,
      Colors.purpleAccent.shade200,
      Colors.purpleAccent.shade400,
      Colors.purpleAccent.shade700,
    ],

    // Deep purple
    Colors.deepPurple.shade500: [
      Colors.deepPurple.shade50,
      Colors.deepPurple.shade100,
      Colors.deepPurple.shade200,
      Colors.deepPurple.shade300,
      Colors.deepPurple.shade400,
      Colors.deepPurple.shade500,
      Colors.deepPurple.shade600,
      Colors.deepPurple.shade700,
      Colors.deepPurple.shade800,
      Colors.deepPurple.shade900,
      Colors.deepPurpleAccent.shade100,
      Colors.deepPurpleAccent.shade200,
      Colors.deepPurpleAccent.shade400,
      Colors.deepPurpleAccent.shade700,
    ],

    // Indigo
    Colors.indigo.shade500: [
      Colors.indigo.shade50,
      Colors.indigo.shade100,
      Colors.indigo.shade200,
      Colors.indigo.shade300,
      Colors.indigo.shade400,
      Colors.indigo.shade500,
      Colors.indigo.shade600,
      Colors.indigo.shade700,
      Colors.indigo.shade800,
      Colors.indigo.shade900,
      Colors.indigoAccent.shade100,
      Colors.indigoAccent.shade200,
      Colors.indigoAccent.shade400,
      Colors.indigoAccent.shade700,
    ],

    // Blue
    Colors.blue.shade500: [
      Colors.blue.shade50,
      Colors.blue.shade100,
      Colors.blue.shade200,
      Colors.blue.shade300,
      Colors.blue.shade400,
      Colors.blue.shade500,
      Colors.blue.shade600,
      Colors.blue.shade700,
      Colors.blue.shade800,
      Colors.blue.shade900,
      Colors.blueAccent.shade100,
      Colors.blueAccent.shade200,
      Colors.blueAccent.shade400,
      Colors.blueAccent.shade700,
    ],

    // Light blue
    Colors.lightBlue.shade500: [
      Colors.lightBlue.shade50,
      Colors.lightBlue.shade100,
      Colors.lightBlue.shade200,
      Colors.lightBlue.shade300,
      Colors.lightBlue.shade400,
      Colors.lightBlue.shade500,
      Colors.lightBlue.shade600,
      Colors.lightBlue.shade700,
      Colors.lightBlue.shade800,
      Colors.lightBlue.shade900,
      Colors.lightBlueAccent.shade100,
      Colors.lightBlueAccent.shade200,
      Colors.lightBlueAccent.shade400,
      Colors.lightBlueAccent.shade700,
    ],

    // Cyan
    Colors.cyan.shade500: [
      Colors.cyan.shade50,
      Colors.cyan.shade100,
      Colors.cyan.shade200,
      Colors.cyan.shade300,
      Colors.cyan.shade400,
      Colors.cyan.shade500,
      Colors.cyan.shade600,
      Colors.cyan.shade700,
      Colors.cyan.shade800,
      Colors.cyan.shade900,
      Colors.cyanAccent.shade100,
      Colors.cyanAccent.shade200,
      Colors.cyanAccent.shade400,
      Colors.cyanAccent.shade700,
    ],

    // Teal
    Colors.teal.shade500: [
      Colors.teal.shade50,
      Colors.teal.shade100,
      Colors.teal.shade200,
      Colors.teal.shade300,
      Colors.teal.shade400,
      Colors.teal.shade500,
      Colors.teal.shade600,
      Colors.teal.shade700,
      Colors.teal.shade800,
      Colors.teal.shade900,
      Colors.tealAccent.shade100,
      Colors.tealAccent.shade200,
      Colors.tealAccent.shade400,
      Colors.tealAccent.shade700,
    ],

    // Green
    Colors.green.shade500: [
      Colors.green.shade50,
      Colors.green.shade100,
      Colors.green.shade200,
      Colors.green.shade300,
      Colors.green.shade400,
      Colors.green.shade500,
      Colors.green.shade600,
      Colors.green.shade700,
      Colors.green.shade800,
      Colors.green.shade900,
      Colors.greenAccent.shade100,
      Colors.greenAccent.shade200,
      Colors.greenAccent.shade400,
      Colors.greenAccent.shade700,
    ],

    // Light green
    Colors.lightGreen.shade500: [
      Colors.lightGreen.shade50,
      Colors.lightGreen.shade100,
      Colors.lightGreen.shade200,
      Colors.lightGreen.shade300,
      Colors.lightGreen.shade400,
      Colors.lightGreen.shade500,
      Colors.lightGreen.shade600,
      Colors.lightGreen.shade700,
      Colors.lightGreen.shade800,
      Colors.lightGreen.shade900,
      Colors.lightGreenAccent.shade100,
      Colors.lightGreenAccent.shade200,
      Colors.lightGreenAccent.shade400,
      Colors.lightGreenAccent.shade700,
    ],

    // Lime
    Colors.lime.shade500: [
      Colors.lime.shade50,
      Colors.lime.shade100,
      Colors.lime.shade200,
      Colors.lime.shade300,
      Colors.lime.shade400,
      Colors.lime.shade500,
      Colors.lime.shade600,
      Colors.lime.shade700,
      Colors.lime.shade800,
      Colors.lime.shade900,
      Colors.limeAccent.shade100,
      Colors.limeAccent.shade200,
      Colors.limeAccent.shade400,
      Colors.limeAccent.shade700,
    ],

    // Yellow
    Colors.yellow.shade500: [
      Colors.yellow.shade50,
      Colors.yellow.shade100,
      Colors.yellow.shade200,
      Colors.yellow.shade300,
      Colors.yellow.shade400,
      Colors.yellow.shade500,
      Colors.yellow.shade600,
      Colors.yellow.shade700,
      Colors.yellow.shade800,
      Colors.yellow.shade900,
      Colors.yellowAccent.shade100,
      Colors.yellowAccent.shade200,
      Colors.yellowAccent.shade400,
      Colors.yellowAccent.shade700,
    ],

    // Amber
    Colors.amber.shade500: [
      Colors.amber.shade50,
      Colors.amber.shade100,
      Colors.amber.shade200,
      Colors.amber.shade300,
      Colors.amber.shade400,
      Colors.amber.shade500,
      Colors.amber.shade600,
      Colors.amber.shade700,
      Colors.amber.shade800,
      Colors.amber.shade900,
      Colors.amberAccent.shade100,
      Colors.amberAccent.shade200,
      Colors.amberAccent.shade400,
      Colors.amberAccent.shade700,
    ],

    // Orange
    Colors.orange.shade500: [
      Colors.orange.shade50,
      Colors.orange.shade100,
      Colors.orange.shade200,
      Colors.orange.shade300,
      Colors.orange.shade400,
      Colors.orange.shade500,
      Colors.orange.shade600,
      Colors.orange.shade700,
      Colors.orange.shade800,
      Colors.orange.shade900,
      Colors.orangeAccent.shade100,
      Colors.orangeAccent.shade200,
      Colors.orangeAccent.shade400,
      Colors.orangeAccent.shade700,
    ],

    // Deep orange
    Colors.deepOrange.shade500: [
      Colors.deepOrange.shade50,
      Colors.deepOrange.shade100,
      Colors.deepOrange.shade200,
      Colors.deepOrange.shade300,
      Colors.deepOrange.shade400,
      Colors.deepOrange.shade500,
      Colors.deepOrange.shade600,
      Colors.deepOrange.shade700,
      Colors.deepOrange.shade800,
      Colors.deepOrange.shade900,
      Colors.deepOrangeAccent.shade100,
      Colors.deepOrangeAccent.shade200,
      Colors.deepOrangeAccent.shade400,
      Colors.deepOrangeAccent.shade700,
    ],

    // Brown
    Colors.brown.shade500: [
      Colors.brown.shade50,
      Colors.brown.shade100,
      Colors.brown.shade200,
      Colors.brown.shade300,
      Colors.brown.shade400,
      Colors.brown.shade500,
      Colors.brown.shade600,
      Colors.brown.shade700,
      Colors.brown.shade800,
      Colors.brown.shade900,
    ],

    // Grey
    Colors.grey.shade500: [
      Colors.grey.shade50,
      Colors.grey.shade100,
      Colors.grey.shade200,
      Colors.grey.shade300,
      Colors.grey.shade400,
      Colors.grey.shade500,
      Colors.grey.shade600,
      Colors.grey.shade700,
      Colors.grey.shade800,
      Colors.grey.shade900,
    ],

    // Blue grey
    Colors.blueGrey.shade500: [
      Colors.blueGrey.shade50,
      Colors.blueGrey.shade100,
      Colors.blueGrey.shade200,
      Colors.blueGrey.shade300,
      Colors.blueGrey.shade400,
      Colors.blueGrey.shade500,
      Colors.blueGrey.shade600,
      Colors.blueGrey.shade700,
      Colors.blueGrey.shade800,
      Colors.blueGrey.shade900,
    ],

    // Additional main colors.
    Colors.black: [],
    Colors.white: [],
  };
}

/// The pages in the selection process.
enum _SelectionPage {
  mainColor,
  colorShade,
}
