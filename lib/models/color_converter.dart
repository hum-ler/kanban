import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

/// Serializes (and de-serializes) a [Color].
class ColorConverter implements JsonConverter<Color, int> {
  /// Creates an instance of [ColorConverter].
  const ColorConverter();

  @override
  Color fromJson(int json) => Color(json);

  @override
  int toJson(Color object) => object.value;
}

/// Serializes (and de-serializes) a [Color?].
class NullableColorConverter implements JsonConverter<Color?, int?> {
  /// Creates an instance of [ColorConverter].
  const NullableColorConverter();

  @override
  Color? fromJson(int? json) => json == null ? null : Color(json);

  @override
  int? toJson(Color? object) => object == null ? null : object.value;
}
