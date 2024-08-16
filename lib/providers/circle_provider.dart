// lib/providers/circle_provider.dart
import 'package:flutter/material.dart';
import '../models/circle.dart';

class CircleProvider with ChangeNotifier {
  Circle _rootCircle = Circle(
    id: 'root',
    text: 'Main Goal',
    isGoal: true,
    offset: Offset(200, 200),
  );

  Circle get rootCircle => _rootCircle;

  void addCircle(Circle parent, Circle child) {
    // Calculate position for the new circle to be to the upper right of the parent
    final parentPosition = parent.offset;
    const double distance = 100; // Adjust as needed for spacing
    final Offset newPosition = Offset(
      parentPosition.dx + distance,
      parentPosition.dy - distance,
    );

    // Update the child's position
    child.offset = newPosition;

    // Add the new circle as a child of the parent
    parent.children.add(child); // Ensure children list is mutable

    notifyListeners();
  }

  void removeCircle(Circle parent, Circle child) {
    if (parent.children.contains(child)) {
      parent.children.remove(child);
      parent.children.addAll(child.children); // Attach children to parent
      notifyListeners();
    }
  }

  void moveCircle(Circle from, Circle to) {
    if (from != to && !to.children.contains(from)) {
      to.children.add(from);
      from.children.forEach((child) => to.children.add(child));
      notifyListeners();
    }
  }

  void updateCircle(Circle circle, String newText) {
    circle.text = newText;
    notifyListeners();
  }

  void setCircleDate(Circle circle, DateTime date) {
    circle.date = date;
    notifyListeners();
  }
}
