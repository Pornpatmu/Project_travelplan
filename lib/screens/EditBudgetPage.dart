import 'package:flutter/material.dart';
import '../models/travel_plan.dart';

class EditBudgetPage extends StatefulWidget {
  final TravelPlan plan;
  final Function(double, double, List<Map<String, dynamic>>) onSave;

  const EditBudgetPage({
    super.key,
    required this.plan,
    required this.onSave,
  });

  @override
  State<EditBudgetPage> createState() => _EditBudgetPageState();
}

class _EditBudgetPageState extends State<EditBudgetPage> {
  TextEditingController budgetController = TextEditingController();
  late List<Map<String, dynamic>> otherExpenses;

  double get calculatedSpending {
    double fromPlaces = 0.0;
    widget.plan.placesByDay.forEach((day, places) {
      for (var place in places) {
        fromPlaces += place['expense'] ?? 0.0;
      }
    });

    double fromOthers = otherExpenses.fold(
      0.0,
      (sum, item) => sum + (item['amount'] ?? 0.0),
    );
    debugPrint('[DEBUG] Spending from places: $fromPlaces');
    debugPrint('[DEBUG] Spending from other expenses: $fromOthers');

    return fromPlaces + fromOthers;
  }

  @override
  void initState() {
    super.initState();
    debugPrint('[DEBUG] Initial budget: ${widget.plan.budget}');

    budgetController.text = widget.plan.budget.toString();
    otherExpenses = widget.plan.otherExpenses.map((expense) {
      final icon = expense['icon'];
      final iconCode = expense['icon_code'];
      return {
        'desc': expense['desc'],
        'amount': expense['amount'],
        'icon': icon ??
            (iconCode != null
                ? IconData(iconCode, fontFamily: 'MaterialIcons')
                : Icons.receipt),
      };
    }).toList();

    debugPrint('[DEBUG] Initial otherExpenses with icons: $otherExpenses');
  }

  @override
  void dispose() {
    budgetController.dispose();
    super.dispose();
  }

  void handleSave() {
    final newBudget =
        double.tryParse(budgetController.text) ?? widget.plan.budget;
    final newSpending = calculatedSpending;

    debugPrint('[DEBUG] Saving new budget: $newBudget');
    debugPrint('[DEBUG] Saving new spending: $newSpending');
    debugPrint('[DEBUG] Saving updated otherExpenses: $otherExpenses');

    widget.onSave(newBudget, newSpending, otherExpenses);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FBFD),
        title:
            const Text('แก้ไขงบประมาณ', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF9FBFD),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _inputBox("งบของคุณ", budgetController),
                  _inputDisplayBox("ใช้จ่าย", calculatedSpending),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _iconAddButton(Icons.hotel),
                _iconAddButton(Icons.directions_car),
                _iconAddButton(Icons.restaurant),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => _showAddExpenseDialog(Icons.receipt),
                    child: const Row(
                      children: [
                        Icon(Icons.add_circle,
                            size: 20, color: Color(0xFF1B9D66)),
                        SizedBox(width: 8),
                        Text("เพิ่มรายการใช้จ่าย",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...otherExpenses.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(item['icon'],
                                size: 20, color: Colors.grey[700]),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(
                                    '${item['desc']} ${item['amount']} บาท')),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B9D66),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text(
                  'บันทึก',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _inputDisplayBox(String title, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          '฿${value.toStringAsFixed(2)}',
          style: const TextStyle(color: Color(0xFF1B9D66), fontSize: 16),
        ),
      ],
    );
  }

  Widget _inputBox(String title, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        SizedBox(
          width: 100,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              color: Color(0xFF1B9D66),
              fontSize: 16,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              border: OutlineInputBorder(),
              prefix: Text(
                '฿',
                style: TextStyle(
                  color: Color(0xFF1B9D66), // สีเขียวสำหรับ "฿"
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _iconAddButton(IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.black),
        const SizedBox(height: 4),
        IconButton(
          icon:
              const Icon(Icons.add_circle, size: 20, color: Color(0xFF1B9D66)),
          onPressed: () {
            _showAddExpenseDialog(icon);
          },
        ),
      ],
    );
  }

  void _showAddExpenseDialog(IconData icon) {
    final descController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("เพิ่มรายการใช้จ่าย"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: "รายละเอียด"),
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "จำนวนเงิน (บาท)"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก"),
          ),
          ElevatedButton(
            onPressed: () {
              if (descController.text.isNotEmpty &&
                  amountController.text.isNotEmpty) {
                setState(() {
                  otherExpenses.add({
                    'desc': descController.text,
                    'amount': double.tryParse(amountController.text) ?? 0.0,
                    'icon': icon,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text("เพิ่ม"),
          ),
        ],
      ),
    );
  }
}
