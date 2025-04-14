import 'package:flutter/material.dart';

class PlaceDetailPage extends StatelessWidget {
  final Map<String, dynamic> place;

  PlaceDetailPage({required this.place});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place['name']),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                place['image'],
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            Text(
              place['name'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("📍 ที่อยู่: ${place['address']}"),
            SizedBox(height: 10),
            Text("🕒 เวลาเปิด-ปิด: ${place['hours']}"),
            SizedBox(height: 10),
            Text("💰 ค่าเข้า: ${place['entryFee'] ?? 'ฟรี'}"),
            SizedBox(height: 10),
            Text("📞 เบอร์โทร: ${place['phone'] ?? '-'}"),
          ],
        ),
      ),
    );
  }
}