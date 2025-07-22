import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../pages/profile_page.dart';
import '../pages/change_password_page.dart';
import '../pages/my_shipments_page.dart';
import '../pages/quotes_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppDrawer extends StatelessWidget {
  final double profileSize;
  AppDrawer({this.profileSize = 36});

  Widget _buildCountTile({required IconData icon, required String title, required Stream<QuerySnapshot> stream, required VoidCallback onTap}) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        int count = 0;
        if (snapshot.hasData) {
          count = snapshot.data!.docs.length;
        }
        return ListTile(
          leading: Icon(icon, color: AppTheme.primaryOrange),
          title: Row(
            children: [
              Text(title),
              if (count > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$count', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
          selectedTileColor: AppTheme.primaryOrange.withOpacity(0.08),
          selectedColor: AppTheme.primaryOrange,
          onTap: onTap,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final shipmentsStream = user != null
      ? FirebaseFirestore.instance.collection('shipments').where('userId', isEqualTo: user.uid).snapshots()
      : const Stream<QuerySnapshot<Object?>>.empty();
    final quotesStream = user != null
      ? FirebaseFirestore.instance.collection('quotes').where('userId', isEqualTo: user.uid).snapshots()
      : const Stream<QuerySnapshot<Object?>>.empty();
    // For demonstration, set isLoggedIn to false to show the login button
    final bool isLoggedIn = false;
    final String userName = 'John Doe';
    final String userInitials = 'JD';
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
              child: GestureDetector(
                onTap: () {
                  if (!isLoggedIn) {
                    Navigator.of(context).pushNamed('/login');
                  }
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: profileSize / 2,
                      backgroundColor: AppTheme.primaryDarkBlue,
                      child: Text(
                        userInitials,
                        style: TextStyle(
                          color: AppTheme.primaryOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: profileSize / 2.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isLoggedIn ? userName : 'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: AppTheme.primaryOrange),
              title: Text('Profile', style: TextStyle(fontWeight: FontWeight.w600)),
              selectedTileColor: AppTheme.primaryOrange.withOpacity(0.08),
              selectedColor: AppTheme.primaryOrange,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CustomerProfilePage(),
                  ),
                );
              },
            ),
            _buildCountTile(
              icon: Icons.local_shipping,
              title: 'My Shipments',
              stream: shipmentsStream,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MyShipmentsPage(),
                  ),
                );
              },
            ),
            _buildCountTile(
              icon: Icons.request_quote,
              title: 'Quotations',
              stream: quotesStream,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const QuotesPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: AppTheme.primaryOrange),
              title: Text('Settings'),
              selectedTileColor: AppTheme.primaryOrange.withOpacity(0.08),
              selectedColor: AppTheme.primaryOrange,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
} 