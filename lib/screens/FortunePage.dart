import 'package:flutter/material.dart';
import 'dart:math';

import '../widgets/main_layout.dart';
import '../widgets/custom_app_bar.dart';

class FortunePage extends StatefulWidget {
  const FortunePage({super.key});

  @override
  State<FortunePage> createState() => _FortunePageState();
}

class _FortunePageState extends State<FortunePage> {
  String? selectedProvince;
  DateTimeRange? selectedDateRange;
  String? fortuneResult;

  final List<String> provinces = [
    'ขอนแก่น',
    'บุรีรัมย์',
    'สุรินทร์',
    'อุดรธานี'
  ];

  final List<String> fortunes = [
    "วันนี้คุณจะพบสิ่งที่ไม่คาดฝัน",
    "โชคดีจะเข้าข้างคุณในการเดินทางครั้งนี้",
    "อาจมีอุปสรรคเล็กน้อย แต่จะผ่านไปได้",
    "จะได้พบกับมิตรใหม่ที่มีความหมาย",
    "โอกาสใหม่กำลังรออยู่ข้างหน้า",
  ];

  Future<void> pickDateRange() async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2026),
    );
    if (result != null) {
      setState(() => selectedDateRange = result);
    }
  }

  void drawFortune() {
    if (selectedProvince != null && selectedDateRange != null) {
      final result = fortunes[Random().nextInt(fortunes.length)];
      setState(() => fortuneResult = result);
    } else {
      setState(() {
        fortuneResult = "กรุณาเลือกจังหวัดและช่วงวันที่ก่อนเสี่ยงดวงนะ!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      appBar: const CustomAppBar(),
      currentIndex: 0, // หรือ 1
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF9FBFD),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'เสี่ยงดวง✨',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // จังหวัด
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text("จังหวัดที่จะไป?"),
                    value: selectedProvince,
                    items: provinces
                        .map((prov) => DropdownMenuItem(
                              value: prov,
                              child: Text(prov),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedProvince = value);
                    },
                  ),
                ),
              ),

              // วันที่
              InkWell(
                onTap: pickDateRange,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            selectedDateRange == null
                                ? "เริ่มต้น"
                                : "${selectedDateRange!.start.toLocal()}"
                                    .split(' ')[0],
                          ),
                        ],
                      ),
                      const Text('|'),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            selectedDateRange == null
                                ? "สิ้นสุด"
                                : "${selectedDateRange!.end.toLocal()}"
                                    .split(' ')[0],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ปุ่มสุ่ม
              ElevatedButton(
                onPressed: drawFortune,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'เริ่มสุ่มดวง',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),

              if (fortuneResult != null) ...[
                const SizedBox(height: 24),
                Text(
                  fortuneResult!,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
