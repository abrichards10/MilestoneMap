import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goals_app/bloc/circle_bloc.dart';
import 'package:goals_app/bloc/circle_state.dart';
import 'package:goals_app/providers/circle_provider.dart';
import 'package:provider/provider.dart';
import '../models/circle.dart';
import '../painters/root_circle_painters.dart';

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
  Offset _initialOffset = Offset.zero; // Store the initial offset

  void _removeMenu() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  void _showAddDialog(Circle parent, CircleProvider circleProvider) {
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
                    isGoal: false, // Task circle
                    offset: Offset(parent.offset.dx,
                        parent.offset.dy - 100), // Place above parent
                    size: 50, // Smaller size for task circles
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

  void _showRemoveDialog(Circle circle, CircleProvider circleProvider) {
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
    final double circleRadius =
        circle.size / 2; // Adjust to match your circle size
    final distance = (point - circle.offset).distance;
    return distance <= circleRadius;
  }

  void _handleTap(Offset position, CircleProvider circleProvider) {
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

  void searchCircle(Circle rootCircle, Offset position) {
    if (_selectedCircle != null) return;

    if (_isPointInsideCircle(position, rootCircle)) {
      _selectedCircle = rootCircle;
    } else {
      for (var child in rootCircle.children) {
        searchCircle(child, position);
        if (_selectedCircle != null) return;
      }
    }
  }

  blocListenerComponent(state, circleProvider) {
    if ((state is CircleUpdatedState) || (state is CircleInitialState)) {
      print("Circle updated");
    }
  }

  Widget returnRootCircle(CircleProvider circleProvider) {
    return Transform(
      transform: Matrix4.identity()
        ..translate(_offset.dx, _offset.dy)
        ..scale(_scale),
      child: CustomPaint(
        key: ValueKey('custom_paint_${DateTime.now().millisecondsSinceEpoch}'),
        painter: RootCirclePainter(circleProvider.rootCircle),
        size: Size.infinite,
      ),
    );
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
            backgroundColor: Color.fromARGB(176, 165, 255, 166),
            body: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onScaleUpdate: (details) {
                      setState(() {
                        _scale = details.scale;
                        _offset = details.focalPoint - details.localFocalPoint;
                      });
                    },
                    onTapUp: (details) {
                      _handleTap(
                        details.localPosition / _scale - _offset,
                        circleProvider,
                      );
                    },
                    child: returnRootCircle(circleProvider),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        _scale = 1.0;
                        _offset =
                            _initialOffset; // Reset to the initial position
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
