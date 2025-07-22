import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AgentBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AgentBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: AppTheme.primaryBlue,
      unselectedItemColor: AppTheme.primaryDarkBlue,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: 'Shipments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: 'Create',
        ),
      ],
    );
  }
} 