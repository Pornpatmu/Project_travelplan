import 'package:flutter/material.dart';
import '../models/travel_plan.dart';

class EditBudgetPage extends StatefulWidget {
  final TravelPlan plan;
  final Function(double, double, List<Map<String, dynamic>>) onSave;

  const EditBudgetPage({super.key, required this.plan, required this.onSave});

  @override
  State<EditBudgetPage> createState() => _EditBudgetPageState();
}

class _EditBudgetPageState extends State<EditBudgetPage> {
  late double budget;
  late TextEditingController budgetController;
  List<Map<String, dynamic>> otherExpenses = [];

  final List<Map<String, dynamic>> expenseTypes = [
    {'label': 'ที่พัก', 'icon': Icons.hotel},
    {'label': 'การเดินทาง', 'icon': Icons.directions_car},
    {'label': 'ร้านอาหาร', 'icon': Icons.restaurant},
    {'label': 'ของฝาก', 'icon': Icons.card_giftcard},
    {'label': 'อื่น ๆ', 'icon': Icons.miscellaneous_services},
  ];

  @override
  void initState() {
    super.initState();
    budget = widget.plan.budget;
    budgetController = TextEditingController(text: budget.toStringAsFixed(2));
    otherExpenses = List<Map<String, dynamic>>.from(widget.plan.otherExpenses);
  }

  double get totalSpending {
    return otherExpenses.fold(0.0, (sum, e) => sum + (e['amount'] ?? 0.0));
  }

  void _showAddExpenseDialog(IconData icon) {
    final amountController = TextEditingController();
    final selectedLabel =
        expenseTypes.firstWhere((e) => e['icon'] == icon)['label'];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("เพิ่มรายการใช้จ่าย"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("หมวด: $selectedLabel"),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "จำนวนเงิน (บาท)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก"),
          ),
          ElevatedButton(
            onPressed: () {
              if (amountController.text.isNotEmpty) {
                setState(() {
                  otherExpenses.add({
                    'desc': selectedLabel,
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

  Widget _inputDisplayBox(String label, double value,
      {bool overBudget = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(
            '฿${value.toStringAsFixed(2)}',
            style: TextStyle(
              color: overBudget ? Colors.red : const Color(0xFF1B9D66),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(int index, Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(item['icon'], size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text('${item['desc']}  ${item['amount']} บาท'),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                otherExpenses.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final overBudget = totalSpending > budget;

    return Scaffold(
      appBar: AppBar(
        title: const Text("แก้ไขงบประมาณ"),
        backgroundColor: const Color(0xFF1B9D66),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: budgetController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "งบของคุณ (บาท)",
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  budget = double.tryParse(val) ?? 0.0;
                });
              },
            ),
            const SizedBox(height: 12),
            _inputDisplayBox("ใช้จ่ายทั้งหมด", totalSpending,
                overBudget: overBudget),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            const Text("เพิ่มรายการใช้จ่าย", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: expenseTypes.map((type) {
                return IconButton(
                  icon: Icon(type['icon'], size: 28),
                  onPressed: () => _showAddExpenseDialog(type['icon']),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("รายการทั้งหมด",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: otherExpenses
                    .asMap()
                    .entries
                    .map((entry) => _buildExpenseItem(entry.key, entry.value))
                    .toList(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final result = {
                  'budget': budget,
                  'spending': totalSpending,
                  'otherExpenses': otherExpenses,
                };
                widget.onSave(budget, totalSpending, otherExpenses);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
              ),
              child: const Text("บันทึก", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
