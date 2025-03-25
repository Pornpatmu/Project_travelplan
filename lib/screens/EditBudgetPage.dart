import 'package:flutter/material.dart';

class EditBudgetPage extends StatefulWidget {
  final double initialBudget;
  final Map<int, List<Map<String, dynamic>>> placesByDay;
  final Function(double, double, List<Map<String, dynamic>>) onSave;
  final List<Map<String, dynamic>>? initialOtherExpenses;

  const EditBudgetPage({
    super.key,
    required this.initialBudget,
    required this.placesByDay,
    required this.initialOtherExpenses,
    required this.onSave,
  });

  @override
  State<EditBudgetPage> createState() => _EditBudgetPageState();
}

class _EditBudgetPageState extends State<EditBudgetPage> {
  TextEditingController budgetController = TextEditingController();
  double get calculatedSpending {
    double fromPlaces = 0.0;
    widget.placesByDay.forEach((day, places) {
      for (var place in places) {
        fromPlaces += place['expense'] ?? 0.0;
      }
    });

    double fromOthers = otherExpenses.fold(
      0.0,
      (sum, item) => sum + (item['amount'] ?? 0.0),
    );

    return fromPlaces + fromOthers;
  }

  List<Map<String, dynamic>> otherExpenses = [];
  @override
  void initState() {
    super.initState();
    budgetController.text = widget.initialBudget.toString();
    otherExpenses =
        List<Map<String, dynamic>>.from(widget.initialOtherExpenses ?? []);
  }

  @override
  void dispose() {
    budgetController.dispose();
    super.dispose();
  }

  void handleSave() {
    final newBudget = double.tryParse(budgetController.text) ?? 0.0;
    final newSpending = calculatedSpending;

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
            // 🔸 งบและใช้จ่าย (พร้อมกรอก)
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

            // 🔸 ปุ่มเพิ่มไอคอนประเภท
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _iconAddButton(Icons.hotel),
                _iconAddButton(Icons.directions_car),
                _iconAddButton(Icons.restaurant),
              ],
            ),
            const SizedBox(height: 16),

            // 🔸 รายการค่าใช้จ่ายอื่น ๆ
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
                    onTap: () =>
                        _showAddExpenseDialog(Icons.receipt), // หรือ icon อื่น
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

            // 🔸 ปุ่มบันทึก
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
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: Color(0xFF1B9D66),
            ),
            decoration: const InputDecoration(
              isDense: true,
              suffixText: "บาท",
              suffixStyle: TextStyle(color: Color(0xFF1B9D66)),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
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
          // 🔥 แก้ตรงนี้
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
