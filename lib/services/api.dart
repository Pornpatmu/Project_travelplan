import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import '../models/travel_plan.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000';

  // ดึงรายชื่อจังหวัดทั้งหมด
  Future<List<String>> getProvinces() async {
    final res = await http.get(Uri.parse('$baseUrl/provinces'));
    if (res.statusCode == 200) {
      return List<String>.from(json.decode(res.body));
    } else {
      throw Exception('Failed to load provinces');
    }
  }

  // ดึงข้อมูลแผนเที่ยวทั้งหมด
  Future<List<Map<String, dynamic>>> getAllPlans() async {
    final res = await http.get(Uri.parse('$baseUrl/plans'));
    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(res.body));
    } else {
      throw Exception('Failed to load plans');
    }
  }

  // สร้างแผนเที่ยวใหม่
  Future<int> createPlan(Map<String, dynamic> plan) async {
    final res = await http.post(
      Uri.parse('$baseUrl/plans'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(plan),
    );

    if (res.statusCode == 201 || res.statusCode == 200) {
      return json.decode(res.body)['id'];
    } else {
      // อ่าน error message จาก response
      final errorData = json.decode(res.body);
      throw Exception(errorData['error'] ?? 'Failed to create plan');
    }
  }

  // เพิ่มสถานที่ในแผนเที่ยว
  Future<void> addPlace(Map<String, dynamic> place) async {
    final res = await http.post(
      Uri.parse('$baseUrl/places'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(place),
    );

    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Failed to add place: ${res.body}');
    }
  }

  // เพิ่มสถานที่ในรายการที่สนใจ
  Future<void> addFavorite(Map<String, dynamic> place) async {
    final res = await http.post(
      Uri.parse('$baseUrl/favorites'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(place),
    );

    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Failed to add favorite: ${res.body}');
    }
  }

  // เพิ่มค่าใช้จ่ายอื่นๆ
  Future<void> addExpense(Map<String, dynamic> expense) async {
    final res = await http.post(
      Uri.parse('$baseUrl/expenses'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(expense),
    );

    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Failed to add expense: ${res.body}');
    }
  }

  Future<Map<String, dynamic>> getPlanDetails(int planId) async {
    final url = Uri.parse('http://10.0.2.2:3000/plans/$planId');
    debugPrint('เรียกดูแผน id: $planId ที่ $url');

    final response = await http.get(url);

    debugPrint('สถานะ: ${response.statusCode}');
    debugPrint('ข้อมูลที่ได้: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('ไม่สามารถโหลดข้อมูลแผนเที่ยวได้');
    }
  }

  // ลบสถานที่ออกจากแผน
  Future<void> deletePlace(int placeId) async {
    final res = await http.delete(Uri.parse('$baseUrl/places/$placeId'));
    if (res.statusCode != 200) {
      throw Exception('Failed to delete place');
    }
  }

// อัปเดตงบประมาณและใช้จ่ายในแผนโดยใช้ TravelPlan class
  Future<void> updatePlanBudget(
    TravelPlan plan,
    double spending,
    List<Map<String, dynamic>> otherExpenses,
  ) async {
    final budget = plan.budget;
    final encodedOtherExpenses = otherExpenses.map((expense) {
      return {
        'desc': expense['desc'],
        'amount': expense['amount'],
        'icon_code': (expense['icon'] as IconData).codePoint,
      };
    }).toList();

    debugPrint('[DEBUG] Saving updated otherExpenses: $encodedOtherExpenses');

    final res = await http.put(
      Uri.parse('$baseUrl/plans/${plan.id}/budget'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'budget': budget,
        'spending': spending,
        'otherExpenses': encodedOtherExpenses,
      }),
    );

    if (res.statusCode != 200) {
      debugPrint('[ERROR] Failed to update budget: ${res.body}');
      throw Exception('Failed to update budget');
    }
  }

  // อัปเดตแผนเที่ยวทั้งชุด (ชื่อแผน + ข้อมูลทั้งหมด)
  Future<bool> updatePlan(int planId, Map<String, dynamic> data) async {
    try {
      final encodedData = {
        ...data,

        // ✅ แปลง key ของ dayColors เป็น String
        'dayColors': (data['dayColors'] as Map).map(
          (key, value) => MapEntry(key.toString(), (value as Color).value),
        ),

        // ✅ แปลง placesByDay
        'placesByDay':
            (data['placesByDay'] as Map).map((key, value) => MapEntry(
                  key.toString(),
                  (value as List)
                      .map((p) => {
                            'place_id': p['place_id'],
                            'expense': p['expense'],
                            'order_index': p['order_index'],
                            'category': p['category'],
                          })
                      .toList(),
                )),

        // ✅ แปลง favoritePlaces
        'favoritePlaces': (data['favoritePlaces'] as List)
            .map((f) => {
                  'name': f['name'],
                  'lat': f['lat'],
                  'lon': f['lon'],
                  'category': f['category'],
                })
            .toList(),

        // ✅ แปลง otherExpenses (เอาเฉพาะ icon_code)
        'otherExpenses': (data['otherExpenses'] as List)
            .map((e) => {
                  'desc': e['desc'],
                  'amount': e['amount'],
                  'icon_code': (e['icon'] as IconData?)?.codePoint ?? 0,
                })
            .toList(),
      };

      final res = await http.put(
        Uri.parse('$baseUrl/plans/$planId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(encodedData),
      );

      if (res.statusCode == 200) return true;
      debugPrint('[ERROR] Failed to update plan: ${res.body}');
      return false;
    } catch (e) {
      debugPrint('[ERROR] updatePlan failed: $e');
      return false;
    }
  }

  //ข้อมูลจังหวัด + พิกัด
  Future<LatLng> getProvinceLatLng(String name) async {
    final response = await http
        .get(Uri.parse('http://10.0.2.2:3000/province/location?name=$name'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return LatLng(data['lat'], data['lon']);
    } else {
      throw Exception('โหลดพิกัดจังหวัดไม่สำเร็จ');
    }
  }

  Future<Map<String, dynamic>> getPlaceById(int placeId) async {
    final res = await http.get(Uri.parse('$baseUrl/places/$placeId'));
    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else {
      throw Exception('ไม่พบสถานที่ที่ต้องการ');
    }
  }

  Future<void> deletePlan(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/plans/$id'));
    if (res.statusCode != 200) {
      throw Exception('ลบแผนไม่สำเร็จ');
    }
  }
}
