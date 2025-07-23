import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:latlong2/latlong.dart' as latlng2;
import 'driver_profile_page.dart';
import 'driver_payments_page.dart';
import 'driver_shipments_page.dart';
import 'driver_create_shipment_page.dart';
import 'driver_quotes_page.dart';

class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> with TickerProviderStateMixin {
  bool isSearchExpanded = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    // Initialize the animation to the starting position
    _animationController.value = 0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      isSearchExpanded = !isSearchExpanded;
    });
    if (isSearchExpanded) {
      _animationController.forward().then((_) {
        // Animation completed
      });
    } else {
      _animationController.reverse().then((_) {
        // Animation completed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mock driver assignment data for demo
    final assignment = {
      'pickupLocation': '123 Main St, Dar es Salaam',
      'dropoffLocation': '456 Arusha Ave, Arusha',
      'packageType': 'Parcel Delivery',
      'status': 'Navigate to Pickup',
      'fare': 'TZS 12,000',
      'customerName': 'Asha Mussa',
      'customerPhone': '+255 700 123 456',
      'eta': '8 min',
      'pickupLatLng': latlng2.LatLng(-6.7924, 39.2083),
      'dropoffLatLng': latlng2.LatLng(-3.3869, 36.68299),
    };
    return Scaffold(
      drawer: _DriverDrawer(),
      body: Stack(
        children: [
          // OpenStreetMap with flutter_map
          flutter_map.FlutterMap(
            options: flutter_map.MapOptions(
              initialCenter: assignment['pickupLatLng'] as latlng2.LatLng,
              initialZoom: 8.5,
              interactionOptions: const flutter_map.InteractionOptions(
                flags: flutter_map.InteractiveFlag.pinchZoom | flutter_map.InteractiveFlag.drag,
              ),
            ),
            children: [
              flutter_map.TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.arenoapp',
              ),
              flutter_map.PolylineLayer(
                polylines: [
                  flutter_map.Polyline(
                    points: [
                      assignment['pickupLatLng'] as latlng2.LatLng,
                      assignment['dropoffLatLng'] as latlng2.LatLng,
                    ],
                    color: AppTheme.primaryBlue,
                    strokeWidth: 5,
                  ),
                ],
              ),
              flutter_map.MarkerLayer(
                markers: [
                  flutter_map.Marker(
                    width: 40,
                    height: 40,
                    point: assignment['pickupLatLng'] as latlng2.LatLng,
                    child: Icon(Icons.location_pin, color: AppTheme.primaryOrange, size: 40),
                  ),
                  flutter_map.Marker(
                    width: 40,
                    height: 40,
                    point: assignment['dropoffLatLng'] as latlng2.LatLng,
                    child: Icon(Icons.flag, color: AppTheme.successGreen, size: 40),
                  ),
                ],
              ),
            ],
          ),
          // Overlay info banner and ride card at the bottom
          Align(
            alignment: Alignment.bottomCenter,
          child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
            child: Column(
                mainAxisSize: MainAxisSize.min,
              children: [
                  // Assignment card for driver
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    color: Colors.white,
                    child: Padding(
                  padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search field inside the card
                          if (!isSearchExpanded)
                            GestureDetector(
                              onTap: () {
                                _toggleSearch();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                                    Icon(Icons.search, color: Colors.grey[600]),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Search location...',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (!isSearchExpanded) const SizedBox(height: 16),
                          Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                        ),
                                padding: const EdgeInsets.all(8),
                                child: Icon(Icons.local_shipping, color: AppTheme.primaryBlue, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                                    Text(assignment['packageType'] as String, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryDarkBlue)),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(Icons.timer, size: 16, color: AppTheme.primaryOrange),
                                        const SizedBox(width: 4),
                                        Text(assignment['eta'] as String, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.primaryOrange)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Text(assignment['fare'] as String, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.successGreen, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Icon(Icons.location_pin, color: AppTheme.primaryOrange, size: 20),
                              const SizedBox(width: 8),
                              Expanded(child: Text(assignment['pickupLocation'] as String, style: Theme.of(context).textTheme.bodyMedium)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.flag, color: AppTheme.successGreen, size: 20),
                              const SizedBox(width: 8),
                              Expanded(child: Text(assignment['dropoffLocation'] as String, style: Theme.of(context).textTheme.bodyMedium)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.person, color: AppTheme.primaryBlue, size: 20),
                              const SizedBox(width: 8),
                              Expanded(child: Text(assignment['customerName'] as String, style: Theme.of(context).textTheme.bodyMedium)),
                              IconButton(
                                icon: Icon(Icons.phone, color: AppTheme.primaryOrange),
                                onPressed: () {}, // Call customer
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.successGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                textStyle: Theme.of(context).textTheme.titleMedium,
                              ),
                              onPressed: () {},
                              child: Text(assignment['status'] as String),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Top search section for origin and destination (topmost layer)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Row(
                  children: [
                    if (!isSearchExpanded)
                      Builder(
                        builder: (context) => Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.slate900.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                            ),
                          ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.menu, color: AppTheme.successGreen, size: 24),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                            tooltip: 'Menu',
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ),
          ),
          // Full screen search overlay
          if (isSearchExpanded)
            SlideTransition(
              position: _slideAnimation,
              child: Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                top: 200, // Fixed height to leave space at top
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                  child: Column(
                    children: [
                        // Cross icon for cancel at top right
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.black, size: 28),
                              onPressed: () {
                                _toggleSearch();
                              },
                              tooltip: 'Cancel',
                            ),
                          ),
                        ),
                        // Search fields
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _LocationSearchField(
                                hintText: 'Origin (Pickup Location)',
                                icon: Icons.my_location,
                      ),
                      const SizedBox(height: 16),
                              // Dotted line connecting origin to destination
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                        children: [
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: AppTheme.successGreen.withOpacity(0.3),
                                              width: 1,
                                              style: BorderStyle.solid,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: AppTheme.successGreen,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: AppTheme.successGreen.withOpacity(0.3),
                                              width: 1,
                                              style: BorderStyle.solid,
                                            ),
                                          ),
                                        ),
                                      ),
                      ),
                    ],
                  ),
                ),
                              const SizedBox(height: 16),
                              _LocationSearchField(
                                hintText: 'Destination (Drop-off Location)',
                                icon: Icons.location_on,
                              ),
                            ],
                          ),
                        ),
                        // Location suggestions area
                Expanded(
                          child: Container(
                            color: Colors.grey[50],
                            child: ListView(
                              padding: const EdgeInsets.all(16),
                    children: [
                                // Mock location suggestions
                                _LocationSuggestionTile(
                                  title: 'Dar es Salaam Airport',
                                  subtitle: 'Dar es Salaam, Tanzania',
                                  icon: Icons.flight,
                                ),
                                _LocationSuggestionTile(
                                  title: 'Arusha City Center',
                                  subtitle: 'Arusha, Tanzania',
                                  icon: Icons.location_city,
                                ),
                                _LocationSuggestionTile(
                                  title: 'Mwanza Port',
                                  subtitle: 'Mwanza, Tanzania',
                                  icon: Icons.local_shipping,
                                ),
                                _LocationSuggestionTile(
                                  title: 'Dodoma Capital',
                                  subtitle: 'Dodoma, Tanzania',
                                  icon: Icons.account_balance,
                                ),
                    ],
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
            ),
        ],
      ),
    );
  }
}

