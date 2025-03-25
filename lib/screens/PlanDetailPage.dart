import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/custom_bottom_nav.dart';
import 'EditBudgetPage.dart';
import 'SearchPlacePage.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'RouterViewPage.dart';

class PlanDetailPage extends StatefulWidget {
  final String selectedProvince;
  final DateTimeRange selectedDateRange;
  final String? initialPlanName;
  final double? initialBudget;
  final double? initialSpending;
  final List<Map<String, dynamic>>? initialFavoritePlaces;
  final Map<int, List<Map<String, dynamic>>>? initialPlacesByDay;
  final List<Map<String, dynamic>>? initialOtherExpenses;

  const PlanDetailPage({
    super.key,
    required this.selectedProvince,
    required this.selectedDateRange,
    this.initialPlanName,
    this.initialBudget,
    this.initialSpending,
    this.initialFavoritePlaces,
    this.initialPlacesByDay,
    this.initialOtherExpenses,
  });

  @override
  State<PlanDetailPage> createState() => _PlanDetailPageState();
}

class _PlanDetailPageState extends State<PlanDetailPage> {
  double budget = 0.0;
  double spending = 0.0;
  final int _currentIndex = 0;
  final TextEditingController _planNameController = TextEditingController();
  String planName = '';
  List<Map<String, dynamic>> favoritePlaces = [];
  Map<int, List<Map<String, dynamic>>> placesByDay = {};
  List<Map<String, dynamic>> otherExpenses = [];
  Map<int, Color> dayColors = {};
  final PopupController _popupController = PopupController();

  @override
  void initState() {
    super.initState();

    planName = widget.initialPlanName ?? '';
    _planNameController.text = planName;
    budget = widget.initialBudget ?? 0.0;
    spending = widget.initialSpending ?? 0.0;
    favoritePlaces = widget.initialFavoritePlaces ?? [];
    placesByDay = widget.initialPlacesByDay ?? {};
    otherExpenses = widget.initialOtherExpenses ?? [];
  }

  LatLng getProvinceLatLng(String province) {
    switch (province) {
      case 'ขอนแก่น':
        return const LatLng(16.4322, 102.8236);
      case 'บุรีรัมย์':
        return const LatLng(14.9946, 103.1036);
      case 'สุรินทร์':
        return const LatLng(14.8818, 103.4936);
      case 'อุดรธานี':
        return const LatLng(17.4138, 102.7872);
      default:
        return const LatLng(16.4322, 102.8236);
    }
  }

