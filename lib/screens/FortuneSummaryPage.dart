import 'package:flutter/material.dart';
import 'package:tripplan_1/widgets/main_layout.dart';
import 'package:tripplan_1/widgets/custom_app_bar.dart';
import 'PlaceDetailPage.dart';
import 'ViewRouteFortunePage.dart';
import '../services/api.dart';
import 'dart:math';

class FortuneSummaryPage extends StatefulWidget {
  final DateTimeRange dateRange;
  final String province;
  final Map<int, List<Map<String, dynamic>>> allPlacesByDay;
  final Map<int, String> tripTypesByDay;
  final String companion;

  const FortuneSummaryPage({
    super.key,
    required this.dateRange,
    required this.province,
    required this.allPlacesByDay,
    required this.tripTypesByDay,
    required this.companion,
  });

  @override
  _FortuneSummaryPageState createState() => _FortuneSummaryPageState();
}

class _FortuneSummaryPageState extends State<FortuneSummaryPage> {
  bool _isLoading = true;
  Map<int, List<Map<String, dynamic>>> recommendedHotels = {};
  Set<int> expandedHotels = {};

  static const List<Color> defaultDayColors = [
    Color(0xFFEF5350),
    Color(0xFFAB47BC),
    Color(0xFF5C6BC0),
    Color(0xFF29B6F6),
    Color(0xFF26A69A),
    Color(0xFF66BB6A),
    Color(0xFFFFCA28),
    Color(0xFFFFA726),
    Color(0xFF8D6E63),
    Color(0xFF78909C),
  ];

  Color getDayColor(int dayIndex) {
    return defaultDayColors[dayIndex % defaultDayColors.length];
  }

  @override
  void initState() {
    super.initState();
    print('🟢 initState called!');
    fetchAll().then((_) {
      print('✅ fetchAll done');
      setState(() => _isLoading = false);
    });
  }

