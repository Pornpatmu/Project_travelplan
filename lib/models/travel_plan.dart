import 'package:flutter/material.dart';

class TravelPlan {
  int id; // ลบ final ออก
  final String name;
  final String province;
  final DateTimeRange dateRange;
  double budget;
  double spending;
  List<Map<String, dynamic>> favoritePlaces;
  Map<int, List<Map<String, dynamic>>> placesByDay;
  List<Map<String, dynamic>> otherExpenses;

  TravelPlan({
    required this.id,
    required this.name,
    required this.province,
    required this.dateRange,
    required this.budget,
    required this.spending,
    required this.favoritePlaces,
    required this.placesByDay,
    required this.otherExpenses,
  });
}