// Sidebar (drawer) for driver
class _DriverDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final username = user?.displayName ?? user?.email ?? 'Driver';
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.slateGradient,
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 0),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: AppTheme.successGreen, size: 28),
          ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          username,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: AppTheme.successGreen),
              title: const Text('Profile'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const DriverProfilePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.payment, color: AppTheme.successGreen),
              title: const Text('Payments'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const DriverPaymentsPage()),
                );
              },
      ),
            ListTile(
              leading: Icon(Icons.local_shipping, color: AppTheme.successGreen),
              title: const Text('Shipments'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const DriverShipmentsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.add_box, color: AppTheme.successGreen),
              title: const Text('Create Shipment'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const DriverCreateShipmentPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.receipt_long, color: AppTheme.successGreen),
              title: const Text('Quotes'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const DriverQuotesPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationSearchField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  const _LocationSearchField({required this.hintText, required this.icon});
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppTheme.successGreen),
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.slate400),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.successGreen.withOpacity(0.18)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.successGreen.withOpacity(0.18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.successGreen, width: 2),
        ),
      ),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.slate900),
    );
  }
}

class _LocationSuggestionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _LocationSuggestionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.successGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.successGreen, size: 20),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey[600],
        ),
      ),
      onTap: () {
        // Handle location selection
      },
    );
  }
}


