import 'package:flutter/material.dart';
import '../../../books/presentation/screens/browse_listings_screen.dart';
import '../../../books/presentation/screens/my_listings_screen.dart';
import '../../../swaps/presentation/screens/my_offers_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class MainNavigationSimple extends StatefulWidget {
  const MainNavigationSimple({super.key});

  @override
  State<MainNavigationSimple> createState() => _MainNavigationSimpleState();
}

class _MainNavigationSimpleState extends State<MainNavigationSimple> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const BrowseListingsScreen(),
    const MyListingsScreen(),
    const MyOffersScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'My Books',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Offers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
