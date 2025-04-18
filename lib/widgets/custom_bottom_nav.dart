import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // ปุ่ม back
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: Colors.white,
            onPressed: () => onTap(0), // index 0 = back
          ),

// ปุ่ม home
          IconButton(
            icon: Icon(
              Icons.home,
              color: currentIndex == 1 ? Colors.white : Colors.white54,
            ),
            onPressed: () => onTap(1), // index 1 = home จริง
          ),

          // เมนู 3 ขีด
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.white),
            onSelected: (value) {
              if (value == 'fortune') {
                Navigator.pushReplacementNamed(context, '/fortune');
              } else if (value == 'customplan') {
                Navigator.pushReplacementNamed(context, '/customplan');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'fortune',
                child: Text('สุ่มแผนเที่ยว'),
              ),
              const PopupMenuItem(
                value: 'customplan',
                child: Text('วางแผนเอง'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
