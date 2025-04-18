import 'package:flutter/material.dart';
import 'package:tripplan_1/screens/HomePage.dart';
import 'package:tripplan_1/screens/FortunePage.dart';
import 'package:tripplan_1/widgets/main_layout.dart';
import 'package:tripplan_1/widgets/custom_app_bar.dart';
import 'package:tripplan_1/screens/HistoryPage.dart';
import 'screens/CustomplanPage.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),

        //  ฟอนต์หลักทั่วทั้งแอป
        textTheme: GoogleFonts.interTextTheme(),

        //  ปุ่ม TextButton
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            textStyle: GoogleFonts.inter(),
          ),
        ),

        //  ปุ่ม ElevatedButton
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
        ),

        //  ปุ่ม OutlinedButton
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            textStyle: GoogleFonts.inter(),
          ),
        ),

        //  AppBar
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          elevation: 0,
        ),

        //  Dialog / AlertDialog
        dialogTheme: DialogTheme(
          titleTextStyle: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          contentTextStyle: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),

        //  SnackBar
        snackBarTheme: SnackBarThemeData(
          contentTextStyle: GoogleFonts.inter(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
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
