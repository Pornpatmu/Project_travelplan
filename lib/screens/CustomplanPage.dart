import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';
import '../widgets/custom_app_bar.dart';
import 'PlanDetailPage.dart';

class CustomplanPage extends StatefulWidget {
  const CustomplanPage({super.key});

  @override
  State<CustomplanPage> createState() => _CustomplanPageState();
}

class _CustomplanPageState extends State<CustomplanPage> {
  String? selectedProvince;
  DateTimeRange? selectedDateRange;

  final List<String> provinces = [
    'ขอนแก่น',
    'บุรีรัมย์',
    'สุรินทร์',
    'อุดรธานี'
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

  void startPlanning() {
    final now = DateTime.now();

    if (selectedProvince == null || selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("กรุณาเลือกจังหวัดและช่วงวันที่ก่อนเริ่มวางแผน")),
      );
      return;
    }

    if (selectedDateRange!.start
        .isBefore(DateTime(now.year, now.month, now.day))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ไม่สามารถเลือกวันที่ย้อนหลังได้")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlanDetailPage(
          selectedProvince: selectedProvince!,
          selectedDateRange: selectedDateRange!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      appBar: const CustomAppBar(),
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/fortune');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/customplan');
            break;
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
                'วางแผนท่องเที่ยวภาคอีสาน',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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

              // ปุ่มเริ่มวางแผน
              ElevatedButton(
                onPressed: startPlanning, // ไปหน้า PlanDetail
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'เริ่มวางแผน',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
