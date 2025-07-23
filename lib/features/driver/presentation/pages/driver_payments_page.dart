import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DriverPaymentsPage extends ConsumerStatefulWidget {
  const DriverPaymentsPage({super.key});

  @override
  ConsumerState<DriverPaymentsPage> createState() => _DriverPaymentsPageState();
}

class _DriverPaymentsPageState extends ConsumerState<DriverPaymentsPage> {
  String selectedPeriod = 'This Week';
  final List<String> periods = ['Today', 'This Week', 'This Month', 'This Year'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        backgroundColor: AppTheme.successGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Earnings Overview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.successGreen, AppTheme.primaryBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.attach_money, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Total Earnings',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'TZS 8,500,000',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Completed',
                          value: '156',
                          subtitle: 'deliveries',
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Pending',
                          value: '12',
                          subtitle: 'payments',
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Period Selector
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Period',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedPeriod,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: periods.map((period) {
                        return DropdownMenuItem(
                          value: period,
                          child: Text(period),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPeriod = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Earnings Breakdown
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
                        Icon(Icons.pie_chart, color: AppTheme.successGreen, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Earnings Breakdown',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _EarningsBreakdownItem(
                      title: 'Delivery Fees',
                      amount: 'TZS 6,200,000',
                      percentage: 73,
                      color: AppTheme.successGreen,
                    ),
                    const SizedBox(height: 12),
                    _EarningsBreakdownItem(
                      title: 'Tips',
                      amount: 'TZS 1,800,000',
                      percentage: 21,
                      color: AppTheme.primaryOrange,
                    ),
                    const SizedBox(height: 12),
                    _EarningsBreakdownItem(
                      title: 'Bonuses',
                      amount: 'TZS 500,000',
                      percentage: 6,
                      color: AppTheme.primaryBlue,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Payment History
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
                        Icon(Icons.history, color: AppTheme.successGreen, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Payment History',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'View All',
                            style: TextStyle(color: AppTheme.successGreen),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _PaymentHistoryItem(
                      date: 'Today',
                      amount: 'TZS 45,000',
                      status: 'Completed',
                      description: 'Dar es Salaam to Arusha delivery',
                    ),
                    _PaymentHistoryItem(
                      date: 'Yesterday',
                      amount: 'TZS 38,000',
                      status: 'Completed',
                      description: 'Mwanza to Dodoma delivery',
                    ),
                    _PaymentHistoryItem(
                      date: '2 days ago',
                      amount: 'TZS 52,000',
                      status: 'Completed',
                      description: 'Arusha to Dar es Salaam delivery',
                    ),
                    _PaymentHistoryItem(
                      date: '3 days ago',
                      amount: 'TZS 41,000',
                      status: 'Pending',
                      description: 'Dodoma to Mwanza delivery',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Withdrawal Options
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
                        Icon(Icons.account_balance_wallet, color: AppTheme.successGreen, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Withdrawal Options',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _WithdrawalOption(
                      title: 'Bank Transfer',
                      subtitle: 'Transfer to your bank account',
                      icon: Icons.account_balance,
                      onTap: () {},
                    ),
                    _WithdrawalOption(
                      title: 'Mobile Money',
                      subtitle: 'M-Pesa, Airtel Money, Tigo Pesa',
                      icon: Icons.phone_android,
                      onTap: () {},
                    ),
                    _WithdrawalOption(
                      title: 'Cash Pickup',
                      subtitle: 'Collect cash from our offices',
                      icon: Icons.location_on,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Payment Methods
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
                          'Payment Methods',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.add, color: AppTheme.successGreen),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _PaymentMethod(
                      title: 'M-Pesa',
                      subtitle: '0712 345 678',
                      icon: Icons.phone_android,
                      isDefault: true,
                    ),
                    _PaymentMethod(
                      title: 'Bank Account',
                      subtitle: 'CRDB Bank - 1234567890',
                      icon: Icons.account_balance,
                      isDefault: false,
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _EarningsBreakdownItem extends StatelessWidget {
  final String title;
  final String amount;
  final int percentage;
  final Color color;

  const _EarningsBreakdownItem({
    required this.title,
    required this.amount,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          amount,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _PaymentHistoryItem extends StatelessWidget {
  final String date;
  final String amount;
  final String status;
  final String description;

  const _PaymentHistoryItem({
    required this.date,
    required this.amount,
    required this.status,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.local_shipping,
              color: AppTheme.successGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.successGreen,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: status == 'Completed' 
                      ? AppTheme.successGreen.withOpacity(0.1)
                      : AppTheme.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: status == 'Completed' 
                        ? AppTheme.successGreen
                        : AppTheme.primaryOrange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WithdrawalOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _WithdrawalOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.successGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.successGreen, size: 20),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

class _PaymentMethod extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isDefault;

  const _PaymentMethod({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isDefault,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.successGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.successGreen, size: 20),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: isDefault
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Default',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.successGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : null,
    );
  }
} 