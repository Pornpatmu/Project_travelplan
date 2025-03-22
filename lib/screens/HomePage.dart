import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/main_layout.dart';
import '../widgets/custom_plan_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "วางแผนเที่ยวภาคอีสาน",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 5,
              shadowColor: Colors.black26,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                child: Column(
                  children: [
                    CustomPlanButton(
                      icon: Icons.edit,
                      title: "Custom plan",
                      subtitle: "เลือกการวางแผนด้วยตัวเอง",
                      onTap: () {
                        // TODO: ไปหน้า custom plan
                      },
                    ),
                    const SizedBox(height: 15),
                    const Divider(thickness: 1, color: Colors.grey),
                    const SizedBox(height: 15),
                    CustomPlanButton(
                      icon: Icons.auto_awesome,
                      title: "Trip fortune!",
                      subtitle: "สุ่มสถานที่ท่องเที่ยว",
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/fortune');
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () {
                // TODO: ไปหน้าดูประวัติการวางแผน
              },
              child: const Text(
                "ดูประวัติการวางแผน",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
