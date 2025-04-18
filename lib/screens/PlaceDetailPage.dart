import 'package:flutter/material.dart';

class PlaceDetailPage extends StatelessWidget {
  final Map<String, dynamic> place;

  const PlaceDetailPage({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    print('Image path: ${place['image']}');
    return Scaffold(
      appBar: AppBar(
        title: Text(place['name'] ?? 'ไม่ระบุชื่อ'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: place['image'] != null
                  ? Image.asset(
                      place['image'],
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildNoImage();
                      },
                    )
                  : _buildNoImage(),
            ),
            const SizedBox(height: 20),
            Text(
              place['name'] ?? 'ไม่ระบุชื่อ',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("📍 ที่อยู่: ${place['address'] ?? 'ไม่ระบุ'}"),
            const SizedBox(height: 10),
            Text("🕒 เวลาเปิด-ปิด: ${place['hours'] ?? 'ไม่ระบุ'}"),
            const SizedBox(height: 10),
            Text("💰 ค่าเข้า: ${place['entryFee'] ?? 'ฟรี'}"),
            const SizedBox(height: 10),
            Text("📞 เบอร์โทร: ${place['phone'] ?? '-'}"),
          ],
        ),
      ),
    );
  }

  Widget _buildNoImage() {
    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.grey[200],
      child: const Center(
        child: Text('ไม่มีรูปภาพ'),
      ),
    );
  }
}
