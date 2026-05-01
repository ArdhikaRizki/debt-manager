import 'package:json_annotation/json_annotation.dart';

class SafeNumConverter implements JsonConverter<double, dynamic> {
  const SafeNumConverter();

  @override
  double fromJson(dynamic json) {
    if (json == null) return 0.0;
    if (json is num) return json.toDouble();
    if (json is String) return double.tryParse(json) ?? 0.0;
    return 0.0;
  }

  @override
  dynamic toJson(double object) => object;
}

class SafeIntConverter implements JsonConverter<int, dynamic> {
  const SafeIntConverter();

  @override
  int fromJson(dynamic json) {
    if (json == null) return 0;
    if (json is int) return json;
    if (json is num) return json.toInt();
    if (json is String) return int.tryParse(json) ?? 0;
    return 0;
  }

  @override
  dynamic toJson(int object) => object;
}

class SafeDateTimeConverter implements JsonConverter<DateTime, dynamic> {
  const SafeDateTimeConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json == null) return DateTime.now();
    if (json is String) return DateTime.tryParse(json) ?? DateTime.now();
    return DateTime.now();
  }

  @override
  dynamic toJson(DateTime object) => object.toIso8601String();
}

/// Converts null/non-string to empty string ''
class SafeStringConverter implements JsonConverter<String, dynamic> {
  const SafeStringConverter();

  @override
  String fromJson(dynamic json) {
    if (json == null) return '';
    return json.toString();
  }

  @override
  dynamic toJson(String object) => object;
}

/// Converts null/non-string to 'pending' (for debt status)
class SafeStatusConverter implements JsonConverter<String, dynamic> {
  const SafeStatusConverter();

  @override
  String fromJson(dynamic json) {
    if (json == null) return 'pending';
    return json.toString();
  }

  @override
  dynamic toJson(String object) => object;
}

/// Converts null/non-string to 'Grup' (for group name)
class SafeGroupNameConverter implements JsonConverter<String, dynamic> {
  const SafeGroupNameConverter();

  @override
  String fromJson(dynamic json) {
    if (json == null) return 'Grup';
    return json.toString();
  }

  @override
  dynamic toJson(String object) => object;
}

/// Converts null/non-string to 'User' (for username)
class SafeUsernameConverter implements JsonConverter<String, dynamic> {
  const SafeUsernameConverter();

  @override
  String fromJson(dynamic json) {
    if (json == null) return 'User';
    return json.toString();
  }

  @override
  dynamic toJson(String object) => object;
}
