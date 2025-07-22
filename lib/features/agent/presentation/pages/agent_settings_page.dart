import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AgentSettingsPage extends StatelessWidget {
  const AgentSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.primaryDarkBlue,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.slateGradient,
        ),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            ListTile(
              leading: Icon(Icons.notifications, color: AppTheme.primaryOrange),
              title: const Text('Notifications'),
              trailing: Icon(Icons.chevron_right, color: AppTheme.primaryBlue),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.lock, color: AppTheme.primaryOrange),
              title: const Text('Change Password'),
              trailing: Icon(Icons.chevron_right, color: AppTheme.primaryBlue),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout, color: AppTheme.primaryOrange),
              title: const Text('Logout'),
              trailing: Icon(Icons.chevron_right, color: AppTheme.primaryBlue),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
} 