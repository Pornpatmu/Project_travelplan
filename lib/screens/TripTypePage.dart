import 'package:flutter/material.dart';
import 'package:tripplan_1/widgets/main_layout.dart';
import 'package:tripplan_1/widgets/custom_app_bar.dart';
import 'ShakeFortunePage.dart';

class TripTypePage extends StatefulWidget {
  final DateTimeRange dateRange;
  final String province;
  final String fortune;
  final String companion;

  const TripTypePage({
    super.key,
    required this.dateRange,
    required this.province,
    required this.fortune,
    required this.companion,
  });

  @override
  State<TripTypePage> createState() => _TripTypePageState();
}

class _TripTypePageState extends State<TripTypePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<int, String> selectedTypes = {}; // วัน -> ประเภท

  final List<String> tripTypes = [
    "ผจญภัย",
    "คาเฟ่ & ช็อปปิ้ง",
    "ธรรมชาติ & ชมวิว",
    "วัฒนธรรม & ประวัติศาสตร์",
    "ครอบครัว & ทำบุญ",
    "ปาร์ตี้ & สายกลางคืน"
  ];

  List<DateTime> getTripDates() {
    final days =
        widget.dateRange.end.difference(widget.dateRange.start).inDays + 1;
    return List.generate(
        days, (i) => widget.dateRange.start.add(Duration(days: i)));
  }

  @override
  void initState() {
    super.initState();
    final tripDays =
        widget.dateRange.end.difference(widget.dateRange.start).inDays + 1;
    _tabController = TabController(length: tripDays, vsync: this);
  }

  void goNextPage() {
    if (selectedTypes.length == _tabController.length) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShakeFortunePage(
            province: widget.province,
            dateRange: widget.dateRange,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณาเลือกประเภทให้ครบทุกวัน")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripDates = getTripDates();

    return MainLayout(
      appBar: const CustomAppBar(),
      currentIndex: 0,
      onTap: (index) {
        if (index == 0) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context); // ถ้าสามารถย้อนกลับได้
          } else {
            Navigator.pushReplacementNamed(
                context, '/home'); // ไปหน้า home ถ้าไม่สามารถย้อนกลับได้
          }
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      },
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "เสี่ยงดวง✨",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "วันที่ ${_tabController.index + 1} (${tripDates[_tabController.index].day}/${tripDates[_tabController.index].month})",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TabBar(
                controller: _tabController,
                labelColor: Colors.purple,
                unselectedLabelColor: Colors.black,
                indicatorColor: Colors.purple,
                isScrollable: true,
                onTap: (_) => setState(() {}),
                tabs: tripDates
                    .asMap()
                    .entries
                    .map((entry) => Tab(
                          child: Text(
                            "วันที่ ${entry.key + 1}\n${entry.value.day}/${entry.value.month}",
                            textAlign: TextAlign.center,
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),

              // กรอบที่ใส่ title
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    // ใส่ title ที่ด้านบนของกรอบ
                    Text(
                      "เลือกประเภทการเที่ยวของคุณ", // ข้อความที่คุณต้องการ
                      style: TextStyle(
                        fontSize: 18, // ขนาดตัวอักษร
                        fontWeight: FontWeight.bold, // ตัวหนา
                        color: Colors.black, // สีข้อความ
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ตัวเลือกประเภทการเที่ยว
                    ...tripTypes.map((type) {
                      final isSelected =
                          selectedTypes[_tabController.index] == type;
                      return GestureDetector(
                        onTap: () => setState(() {
                          selectedTypes[_tabController.index] = type;
                        }),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: isSelected
                                    ? Colors.purple
                                    : Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                            color: isSelected
                                ? Colors.purple.shade50
                                : Colors.white,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: isSelected
                                    ? Colors.purple
                                    : Colors.transparent,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  type,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: goNextPage,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text("ถัดไป",
                            style: TextStyle(color: Colors.purple)),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
