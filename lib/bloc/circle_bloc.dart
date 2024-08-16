// lib/bloc/circle_bloc.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'circle_event.dart';
import 'circle_state.dart';

class CircleBloc extends Bloc<CircleEvent, CircleState> {
  CircleBloc() : super(CircleInitialState());

  Stream<CircleState> mapEventToState(CircleEvent event) async* {
    if (event is AddCircleEvent) {
      emit(AddCircleState());
    } else if (event is RemoveCircleEvent) {
      // yield CircleUpdatedState(_rootCircle);
    } else if (event is MoveCircleEvent) {
      // yield CircleUpdatedState(_rootCircle);
    } else if (event is UpdateCircleEvent) {
      // yield CircleUpdatedState(_rootCircle);
    } else if (event is SetCircleDateEvent) {
      // yield CircleUpdatedState(_rootCircle);
    }
  }
}
