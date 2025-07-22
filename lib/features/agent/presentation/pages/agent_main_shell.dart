import 'package:flutter/material.dart';
import '../widgets/agent_bottom_nav.dart';
import 'agent_home_screen.dart';
import 'agent_shipments_page.dart';
import 'agent_register_shipment_page.dart';

class AgentMainShell extends StatefulWidget {
  const AgentMainShell({Key? key}) : super(key: key);

  @override
  State<AgentMainShell> createState() => _AgentMainShellState();
}

class _AgentMainShellState extends State<AgentMainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    AgentHomeScreen(),
    AgentShipmentsPage(),
    AgentRegisterShipmentPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: AgentBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
} 