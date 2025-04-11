import 'package:flutter/material.dart';
import 'package:tripplan_1/screens/HomePage.dart';
import 'package:tripplan_1/screens/FortunePage.dart';
import 'package:tripplan_1/widgets/main_layout.dart';
import 'package:tripplan_1/widgets/custom_app_bar.dart';
import 'package:tripplan_1/screens/HistoryPage.dart';
import 'screens/CustomplanPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TripPlan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomeScreen(),
        '/fortune': (context) => const FortunePage(),
        '/customplan': (context) => const CustomplanPage(),
        '/history': (context) => const HistoryScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const FortunePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      appBar: const CustomAppBar(),
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      body: _pages[_selectedIndex],
    );
  }
}