  Future<void> fetchAll() async {
    for (int day in widget.allPlacesByDay.keys) {
      try {
        print('\n🟠 [START] Day $day');
        final places = widget.allPlacesByDay[day];
        if (places == null) {
          throw Exception('places is null at day $day');
        }
        print('📌 Day $day has ${places.length} places');
        for (var i = 0; i < places.length; i++) {
          final place = places[i];
          print('🔍 Place[$i]: $place');
          print('🔍 place_id: ${place['place_id']}');

          if (!place.containsKey('lat') || !place.containsKey('lon')) {
            print('🔧 No lat/lon → calling getPlaceById(${place['place_id']})');
            final result = await ApiService().getPlaceById(place['place_id']);
            print('📦 Result from API: $result');

            if (result['lat'] == null || result['lon'] == null) {
              throw Exception(
                  '❌ API returned null lat/lon for ${place['place_id']}');
            }

            place['lat'] = result['lat'];
            place['lon'] = result['lon'];
          }
        }

        if (places.length < 2) {
          print('⚠️ Not enough places to find hotel on day $day');
          continue;
        }

        final first = places.first;
        final last = places.last;
        print(
            '📍 First: ${first['name']}, lat=${first['lat']}, lon=${first['lon']}');
        print(
            '📍 Last: ${last['name']}, lat=${last['lat']}, lon=${last['lon']}');

        final nearFirst = await getNearbyHotels(first['lat'], first['lon']);
        final nearLast = await getNearbyHotels(last['lat'], last['lon']);
        print(
            '🏨 nearFirst = ${nearFirst.length}, nearLast = ${nearLast.length}');

        final mergedHotels = [...nearFirst, ...nearLast];
        recommendedHotels[day] = mergedHotels;
        print('✅ recommendedHotels[$day] = ${mergedHotels.length} hotels');
      } catch (e, stack) {
        final errorMessage =
            'เกิดข้อผิดพลาดในวันที่ ${day + 1}\n${e.toString()}';
        print('❌ ERROR: $errorMessage');
        print('🧵 STACK TRACE:\n$stack');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                errorMessage,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
              duration: const Duration(seconds: 6),
            ),
          );
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> getNearbyHotels(
      double lat, double lon) async {
    final allHotels = await ApiService().getPlaces(
      province: widget.province,
      type: 'accommodation',
      companion: widget.companion,
      tripType: '',
      onlyHotel: true,
    );
    allHotels.sort((a, b) {
      final d1 = _distance(lat, lon, a['lat'], a['lon']);
      final d2 = _distance(lat, lon, b['lat'], b['lon']);
      return d1.compareTo(d2);
    });
    return allHotels.take(1).toList();
  }

  double _distance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.0174533;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  @override
  Widget build(BuildContext context) {
    final tripDates = getTripDates();
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
              final places = widget.allPlacesByDay[index] ?? [];
              final tripType = widget.tripTypesByDay[index] ?? 'ไม่ระบุประเภท';

              return SingleChildScrollView(
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
                      Text("🎯 ประเภทการเที่ยว: ${_getTripTypeThai(tripType)}"),
                      Text(
                          "👥 เหมาะกับ: ${_getCompanionThai(widget.companion)}"),
                      const SizedBox(height: 24),
                      if (recommendedHotels.containsKey(index))
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (expandedHotels.contains(index)) {
                                    expandedHotels.remove(index);
                                  } else {
                                    expandedHotels.add(index);
                                  }
                                });
                              },
                              child: const Row(
                                children: [
                                  Icon(Icons.hotel, color: Colors.deepOrange),
                                  SizedBox(width: 8),
                                  Text("ที่พักแนะนำ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (expandedHotels.contains(index))
                              ...(recommendedHotels[index] ?? [])
                                  .map<Widget>((hotel) => ListTile(
                                        leading: const Icon(Icons.hotel,
                                            color: Colors.indigo),
                                        title: Text(hotel['name'] ?? '-'),
                                        subtitle: Text(hotel['address'] ?? ''),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  PlaceDetailPage(place: hotel),
                                            ),
                                          );
                                        },
                                      ))
                                  .toList(),
                          ],
                        ),
                      const SizedBox(height: 24),
                      const Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.purple),
                          SizedBox(width: 8),
                          Text("สถานที่แนะนำ",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...places.asMap().entries.map((e) {
                        final place = e.value;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: getDayColor(index),
                            child: Text('${e.key + 1}',
                                style: const TextStyle(color: Colors.white)),
                          ),
                          title: Text(place['name'] ?? 'ไม่พบชื่อ'),
                          subtitle: GestureDetector(
                            child: const Text(
                              "รายละเอียด",
                              style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PlaceDetailPage(place: place),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.map),
              label: const Text("ดูเส้นทางทั้งหมด"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FortuneRouteViewPage(
                      allPlacesByDay: widget.allPlacesByDay,
                      selectedDay: 0,
                      dayColors: defaultDayColors,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                elevation: 4,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<DateTime> getTripDates() {
    final days =
        widget.dateRange.end.difference(widget.dateRange.start).inDays + 1;
    return List.generate(
        days, (i) => widget.dateRange.start.add(Duration(days: i)));
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

  String _getTripTypeThai(String type) {
    const map = {
      'adventure': 'ผจญภัย',
      'cafe': 'คาเฟ่',
      'history': 'ประวัติศาสตร์',
      'nature': 'ธรรมชาติ',
      'nightlife': 'กลางคืน',
      'family': 'ครอบครัว',
      'romantic': 'โรแมนติก',
      'chill': 'ชิลล์',
      'food': 'อาหาร',
    };
    return map[type] ?? type;
  }

  String _getCompanionThai(String companion) {
    const map = {
      'family': 'ครอบครัว',
      'couple': 'คู่รัก',
      'friends': 'กลุ่มเพื่อน',
      'solo': 'คนเดียว',
      'company': 'หมู่คณะ',
    };
    return map[companion] ?? companion;
  }

  String getThaiDay(DateTime date) {
    const days = ['อา.', 'จ.', 'อ.', 'พ.', 'พฤ.', 'ศ.', 'ส.'];
    return days[date.weekday % 7];
  }
}
