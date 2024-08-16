// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goals_app/bloc/circle_bloc.dart';
import 'package:provider/provider.dart';
import 'providers/circle_provider.dart';
import 'screens/home_screen.dart';
import 'screens/calendar_screen.dart';

void main() {
  runApp(
    BlocProvider(
      create: (context) => CircleBloc(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CircleProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => HomeScreen(),
          '/calendar': (context) => CalendarScreen(),
        },
      ),
    );
  }
}
