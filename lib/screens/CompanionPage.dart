import 'package:flutter/material.dart';
import 'package:tripplan_1/screens/TripTypePage.dart';
import 'package:tripplan_1/widgets/main_layout.dart';
import 'package:tripplan_1/widgets/custom_app_bar.dart';  // นำเข้า CustomAppBar

class CompanionPage extends StatefulWidget {
  final String province;
  final DateTimeRange dateRange;
  final String fortune;

  const CompanionPage({
    super.key,
    required this.province,
    required this.dateRange,
    required this.fortune,
  });

  @override
  State<CompanionPage> createState() => _CompanionPageState();
}

class _CompanionPageState extends State<CompanionPage> {
  String? selectedCompanion;

  final List<Map<String, String>> companions = [
    {'label': 'ครอบครัว', 'emoji': '👨‍👩‍👧‍👦'},
    {'label': 'คู่รัก', 'emoji': '💑'},
    {'label': 'เพื่อน', 'emoji': '🤝'},
    {'label': 'องค์กร', 'emoji': '🏢'},
    {'label': 'คนเดียว', 'emoji': '🧍‍♂️'},
  ];

  void goNextPage() {
    if (selectedCompanion != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TripTypePage(
            province: widget.province,
            dateRange: widget.dateRange,
            fortune: widget.fortune,
            companion: selectedCompanion!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณาเลือกเพื่อนร่วมเดินทางก่อน")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      appBar: const CustomAppBar(),  // ใช้ CustomAppBar
      currentIndex: 0,
      onTap: (index) {
        if (index == 0) {
          Navigator.pop(context);
        } else if (index == 1) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      },
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "เสี่ยงดวง✨",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // 🔮 โชว์คำทำนายอย่างเดียว
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "🔮 คำทำนายของคุณ:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.fortune,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),

            // กรอบเลือกเพื่อนร่วมเดินทาง
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "เลือกเพื่อนร่วมเดินทางของคุณ",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...companions.map((companion) {
                    final label = companion['label']!;
                    final emoji = companion['emoji']!;
                    return RadioListTile<String>(
                      title: Text('$emoji $label'),
                      value: label,
                      groupValue: selectedCompanion,
                      onChanged: (value) {
                        setState(() => selectedCompanion = value);
                      },
                      activeColor: Colors.purple,
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: goNextPage,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text(
                        "ถัดไป",
                        style: TextStyle(fontSize: 16, color: Colors.purple),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
