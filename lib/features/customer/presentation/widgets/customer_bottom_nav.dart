import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CustomerBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomerBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: AppTheme.successGreen,
      unselectedItemColor: AppTheme.successGreen.withOpacity(0.5),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.location_city),
          label: 'Offices',
          ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
          ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book_online),
          label: 'Booking',
          ),
        ],
    );
  }
}
