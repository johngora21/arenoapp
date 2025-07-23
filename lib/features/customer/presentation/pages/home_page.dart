import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stats = [
      {'icon': Icons.local_shipping, 'label': 'Shipments', 'value': '2', 'color': AppTheme.primaryOrange},
      {'icon': Icons.request_quote, 'label': 'Quotes', 'value': '1', 'color': AppTheme.successGreen},
      {'icon': Icons.check_circle, 'label': 'Delivered', 'value': '5', 'color': AppTheme.successGreen},
    ];
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.slateGradient,
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Poster Card (rectangular, smooth)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AspectRatio(
                      aspectRatio: 16 / 7,
                      child: Image.asset(
                        'assets/images/poster_placeholder.png', // Replace with your actual poster image
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // Analytics/Dashboard Section
                Text(
                  'Your Analytics',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.slate900,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                  children: stats.map((stat) => _DashboardStatCard(
                    icon: stat['icon'] as IconData,
                    label: stat['label'] as String,
                    value: stat['value'] as String,
                    color: stat['color'] as Color,
                  )).toList(),
                ),
                const SizedBox(height: 24),
                // Realtime Notification Card
                _NotificationCard(
                  message: 'Your shipment #1234 has arrived at Arusha branch.',
                ),
                // Add more dashboard sections as needed
              ],
            ),
          ),
        ),
        // Floating action button for call/WhatsApp
        Positioned(
          bottom: 24,
          right: 24,
          child: _CallFab(),
        ),
      ],
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _DashboardStatCard({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color)),
            Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _CallFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: AppTheme.successGreen,
      child: const Icon(Icons.phone, color: Colors.white),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (ctx) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.phone, color: Colors.green),
                  title: const Text('Call Customer Support'),
                  onTap: () {
                    // TODO: Implement call functionality
                    Navigator.of(ctx).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.chat, color: Colors.green), // Use chat icon for WhatsApp
                  title: const Text('Chat on WhatsApp'),
                  onTap: () {
                    // TODO: Implement WhatsApp chat
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String message;
  const _NotificationCard({required this.message});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.primaryOrange,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 