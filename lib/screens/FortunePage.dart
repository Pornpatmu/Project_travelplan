import 'package:flutter/material.dart';
import 'dart:math';

class FortunePage extends StatefulWidget {
  @override
  _FortunePageState createState() => _FortunePageState();
}

class _FortunePageState extends State<FortunePage> {
  String? selectedProvince;
  DateTimeRange? selectedDateRange;
  String? fortuneResult;

  final List<String> provinces = ['ขอนแก่น', 'บุรีรัมย์', 'สุรินทร์', 'อุดรธานี'];

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
      final random = Random();
      final result = fortunes[random.nextInt(fortunes.length)];
      setState(() {
        fortuneResult = result;
      });
    } else {
      setState(() {
        fortuneResult = "กรุณาเลือกจังหวัดและช่วงวันที่ก่อนเสี่ยงดวงนะ!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FBFD),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.black,
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'TripPlan',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Text(
              'เสี่ยงดวง✨',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: Text("จังหวัดที่จะไป?"),
                        value: selectedProvince,
                        items: provinces
                            .map((prov) => DropdownMenuItem(
                                  child: Text(prov),
                                  value: prov,
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedProvince = value;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  InkWell(
                    onTap: pickDateRange,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16),
                              SizedBox(width: 8),
                              Text(selectedDateRange == null
                                  ? "เริ่มต้น"
                                  : "${selectedDateRange!.start.toLocal()}".split(' ')[0]),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16),
                              SizedBox(width: 8),
                              Text(selectedDateRange == null
                                  ? "สิ้นสุด"
                                  : "${selectedDateRange!.end.toLocal()}".split(' ')[0]),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: drawFortune,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      shape: StadiumBorder(),
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    ),
                    child: Text(
                      'เริ่มสุ่มดวง',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  if (fortuneResult != null) ...[
                    SizedBox(height: 24),
                    Text(
                      fortuneResult!,
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    )
                  ]
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
