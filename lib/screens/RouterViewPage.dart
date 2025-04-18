import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api.dart';

class ViewRoutePage extends StatefulWidget {
  final Map<int, List<Map<String, dynamic>>> placesByDay;
  final Map<int, Color> dayColors;

  const ViewRoutePage({
    super.key,
    required this.placesByDay,
    required this.dayColors,
  });

  @override
  State<ViewRoutePage> createState() => _ViewRoutePageState();
}

class _ViewRoutePageState extends State<ViewRoutePage> {
  @override
  void initState() {
    super.initState();
    fetchPlaceDetailsIfNeeded();
  }

  int selectedDay = 0;

  List<LatLng> _getRoutePoints() {
    final places = widget.placesByDay[selectedDay] ?? [];
    return places
        .where((place) => place.containsKey('lat') && place.containsKey('lon'))
        .map((place) => LatLng(place['lat'], place['lon']))
        .toList();
  }

  Future<void> fetchPlaceDetailsIfNeeded() async {
    for (int dayIndex in widget.placesByDay.keys) {
      final dayList = widget.placesByDay[dayIndex]!;
      for (var place in dayList) {
        if (!place.containsKey('lat') || !place.containsKey('lon')) {
          final fetched = await ApiService().getPlaceById(place['place_id']);
          place['lat'] = fetched['lat'];
          place['lon'] = fetched['lon'];
        }
      }
    }

    setState(() {});
  }

  List<Marker> _getMarkers() {
    final places = widget.placesByDay[selectedDay] ?? [];
    final color = widget.dayColors[selectedDay] ?? Colors.purple;

    return List.generate(places.length, (i) {
      final place = places[i];
      if (place.containsKey('lat') && place.containsKey('lon')) {
        return Marker(
          point: LatLng(place['lat'], place['lon']),
          width: 50,
          height: 50,
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: color,
                radius: 18,
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      }
      return const Marker(point: LatLng(0, 0), child: SizedBox());
    });
  }

  @override
  Widget build(BuildContext context) {
    final todayPlaces = widget.placesByDay[selectedDay] ?? [];
    debugPrint('selectedDay: $selectedDay');
    debugPrint('places for today: $todayPlaces');

    final markers = _getMarkers();
    final routePoints = _getRoutePoints();

    // คำนวณจุดศูนย์กลางเพื่อโฟกัสแผนที่
    final center = routePoints.isNotEmpty
        ? routePoints[0]
        : const LatLng(16.4322, 102.8236); // default: ขอนแก่น

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('ดูเส้นทาง'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: FlutterMap(
              options: MapOptions(center: center, zoom: 14),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.tripplan',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 4,
                      color: Colors.blueAccent,
                    ),
                  ],
                ),
                MarkerLayer(markers: markers),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: _buildDaySelector(),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    final dayIndexes = widget.placesByDay.keys.toList()..sort();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: dayIndexes.map((index) {
          final color = widget.dayColors[index] ?? Colors.grey;
          final isSelected = index == selectedDay;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDay = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
                border: Border.all(
                  color: isSelected ? color : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'วันที่ ${index + 1}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
