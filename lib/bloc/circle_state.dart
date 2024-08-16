import '../models/circle.dart';

abstract class CircleState {}

class CircleInitialState extends CircleState {}

class CircleUpdatedState extends CircleState {
  final Circle rootCircle;

  CircleUpdatedState(this.rootCircle);
}

class AddCircleState extends CircleState {}
