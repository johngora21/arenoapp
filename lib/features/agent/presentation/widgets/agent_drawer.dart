import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../pages/agent_profile_page.dart';

import '../pages/agent_quotes_page.dart';

// import other pages as needed

class AgentDrawer extends StatelessWidget {
  final double profileSize;
  final String username;
  const AgentDrawer({this.profileSize = 36, this.username = 'Agent Username', Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.slateGradient,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryDarkBlue,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.only(left: 16, top: 32, bottom: 24, right: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: profileSize / 2,
                    backgroundColor: AppTheme.primaryDarkBlue,
                    child: Icon(Icons.person, color: AppTheme.primaryOrange, size: profileSize / 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: AppTheme.primaryOrange),
              title: const Text('Profile'),
              selectedTileColor: AppTheme.primaryOrange.withOpacity(0.08),
              selectedColor: AppTheme.primaryOrange,
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const AgentProfilePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.request_quote, color: AppTheme.primaryOrange),
              title: const Text('Quotes'),
              selectedTileColor: AppTheme.primaryOrange.withOpacity(0.08),
              selectedColor: AppTheme.primaryOrange,
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const AgentQuotesPage()),
                );
              },
            ),
           
           
            ListTile(
              leading: Icon(Icons.settings, color: AppTheme.primaryOrange),
              title: const Text('Settings'),
              selectedTileColor: AppTheme.primaryOrange.withOpacity(0.08),
              selectedColor: AppTheme.primaryOrange,
              onTap: () {
                // TODO: Navigate to Settings page
              },
            ),
          ],
        ),
      ),
    );
  }
} 