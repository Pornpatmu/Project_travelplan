import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/custom_bottom_nav.dart';
import 'EditBudgetPage.dart';
import 'SearchPlacePage.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'RouterViewPage.dart';
import '../models/travel_plan.dart';
import '../services/api.dart';
import 'dart:convert';

class PlanDetailPage extends StatefulWidget {
  final TravelPlan plan;
  const PlanDetailPage({super.key, required this.plan});

  @override
  State<PlanDetailPage> createState() => _PlanDetailPageState();
}

class _PlanDetailPageState extends State<PlanDetailPage> {
  bool isSaved = false;
  LatLng? centerLatLng;
  final api = ApiService();
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
  List<String> existingPlanNames = [];
  Map<String, dynamic>? originalSnapshot;

  late int _planId;
  bool hasDataChanged({String? newPlanName, List? newFavoritePlaces}) {
    if (newPlanName != null && newPlanName != planName) return true;
    if (newFavoritePlaces != null &&
        newFavoritePlaces.length != favoritePlaces.length) {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _planId = widget.plan.id;
    fetchLatLngAndPlanDetails();
    fetchAllPlanNames();
  }

  Future<void> fetchAllPlanNames() async {
    final allPlans = await api.getAllPlans();
    setState(() {
      existingPlanNames = allPlans
          .map((plan) => plan['name']?.toString() ?? '')
          .where((name) => name.isNotEmpty && planName != name)
          .toList();
    });
  }

  Future<void> fetchLatLngAndPlanDetails() async {
    try {
      final latLng = await api.getProvinceLatLng(widget.plan.province);
      centerLatLng = latLng;

      if (_planId == 0) {
        planName = widget.plan.name;
        budget = widget.plan.budget;
        spending = widget.plan.spending;
        favoritePlaces = widget.plan.favoritePlaces;
        otherExpenses = widget.plan.otherExpenses;
        placesByDay = widget.plan.placesByDay;

        //   final start = widget.plan.dateRange.start;
        //   final end = widget.plan.dateRange.end;
        //   final dayCount = end.difference(start).inDays + 1;
        //   for (int i = 0; i < dayCount; i++) {
        //     dayColors[i] = Colors.orange;
        //   }
        //   setState(() {});
        //   return;
        // }

        final start = widget.plan.dateRange.start;
        final end = widget.plan.dateRange.end;
        final difference = end.difference(start).inDays;
        final dayCount = end.difference(start).inDays + 1;

        if (difference > 2) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('สามารถวางแผนได้สูงสุด 3 วัน 2 คืนเท่านั้น'),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.pop(context); // กลับไปหน้าก่อนหน้า
          });

          return;
        } else {
          for (int i = 0; i < dayCount; i++) {
            dayColors[i] = Colors.orange;
          }
          setState(() {});
          return;
        }
      }

