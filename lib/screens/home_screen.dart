// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goals_app/bloc/circle_bloc.dart';
import 'package:goals_app/bloc/circle_state.dart';
import 'package:provider/provider.dart';
import '../models/circle.dart';
import '../painters/circle_painters.dart';
import '../providers/circle_provider.dart';
import '../widgets/custom_navbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Circle? _selectedCircle;
  OverlayEntry? _overlayEntry;
  double _scale = 1.0;
  Offset _offset = Offset.zero;

  void _removeMenu() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  void _showAddDialog(Circle parent, circleProvider) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Circle'),
          content: TextField(
            controller: textController,
            decoration: InputDecoration(hintText: 'Enter circle text'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final text = textController.text;
                if (text.isNotEmpty) {
                  final newCircle = Circle(
                    id: DateTime.now().toString(),
                    text: text,
                    isGoal: false,
                    offset: Offset(100, 100), // Placeholder position
                  );
                  circleProvider.addCircle(parent, newCircle);
                  Navigator.of(context).pop();
                  _removeMenu();
                }
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showRemoveDialog(Circle circle, circleProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Remove Circle'),
          content: Text('Are you sure you want to remove this circle?'),
          actions: [
            TextButton(
              onPressed: () {
                circleProvider.removeCircle(circleProvider.rootCircle, circle);
                Navigator.of(context).pop();
                _removeMenu();
              },
              child: Text('Remove'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showMoveDialog(Circle circle) {
    // Implement move dialog or drag-and-drop logic here
  }

  void _showEditDialog(Circle circle, CircleProvider circleProvider) {
    final textController = TextEditingController(text: circle.text);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Circle'),
          content: TextField(
            controller: textController,
            decoration: InputDecoration(hintText: 'Enter new text'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final newText = textController.text;
                if (newText.isNotEmpty) {
                  circleProvider.updateCircle(circle, newText);
                  Navigator.of(context).pop();
                  _removeMenu();
                  setState(() {});
                }
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _removeMenu();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuItem(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        onTap();
        _removeMenu(); // Remove menu after item is tapped
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Text(title),
      ),
    );
  }

  void _showMenu(
      Circle circle, Offset position, CircleProvider circleProvider) {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx + 20,
        top: position.dy,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(8),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMenuItem('Add Circle', () {
                  _showAddDialog(circle, circleProvider);
                }),
                _buildMenuItem('Remove Circle', () {
                  _showRemoveDialog(circle, circleProvider);
                }),
                _buildMenuItem('Move Circle', () {
                  _showMoveDialog(circle);
                }),
                _buildMenuItem('Edit Circle', () {
                  _showEditDialog(circle, circleProvider);
                }),
                _buildMenuItem('Set Date', () {
                  // Implement date functionality
                  _removeMenu();
                }),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)!.insert(_overlayEntry!);
  }

  bool _isPointInsideCircle(Offset point, Circle circle) {
    const double circleRadius = 50; // Adjust to match your circle size
    final distance = (point - circle.offset).distance;
    return distance <= circleRadius;
  }

  void searchCircle(Circle circle, Offset position) {
    if (_selectedCircle != null) return;

    if (_isPointInsideCircle(position, circle)) {
      _selectedCircle = circle;
    } else {
      for (var child in circle.children) {
        searchCircle(child, position);
        if (_selectedCircle != null) return;
      }
    }
  }

  void _handleTap(Offset position, circleProvider) {
    _selectedCircle = null; // Reset selected circle

    searchCircle(circleProvider.rootCircle, position);

    if (_selectedCircle == null) {
      print("No circle found at position: $position");
      _removeMenu(); // Close menu if tapping outside any circle
    } else {
      print("Found a circle: ${_selectedCircle!.text} at position: $position");
      _showMenu(_selectedCircle!, position, circleProvider);
    }
  }

  blocListenerComponent(state, circleProvider) {
    if ((state is CircleUpdatedState) || (state is CircleInitialState)) {
      print("Circle updated");
    }
  }

  @override
  Widget build(BuildContext context) {
    final circleProvider = Provider.of<CircleProvider>(context);

    return BlocListener<CircleBloc, CircleState>(
      listener: (context, state) {
        blocListenerComponent(state, circleProvider);
      },
      child: BlocBuilder<CircleBloc, CircleState>(
        builder: (context, state) {
          return Scaffold(
            appBar: CustomNavbar(), // Use your custom navbar here
            body: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onScaleUpdate: (details) {
                      _scale = details.scale;
                      _offset = details.focalPoint - details.localFocalPoint;
                    },
                    onTapUp: (details) {
                      _handleTap(details.localPosition / _scale - _offset,
                          circleProvider);
                    },
                    child: Transform(
                      transform: Matrix4.identity()
                        ..translate(_offset.dx, _offset.dy)
                        ..scale(_scale),
                      child: CustomPaint(
                        key: ValueKey(
                            'custom_paint_${DateTime.now().millisecondsSinceEpoch}'),
                        painter: CirclePainter(circleProvider.rootCircle),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        _scale = 1.0;
                        _offset = Offset.zero;
                      });
                    },
                    child: Icon(Icons.home),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
