import 'package:flutter/material.dart';
import 'package:tripplan_1/widgets/main_layout.dart';  // นำเข้า MainLayout
import 'package:tripplan_1/widgets/custom_app_bar.dart';  // นำเข้า CustomAppBar

class FortuneSummaryPage extends StatelessWidget {
  final DateTimeRange dateRange;
  final String province;
  final String fortune;

  const FortuneSummaryPage({
    super.key,
    required this.dateRange,
    required this.province,
    required this.fortune,
  });

  List<DateTime> getTripDates() {
    final days = dateRange.end.difference(dateRange.start).inDays + 1;
    return List.generate(
      days,
      (i) => dateRange.start.add(Duration(days: i)),
    );
  }

  String getThaiDay(DateTime date) {
    const days = ['อา.', 'จ.', 'อ.', 'พ.', 'พฤ.', 'ศ.', 'ส.'];
    return days[date.weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    final tripDates = getTripDates();

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
      body: DefaultTabController(
        length: tripDates.length,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),        
            foregroundColor: const Color.fromARGB(255, 0, 0, 0),         
            centerTitle: true,                     // ทำให้หัวข้ออยู่ตรงกลาง
            title: const Text("เสี่ยงดวง✨"),
            bottom: TabBar(
              indicatorColor: Colors.purple,       // กำหนดสีของ indicator
              labelColor: Colors.white,            // สีของข้อความใน Tab ให้เป็นสีขาว
              unselectedLabelColor: Colors.white,  // สีของข้อความที่ไม่ถูกเลือก
              isScrollable: true,
              tabs: tripDates.asMap().entries.map((entry) {
                final index = entry.key;
                final date = entry.value;
                return Tab(
                   child: Text(
                    "${date.day} ${_monthShort(date.month)} (${getThaiDay(date)})",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black, // ⭐ เปลี่ยนสีตัวอักษรเป็นสีดำ
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          body: TabBarView(
            children: tripDates.map((date) {
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
                      Text(
                        "📍 จังหวัด: $province",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                      const ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple,
                          child: Text('1', style: TextStyle(color: Colors.white)),
                        ),
                        title: Text("วัดหนองแวง พระอารามหลวง"),
                      ),
                      const ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple,
                          child: Text('2', style: TextStyle(color: Colors.white)),
                        ),
                        title: Text("พิพิธภัณฑสถานแห่งชาติ ขอนแก่น"),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () {
                          // TODO: ไปยังหน้าที่พัก
                        },
                        child: const Text("ดูที่พักที่แนะนำ"),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // กลับไปเขย่าใหม่
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple[100],
                            foregroundColor: Colors.deepPurple,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          ),
                          child: const Text("เขย่าเซียมซีรอบใหม่!"),
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

  String _monthShort(int month) {
    const months = [
      '',
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.'
    ];
    return months[month];
  }
}
