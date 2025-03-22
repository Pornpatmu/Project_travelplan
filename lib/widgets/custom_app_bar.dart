import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'TripPlan',
        style: TextStyle(
          color: Colors.greenAccent,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          fontSize: 20,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
