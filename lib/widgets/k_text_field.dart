import 'package:flutter/material.dart';

/// Wraps a [TextFormField] to report its value when focus is lost.
class KTextField extends StatefulWidget {
  /// The icon for decorating this text field.
  final IconData icon;

  /// The name label for decorating this text field.
  final String name;

  /// The value for this text field.
  final String value;

  /// The text style for this text field.
  final TextStyle? style;

  /// The minimum number of lines for this text field.
  ///
  /// Depending on the length of the text value, the height of this widget
  /// changes dynamically between [minLines] and [maxLines].
  final int? minLines;

  /// The maximum number of lines for this text field.
  ///
  /// Depending on the length of the text value, the height of this widget
  /// changes dynamically between [minLines] and [maxLines].
  final int? maxLines;

  /// Indicates whether this field should be focused when the form is loaded.
  final bool autofocus;

  /// The [AutovalidateMode] for this text field.
  final AutovalidateMode? autovalidateMode;

  /// The validating function for this text field.
  final String? Function(String? value)? validator;

  /// Called when focus is lost.
  final void Function(String value)? onFocusLost;

  /// Called when the value has changed.
  final void Function(String value)? onChanged;

  /// Creates an instance of [KTextField].
  const KTextField({
    required this.icon,
    required this.name,
    required this.value,
    this.onFocusLost,
    this.onChanged,
    this.style,
    this.minLines,
    this.maxLines,
    this.autovalidateMode,
    this.validator,
    this.autofocus = false,
    Key? key,
  })  : assert((minLines ?? 1) >= 1),
        assert((maxLines ?? 1) >= 1),
        assert(maxLines != null ? (minLines ?? maxLines) <= maxLines : true),
        assert(minLines != null ? minLines <= (maxLines ?? minLines) : true),
        super(key: key);

  @override
  _KTextFieldState createState() => _KTextFieldState();
}

class _KTextFieldState extends State<KTextField> {
  /// The [FocusNode] of this text field.
  late final FocusNode _focusNode;

  /// The [TextEditingController] of this text field.
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.value);
    if (widget.autofocus) {
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: widget.value.length,
      );
    }

    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();

    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: _focusNode,
      controller: _controller,
      style: widget.style,
      keyboardType: TextInputType.text,
      autofocus: widget.autofocus,
      decoration: InputDecoration(
        hintText: widget.name,
        labelText: widget.name,
        border: InputBorder.none,
        icon: Icon(widget.icon),
      ),
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      autovalidateMode: widget.autovalidateMode,
      validator: widget.validator,
      onChanged: (value) {
        if (widget.onChanged != null) widget.onChanged!(value);
      },
    );
  }

  /// Handles a focus change.
  void _onFocusChanged() {
    // Make sure the value validates.
    if (widget.validator != null &&
        widget.validator!(_controller.value.text) != null) return;

    if (widget.onFocusLost != null && !_focusNode.hasFocus) {
      widget.onFocusLost!(_controller.value.text);
    }
  }
}
