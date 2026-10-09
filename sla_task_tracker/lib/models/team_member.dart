import 'package:flutter/material.dart';

class TeamMember {
  final String id;
  final String name;
  final String email;
  final String role;
  final String team;
  final String location;
  final bool isAvailable;
  final int avatarColorValue;

  const TeamMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.team,
    required this.location,
    required this.avatarColorValue,
    this.isAvailable = true,
  });

  Color get avatarColor => Color(avatarColorValue);


  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }

  TeamMember copyWith({
    String? name,
    String? email,
    String? role,
    String? team,
    String? location,
    bool? isAvailable,
    int? avatarColorValue,
  }) {
    return TeamMember(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      team: team ?? this.team,
      location: location ?? this.location,
      isAvailable: isAvailable ?? this.isAvailable,
      avatarColorValue: avatarColorValue ?? this.avatarColorValue,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'team': team,
        'location': location,
        'isAvailable': isAvailable,
        'avatarColorValue': avatarColorValue,
      };

  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
        team: json['team'] as String,
        location: json['location'] as String,
        isAvailable: json['isAvailable'] as bool? ?? true,
        avatarColorValue: json['avatarColorValue'] as int,
      );
}
