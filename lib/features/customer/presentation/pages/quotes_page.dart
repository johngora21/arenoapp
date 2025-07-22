import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class QuotesPage extends StatelessWidget {
  const QuotesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final quotes = [
      {
        'serviceType': 'Courier',
        'date': '2024-06-01',
        'destination': 'Dar es Salaam',
        'packageName': 'Electronics',
        'status': 'Pending',
        'quotedPrice': 'TZS 120,000',
      },
      {
        'serviceType': 'Freight',
        'date': '2024-05-28',
        'destination': 'Arusha',
        'packageName': 'Furniture',
        'status': 'Approved',
        'quotedPrice': 'TZS 350,000',
      },
      {
        'serviceType': 'Moving',
        'date': '2024-05-25',
        'destination': 'Mwanza',
        'packageName': 'Household Items',
        'status': 'Rejected',
        'quotedPrice': 'TZS 500,000',
      },
    ];

    Color statusColor(String status) {
      switch (status) {
        case 'Approved':
          return Colors.green;
        case 'Rejected':
          return Colors.red;
        case 'Pending':
        default:
          return AppTheme.primaryOrange;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quotations'),
        backgroundColor: AppTheme.primaryDarkBlue,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView.separated(
          itemCount: quotes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 18),
          itemBuilder: (context, index) {
            final quote = quotes[index];
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 8,
              color: Colors.white,
              shadowColor: AppTheme.primaryDarkBlue.withOpacity(0.08),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.request_quote, color: AppTheme.primaryOrange, size: 32),
                        const SizedBox(width: 12),
                        Text(
                          quote['serviceType']!,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontFamily: 'Poppins',
                            color: AppTheme.primaryDarkBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryDarkBlue.withOpacity(0.13),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            quote['status']!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              color: statusColor(quote['status']!),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: AppTheme.primaryDarkBlue, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          quote['date']!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Poppins',
                            color: AppTheme.slate900,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Icon(Icons.location_on, color: AppTheme.primaryOrange, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          quote['destination']!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Poppins',
                            color: AppTheme.slate900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.inventory_2_rounded, color: AppTheme.primaryDarkBlue, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          quote['packageName']!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Poppins',
                            color: AppTheme.slate900,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          quote['quotedPrice']!,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontFamily: 'Poppins',
                            color: AppTheme.primaryOrange,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.edit, size: 18),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppTheme.primaryDarkBlue),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontFamily: 'Poppins', fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () {},
                          label: const Text('Edit'),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          icon: Icon(Icons.delete, color: AppTheme.errorRed),
                          tooltip: 'Delete',
                          onPressed: () {},
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                            textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontFamily: 'Poppins', fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () {},
                          child: const Text('Proceed'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
} 