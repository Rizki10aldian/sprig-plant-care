import 'package:flutter/foundation.dart';

@immutable
class UserProfile {
  const UserProfile({required this.name, required this.email});

  final String name;
  final String email;

  String get initial => name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();
}
