import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tripplan_1/screens/CompanionPage.dart';
import 'package:tripplan_1/screens/FortuneResultPage.dart';
import 'package:tripplan_1/widgets/main_layout.dart';  // นำเข้า MainLayout
import 'package:tripplan_1/widgets/custom_app_bar.dart';  // นำเข้า CustomAppBar

final List<String> fortuneList = [
  'โชคดีมาก 🎉',
  'ระวังเรื่องการเงิน 💸',
  'ความรักกำลังมา 💕',
  'มีข่าวดีเร็วๆ นี้ 📬',
  'พักผ่อนบ้างนะ 😌',
];

class ShakeFortunePage extends StatefulWidget {
  final String province;
  final DateTimeRange dateRange;

  const ShakeFortunePage({
    Key? key,
    required this.province,
    required this.dateRange,
  }) : super(key: key);

  @override
  _ShakeFortunePageState createState() => _ShakeFortunePageState();
}

class _ShakeFortunePageState extends State<ShakeFortunePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_controller);
  }

  void _onShakePressed() {
    _controller.forward(from: 0).then((_) {
      final randomFortune = (fortuneList..shuffle()).first;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FortuneResultPage(
            province: widget.province,
            dateRange: widget.dateRange,
            fortune: randomFortune,
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
      appBar: const CustomAppBar(),  // ใช้ CustomAppBar
      currentIndex: 0,
      onTap: (index) {
        if (index == 0) {
          Navigator.pop(context);  // ถ้าสามารถย้อนกลับได้
        } else if (index == 1) {
          Navigator.pushReplacementNamed(context, '/home');  // ไปหน้า home
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 🔼 Top Section (ปุ่มย้อน + ข้อความกลาง)
                    Row(
                      children: [
                        const Icon(Icons.arrow_back),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'เริ่มเสี่ยงดวงกันเลย',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 🔁 Centered Fortune + Circle + Button
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: const Offset(0, 125),
                          child: child,
                        );
                      },
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final screenWidth = MediaQuery.of(context).size.width;
                          final circleSize = screenWidth * 0.6;
                          final imageSize = screenWidth * 0.5;

                          return Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // วงกลมพื้นหลัง
                                Transform.translate(
                                  offset: Offset(0, 50), // ✅ ขยับวงกลมลง 20 px
                                  child: Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.purple[100],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                // รูปเซียมซี
                                Transform.translate(
                                  offset: const Offset(0, 12), // ขยับเล็กน้อย
                                  child: Image.asset(
                                    'assets/images/fortune_stick.png',
                                    height: 300,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                // ปุ่มเขย่า
                                Positioned(
                                  bottom: 4,
                                  child: ElevatedButton(
                                    onPressed: _onShakePressed,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.purple,
                                      side: const BorderSide(
                                          color: Colors.purple),
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
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 32), // ระยะล่างพอดี
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
