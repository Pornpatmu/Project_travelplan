import 'package:flutter/material.dart';
import 'dart:math';
import '../widgets/main_layout.dart';
import '../widgets/custom_app_bar.dart';
import 'TripTypePage.dart';
import '../services/api.dart'; // Import ApiService

class FortunePage extends StatefulWidget {
  const FortunePage({super.key});

  @override
  State<FortunePage> createState() => _FortunePageState();
}

class _FortunePageState extends State<FortunePage> {
  String? selectedProvince;
  DateTimeRange? selectedDateRange;
  String? fortuneResult;

  List<String> provinces = []; // รายการจังหวัดที่ได้จาก API

  final List<String> fortunes = [
    "วันนี้คุณจะพบสิ่งที่ไม่คาดฝัน",
    "โชคดีจะเข้าข้างคุณในการเดินทางครั้งนี้",
    "อาจมีอุปสรรคเล็กน้อย แต่จะผ่านไปได้",
    "จะได้พบกับมิตรใหม่ที่มีความหมาย",
    "โอกาสใหม่กำลังรออยู่ข้างหน้า",
  ];

  @override
  void initState() {
    super.initState();
    fetchProvinces(); // ดึงข้อมูลจังหวัดจาก API เมื่อเริ่มหน้า
  }

  // ฟังก์ชันดึงข้อมูลจังหวัดจาก API
  Future<void> fetchProvinces() async {
    try {
      ApiService apiService = ApiService();
      final List<String> fetchedProvinces = await apiService.getProvinces();
      setState(() {
        provinces = fetchedProvinces;
      });
    } catch (e) {
      print("Error fetching provinces: $e");
    }
  }

  Future<void> pickDateRange() async {
    final DateTime now = DateTime.now();

    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: now, // วันที่เริ่มต้นเป็นวันที่ปัจจุบัน
      lastDate: DateTime(2026), // สามารถเลือกวันที่ในอนาคตได้ถึงปี 2026
      initialDateRange: selectedDateRange, // ขอบเขตที่เลือกไว้ก่อนหน้านี้
    );

    if (result != null) {
      setState(() => selectedDateRange = result);
    }
  }

  void drawFortune() {
    final now = DateTime.now();

    if (selectedProvince == null || selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("กรุณาเลือกจังหวัดและช่วงวันที่ก่อนเสี่ยงดวงนะ!"),
        ),
      );
      return;
    }

    if (selectedDateRange!.start
        .isBefore(DateTime(now.year, now.month, now.day))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("ไม่สามารถเลือกวันที่ย้อนหลังได้นะ!"),
        ),
      );
      return;
    }

    final result = fortunes[Random().nextInt(fortunes.length)];
    setState(() => fortuneResult = result);

    // นำทางไปหน้า TripTypePage พร้อมส่งข้อมูลที่เลือก
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripTypePage(
          dateRange: selectedDateRange!,
          province: selectedProvince!,
          fortune: result,
          companion: 'เพื่อนเดินทาง', // สามารถส่งข้อมูลอื่น ๆ เช่น ข้อมูลเพื่อนที่เดินทางได้
        ),
      ),
    );
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

              // จังหวัด (Dropdown ที่ดึงข้อมูลจาก API)
              provinces.isEmpty
                  ? const CircularProgressIndicator() // แสดง loader เมื่อข้อมูลยังไม่มา
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
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
