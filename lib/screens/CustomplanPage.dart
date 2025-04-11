import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';
import '../widgets/custom_app_bar.dart';
import '../services/api.dart';
import 'PlanDetailPage.dart';
import '../models/travel_plan.dart';

class CustomplanPage extends StatefulWidget {
  const CustomplanPage({super.key});

  @override
  State<CustomplanPage> createState() => _CustomplanPageState();
}

class _CustomplanPageState extends State<CustomplanPage> {
  String? selectedProvince;
  DateTimeRange? selectedDateRange;

  List<String> provinces = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProvinces();
  }

  Future<void> fetchProvinces() async {
    try {
      provinces = await ApiService().getProvinces();
    } catch (e) {
      debugPrint('โหลดจังหวัดล้มเหลว: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

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

  void startPlanning() async {
    if (selectedProvince == null || selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณาเลือกจังหวัด และช่วงวันที่")),
      );
      return;
    }

    final newPlan = TravelPlan(
      id: 0,
      name: "แผนเที่ยวใหม่",
      province: selectedProvince!,
      dateRange: selectedDateRange!,
      budget: 0.0,
      spending: 0.0,
      favoritePlaces: [],
      placesByDay: {},
      otherExpenses: [],
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PlanDetailPage(plan: newPlan)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      appBar: const CustomAppBar(),
      currentIndex: 2,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home'); // หน้า Home
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/fortune'); // หน้า Fortune
            break;
          case 2:
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
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonHideUnderline(
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
                onPressed: startPlanning,
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
