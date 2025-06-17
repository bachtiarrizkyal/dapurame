import 'package:flutter/material.dart';

class CustomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: BottomNavigationBar(
        backgroundColor: const Color(0xFFFFF2DF),
        selectedItemColor: const Color(0xFF662B0E),
        unselectedItemColor: const Color(0xFFB39B93),
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: onTap,
        selectedLabelStyle: const TextStyle(fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        selectedIconTheme: const IconThemeData(size: 24),
        unselectedIconTheme: const IconThemeData(size: 24),
        items: [
          _buildNavItem(icon: Icons.home, label: 'Home', index: 0),
          _buildNavItem(icon: Icons.restaurant, label: 'Nutrisi', index: 1),
          _buildNavItem(icon: Icons.menu_book, label: 'Resepku', index: 2),
          _buildNavItem(icon: Icons.bookmark, label: 'Bookmark', index: 3),
          _buildNavItem(icon: Icons.person, label: 'Profil', index: 4),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = index == currentIndex;

    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color:
                isSelected ? const Color(0xFF662B0E) : const Color(0xFFB39B93),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color:
                  isSelected
                      ? const Color(0xFF662B0E)
                      : const Color(0xFFB39B93),
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 2),
              height: 3,
              width: 90,
              color: const Color(0xFF662B0E),
            ),
        ],
      ),
      label: '',
    );
  }
}
