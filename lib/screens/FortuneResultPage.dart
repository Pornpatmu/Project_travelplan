import 'package:flutter/material.dart';
import 'package:tripplan_1/screens/FortuneSummaryPage.dart';
import 'package:tripplan_1/widgets/main_layout.dart'; // นำเข้า MainLayout
import 'package:tripplan_1/widgets/custom_app_bar.dart'; // นำเข้า CustomAppBar

class FortuneResultPage extends StatelessWidget {
  final String province;
  final DateTimeRange dateRange;
  // final String fortune;
  // final List<Map<String, dynamic>> places; //  รับสถานที่ที่สุ่มมาจาก ShakePage
  final Map<int, String> allFortunesByDay;
  final Map<int, List<Map<String, dynamic>>> allPlacesByDay;

  const FortuneResultPage({
    super.key,
    required this.province,
    required this.dateRange,
    // required this.fortune,
    // required this.places,
    required this.allFortunesByDay,
    required this.allPlacesByDay,
  });

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      appBar: const CustomAppBar(),
      currentIndex: 0,
      onTap: (index) {
        if (index == 0) {
          Navigator.pop(context);
        } else if (index == 1) {
          Navigator.pushReplacementNamed(context, '/home');
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
                        allFortunesByDay: allFortunesByDay,
                        allPlacesByDay: allPlacesByDay,
                        // fortune: fortune,
                        // places: places,
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
