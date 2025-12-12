import 'package:flutter/material.dart';
import 'ProfileScreen.dart';
import 'CircularBottomNavigation.dart';
import 'Tab_item.dart';
import 'RentalHistoryScreen.dart';
import 'HomeScreen.dart';
import 'MapScreen.dart';
import 'assistance_screen.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int selectedPos = 0;
  late CircularBottomNavigationController _navigationController;

  final double bottomNavBarHeight = 60;

  final List<TabItem> tabItems = [
    TabItem(Icons.explore, "Explorer", Colors.blue),
    TabItem(Icons.calendar_today, "Mes résas", Colors.orange),
    TabItem(Icons.map, "Carte", Colors.red),
    TabItem(Icons.support_agent, "Assistance", Colors.cyan),
    TabItem(Icons.person, "Profil", Colors.purple),
  ];

  final List<Widget> pages = [
    const HomeScreen(),
    RentalHistoryScreen(),
    const MapScreen(),
    AssistanceScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _navigationController = CircularBottomNavigationController(selectedPos);
  }

  @override
  void dispose() {
    _navigationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedPos],
      bottomNavigationBar: CircularBottomNavigation(
        tabItems,
        controller: _navigationController,
        barHeight: bottomNavBarHeight,
        barBackgroundColor: Colors.white,
        animationDuration: const Duration(milliseconds: 300),
        selectedCallback: (int? selectedPos) {
          setState(() {
            this.selectedPos = selectedPos!;
          });
        },
      ),
    );
  }
}