
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'shipment_details_page.dart';

class MyShipmentsPage extends StatefulWidget {
  const MyShipmentsPage({Key? key}) : super(key: key);

  @override
  State<MyShipmentsPage> createState() => _MyShipmentsPageState();
}

class _MyShipmentsPageState extends State<MyShipmentsPage> {
  String _searchTracking = '';
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final shipments = [
      {
        'trackingNumber': 'TRK123456',
        'parcelNumber': 'PCL987654',
        'date': '2024-06-01',
        'destination': 'Dar es Salaam',
        'receiver': 'Asha Mussa',
        'packageName': 'Electronics',
        'status': 'In Transit',
      },
      {
        'trackingNumber': 'TRK123457',
        'parcelNumber': 'PCL987655',
        'date': '2024-05-28',
        'destination': 'Arusha',
        'receiver': 'John Kimaro',
        'packageName': 'Documents',
        'status': 'Delivered',
      },
      {
        'trackingNumber': 'TRK123458',
        'parcelNumber': 'PCL987656',
        'date': '2024-05-25',
        'destination': 'Mwanza',
        'receiver': 'Mary Peter',
        'packageName': 'Clothes',
        'status': 'Pending Pickup',
      },
    ];

    final filteredShipments = shipments.where((shipment) {
      final matchesTracking = _searchTracking.isEmpty || shipment['trackingNumber']!.toLowerCase().contains(_searchTracking.toLowerCase());
      final matchesStatus = _selectedStatus == 'All' || shipment['status'] == _selectedStatus;
      return matchesTracking && matchesStatus;
    }).toList();

    Color statusColor(String status) {
      switch (status) {
        case 'Delivered':
          return AppTheme.successGreen;
        case 'In Transit':
          return AppTheme.primaryOrange;
        case 'Pending Pickup':
          return AppTheme.primaryDarkBlue;
        default:
          return AppTheme.primaryDarkBlue;
      }
    }

    IconData typeIcon(String type) {
      switch (type) {
        case 'Parcel':
          return Icons.inventory_2_rounded;
        case 'Document':
          return Icons.description_rounded;
        case 'Freight':
          return Icons.local_shipping_rounded;
        default:
          return Icons.local_offer_rounded;
      }
    }

    Color iconColor(String status, String type) {
      // Only blue or orange for icons
      if (status == 'Delivered' || status == 'Pending Pickup' || type == 'Freight') {
        return AppTheme.primaryOrange;
      } else {
        return AppTheme.primaryDarkBlue;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shipments'),
        backgroundColor: AppTheme.primaryDarkBlue,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search/filter section
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Search by Tracking Number',
                      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontFamily: 'Poppins', color: AppTheme.slate500),
                      prefixIcon: const Icon(Icons.search, color: AppTheme.primaryDarkBlue),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontFamily: 'Poppins'),
                    onChanged: (v) => setState(() => _searchTracking = v),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _selectedStatus,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'In Transit', child: Text('In Transit')),
                    DropdownMenuItem(value: 'Delivered', child: Text('Delivered')),
                    DropdownMenuItem(value: 'Pending Pickup', child: Text('Pending Pickup')),
                  ],
                  onChanged: (v) => setState(() => _selectedStatus = v ?? 'All'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontFamily: 'Poppins', color: AppTheme.primaryDarkBlue),
                  dropdownColor: Colors.white,
                  underline: Container(),
                  borderRadius: BorderRadius.circular(12),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'My Shipments',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.slate900,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: filteredShipments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 18),
                itemBuilder: (context, index) {
                  final shipment = filteredShipments[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 8,
                    color: Colors.white,
                    shadowColor: AppTheme.primaryDarkBlue.withOpacity(0.08),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.primaryDarkBlue.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Icon(
                              Icons.local_shipping_rounded,
                              color: AppTheme.primaryDarkBlue,
                              size: 38,
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            shipment['trackingNumber']!,
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontFamily: 'Poppins',
                                              color: AppTheme.primaryDarkBlue,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Tracking Number',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              fontFamily: 'Poppins',
                                              color: AppTheme.slate500,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(left: 8, top: 2),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: statusColor(shipment['status']!).withOpacity(0.13),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        shipment['status']!,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                          color: statusColor(shipment['status']!),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(Icons.confirmation_number, color: AppTheme.primaryDarkBlue, size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      shipment['parcelNumber']!,
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
                                    Icon(Icons.location_on, color: AppTheme.primaryOrange, size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      shipment['destination']!,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontFamily: 'Poppins',
                                        color: AppTheme.slate900,
                                      ),
                                    ),
                                    const SizedBox(width: 18),
                                    Icon(Icons.person, color: AppTheme.primaryDarkBlue, size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      shipment['receiver']!,
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
                                      shipment['packageName']!,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontFamily: 'Poppins',
                                        color: AppTheme.slate900,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
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
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => ShipmentDetailsPage(shipment: Map<String, String>.from(shipment)),
                                          ),
                                        );
                                      },
                                      child: const Text('View'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 