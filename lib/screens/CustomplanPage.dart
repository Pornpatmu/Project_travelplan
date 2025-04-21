import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';
import '../widgets/custom_app_bar.dart';
import '../services/api.dart';
import 'PlanDetailPage.dart';
import '../models/travel_plan.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CustomplanPage extends StatefulWidget {
  const CustomplanPage({super.key});

  @override
  State<CustomplanPage> createState() => _CustomplanPageState();
}

class _CustomplanPageState extends State<CustomplanPage> {
  String? selectedProvince;
  DateTimeRange? selectedDateRange;
  FocusNode dropdownFocusNode = FocusNode();
  bool isDropdownOpen = false;
  List<String> provinces = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProvinces();

    dropdownFocusNode.addListener(() {
      setState(() {
        isDropdownOpen = dropdownFocusNode.hasFocus;
      });
    });
  }

  Future<void> fetchProvinces() async {
    try {
      provinces = await ApiService().getProvinces();
    } catch (e) {
      debugPrint('เกิดข้อผิดพลาด: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> pickDateRange() async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            useMaterial3: false,
            primaryColor: const Color(0xFF11AF6D),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF11AF6D),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textTheme: const TextTheme(
              bodyMedium: TextStyle(fontSize: 14),
            ),
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null && mounted) {
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
    final normalizedStart = DateTime(
      selectedDateRange!.start.year,
      selectedDateRange!.start.month,
      selectedDateRange!.start.day,
    );
    final normalizedEnd = DateTime(
      selectedDateRange!.end.year,
      selectedDateRange!.end.month,
      selectedDateRange!.end.day,
      23,
      59,
      59,
    );
    final newPlan = TravelPlan(
      id: 0,
      name: "แผนเที่ยวใหม่",
      province: selectedProvince!,
      dateRange: DateTimeRange(start: normalizedStart, end: normalizedEnd),
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
                'วางแผนท่องเที่ยวภาคอีสาน',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // จังหวัด
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    focusNode: dropdownFocusNode,
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
                    buttonStyleData: ButtonStyleData(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDropdownOpen
                              ? const Color(0xFF11AF6D)
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                        boxShadow: isDropdownOpen
                            ? [
                                BoxShadow(
                                  color: Colors.greenAccent.withOpacity(0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : [],
                      ),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 250, // 🟢 ปรับความสูง dropdown
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      scrollbarTheme: ScrollbarThemeData(
                        radius: const Radius.circular(8),
                        thickness: WidgetStateProperty.all(6),
                        thumbColor:
                            WidgetStateProperty.all(const Color(0xFF11AF6D)),
                      ),
                    ),
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
