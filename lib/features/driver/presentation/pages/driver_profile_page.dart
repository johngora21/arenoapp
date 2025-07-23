import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DriverProfilePage extends ConsumerStatefulWidget {
  const DriverProfilePage({super.key});

  @override
  ConsumerState<DriverProfilePage> createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends ConsumerState<DriverProfilePage> {
  bool isEditing = false;
  DocumentSnapshot? driverProfile;
  bool isLoading = true;

  String name = '';
  String email = '';
  String phone = '';
  String vehicleNumber = '';
  String vehicleType = '';
  String licenseNumber = '';

  @override
  void initState() {
    super.initState();
    _fetchDriverProfile();
  }

  Future<void> _fetchDriverProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('drivers').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          driverProfile = doc;
          name = doc['name'] ?? '';
          email = doc['email'] ?? '';
          phone = doc['phone'] ?? '';
          vehicleNumber = doc['vehicleNumber'] ?? '';
          vehicleType = doc['vehicleType'] ?? '';
          licenseNumber = doc['licenseNumber'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() { isLoading = false; });
      }
    } else {
      setState(() { isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Profile'),
        backgroundColor: AppTheme.successGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Pic and Name (no container)
                  const SizedBox(height: 24),
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: AppTheme.successGreen,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          name.isNotEmpty ? name : 'Driver Name',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppTheme.slate900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Professional Driver',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Personal Information
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person, color: AppTheme.successGreen, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'Personal Information',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: Icon(
                                  isEditing ? Icons.save : Icons.edit,
                                  color: AppTheme.successGreen,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isEditing = !isEditing;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _InfoField(
                            label: 'Full Name',
                            value: name,
                            icon: Icons.person_outline,
                            isEditing: isEditing,
                            onChanged: (value) => setState(() => name = value),
                          ),
                          const SizedBox(height: 12),
                          _InfoField(
                            label: 'Email',
                            value: email,
                            icon: Icons.email_outlined,
                            isEditing: isEditing,
                            onChanged: (value) => setState(() => email = value),
                          ),
                          const SizedBox(height: 12),
                          _InfoField(
                            label: 'Phone Number',
                            value: phone,
                            icon: Icons.phone_outlined,
                            isEditing: isEditing,
                            onChanged: (value) => setState(() => phone = value),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Vehicle Information
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.directions_car, color: AppTheme.successGreen, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'Vehicle Information',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _InfoField(
                            label: 'Vehicle Number',
                            value: vehicleNumber,
                            icon: Icons.confirmation_number,
                            isEditing: isEditing,
                            onChanged: (value) => setState(() => vehicleNumber = value),
                          ),
                          const SizedBox(height: 12),
                          _InfoField(
                            label: 'Vehicle Type',
                            value: vehicleType,
                            icon: Icons.category,
                            isEditing: isEditing,
                            onChanged: (value) => setState(() => vehicleType = value),
                          ),
                          const SizedBox(height: 12),
                          _InfoField(
                            label: 'License Number',
                            value: licenseNumber,
                            icon: Icons.card_membership,
                            isEditing: isEditing,
                            onChanged: (value) => setState(() => licenseNumber = value),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Settings
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.settings, color: AppTheme.successGreen, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'Settings',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _SettingsTile(
                            title: 'Notifications',
                            subtitle: 'Manage push notifications',
                            icon: Icons.notifications_outlined,
                            onTap: () {},
                          ),
                          _SettingsTile(
                            title: 'Privacy',
                            subtitle: 'Manage your privacy settings',
                            icon: Icons.privacy_tip_outlined,
                            onTap: () {},
                          ),
                          _SettingsTile(
                            title: 'Help & Support',
                            subtitle: 'Get help and contact support',
                            icon: Icons.help_outline,
                            onTap: () {},
                          ),
                          _SettingsTile(
                            title: 'About',
                            subtitle: 'App version and information',
                            icon: Icons.info_outline,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;

  const _EarningsCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isEditing;
  final Function(String) onChanged;

  const _InfoField({
    required this.label,
    required this.value,
    required this.icon,
    required this.isEditing,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.successGreen, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: isEditing
              ? TextFormField(
                  initialValue: value,
                  decoration: InputDecoration(
                    labelText: label,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: onChanged,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value.isNotEmpty ? value : 'Not provided',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.successGreen),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
} 