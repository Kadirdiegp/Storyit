import 'package:flutter/material.dart';

class Emotion {
  final String name;
  final IconData icon;
  final Color color;

  const Emotion({
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<Emotion> predefinedEmotions = [
    Emotion(
      name: 'Fröhlich',
      icon: Icons.sentiment_very_satisfied,
      color: Color(0xFF4CAF50),
    ),
    Emotion(
      name: 'Ruhig',
      icon: Icons.sentiment_satisfied,
      color: Color(0xFF2196F3),
    ),
    Emotion(
      name: 'Müde',
      icon: Icons.sentiment_neutral,
      color: Color(0xFF9E9E9E),
    ),
    Emotion(
      name: 'Aufgeregt',
      icon: Icons.mood,
      color: Color(0xFFFF9800),
    ),
    Emotion(
      name: 'Traurig',
      icon: Icons.sentiment_dissatisfied,
      color: Color(0xFF9C27B0),
    ),
  ];
}
