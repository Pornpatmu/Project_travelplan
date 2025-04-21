import 'package:flutter/material.dart';
import 'TripTypePage.dart';
import 'package:tripplan_1/widgets/custom_app_bar.dart';
import 'package:tripplan_1/widgets/main_layout.dart';

class SelectCompanionPage extends StatefulWidget {
  final DateTimeRange dateRange;
  final String province;
  final String fortune;

  const SelectCompanionPage({
    super.key,
    required this.dateRange,
    required this.province,
    required this.fortune,
  });

  @override
  State<SelectCompanionPage> createState() => _SelectCompanionPageState();
}

class _SelectCompanionPageState extends State<SelectCompanionPage> {
  String? selectedCompanion;

  final companions = [
    {'label': 'ครอบครัว', 'value': 'family', 'icon': 'assets/icons/Family.png'},
    {'label': 'คู่รัก', 'value': 'couple', 'icon': 'assets/icons/Couple.png'},
    {'label': 'เพื่อน', 'value': 'friend', 'icon': 'assets/icons/Friends.png'},
    {'label': 'องค์กร', 'value': 'company', 'icon': 'assets/icons/Company.png'},
    {'label': 'คนเดียว', 'value': 'solo', 'icon': 'assets/icons/Alone.png'},
  ];

  void goToNextPage() {
    if (selectedCompanion != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TripTypePage(
            dateRange: widget.dateRange,
            province: widget.province,
            fortune: widget.fortune,
            companion: selectedCompanion!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกเพื่อนร่วมเดินทาง')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      appBar: const CustomAppBar(),
      currentIndex: 0,
      onTap: (index) {
        if (index == 0) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      },
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'เสี่ยงดวง✨',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'เลือกเพื่อนร่วมเดินทางของคุณ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    ...companions.map((companion) {
                      final isSelected =
                          selectedCompanion == companion['value'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCompanion = companion['value'];
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.purple
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.purple.withOpacity(0.25),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                companion['icon']!,
                                width: 40,
                                height: 40,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  companion['label']!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.purple
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle,
                                    color: Colors.purple),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: TextButton(
                  onPressed: goToNextPage,
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('ถัดไป',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
