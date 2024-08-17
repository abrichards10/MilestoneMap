import 'package:flutter/material.dart';

class Circle {
  String id;
  String text;
  bool isGoal;
  Offset offset;
  List<Circle> children = [];
  DateTime? date;
  double size; // Add a size property to manage circle size

  Circle({
    required this.id,
    required this.text,
    required this.isGoal,
    required this.offset,
    this.date,
    this.size = 100, // Default size for root circle
  });
}
