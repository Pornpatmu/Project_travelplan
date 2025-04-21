import 'package:flutter/material.dart';
import 'package:tripplan_1/screens/FortuneResultPage.dart';
import 'package:tripplan_1/widgets/main_layout.dart';
import 'package:tripplan_1/widgets/custom_app_bar.dart';
import 'package:tripplan_1/services/api.dart';

class ShakeFortunePage extends StatefulWidget {
  final String province;
  final DateTimeRange dateRange;
  final Map<int, String> selectedCategoriesByDay;
  final String companion;

  const ShakeFortunePage({
    Key? key,
    required this.province,
    required this.dateRange,
    required this.companion,
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
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -0.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.1, end: 0.1), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.1, end: -0.1), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.1, end: 0), weight: 1),
    ]).animate(_controller);
  }

  void _onShakePressed() async {
    _controller.forward(from: 0).then((_) async {
      final Map<int, List<Map<String, dynamic>>> allPlacesByDay = {};

      for (int i = 0; i < tripDates.length; i++) {
        final category = widget.selectedCategoriesByDay[i];
        if (category == null || category.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ไม่พบประเภทในวันที่ ${i + 1}')),
          );
          return;
        }

        try {
          // 🔍 Debug print
          print('📦 QUERY → day=${i + 1}');
          print('➡️ province = ${widget.province}');
          print('➡️ category = $category');
          print('➡️ companion = ${widget.companion}');

          final places = await ApiService().getRandomNearbyPlaces(
            widget.province,
            category,
            companion: widget.companion,
            tripType: category,
          );

          print('✅ ได้สถานที่ ${places.length} แห่งในวัน ${i + 1}');
          allPlacesByDay[i] = places;
        } catch (e, stack) {
          print('❌ ERROR on day ${i + 1}: $e');
          print('🧵 STACK TRACE:\n$stack');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('เกิดข้อผิดพลาดในวันที่ ${i + 1}\n${e.toString()}'),
              duration: const Duration(seconds: 5),
            ),
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
            tripTypesByDay: widget.selectedCategoriesByDay,
            companion: widget.companion,
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
                  minHeight: MediaQuery.of(context).size.height * 0.55,
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
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                            return Transform.rotate(
                              angle: _shakeAnimation.value,
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

  const DetailPage({super.key, required this.placeName});

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
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
