import 'package:flutter/material.dart';

/// Wraps a [TextFormField] to report its value when focus is lost.
///
/// Only works with integers.
class NumericTextField extends StatefulWidget {
  /// The icon for decorating this text field.
  final IconData icon;

  /// The name label for decorating this text field.
  final String name;

  /// The value for this number.
  final int value;

  /// The minimum value for this number.
  final int minValue;

  /// The maximum value for this number.
  final int maxValue;

  /// The text style for this text field.
  final TextStyle? style;

  /// Called when focus is lost.
  ///
  /// If validation fails, [value] will be null.
  final void Function(int? value) onFocusLost;

  /// Creates an instance of [KTextField].
  const NumericTextField({
    required this.icon,
    required this.name,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.onFocusLost,
    this.style,
    Key? key,
  })  : assert(minValue <= maxValue),
        super(key: key);

  @override
  _NumericTextFieldState createState() => _NumericTextFieldState();
}

class _NumericTextFieldState extends State<NumericTextField> {
  /// The [FocusNode] of this text field.
  late final FocusNode _focusNode;

  /// The value of this text field.
  late String _value;

  @override
  void initState() {
    super.initState();

    _value = widget.value.toString();

    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: _focusNode,
      initialValue: _value,
      style: widget.style,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: widget.name,
        labelText: widget.name,
        border: InputBorder.none,
        icon: Icon(widget.icon),
      ),
      maxLines: 1,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: _numericValidator,
      onChanged: (value) {
        setState(() {
          _value = value;
        });
      },
    );
  }

  /// Validates the input.
  String? _numericValidator(String? value) {
    if (value != null && RegExp(r'^\-?\d*$').hasMatch(value)) {
      final int? i = int.tryParse(value);
      if (i == null) return 'Invalid number';

      if (i < widget.minValue || i > widget.maxValue) {
        return 'Number must be between ${widget.minValue} to ${widget.maxValue}';
      }

      // Number checks out.
      return null;
    }

    return 'Invalid number';
  }

  /// Handles a focus change.
  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      if (_numericValidator(_value) != null)
        widget.onFocusLost(null);
      else
        widget.onFocusLost(int.tryParse(_value));
    }
  }
}
