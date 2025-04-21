import 'package:flutter/material.dart';
import 'package:tripplan_1/widgets/main_layout.dart';
import 'package:tripplan_1/widgets/custom_app_bar.dart';
import 'ShakeFortunePage.dart';

class TripTypePage extends StatefulWidget {
  final DateTimeRange dateRange;
  final String province;
  final String fortune;
  final String companion;

  const TripTypePage({
    super.key,
    required this.dateRange,
    required this.province,
    required this.fortune,
    required this.companion,
  });

  @override
  State<TripTypePage> createState() => _TripTypePageState();
}

class _TripTypePageState extends State<TripTypePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<int, String> selectedTypes = {}; // วัน -> ประเภท

  final categories = [
    {
      'label': 'ผจญภัย',
      'value': 'adventure',
      'icon': 'assets/icons/Adventure.png',
    },
    {
      'label': 'คาเฟ่',
      'value': 'cafe',
      'icon': 'assets/icons/Cafe.png',
    },
    {
      'label': 'ธรรมชาติ & ชมวิว',
      'value': 'nature',
      'icon': 'assets/icons/Nature.png',
    },
    {
      'label': 'วัฒนธรรม & ประวัติศาสตร์',
      'value': 'history',
      'icon': 'assets/icons/History.png',
    },
    {
      'label': 'ครอบครัว & ทำบุญ',
      'value': 'family',
      'icon': 'assets/icons/Family.png',
    },
    {
      'label': 'สายเดินตลาดกลางคืน',
      'value': 'nightlife',
      'icon': 'assets/icons/Party.png',
    },
  ];

  List<DateTime> getTripDates() {
    final days =
        widget.dateRange.end.difference(widget.dateRange.start).inDays + 1;
    return List.generate(
        days, (i) => widget.dateRange.start.add(Duration(days: i)));
  }

  @override
  void initState() {
    super.initState();
    final tripDays =
        widget.dateRange.end.difference(widget.dateRange.start).inDays + 1;
    _tabController = TabController(length: tripDays, vsync: this);
  }

  void goNextPage() {
    if (selectedTypes.length == _tabController.length) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShakeFortunePage(
            province: widget.province,
            dateRange: widget.dateRange,
            selectedCategoriesByDay: selectedTypes,
            companion: widget.companion,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณาเลือกประเภทให้ครบทุกวัน")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripDates = getTripDates();
    final monthsInThai = [
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.'
    ];

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
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "เสี่ยงดวง✨",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.purple,
                      unselectedLabelColor: Colors.black,
                      indicatorColor: Colors.purple,
                      isScrollable: true,
                      onTap: (_) => setState(() {}),
                      tabs: tripDates.asMap().entries.map((entry) {
                        final date = entry.value;
                        final thaiMonth = monthsInThai[date.month - 1];
                        return Tab(
                          text:
                              "วันที่ ${entry.key + 1} (${date.day} $thaiMonth)",
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'เลือกประเภทการเที่ยวสำหรับวันที่ ${_tabController.index + 1} (${tripDates[_tabController.index].day} ${monthsInThai[tripDates[_tabController.index].month - 1]})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: categories.map((category) {
                        final isSelected =
                            selectedTypes[_tabController.index] ==
                                category['value'];

                        return GestureDetector(
                          onTap: () {
                            final value = category['value'];
                            if (value != null) {
                              setState(() {
                                selectedTypes[_tabController.index] = value;
                              });
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
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
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: Image.asset(
                                          category['icon']!,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(
                                                Icons.image_not_supported,
                                                size: 20,
                                                color: Colors.grey);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    category['label']!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.purple
                                          : Colors.black87,
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
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: TextButton(
                  onPressed: goNextPage,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black87,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ถัดไป',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
