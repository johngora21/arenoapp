import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class DriverShipmentsPage extends StatefulWidget {
  const DriverShipmentsPage({super.key});

  @override
  State<DriverShipmentsPage> createState() => _DriverShipmentsPageState();
}

class _DriverShipmentsPageState extends State<DriverShipmentsPage> {
  String selectedFilter = 'Pending';
  final List<String> filters = ['Pending', 'Active', 'Completed', 'All'];

  // Mock shipment data
  final List<Map<String, dynamic>> shipments = [
    {
      'route': 'Dar es Salaam → Arusha',
      'status': 'Active',
      'pickup': 'Dar es Salaam Airport',
      'dropoff': 'Arusha City Center',
      'customer': 'Asha Mussa',
      'fare': 'TZS 45,000',
      'time': '2 hours',
    },
    {
      'route': 'Mwanza → Dodoma',
      'status': 'Completed',
      'pickup': 'Mwanza Port',
      'dropoff': 'Dodoma Capital',
      'customer': 'John Mwangi',
      'fare': 'TZS 38,000',
      'time': 'Delivered',
    },
    {
      'route': 'Arusha → Dar es Salaam',
      'status': 'Pending',
      'pickup': 'Arusha Airport',
      'dropoff': 'Dar es Salaam Port',
      'customer': 'Sarah Kimani',
      'fare': 'TZS 52,000',
      'time': 'Pending',
    },
    {
      'route': 'Dodoma → Mwanza',
      'status': 'Completed',
      'pickup': 'Dodoma Central',
      'dropoff': 'Mwanza Port',
      'customer': 'Michael Ochieng',
      'fare': 'TZS 41,000',
      'time': 'Delivered',
    },
    {
      'route': 'Dar es Salaam → Mwanza',
      'status': 'Completed',
      'pickup': 'Dar es Salaam City',
      'dropoff': 'Mwanza Airport',
      'customer': 'Grace Wanjiku',
      'fare': 'TZS 48,000',
      'time': 'Delivered',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredShipments = selectedFilter == 'All'
        ? shipments
        : shipments.where((s) => s['status'] == selectedFilter).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipments'),
        backgroundColor: AppTheme.successGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filters.map((filter) {
                  bool isSelected = selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFilter = filter;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.successGreen : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppTheme.successGreen : Colors.grey[300]!,
                          ),
                        ),
                        child: Text(
                          filter,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isSelected ? Colors.white : Colors.grey[600],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Shipments List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredShipments.length,
              itemBuilder: (context, i) {
                final s = filteredShipments[i];
                return _ShipmentCard(
                  route: s['route'],
                  status: s['status'],
                  pickup: s['pickup'],
                  dropoff: s['dropoff'],
                  customer: s['customer'],
                  fare: s['fare'],
                  time: s['time'],
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ShipmentCard extends StatelessWidget {
  final String route;
  final String status;
  final String pickup;
  final String dropoff;
  final String customer;
  final String fare;
  final String time;
  final VoidCallback onTap;

  const _ShipmentCard({
    required this.route,
    required this.status,
    required this.pickup,
    required this.dropoff,
    required this.customer,
    required this.fare,
    required this.time,
    required this.onTap,
  });

  Color _getStatusColor() {
    switch (status) {
      case 'Active':
        return AppTheme.primaryOrange;
      case 'Completed':
        return AppTheme.successGreen;
      case 'Pending':
        return AppTheme.primaryBlue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case 'Active':
        return Icons.local_shipping;
      case 'Completed':
        return Icons.check_circle;
      case 'Pending':
        return Icons.schedule;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getStatusIcon(),
                      color: _getStatusColor(),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            status,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _getStatusColor(),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    fare,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.successGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Pickup and Dropoff
              Row(
                children: [
                  Icon(Icons.location_pin, color: AppTheme.primaryOrange, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pickup,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.flag, color: AppTheme.successGreen, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dropoff,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Customer
              Row(
                children: [
                  Icon(Icons.person, color: AppTheme.primaryBlue, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      customer,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Icon(Icons.timer, color: AppTheme.primaryOrange, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    time,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryOrange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 