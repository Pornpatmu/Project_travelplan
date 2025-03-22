import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';
import '../widgets/custom_app_bar.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      appBar: const CustomAppBar(),
      currentIndex: 0,
      onTap: (index) {
        if (index == 0) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context); // 🔙 ย้อนกลับ
          } else {
            Navigator.pushReplacementNamed(
                context, '/home'); // fallback ไปหน้า home
          }
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      },
      body: const Center(
        child: Text('ยังไม่มีประวัติการวางแผนเที่ยว'),
      ),
    );
  }
}
