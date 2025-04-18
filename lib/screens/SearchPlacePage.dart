import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchPlacePage extends StatefulWidget {
  final LatLng center;
  final String province;
  final List<Map<String, dynamic>>? initialFavorites;

  const SearchPlacePage({
    super.key,
    required this.center,
    required this.province,
    this.initialFavorites,
  });

  @override
  State<SearchPlacePage> createState() => _SearchPlacePageState();
}

class _SearchPlacePageState extends State<SearchPlacePage> {
  String? selectedCategory;
  List<Map<String, dynamic>> allPlaces = [];
  List<Map<String, dynamic>> favoritePlaces = [];

  @override
  void initState() {
    super.initState();
    favoritePlaces =
        List<Map<String, dynamic>>.from(widget.initialFavorites ?? []);
    selectedCategory = 'food';
    fetchPlaces(widget.province, selectedCategory!);
  }

  Future<void> fetchPlaces(String province, [String? type]) async {
    final trimmedProvince = province.trim();
    final trimmedType = type?.trim();

    // ใช้ endpoint ปกติ ไม่สุ่ม
    const baseUrl = 'http://10.0.2.2:3000/places';
    final url = trimmedType != null && trimmedType.isNotEmpty
        ? Uri.parse('$baseUrl?province=$trimmedProvince&type=$trimmedType')
        : Uri.parse('$baseUrl?province=$trimmedProvince');

    final res = await http.get(url);

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      print('📍 ${data.length} places loaded (${type ?? 'all'})');
      setState(() {
        allPlaces = List<Map<String, dynamic>>.from(data);
      });
    } else {
      print('⚠️ Failed to load places: ${res.statusCode}');
      setState(() {
        allPlaces = [];
      });
    }
  }

  List<Marker> getFilteredMarkers() {
    final markers = <Marker>[];

    for (var place in allPlaces) {
      if (place['lat'] == null || place['lon'] == null) continue;

      markers.add(
        Marker(
          point: LatLng(place['lat'], place['lon']),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _showPlaceDetails(place),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: place['type'] == 'food'
                    ? Colors.green
                    : place['type'] == 'hotel'
                        ? Colors.pink
                        : Colors.orange,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Center(
                child: Icon(
                  place['type'] == 'food'
                      ? Icons.restaurant
                      : place['type'] == 'hotel'
                          ? Icons.hotel
                          : Icons.place,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  void _showPlaceDetails(Map<String, dynamic> place) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isFavorite =
                favoritePlaces.any((p) => p['name'] == place['name']);

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (place['image'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        place['image'],
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 120,
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: const Center(child: Text('ไม่พบรูปภาพ')),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          place['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.pink : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            setModalState(() {});
                            if (isFavorite) {
                              favoritePlaces.removeWhere(
                                  (p) => p['name'] == place['name']);
                            } else {
                              favoritePlaces.add(place);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 18),
                      const SizedBox(width: 8),
                      Text("เวลาเปิด-ปิด: ${place['hours'] ?? 'ไม่ระบุ'}"),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 18),
                      const SizedBox(width: 8),
                      Text(place['phone'] ?? 'ไม่ระบุ'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context, favoritePlaces);
                      },
                      child: const Text("เสร็จสิ้น"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(center: widget.center, zoom: 14),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.tripplan',
              ),
              MarkerLayer(markers: getFilteredMarkers()),
            ],
          ),
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context, favoritePlaces),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(Icons.close, color: Colors.green),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _categoryButton('ร้านอาหาร', 'food'),
                const SizedBox(width: 8),
                _categoryButton('โรงแรม', 'hotel'),
                const SizedBox(width: 8),
                _categoryButton('ที่เที่ยว', 'tourist'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _categoryButton(String label, String value) {
    final bool isSelected = selectedCategory == value;

    return ElevatedButton(
      onPressed: () {
        final newCategory = isSelected ? null : value;
        setState(() {
          selectedCategory = newCategory;
          allPlaces.clear();
        });
        fetchPlaces(widget.province, newCategory);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF1B9D66) : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        side: const BorderSide(color: Color(0xFF1B9D66)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(label),
    );
  }
}