      final planData = await api.getPlanDetails(_planId);
      planName = planData['name'];
      _planNameController.text = planData['name'];
      budget = (planData['budget'] as num).toDouble();
      spending = (planData['spending'] as num).toDouble();
      favoritePlaces =
          List<Map<String, dynamic>>.from(planData['favoritePlaces']);
      otherExpenses =
          List<Map<String, dynamic>>.from(planData['otherExpenses']);
      placesByDay = Map<int, List<Map<String, dynamic>>>.from(
        (planData['placesByDay'] as Map).map(
          (key, value) => MapEntry(
            int.parse(key.toString()),
            List<Map<String, dynamic>>.from(value),
          ),
        ),
      );
      if (planData['dayColors'] != null) {
        dayColors = (planData['dayColors'] as Map).map(
          (key, value) => MapEntry(int.parse(key.toString()), Color(value)),
        );
      } else {
        final start = widget.plan.dateRange.start;
        final end = widget.plan.dateRange.end;
        final dayCount = end.difference(start).inDays + 1;
        for (int i = 0; i < dayCount; i++) {
          dayColors[i] = Colors.orange;
        }
      }
      setState(() {});
      originalSnapshot = {
        'planName': planName,
        'budget': budget,
        'spending': spending,
        'favoritePlaces': jsonEncode(favoritePlaces),
        'otherExpenses': jsonEncode(otherExpenses),
        'placesByDay': jsonEncode(placesByDay),
        'dayColors': jsonEncode(
          dayColors.map((key, value) => MapEntry(key.toString(), value.value)),
        ),
      };
    } catch (e) {
      debugPrint('[ERROR] fetchLatLngAndPlanDetails: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  bool isModified() {
    if (originalSnapshot == null) return false;

    return originalSnapshot!['planName'] != planName ||
        originalSnapshot!['budget'] != budget ||
        originalSnapshot!['spending'] != spending ||
        originalSnapshot!['favoritePlaces'] != jsonEncode(favoritePlaces) ||
        originalSnapshot!['otherExpenses'] != jsonEncode(otherExpenses) ||
        originalSnapshot!['placesByDay'] != jsonEncode(placesByDay) ||
        originalSnapshot!['dayColors'] !=
            jsonEncode(
              dayColors
                  .map((key, value) => MapEntry(key.toString(), value.value)),
            );
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
    final start = widget.plan.dateRange.start;
    final end = widget.plan.dateRange.end;
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
        // ตรวจสอบและสร้างรายการสำหรับวันนั้น ๆ
        placesByDay.putIfAbsent(selectedDay, () => []);
        final alreadyAdded =
            placesByDay[selectedDay]!.any((p) => p['place_id'] == place['id']);

        if (!alreadyAdded) {
          // บันทึก minimal record ลงใน state พร้อมกับชื่อสถานที่
          final minimalPlaceData = {
            'place_id': place['id'], // ใช้รหัสสถานที่จาก all_places
            'place_name': place['name'], // เพิ่มชื่อสถานที่ลงไปด้วย
            'expense': 0.0,
            'order_index':
                placesByDay[selectedDay]!.length, // อ้างอิงตำแหน่งในรายการ
          };

          placesByDay[selectedDay]!.add(minimalPlaceData);

          // ไม่ต้องเรียก API addPlace ในตอนนี้
          isSaved = false;
          debugPrint(
              '[DEBUG] เพิ่มสถานที่ (แบบ minimal) ลงใน state, isSaved = false');
        }
      });
    }
  }

  Future<void> _tryLeavePage() async {
    if (!isModified()) {
      Navigator.pop(context);
      return;
    }

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยังไม่ได้บันทึก'),
        content:
            const Text('หากย้อนกลับตอนนี้ ข้อมูลที่ยังไม่ได้เซฟจะหายไปทั้งหมด'),
        actions: [
          TextButton(
            child: const Text('ยกเลิก'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            child: const Text('ย้อนกลับเลย'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (shouldLeave == true) {
      Navigator.pop(context);
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
    final start = widget.plan.dateRange.start;
    final end = widget.plan.dateRange.end;
    final dayCount = end.difference(start).inDays + 1;

    return List.generate(dayCount, (index) {
      final date = start.add(Duration(days: index));
      final thaiWeekday = _thaiWeekday(date.weekday);

      final dayPlaces = placesByDay[index] ?? [];

      debugPrint('dayPlaces[$index]: $dayPlaces');

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
                  final place =
                      dayPlaces[i]; // place คือตัวแปร Map<String, dynamic>
                  return ListTile(
                    key: ValueKey('$i-${place['place_name'] ?? 'unknown'}'),
                    leading: _buildNumberedPin(i + 1, index),
                    title: Text(place['place_name'] ?? 'ไม่ระบุ'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          placesByDay[index]?.removeAt(i);
                          _popupController.hideAllPopups();
                          isSaved = false;
                          debugPrint(
                              '[DEBUG] ลบสถานที่ออกจาก state, isSaved = false');
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
          plan: widget.plan,
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
        isSaved = false;
        widget.plan.budget = budget;
        widget.plan.spending = spending;
        widget.plan.otherExpenses = otherExpenses;
      });
    }
  }

  void savePlan() async {
    final currentName = _planNameController.text.trim();

    if (currentName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณากรอกชื่อแผนก่อนบันทึก")),
      );
      return;
    }

    await fetchAllPlanNames(); // โหลดชื่อทั้งหมดอัปเดตล่าสุด

    if (_planId == 0 && existingPlanNames.contains(currentName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("มีแผนชื่อ '$currentName' อยู่แล้ว กรุณาตั้งชื่อใหม่")),
      );
      return;
    }

    planName = currentName;

    if (_planId == 0) {
      final createPayload = {
        'name': planName,
        'province': widget.plan.province,
        'start_date': widget.plan.dateRange.start.toIso8601String(),
        'end_date': widget.plan.dateRange.end.toIso8601String(),
        'budget': budget,
        'spending': spending,
      };

      try {
        final newId = await ApiService().createPlan(createPayload);
        setState(() {
          _planId = newId;
        });
        debugPrint('[DEBUG] สร้างแผนใหม่ใน DB แล้ว, ได้ id: $_planId');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("เกิดข้อผิดพลาดในการสร้างแผน: $e")),
        );
        return;
      }
    }

    final success = await ApiService().updatePlan(_planId, {
      'name': planName,
      'province': widget.plan.province,
      'start_date': widget.plan.dateRange.start.toIso8601String(),
      'end_date': widget.plan.dateRange.end.toIso8601String(),
      'budget': budget,
      'spending': spending,
      'dayColors': dayColors,
      'favoritePlaces': favoritePlaces,
      'placesByDay': placesByDay,
      'otherExpenses': otherExpenses
          .map((e) => {
                'desc': e['desc'],
                'amount': e['amount'],
                'icon_code': (e['icon'] as IconData?)?.codePoint ?? 0,
              })
          .toList(),
    });
    if (success) {
      setState(() {
        isSaved = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("แผน '$planName' ถูกบันทึกเรียบร้อยแล้ว!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("เกิดข้อผิดพลาดในการบันทึกแผน")),
      );
    }
  }

  final Map<String, Map<String, dynamic>> _markerKeyToPlace = {};
  List<Marker> _buildAllMarkers() {
    final markers = <Marker>[];
    _markerKeyToPlace.clear();

    placesByDay.forEach((dayIndex, places) {
      for (int i = 0; i < places.length; i++) {
        final place = places[i];
        debugPrint('[MARKER DEBUG] day $dayIndex, place: $place');

        if (place.containsKey('lat') && place.containsKey('lon')) {
          final keyStr = '$dayIndex-$i';
          _markerKeyToPlace[keyStr] = place;

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
    // กรณีรอโหลดพิกัดจาก API
    if (centerLatLng == null) {
      return WillPopScope(
        onWillPop: () async {
          await _tryLeavePage(); // แสดง dialog เตือน
          return false; // บล็อกการย้อนกลับ (ให้ _tryLeavePage จัดการเอง)
        },
        child: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // กรณีโหลดเสร็จแล้ว
    return WillPopScope(
      onWillPop: () async {
        debugPrint('[DEBUG] กำลังย้อนกลับ, isSaved = $isSaved');
        if (isSaved) return true;

        final shouldLeave = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('ยังไม่ได้บันทึก'),
            content: const Text(
                'หากย้อนกลับตอนนี้ ข้อมูลที่ยังไม่ได้เซฟจะหายทั้งหมด'),
            actions: [
              TextButton(
                child: const Text('ยกเลิก'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              ElevatedButton(
                child: const Text('ย้อนกลับเลย'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        );
        return shouldLeave ?? false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FBFD),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 0) {
              _tryLeavePage();
            } else if (index == 1) {
              Navigator.pushReplacementNamed(context, '/home');
            } else {}
          },
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
                                color: const Color(0xFFE0F7E9),
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
                                      color: Color(0xFF1B9D66),
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
                            final start = widget.plan.dateRange.start;
                            final end = widget.plan.dateRange.end;
                            final dayCount = end.difference(start).inDays + 1;

                            for (int i = 0; i < dayCount; i++) {
                              dayColors.putIfAbsent(
                                  i, () => Colors.orange); // default
                            }
                            final convertedPlacesByDay = placesByDay.map(
                              (key, value) =>
                                  MapEntry(int.parse(key.toString()), value),
                            );
                            debugPrint(
                                'ส่ง placesByDay ไปยัง Router: $placesByDay');

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewRoutePage(
                                  placesByDay: convertedPlacesByDay,
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
                                  center: centerLatLng!,
                                  province: widget.plan.province,
                                  initialFavorites: favoritePlaces,
                                ),
                              ),
                            ).then((result) {
                              if (result != null &&
                                  result is List<Map<String, dynamic>>) {
                                if (hasDataChanged(newFavoritePlaces: result)) {
                                  setState(() {
                                    favoritePlaces = result;
                                    isSaved = false;
                                    debugPrint(
                                        '[DEBUG] รายการที่สนใจเปลี่ยนแปลง, isSaved = false');
                                  });
                                }
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
                        if (value != planName) {
                          setState(() {
                            planName = value;
                            isSaved = false;
                            debugPrint(
                                '[DEBUG] ชื่อแผนเปลี่ยนแปลง, isSaved = false');
                          });
                        }
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
                          '${widget.plan.dateRange.start.day} ${_monthName(widget.plan.dateRange.start.month)} - '
                          '${widget.plan.dateRange.end.day} ${_monthName(widget.plan.dateRange.end.month)} ${widget.plan.dateRange.end.year + 543}',
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'บันทึกแผนเที่ยว',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
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
