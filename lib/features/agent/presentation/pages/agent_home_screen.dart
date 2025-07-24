import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/agent_drawer.dart';

class AgentHomeScreen extends StatefulWidget {
  const AgentHomeScreen({Key? key}) : super(key: key);

  @override
  State<AgentHomeScreen> createState() => _AgentHomeScreenState();
}

class _AgentHomeScreenState extends State<AgentHomeScreen> {
  String selectedTab = 'Shipments';
  String selectedTimeFrame = 'Today';
  final List<String> timeFrames = ['Today', 'This Week', 'This Month'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Home'),
        backgroundColor: AppTheme.successGreen,
        elevation: 0,
      ),
      drawer: AgentDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.slateGradient,
        ),
          child: Padding(
            padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedTab == 'Shipments' ? AppTheme.successGreen : AppTheme.slate200,
                          foregroundColor: selectedTab == 'Shipments' ? Colors.white : AppTheme.slate900,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: Theme.of(context).textTheme.titleMedium,
                        ),
                        onPressed: () => setState(() => selectedTab = 'Shipments'),
                        child: const Text('Shipments'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedTab == 'Payments' ? AppTheme.primaryOrange : AppTheme.slate200,
                          foregroundColor: selectedTab == 'Payments' ? Colors.white : AppTheme.slate900,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: Theme.of(context).textTheme.titleMedium,
                        ),
                        onPressed: () => setState(() => selectedTab = 'Payments'),
                        child: const Text('Payments'),
                      ),
                  ),
                        ],
                      ),
                const SizedBox(height: 18),
                // Remove the time frame dropdown from Payments section
                if (selectedTab == 'Shipments') ...[
                  Text('Shipment Analytics', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  _buildPairedCards([
                    _modernStatCard(label: 'Today', value: '12', icon: Icons.today, color: AppTheme.primaryBlue, badge: 'Today', width: 220),
                    _modernStatCard(label: 'Pending', value: '5', icon: Icons.pending_actions, color: AppTheme.primaryOrange, badge: 'Pending', width: 220),
                    _modernStatCard(label: 'Delivered', value: '7', icon: Icons.check_circle, color: AppTheme.successGreen, badge: 'Delivered', width: 220),
                    _modernStatCard(label: 'Returns', value: '1', icon: Icons.undo, color: AppTheme.slate700, badge: 'Returns', width: 220),
                  ]),
                  const SizedBox(height: 24),
                  ..._buildNotificationList([
                    'Shipment #PKG001 has arrived at Arusha branch.',
                    'New shipment assigned: #PKG002.',
                    'Customer confirmed delivery for #PKG001.',
                  ]),
                ] else ...[
                  Text('Finance Analytics', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  _buildPairedCards([
                    _modernStatCard(label: 'Owed', value: 'TZS 120,000', icon: Icons.account_balance_wallet, color: AppTheme.primaryBlue, badge: null, fixed: true, width: 220),
                    _modernStatCard(label: 'Remit', value: 'TZS 80,000', icon: Icons.payments, color: AppTheme.primaryOrange, badge: null, fixed: true, width: 220),
                    _modernStatCard(label: 'Earned', value: 'TZS 300,000', icon: Icons.trending_up, color: AppTheme.successGreen, badge: null, fixed: false, width: 220),
                    _modernStatCard(label: 'Due', value: 'TZS 0', icon: Icons.warning, color: AppTheme.slate700, badge: null, fixed: false, width: 220),
                  ]),
                  const SizedBox(height: 24),
                  ..._buildNotificationList([
                    'Payment received for shipment #PKG001.',
                    'Remit cash for #PKG002 by 5pm today.',
                  ]),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Update _modernStatCard to accept a width parameter
  Widget _modernStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    String? badge,
    bool fixed = false, // ignored, always expands
    double width = 220,
  }) {
    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.85), color.withOpacity(0.65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 10,
            bottom: 10,
            child: Icon(icon, size: 48, color: Colors.white.withOpacity(0.18)),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(badge, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                const SizedBox(height: 18),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Update _buildPairedCards to allow horizontal scroll and fixed card width
  Widget _buildPairedCards(List<Widget> cards) {
    List<Widget> widgets = [];
    for (int i = 0; i < cards.length; i += 2) {
      widgets.add(
        Row(
          children: [
            cards[i],
            if (i + 1 < cards.length) ...[
              const SizedBox(width: 16),
              cards[i + 1],
            ]
          ],
        ),
      );
      if (i + 2 < cards.length) {
        widgets.add(const SizedBox(height: 16));
      }
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }

  List<Widget> _buildNotificationList(List<String> messages) {
    return messages.map((msg) => _NotificationCard(message: msg)).toList();
  }
}

class _NotificationCard extends StatelessWidget {
  final String message;
  const _NotificationCard({required this.message});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
            children: [
            const Icon(Icons.info_outline, color: AppTheme.primaryOrange, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.successGreen, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
