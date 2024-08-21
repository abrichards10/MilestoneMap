// lib/providers/circle_provider.dart

import 'dart:math';

import 'package:flutter/material.dart';
import '../models/circle.dart';

class CircleProvider with ChangeNotifier {
  final Circle _rootCircle = Circle(
    id: 'root',
    text: 'Main Goal',
    isGoal: true,
    offset: Offset(210, 800), // Adjust as needed
    size: 150, // Root circle size
  );
  List<Circle> _circles = [];

  Circle get rootCircle => _rootCircle;
  List<Circle> get circles => _circles;

  bool _placeLeft = true; // Flag to track placement direction
  final Random _random = Random();

  void addCircle(Circle parent, Circle child) {
    final parentPosition = parent.offset;
    final int existingChildren = parent.children.length;

    // Calculate new position based on the number of existing children
    final double xOffset = existingChildren * (child.size) - child.size;

    print("xOffset: $xOffset");

    final Offset newPosition = _placeLeft
        ? Offset(parentPosition.dx - 100,
            parentPosition.dy + xOffset) // Place to the left
        : Offset(parentPosition.dx + 100,
            parentPosition.dy + xOffset); // Place to the right

    _placeLeft = !_placeLeft;

    child.offset = newPosition; // Update the child's position

    parent.children.add(child); // Add the new circle as a child of the parent
    _circles.add(child); // Add the new circle to the list

    notifyListeners();
  }

  void updateCircle(Circle circle, String newText) {
    circle.text = newText;
    notifyListeners();
  }

  void removeCircle(Circle parent, Circle circle) {
    // If the circle being removed has children, move them to its parent
    if (circle.children.isNotEmpty) {
      parent.children.addAll(circle.children);
    }

    // Remove the circle from its parent's children list
    parent.children.remove(circle);
    _circles.remove(circle); // Remove the circle from the list
    notifyListeners();
  }
}
