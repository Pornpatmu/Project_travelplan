import 'package:flutter/material.dart';
import 'package:tripplan_1/widgets/main_layout.dart'; // นำเข้า MainLayout
import 'package:tripplan_1/widgets/custom_app_bar.dart'; // นำเข้า CustomAppBar
import 'package:tripplan_1/services/api.dart'; // นำเข้า ApiService สำหรับดึงข้อมูล
import 'PlaceDetailPage.dart';
class FortuneSummaryPage extends StatefulWidget {
  final DateTimeRange dateRange;
  final String province;
  final Map<int, String> allFortunesByDay;
  final Map<int, List<Map<String, dynamic>>> allPlacesByDay;
  // final String fortune;
  // final List<Map<String, dynamic>> places;

  const FortuneSummaryPage({
    super.key,
    required this.dateRange,
    required this.province,
    required this.allFortunesByDay,
    required this.allPlacesByDay,
    // required this.fortune,
    // required this.places,
  });

  @override
  _FortuneSummaryPageState createState() => _FortuneSummaryPageState();
}
class _FortuneSummaryPageState extends State<FortuneSummaryPage> {
  @override
  Widget build(BuildContext context) {
    final tripDates = getTripDates();

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
      body: DefaultTabController(
        length: tripDates.length,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            centerTitle: true,
            title: const Text("เสี่ยงดวง✨"),
            bottom: TabBar(
              indicatorColor: Colors.purple,
              isScrollable: true,
              tabs: tripDates.map((date) {
                return Tab(
                  child: Text(
                    "${date.day} ${_monthShort(date.month)} (${getThaiDay(date)})",
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                  ),
                );
              }).toList(),
            ),
          ),
          body: TabBarView(
            children: tripDates.asMap().entries.map((entry) {
              final index = entry.key;
              final date = entry.value;
              final places = widget.allPlacesByDay[index] ?? [];
              final fortune = widget.allFortunesByDay[index] ?? 'ไม่พบดวง';

              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("📍 จังหวัด: ${widget.province}",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("🔮 ดวงของคุณ: $fortune"),
                      const SizedBox(height: 24),
                      const Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.purple),
                          SizedBox(width: 8),
                          Text(
                            "สถานที่แนะนำ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: places.length,
                          itemBuilder: (context, idx) {
                            final place = places[idx];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.purple,
                                child: Text(
                                  '${idx + 1}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(place['name'] ?? 'ไม่พบชื่อ'),
                              subtitle: GestureDetector(
                                child: Text(
                                  "รายละเอียด",
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PlaceDetailPage(place: place),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  List<DateTime> getTripDates() {
    final days = widget.dateRange.end.difference(widget.dateRange.start).inDays + 1;
    return List.generate(
      days,
      (i) => widget.dateRange.start.add(Duration(days: i)),
    );
  }

  String _monthShort(int month) {
    const months = [
      '', 'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];
    return months[month];
  }

  String getThaiDay(DateTime date) {
    const days = ['อา.', 'จ.', 'อ.', 'พ.', 'พฤ.', 'ศ.', 'ส.'];
    return days[date.weekday % 7];
  }
}
