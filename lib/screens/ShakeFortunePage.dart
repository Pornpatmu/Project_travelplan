import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tripplan_1/screens/CompanionPage.dart';
import 'package:tripplan_1/screens/FortuneResultPage.dart';
import 'package:tripplan_1/widgets/main_layout.dart';
import 'package:tripplan_1/widgets/custom_app_bar.dart';
import 'package:tripplan_1/services/api.dart';

// ✅ แปลงชื่อหมวดที่ผู้ใช้เลือก (ไทย) ให้ตรงกับ API category
final Map<String, String> thaiCategoryToApiCategory = {
  'สายผจญภัย': 'adventure',
  'สายคาเฟ่': 'cafe',
  'สายธรรมชาติ': 'nature',
  'สายประวัติศาสตร์': 'history',
  'สายทำบุญ & ครอบครัว': 'family',
  'สายกลางคืน': 'nightlife',
};

class ShakeFortunePage extends StatefulWidget {
  final String province;
  final DateTimeRange dateRange;
  // final String selectedCategoriesByDay;
  final Map<int, String> selectedCategoriesByDay;

  const ShakeFortunePage({
    Key? key,
    required this.province,
    required this.dateRange,
    required this.selectedCategoriesByDay,
  }) : super(key: key);

  @override
  _ShakeFortunePageState createState() => _ShakeFortunePageState();
}

class _ShakeFortunePageState extends State<ShakeFortunePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  int currentDayIndex = 0;
  bool allShaken = false;
  Map<int, List<Map<String, dynamic>>> results = {};
  Map<int, String> fortunes = {};

  List<DateTime> get tripDates {
    final days =
        widget.dateRange.end.difference(widget.dateRange.start).inDays + 1;
    return List.generate(
        days, (i) => widget.dateRange.start.add(Duration(days: i)));
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: -10, end: 10)
        .chain(CurveTween(curve: Curves.elasticInOut))
        .animate(_controller);
  }

  void _onShakePressed() async {
    _controller.forward(from: 0).then((_) async {
      final List<String> fortuneList = [
        'โชคดีมาก 🎉',
        'ระวังเรื่องการเงิน 💸',
        'ความรักกำลังมา 💕',
        'มีข่าวดีเร็วๆ นี้ 📬',
        'พักผ่อนบ้างนะ 😌',
      ];

      final Map<int, List<Map<String, dynamic>>> allPlacesByDay = {};
      final Map<int, String> allFortunesByDay = {};

      for (int i = 0; i < tripDates.length; i++) {
        final selectedCategory = widget.selectedCategoriesByDay[i] ?? '';
        final mappedCategory =
            thaiCategoryToApiCategory[selectedCategory] ?? '';
        final fortune = (fortuneList..shuffle()).first;

        try {
          final places = await ApiService().getRandomNearbyPlaces(
            widget.province,
            mappedCategory,
          );
          allPlacesByDay[i] = places;
          allFortunesByDay[i] = fortune;
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เกิดข้อผิดพลาดในวันที่ ${i + 1}')),
          );
          return;
        }
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FortuneResultPage(
            province: widget.province,
            dateRange: widget.dateRange,
            allPlacesByDay: allPlacesByDay,
            allFortunesByDay: allFortunesByDay,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              const Text(
                'เสี่ยงดวง✨',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.75,
                ),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.purple),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'เริ่มเสี่ยงดวงกันเลย',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      height: 300,
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(_shakeAnimation.value, 0),
                              child: child,
                            );
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Colors.purple[100],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Transform.translate(
                                offset: const Offset(0, 12),
                                child: Image.asset(
                                  'assets/images/fortune_stick.png',
                                  height: 300,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Positioned(
                                bottom: 4,
                                child: ElevatedButton(
                                  onPressed: _onShakePressed,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.purple,
                                    side:
                                        const BorderSide(color: Colors.purple),
                                    shape: const StadiumBorder(),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    textStyle: const TextStyle(fontSize: 14),
                                  ),
                                  child: const Text('เขย่าเซียมซี!'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String placeName;

  DetailPage({required this.placeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(placeName),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Center(
        child: Text(
          "รายละเอียดของ $placeName",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
