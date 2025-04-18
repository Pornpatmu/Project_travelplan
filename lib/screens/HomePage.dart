import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/main_layout.dart';
import '../widgets/custom_plan_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      backgroundColor: const Color(0xFFF5F7F9),
      currentIndex: 0,
      onTap: (index) {
        if (index != 0) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      },
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "วางแผนเที่ยวอีสานใหม่",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 5,
                shadowColor: Colors.black26,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
                  child: Column(
                    children: [
                      CustomPlanButton(
                        icon: Icons.edit,
                        title: "Custom plan",
                        subtitle: "เลือกการวางแผนด้วยตัวเอง",
                        onTap: () {
                          Navigator.pushNamed(context, '/customplan');
                        },
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Expanded(
                              child: Divider(thickness: 1, color: Colors.grey)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text("OR",
                                style: TextStyle(color: Colors.grey)),
                          ),
                          Expanded(
                              child: Divider(thickness: 1, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      CustomPlanButton(
                        icon: Icons.auto_awesome,
                        title: "Trip fortune!",
                        subtitle: "สุ่มสถานที่ท่องเที่ยว",
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/fortune');
                        },
                      ),
                      const SizedBox(height: 90),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/history');
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "ดูประวัติการวางแผน",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1F1D1D),
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
