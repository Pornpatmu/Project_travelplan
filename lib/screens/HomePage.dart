import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "MyTrip",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: Colors.green,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 5,
        shadowColor: Colors.black26,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "วางแผนเที่ยวภาคอีสาน",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
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
                      icon: Icons.link,
                      title: "Custom plan",
                      subtitle: "เลือกการวางแผนด้วยตัวเอง",
                    ),
                    const SizedBox(height: 15),
                    const Divider(thickness: 1, color: Colors.grey),
                    const SizedBox(height: 15),
                    CustomPlanButton(
                      icon: Icons.auto_awesome,
                      title: "Trip fortune!",
                      subtitle: "สุ่มสถานที่ท่องเที่ยว",
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () {},
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

class CustomPlanButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const CustomPlanButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(15),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        elevation: 3,
        shadowColor: Colors.black26,
      ),
      onPressed: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2), // พื้นหลังไอคอน
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.green),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
