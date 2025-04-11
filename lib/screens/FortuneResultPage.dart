import 'package:flutter/material.dart';
import 'package:tripplan_1/screens/FortuneSummaryPage.dart';
import 'package:tripplan_1/widgets/main_layout.dart';  // นำเข้า MainLayout
import 'package:tripplan_1/widgets/custom_app_bar.dart';  // นำเข้า CustomAppBar

class FortuneResultPage extends StatelessWidget {
  final String province;
  final DateTimeRange dateRange;
  final String fortune;

  const FortuneResultPage({
    super.key,
    required this.province,
    required this.dateRange,
    required this.fortune,
  });

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      appBar: const CustomAppBar(),  // ใช้ CustomAppBar
      currentIndex: 0,
      onTap: (index) {
        if (index == 0) {
          Navigator.pop(context);  // ไปหน้าก่อนหน้า
        } else if (index == 1) {
          Navigator.pushReplacementNamed(context, '/home');  // ไปหน้า home
        }
      },
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '✨ คุณได้เขย่าเซียมซีแล้ว! ✨',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.purple[800],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FortuneSummaryPage(
                        province: province,
                        dateRange: dateRange,
                        fortune: fortune,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.purple,
                  shape: const StadiumBorder(),
                  side: const BorderSide(color: Colors.purple),
                ),
                child: const Text('ดูผล'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
