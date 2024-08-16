import '../models/circle.dart';

abstract class CircleEvent {}

class AddCircleEvent extends CircleEvent {
  final Circle parent;
  final Circle child;

  AddCircleEvent(this.parent, this.child);
}

class RemoveCircleEvent extends CircleEvent {
  final Circle parent;
  final Circle child;

  RemoveCircleEvent(this.parent, this.child);
}

class MoveCircleEvent extends CircleEvent {
  final Circle from;
  final Circle to;

  MoveCircleEvent(this.from, this.to);
}

class UpdateCircleEvent extends CircleEvent {
  final Circle circle;
  final String newText;

  UpdateCircleEvent(this.circle, this.newText);
}

class SetCircleDateEvent extends CircleEvent {
  final Circle circle;
  final DateTime date;

  SetCircleDateEvent(this.circle, this.date);
}
