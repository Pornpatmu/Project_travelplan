import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';
import '../widgets/custom_app_bar.dart';
import '../services/api.dart';
import 'PlanDetailPage.dart';
import '../models/travel_plan.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final api = ApiService();
  List<Map<String, dynamic>> plans = [];
  Future<void> deletePlan(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบแผน'),
        content: const Text('คุณต้องการลบแผนนี้ใช่หรือไม่?'),
        actions: [
          TextButton(
            child: const Text('ยกเลิก'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('ลบ'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await api.deletePlan(id);
        await loadPlans(); // โหลดใหม่หลังลบ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลบแผนเที่ยวเรียบร้อย')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadPlans();
  }

  Future<void> loadPlans() async {
    final result = await api.getAllPlans();
    setState(() => plans = result);
  }

  void openPlan(Map<String, dynamic> planData) async {
    final planDetails = await api.getPlanDetails(planData['id']);

    final plan = TravelPlan(
      id: planDetails['id'],
      name: planDetails['name'],
      province: planDetails['province'],
      dateRange: DateTimeRange(
        start: DateTime.parse(planDetails['start_date']),
        end: DateTime.parse(planDetails['end_date']),
      ),
      budget: (planDetails['budget'] as num).toDouble(),
      spending: (planDetails['spending'] as num).toDouble(),
      favoritePlaces:
          List<Map<String, dynamic>>.from(planDetails['favoritePlaces']),
      otherExpenses:
          List<Map<String, dynamic>>.from(planDetails['otherExpenses']),
      placesByDay: Map<int, List<Map<String, dynamic>>>.from(
        (planDetails['placesByDay'] as Map).map((k, v) =>
            MapEntry(int.parse(k), List<Map<String, dynamic>>.from(v))),
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlanDetailPage(plan: plan)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      appBar: const CustomAppBar(),
      currentIndex: 0,
      onTap: (index) => Navigator.pushReplacementNamed(context, '/home'),
      body: plans.isEmpty
          ? const Center(child: Text('ยังไม่มีประวัติการวางแผนเที่ยว'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: const Color(0xFFC8FADF),
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "จังหวัด: ${plan['province']}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.green),
                              onPressed: () => openPlan(plan),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.grey[500]),
                              onPressed: () => deletePlan(plan['id']),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
