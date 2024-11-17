import 'package:flutter/material.dart';
import 'story.dart';

class ChildProfile {
  final String id;
  final String name;
  final int age;
  final List<String> interests;
  final List<DiaryEntry> diaryEntries;
  final String? avatarUrl;
  final DateTime createdAt;
  final List<Story> favoriteStories;

  ChildProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.interests,
    this.diaryEntries = const [],
    this.avatarUrl,
    required this.createdAt,
    this.favoriteStories = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'interests': interests,
        'diaryEntries': diaryEntries.map((e) => e.toJson()).toList(),
        'avatarUrl': avatarUrl,
        'createdAt': createdAt.toIso8601String(),
        'favoriteStories': favoriteStories.map((s) => s.toJson()).toList(),
      };

  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    return ChildProfile(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      interests: List<String>.from(json['interests']),
      diaryEntries: (json['diaryEntries'] as List)
          .map((e) => DiaryEntry.fromJson(e))
          .toList(),
      avatarUrl: json['avatarUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      favoriteStories: (json['favoriteStories'] as List)
          .map((s) => Story.fromJson(s))
          .toList(),
    );
  }
}

class DiaryEntry {
  final DateTime date;
  final String eventDescription;
  final String emotion;
  final String? note;
  final List<String>? tags;

  DiaryEntry({
    required this.date,
    required this.eventDescription,
    required this.emotion,
    this.note,
    this.tags,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'eventDescription': eventDescription,
        'emotion': emotion,
        'note': note,
        'tags': tags,
      };

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      date: DateTime.parse(json['date']),
      eventDescription: json['eventDescription'],
      emotion: json['emotion'],
      note: json['note'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }
}
