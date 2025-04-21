import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';
import '../widgets/custom_app_bar.dart';
import '../services/api.dart';
import 'PlanDetailPage.dart';
import '../models/travel_plan.dart';
import '../widgets/confirm_dialog.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final api = ApiService();
  List<Map<String, dynamic>> plans = [];

  Future<void> fetchPlans() async {
    final allPlans = await api.getAllPlans();
    setState(() {
      plans = allPlans;
    });
  }

  Future<void> deletePlan(int id) async {
    final confirmDelete = await showConfirmDialog(
      context: context,
      title: 'ยืนยันการลบ',
      content: 'คุณต้องการลบแผนนี้จริงหรือไม่?',
      confirmText: 'ลบเลย',
    );

    if (confirmDelete == true) {
      final success = await api.deletePlan(id);
      if (success) {
        setState(() {
          plans.removeWhere((plan) => plan['id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ลบแผนเที่ยวเรียบร้อยแล้ว")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("เกิดข้อผิดพลาดในการลบแผนเที่ยว")),
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
      MaterialPageRoute(
        builder: (_) => PlanDetailPage(plan: plan),
      ),
    ).then((result) {
      if (result == true) {
        fetchPlans(); // โหลดใหม่เมื่อมีการบันทึก
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      appBar: const CustomAppBar(),
      backgroundColor: const Color(0xFFF6F8F9),
      currentIndex: 0,
      onTap: (index) => Navigator.pushReplacementNamed(context, '/home'),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(30),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'ประวัติการสร้างแผนเที่ยว',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: plans.isEmpty
                        ? const Center(
                            child: Text('ยังไม่มีประวัติการวางแผนเที่ยว'))
                        : ListView.builder(
                            itemCount: plans.length,
                            itemBuilder: (context, index) {
                              final plan = plans[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC8FADF),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          plan['name'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'จังหวัด${plan['province']}',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              color: Colors.green),
                                          onPressed: () => openPlan(plan),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.grey),
                                          onPressed: () =>
                                              deletePlan(plan['id']),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
