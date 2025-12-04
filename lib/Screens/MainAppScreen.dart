import 'package:flutter/material.dart';
import 'ProfileScreen.dart';
import 'CircularBottomNavigation.dart';
import 'Tab_item.dart';
import 'RentalHistoryScreen.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int selectedPos = 2;
  late CircularBottomNavigationController _navigationController;

  final double bottomNavBarHeight = 60;

  final List<TabItem> tabItems = [
    TabItem(Icons.home, "Home", Colors.blue),
    TabItem(Icons.search, "Search", Colors.orange),
    TabItem(Icons.layers, "Historique", Colors.red),
    TabItem(Icons.notifications, "Notifications", Colors.cyan),
    TabItem(Icons.person, "Profile", Colors.purple),
  ];

  final List<Widget> pages = [
    const Center(child: Text("🏠 Accueil", style: TextStyle(fontSize: 20))),
    const Center(child: Text("🔍 Recherche", style: TextStyle(fontSize: 20))),
    RentalHistoryScreen(),
    const Center(child: Text("🔔 Notifications", style: TextStyle(fontSize: 20))),
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
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: bottomNavBarHeight),
            child: pages[selectedPos],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CircularBottomNavigation(
              tabItems,
              controller: _navigationController,
              selectedPos: selectedPos,
              barHeight: bottomNavBarHeight,
              backgroundBoxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
              animationDuration: Duration(milliseconds: 300),
              selectedCallback: (int? pos) {
                setState(() {
                  selectedPos = pos ?? 0;
                });
              },
            ),
          )
        ],
      ),
    );
  }
}