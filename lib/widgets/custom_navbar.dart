// lib/widgets/custom_navbar.dart
import 'package:flutter/material.dart';

class CustomNavbar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Goals App'),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