  Widget buildFavoriteTile() {
    return buildStyledTile(
      title: const Text('รายการสถานที่ที่สนใจ'),
      children: favoritePlaces.map((place) {
        return ListTile(
          leading: const Icon(Icons.favorite, color: Colors.pink),
          title: Text(place['name'],
              style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAddToDayButton(place),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    favoritePlaces.remove(place);
                  });
                },
                child: const Icon(Icons.delete, color: Colors.grey),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddToDayButton(Map<String, dynamic> place) {
    return ElevatedButton(
      onPressed: () {
        _onAddToDay(place);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[300],
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: const Row(
        children: [
          Text('เพิ่มใน', style: TextStyle(color: Colors.black54)),
          Icon(Icons.arrow_drop_down, color: Colors.black54),
        ],
      ),
    );
  }

  void _onAddToDay(Map<String, dynamic> place) async {
    final start = widget.selectedDateRange.start;
    final end = widget.selectedDateRange.end;
    final dayCount = end.difference(start).inDays + 1;

    final selectedDay = await showModalBottomSheet<int>(
      backgroundColor: const Color.fromARGB(255, 228, 241, 231),
      context: context,
      builder: (context) => ListView(
        children: List.generate(dayCount, (index) {
          final date = start.add(Duration(days: index));
          return ListTile(
            title: Text('วันที่ ${date.day} ${_monthName(date.month)}'),
            onTap: () => Navigator.pop(context, index),
          );
        }),
      ),
    );

    if (selectedDay != null) {
      setState(() {
        placesByDay.putIfAbsent(selectedDay, () => []);

        // 🔸 เพิ่มตรงนี้: ถ้ายังไม่มี ให้เพิ่ม expense = 0.0
        final alreadyAdded =
            placesByDay[selectedDay]!.any((p) => p['name'] == place['name']);

        if (!alreadyAdded) {
          final placeWithExpense = Map<String, dynamic>.from(place);
          placeWithExpense['expense'] = 0.0;

          placesByDay[selectedDay]!.add(placeWithExpense);
        }
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  String _monthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  String _thaiWeekday(int weekday) {
    const weekdays = [
      'จันทร์',
      'อังคาร',
      'พุธ',
      'พฤหัสบดี',
      'ศุกร์',
      'เสาร์',
      'อาทิตย์'
    ];
    return weekdays[(weekday - 1) % 7];
  }

  Widget _buildNumberedPin(int number, int dayIndex) {
    final color = dayColors[dayIndex] ?? Colors.orange; // ถ้าไม่เลือกใช้สีส้ม

    return CircleAvatar(
      backgroundColor: color,
      radius: 14,
      child: Text(
        number.toString(),
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  List<Widget> buildDayTiles() {
    final start = widget.selectedDateRange.start;
    final end = widget.selectedDateRange.end;
    final dayCount = end.difference(start).inDays + 1;

    return List.generate(dayCount, (index) {
      final date = start.add(Duration(days: index));
      final thaiWeekday = _thaiWeekday(date.weekday);

      final dayPlaces = placesByDay[index] ?? [];

      return buildStyledTile(
          key: ValueKey('day-$index'),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'วันที่ ${date.day} ${_monthName(date.month)} , $thaiWeekday',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              GestureDetector(
                onTap: () => _pickColorForDay(index),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dayColors[index] ?? Colors.orange, // ✅ สีที่เลือกไว้
                  ),
                ),
              ),
            ],
          ),
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: dayPlaces.length * 72,
              ),
              child: ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = dayPlaces.removeAt(oldIndex);
                    dayPlaces.insert(newIndex, item);
                    placesByDay[index] = List.from(dayPlaces);
                  });
                },
                children: List.generate(dayPlaces.length, (i) {
                  final place = dayPlaces[i];
                  return ListTile(
                    key: ValueKey('$i-${place['name']}'),
                    leading: _buildNumberedPin(i + 1, index),
                    title: Text(place['name']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          placesByDay[index]?.removeAt(i);
                          _popupController.hideAllPopups();
                        });
                      },
                    ),
                  );
                }),
              ),
            ),
          ]);
    });
  }

  Widget buildStyledTile({
    Key? key, // ✅ เพิ่มตรงนี้
    required Widget title,
    required List<Widget> children,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3))
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: title,
          collapsedIconColor: const Color(0xFF1B9D66),
          iconColor: const Color(0xFF1B9D66),
          children: children,
        ),
      ),
    );
  }

  void _navigateToEditBudget() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBudgetPage(
          initialBudget: budget,
          placesByDay: placesByDay,
          initialOtherExpenses: otherExpenses,
          onSave: (newBudget, newSpending, updatedOtherExpenses) {
            Navigator.pop(context, {
              'budget': newBudget,
              'spending': newSpending,
              'otherExpenses': updatedOtherExpenses,
            });
          },
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        budget = result['budget'] ?? budget;
        spending = result['spending'] ?? spending;
        otherExpenses =
            List<Map<String, dynamic>>.from(result['otherExpenses'] ?? []);
      });
    }
  }

  void savePlan() {
    if (planName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณากรอกชื่อแผนก่อนบันทึก")),
      );
      return;
    }

    // แค่แสดงว่าเซฟสำเร็จ
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("แผน '$planName' ถูกบันทึกเรียบร้อยแล้ว!")),
    );

    //เก็บข้อมูลไว้ใช้ภายหลัง
    // savedPlan = {...};
  }

  final Map<String, Map<String, dynamic>> _markerKeyToPlace = {};
  List<Marker> _buildAllMarkers() {
    final markers = <Marker>[];
    _markerKeyToPlace.clear(); // ล้างก่อน

    placesByDay.forEach((dayIndex, places) {
      for (int i = 0; i < places.length; i++) {
        final place = places[i];
        if (place.containsKey('lat') && place.containsKey('lon')) {
          final keyStr = '$dayIndex-$i'; // ทำให้เป็น key string
          _markerKeyToPlace[keyStr] = place; // map key → place

          final color = dayColors[dayIndex] ?? Colors.orange;
          markers.add(
            Marker(
              key: ValueKey(keyStr),
              point: LatLng(place['lat'], place['lon']),
              width: 40,
              height: 40,
              child: CircleAvatar(
                backgroundColor: color,
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        }
      }
    });

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final LatLng centerLatLng = getProvinceLatLng(widget.selectedProvince);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFD),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(center: centerLatLng, zoom: 13),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.tripplan',
                    ),
                    PopupMarkerLayer(
                      options: PopupMarkerLayerOptions(
                        markers: _buildAllMarkers(),
                        popupController: _popupController,
                        markerTapBehavior: MarkerTapBehavior.togglePopup(),
                        popupDisplayOptions: PopupDisplayOptions(
                          builder: (BuildContext context, Marker marker) {
                            final keyStr =
                                (marker.key as ValueKey<String>).value;
                            final place = _markerKeyToPlace[keyStr];

                            return Card(
                              color: const Color(
                                  0xFFE0F7E9), // ✅ เปลี่ยนสีพื้นหลังตรงนี้
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: Text(
                                  place?['name'] ?? 'ไม่มีชื่อ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B9D66), // ✅ สีตัวอักษร
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          final start = widget.selectedDateRange.start;
                          final end = widget.selectedDateRange.end;
                          final dayCount = end.difference(start).inDays + 1;

                          for (int i = 0; i < dayCount; i++) {
                            dayColors.putIfAbsent(
                                i, () => Colors.orange); // หรือสี default
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewRoutePage(
                                placesByDay: placesByDay,
                                dayColors: dayColors,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF1B9D66), // สีเขียวเข้มแบบละมุน
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 3,
                          shadowColor: const Color.fromARGB(66, 59, 58, 58),
                        ),
                        child: const Text(
                          "ดูเส้นทาง",
                          style: TextStyle(
                            color: Color.fromARGB(255, 236, 231, 231),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8), // ระยะห่างระหว่างปุ่ม
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchPlacePage(
                                center: centerLatLng,
                                province: widget.selectedProvince,
                                initialFavorites: favoritePlaces,
                              ),
                            ),
                          ).then((result) {
                            if (result != null &&
                                result is List<Map<String, dynamic>>) {
                              setState(() {
                                favoritePlaces = result;
                              });
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3DEBA1),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text(
                          "ค้นหาสถานที่",
                          style: TextStyle(
                              color: Color(0xFF1B9D66),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8)
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _planNameController,
                    decoration: const InputDecoration(
                      hintText: "ใส่ชื่อแผนของคุณ...",
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {
                        planName = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.green,
                        radius: 16,
                        child: Icon(Icons.calendar_month,
                            color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${widget.selectedDateRange.start.day} ${_monthName(widget.selectedDateRange.start.month)} - '
                        '${widget.selectedDateRange.end.day} ${_monthName(widget.selectedDateRange.end.month)} ${widget.selectedDateRange.end.year + 543}',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text("งบของคุณ  ",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('฿${budget.toStringAsFixed(2)} บาท'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text("ใช้จ่าย       ",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('฿${spending.toStringAsFixed(2)} บาท'),
                        ],
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: _navigateToEditBudget,
                    child: const Icon(Icons.edit,
                        size: 20, color: Color(0xFF1B9D66)),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                buildFavoriteTile(),
                ...buildDayTiles(),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        color: Colors.white,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: savePlan,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B9D66),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text(
            'บันทึกแผนเที่ยว',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _planNameController.dispose();
    super.dispose();
  }

  Widget _colorOption(Color color, int dayIndex) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, color),
      child: CircleAvatar(
        backgroundColor: color,
        radius: 18,
        child: dayColors[dayIndex] == color
            ? const Icon(Icons.check, color: Colors.white)
            : null,
      ),
    );
  }

  void _pickColorForDay(int dayIndex) async {
    Color pickedColor = dayColors[dayIndex] ?? Colors.orange;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('เลือกสีหมุดของวัน'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickedColor,
              onColorChanged: (color) {
                pickedColor = color;
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('เลือก'),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  dayColors[dayIndex] = pickedColor;
                });
              },
            ),
          ],
        );
      },
    );
  }
}

class TravelPlan {
  final String name;
  final String province;
  final DateTimeRange dateRange;
  final double budget;
  final double spending;

  TravelPlan({
    required this.name,
    required this.province,
    required this.dateRange,
    required this.budget,
    required this.spending,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'province': province,
      'startDate': dateRange.start.toIso8601String(),
      'endDate': dateRange.end.toIso8601String(),
      'budget': budget,
      'spending': spending,
    };
  }
}
