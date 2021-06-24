import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config.dart';

/// Shows a dialog for the user to select a date.
class DatePicker extends StatefulWidget {
  /// Indicates whether to show a "clear" button when [value] is not null.
  ///
  /// The usual scenario where this button is useful is to allow the user to
  /// clear a date that was saved previously.
  ///
  /// When the button is tapped, [onCleared] will be called.
  ///
  /// Defaults to true.
  final bool showClearButton;

  /// The earliest date that can be selected using this picker.
  final DateTime firstDate;

  /// The latest date that can be selected using this picker.
  final DateTime lastDate;

  /// The value of this widget.
  final DateTime? value;

  /// The optional widget to display when [value] is null.
  final Widget? childWhenEmpty;

  /// The color of the picker dialog.
  final Color? color;

  /// Called when the "clear" button is tapped.
  final void Function()? onCleared;

  /// Called when the "CANCEL" option is tapped.
  final void Function()? onCanceled;

  /// Called when the "OK" option is tapped.
  final void Function(DateTime value)? onSelected;

  /// Creates an instance of [DatePicker].
  DatePicker({
    this.showClearButton = true,
    required this.firstDate,
    required this.lastDate,
    this.value,
    this.childWhenEmpty,
    this.color,
    this.onCleared,
    this.onCanceled,
    this.onSelected,
    Key? key,
  }) : super(key: key);

  @override
  _DatePickerState createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  /// The selected date.
  DateTime? _value;

  @override
  void initState() {
    super.initState();

    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.light().copyWith(primary: widget.color),
      ),
      child: Row(
        children: [
          if (widget.showClearButton && _value != null)
            ChoiceChip(
              label: Icon(Icons.cancel),
              selected: false,
              onSelected: (_) {
                setState(() {
                  _value = null;
                });

                if (widget.onCleared != null) widget.onCleared!();
              },
            ),
          if (widget.showClearButton && _value != null) SizedBox(width: 8.0),
          TextButton(
            child: _value != null
                ? Text(DateFormat(dateFormat).format(_value!))
                : widget.childWhenEmpty ??
                    Container(
                      // Make this big enough to tap.
                      width: 100.0,
                      height: 16.0,
                    ),
            onPressed: () => _showDialog(context),
          ),
        ],
      ),
    );
  }

  /// Shows the actual date picker dialog.
  Future<void> _showDialog(
    BuildContext context,
  ) async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: _value ?? DateTime.now(),
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      builder: (context, child) => Theme(
        data: ThemeData(
          colorScheme: ColorScheme.light().copyWith(primary: widget.color),
        ),
        child: child!,
      ),
    );

    if (date == null) {
      setState(() {
        _value = widget.value;
      });

      if (widget.onCanceled != null) widget.onCanceled!();
    }

    if (date != null) {
      setState(() {
        _value = date;
      });

      if (widget.onSelected != null) widget.onSelected!(date);
    }
  }
}
