import 'package:flutter/material.dart';

class TravelPlan {
  int id;
  final String name;
  final String province;
  final DateTimeRange dateRange;
  double budget;
  double spending;
  List<Map<String, dynamic>> favoritePlaces;
  Map<int, List<Map<String, dynamic>>> placesByDay;
  List<Map<String, dynamic>> otherExpenses;
  final Map<int, int>? dayColors;

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
    this.dayColors,
  });
  factory TravelPlan.fromJson(Map<String, dynamic> json) {
    return TravelPlan(
      id: json['id'],
      dayColors: (json['dayColors'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(int.parse(k), v as int),
      ),
      name: json['name'],
      province: json['province'],
      dateRange: DateTimeRange(
        start: DateTime.parse(json['start_date']),
        end: DateTime.parse(json['end_date']).add(
          const Duration(hours: 23, minutes: 59, seconds: 59),
        ),
      ),
      budget: (json['budget'] as num).toDouble(),
      spending: (json['spending'] as num).toDouble(),
      favoritePlaces:
          List<Map<String, dynamic>>.from(json['favoritePlaces'] ?? []),
      placesByDay: Map<int, List<Map<String, dynamic>>>.from(
        (json['placesByDay'] as Map).map(
          (key, value) => MapEntry(
            int.parse(key.toString()),
            List<Map<String, dynamic>>.from(value),
          ),
        ),
      ),
      otherExpenses:
          List<Map<String, dynamic>>.from(json['otherExpenses'] ?? []),
    );
  }
}
