import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/search_page.dart';
import '../pages/settings_page.dart';

class TheBottomBar extends StatefulWidget {
  const TheBottomBar({super.key});

  @override
  TheBottomBarState createState() => TheBottomBarState();
}

class TheBottomBarState extends State<TheBottomBar>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;

  final List<Widget> _pages = [
    const HomePage(),
    const SearchPage(),
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      _animationController.forward(from: 0.0);
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          body: _pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.black45,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: [
              BottomNavigationBarItem(
                icon: _buildFlippingIcon(0, Icons.home_filled),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: _buildFlippingIcon(1, Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: _buildFlippingIcon(2, Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlippingIcon(int index, IconData icon) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        double rotation = 0.0;
        if (_selectedIndex == index) {
          rotation = _animationController.value * 6.28;
        }
        return Transform(
          transform: Matrix4.rotationY(rotation),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 27,
            color: _selectedIndex == index ? Colors.blue : Colors.black45,
          ),
        );
      },
    );
  }
}
