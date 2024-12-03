import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/search_page.dart';

class TheBottomBar extends StatefulWidget {
  const TheBottomBar({super.key});

  @override
  TheBottomBarState createState() => TheBottomBarState();
}

class TheBottomBarState extends State<TheBottomBar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [const HomePage(), const SearchPage()];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Highlight the selected item
        onTap: _onItemTapped, // Handle item tap
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.podcasts), // Normal icon
            label: 'Podcasts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search), // Normal icon
            label: 'Search',
          ),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey.shade600,
      ),
    );
  }
}
