import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AgentProfilePage extends StatefulWidget {
  const AgentProfilePage({Key? key}) : super(key: key);

  @override
  State<AgentProfilePage> createState() => _AgentProfilePageState();
}

class _AgentProfilePageState extends State<AgentProfilePage> {
  bool isEditing = false;
  // Mock agent data for demonstration
  String name = 'Agent Name';
  String email = 'agent@email.com';
  String phone = '+255 700 123 456';
  String location = 'Dar es Salaam, Tanzania';
  String business = 'Areno Logistics';
  String businessType = 'Freight Forwarder';
  String businessContact = '+255 700 123 456';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              color: Colors.black,
            ),
            title: const Text('Agent Profile'),
            centerTitle: false,
            backgroundColor: AppTheme.successGreen,
            elevation: 0,
            pinned: true,
            floating: false,
            expandedHeight: 0,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final scrolled = constraints.biggest.height <= kToolbarHeight + 10;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  color: scrolled ? AppTheme.successGreen : Colors.transparent,
                );
              },
            ),
            foregroundColor: Colors.black,
            toolbarHeight: kToolbarHeight,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppTheme.slate900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Professional Agent',
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
                          const SizedBox(height: 12),
                          _InfoField(
                            label: 'Location',
                            value: location,
                            icon: Icons.location_on_outlined,
                            isEditing: isEditing,
                            onChanged: (value) => setState(() => location = value),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Business Information
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
                              Icon(Icons.business, color: AppTheme.successGreen, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'Business Information',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _InfoField(
                            label: 'Business Name',
                            value: business,
                            icon: Icons.business_outlined,
                            isEditing: isEditing,
                            onChanged: (value) => setState(() => business = value),
                          ),
                          const SizedBox(height: 12),
                          _InfoField(
                            label: 'Business Type',
                            value: businessType,
                            icon: Icons.category_outlined,
                            isEditing: isEditing,
                            onChanged: (value) => setState(() => businessType = value),
                          ),
                          const SizedBox(height: 12),
                          _InfoField(
                            label: 'Business Contact',
                            value: businessContact,
                            icon: Icons.phone,
                            isEditing: isEditing,
                            onChanged: (value) => setState(() => businessContact = value),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Payment Details
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
                              Icon(Icons.payment, color: AppTheme.successGreen, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'Payment Details',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _InfoField(
                            label: 'Payment Type',
                            value: 'Mobile Money',
                            icon: Icons.account_balance_wallet,
                            isEditing: isEditing,
                            onChanged: (_) {},
                          ),
                          const SizedBox(height: 12),
                          _InfoField(
                            label: 'Provider',
                            value: 'M-Pesa',
                            icon: Icons.phone_iphone,
                            isEditing: isEditing,
                            onChanged: (_) {},
                          ),
                          const SizedBox(height: 12),
                          _InfoField(
                            label: 'Account Number',
                            value: '+255 700 123 456',
                            icon: Icons.numbers,
                            isEditing: isEditing,
                            onChanged: (_) {},
                          ),
                          const SizedBox(height: 12),
                          _InfoField(
                            label: 'Account Name',
                            value: 'Asha Mussa',
                            icon: Icons.person,
                            isEditing: isEditing,
                            onChanged: (_) {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
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