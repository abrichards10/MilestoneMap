import 'package:flutter/material.dart';

class Circle {
  String id;
  String text;
  bool isGoal;
  Offset offset;
  List<Circle> children = [];
  DateTime? date;

  Circle({
    required this.id,
    required this.text,
    required this.isGoal,
    required this.offset,
    this.date,
  });
}
