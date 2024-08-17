// lib/providers/circle_provider.dart
import 'package:flutter/material.dart';
import '../models/circle.dart';

class CircleProvider with ChangeNotifier {
  final Circle _rootCircle = Circle(
    id: 'root',
    text: 'Main Goal',
    isGoal: true,
    offset: Offset(210, 500), // TODO: Adjust for phone height
  );

  final Circle _taskCircle = Circle(
    id: 'task',
    text: 'Task',
    isGoal: true,
    offset: Offset(250, 300),
  );

  Circle get rootCircle => _rootCircle;
  Circle get taskCircle => _taskCircle;

  void addCircle(Circle parent, Circle child) {
    final parentPosition = parent.offset;
    const double distance = 100; // Adjust as needed for spacing

    final Offset newPosition = Offset(
      parentPosition.dx + distance,
      parentPosition.dy - distance,
    );

    child.offset = newPosition; // Update the child's position

    // Add the new circle as a child of the parent
    parent.children.add(child); // Ensure children list is mutable

    notifyListeners();
  }

  void removeCircle(Circle parent, Circle child) {
    if (parent == _rootCircle) return; // Prevent removal of the root circle

    if (parent.children.contains(child)) {
      parent.children.remove(child);
      parent.children.addAll(child.children); // Attach children to parent
      notifyListeners();
    }
  }

  void moveCircle(Circle from, Circle to) {
    if (from == _rootCircle || to == _rootCircle)
      return; // Prevent moving to/from root circle

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
