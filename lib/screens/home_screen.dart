import 'package:easy_sidemenu/easy_sidemenu.dart';
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
  Offset _panOffset = Offset.zero; // Separate offset for panning
  Offset _initialOffset = Offset.zero; // Store the initial offset
  bool _dragging = false; // Initialize dragging variable
  SideMenuController sideMenu = SideMenuController();
  ValueNotifier<List<SideMenuItem>> sideMenuItemsNotifier = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CircleProvider>(context, listen: false)
          .addListener(_updateSideMenuItems);
    });
  }

  @override
  void dispose() {
    Provider.of<CircleProvider>(context, listen: false)
        .removeListener(_updateSideMenuItems);
    sideMenuItemsNotifier.dispose();
    super.dispose();
  }

  void _removeMenu() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  void _showAddDialog(Circle parent, CircleProvider circleProvider) {
    final textController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Circle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: InputDecoration(hintText: 'Title:'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(hintText: 'Description:'),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(selectedDate == null
                      ? 'No Date Selected'
                      : '${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.day.toString().padLeft(2, '0')}'),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      setState(() {
                        selectedDate = pickedDate;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final text = textController.text;
                final description = descriptionController.text;
                if (text.isNotEmpty) {
                  final newCircle = Circle(
                    id: DateTime.now().toString(),
                    text: text,
                    description: description, // Include description
                    date: selectedDate != null
                        ? "${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.day.toString().padLeft(2, '0')}"
                        : null, // Include selected date
                    isGoal: false, // Task circle
                    offset: Offset(parent.offset.dx,
                        parent.offset.dy - 100), // Place above parent
                    size: circleProvider.rootCircle.size *
                        .6, // Smaller size for task circles
                  );

                  circleProvider.addCircle(parent, newCircle);
                  Navigator.of(context).pop();
                  _removeMenu();
                  // Show the information menu for the new circle
                  _showInfoMenu(newCircle.offset, circleProvider);
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
                // Find the parent circle and remove the selected circle
                bool removed =
                    _removeCircleFromParent(circleProvider.rootCircle, circle);

                if (removed) {
                  circleProvider.notifyListeners();
                  Navigator.of(context).pop();
                  _removeMenu();
                } else {
                  // Handle case where the circle was not found
                  print('Circle not found in the parent\'s children list.');
                }
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

  bool _removeCircleFromParent(Circle parent, Circle target) {
    if (parent.children.contains(target)) {
      parent.children.remove(target);
      return true;
    } else {
      for (var child in parent.children) {
        bool removed = _removeCircleFromParent(child, target);
        if (removed) return true;
      }
    }
    return false;
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

  void _pickDate(Circle circle, CircleProvider circleProvider) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        // Format the date as MM/DD/YY
        circle.date = "${pickedDate.month.toString().padLeft(2, '0')}/"
            "${pickedDate.day.toString().padLeft(2, '0')}";
        circleProvider.notifyListeners();
      });
    }
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
                _buildMenuItem('Edit Circle', () {
                  _showEditDialog(circle, circleProvider);
                }),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)!.insert(_overlayEntry!);
  }

  void _showInfoMenu(Offset position, CircleProvider circleProvider) {
    _selectedCircle = null; // Reset selected circle

    searchCircle(circleProvider.rootCircle, position);

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
                Text('Title: ${_selectedCircle?.text}'),
                Text('Date: ${_selectedCircle?.date ?? 'No Date Set'}'),
                Text(
                    'Description: ${_selectedCircle?.description ?? 'No Date Set'}'),
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

  void blocListenerComponent(CircleState state, CircleProvider circleProvider) {
    if ((state is CircleUpdatedState) || (state is CircleInitialState)) {
      print("Circle updated");
    }
  }

  Widget returnRootCircle(CircleProvider circleProvider) {
    return Transform(
      transform: Matrix4.identity()
        ..translate(_offset.dx + _panOffset.dx, _offset.dy + _panOffset.dy)
        ..scale(_scale),
      child: CustomPaint(
        key: ValueKey('custom_paint_${DateTime.now().millisecondsSinceEpoch}'),
        painter: RootCirclePainter(circleProvider.rootCircle),
        size: Size.infinite,
      ),
    );
  }

  void _handleCircleMenuTap(Circle circle) {
    // Handle circle menu item tap
    // For example, you might want to show the circle's details
    _showInfoMenu(
        circle.offset, Provider.of<CircleProvider>(context, listen: false));
  }

  void _updateSideMenuItems() {
    final circleProvider = Provider.of<CircleProvider>(context, listen: false);
    final items = <SideMenuItem>[];

    for (var circle in circleProvider.circles) {
      items.add(SideMenuItem(
        title: circle.text,
        onTap: (index, _) {
          _handleCircleMenuTap(circle);
        },
        icon: Icon(Icons.circle),
        tooltipContent: circle.text,
      ));
    }

    sideMenuItemsNotifier.value = items;
  }

  @override
  Widget build(BuildContext context) {
    final circleProvider = Provider.of<CircleProvider>(context);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.width;

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
                Positioned(
                  child: GestureDetector(
                    onScaleStart: (details) {
                      _handleTap(
                        details.localFocalPoint / _scale - _offset,
                        circleProvider,
                      );

                      if (_selectedCircle != null &&
                          _selectedCircle != circleProvider.rootCircle) {
                        _dragging = true;
                      }
                    },
                    onScaleUpdate: (details) {
                      setState(() {
                        _scale = details.scale;

                        if (_dragging && _selectedCircle != null) {
                          _selectedCircle!.offset +=
                              details.focalPointDelta / _scale;
                          circleProvider.notifyListeners();
                        } else {
                          _offset =
                              details.focalPoint - details.localFocalPoint;
                        }
                      });
                    },
                    onScaleEnd: (details) {
                      _dragging = false;
                    },
                    onTapUp: (details) {
                      _handleTap(
                        details.localPosition / _scale - _offset,
                        circleProvider,
                      );
                    },
                    onDoubleTapDown: (details) {
                      _showInfoMenu(details.localPosition / _scale - _offset,
                          circleProvider);
                    },
                    child: returnRootCircle(circleProvider),
                  ),
                ),
                Positioned(
                  top: 60,
                  child: ValueListenableBuilder<List<SideMenuItem>>(
                    valueListenable: sideMenuItemsNotifier,
                    builder: (context, items, child) {
                      // items.length += 1;
                      // items[1] = SideMenuItem(
                      //   title: "Main Goal",
                      //   onTap: (index, _) {
                      //     _handleCircleMenuTap(circleProvider.rootCircle);
                      //   },
                      //   icon: Icon(Icons.circle),
                      //   tooltipContent: "Main Goal",
                      // );
                      return SideMenu(
                        controller: sideMenu,
                        style: SideMenuStyle(
                          showTooltip: false,
                          displayMode: SideMenuDisplayMode.auto,
                          hoverColor: Colors.blue[100],
                          selectedTitleTextStyle:
                              const TextStyle(color: Colors.white),
                          selectedIconColor: Colors.white,
                        ),
                        items: items,
                      );
                    },
                  ),
                ),
                // Positioned(
                //   top: 60,
                //   child: SideMenu(
                //     controller: sideMenu,
                //     style: SideMenuStyle(
                //       showTooltip: false,
                //       displayMode: SideMenuDisplayMode.auto,
                //       // showHamburger: true,
                //       hoverColor: Colors.blue[100],
                //       // selectedHoverColor: Colors.blue[100],
                //       // selectedColor: Colors.lightBlue,
                //       selectedTitleTextStyle:
                //           const TextStyle(color: Colors.white),
                //       selectedIconColor: Colors.white,
                //     ),
                //     items: [
                //       SideMenuExpansionItem(
                //         title: "Expansion Item",
                //         icon: const Icon(Icons.kitchen),
                //         children: [
                //           SideMenuItem(
                //             title: 'Expansion Item 1',
                //             onTap: (index, _) {
                //               sideMenu.changePage(index);
                //             },
                //             icon: const Icon(Icons.circle),
                //             tooltipContent: "Expansion Item 1",
                //           ),
                //           SideMenuItem(
                //             title: 'Expansion Item 2',
                //             onTap: (index, _) {
                //               sideMenu.changePage(index);
                //             },
                //             icon: const Icon(Icons.circle),
                //           )
                //         ],
                //       ),
                //     ],
                //   ),
                // ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        _scale = 1.0;
                        _panOffset = Offset.zero;
                        _offset = _initialOffset;
                      });
                    },
                    child: Icon(
                      Icons.circle,
                      color: Color.fromARGB(255, 67, 111, 70),
                    ),
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
