import 'package:flutter/material.dart';
import 'custom_bottom_nav.dart';

class MainLayout extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final int currentIndex;
  final Function(int) onTap;
  final Color? backgroundColor;

  const MainLayout({
    super.key,
    this.appBar,
    required this.body,
    this.currentIndex = 0,
    required this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      backgroundColor: backgroundColor ?? Colors.white,
      bottomNavigationBar: CustomBottomNav(
        currentIndex: currentIndex,
        onTap: onTap,
      ),
    );
  }
}
