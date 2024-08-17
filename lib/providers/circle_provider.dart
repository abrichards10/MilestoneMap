// lib/providers/circle_provider.dart

import 'package:flutter/material.dart';
import '../models/circle.dart';

class CircleProvider with ChangeNotifier {
  final Circle _rootCircle = Circle(
    id: 'root',
    text: 'Main Goal',
    isGoal: true,
    offset: Offset(210, 500), // Adjust as needed
    size: 100, // Root circle size
  );

  Circle get rootCircle => _rootCircle;

  void addCircle(Circle parent, Circle child) {
    final parentPosition = parent.offset;

    final Offset newPosition = Offset(
      parentPosition.dx,
      parentPosition.dy - 100, // Adjust position to place above parent
    );

    child.offset = newPosition; // Update the child's position

    // Add the new circle as a child of the parent
    parent.children.add(child); // Ensure children list is mutable

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

    notifyListeners();
  }
}
