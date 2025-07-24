import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ShipmentDetailsPage extends StatelessWidget {
  // Use dynamic for mock demonstration
  final Map<String, dynamic>? shipment;
  const ShipmentDetailsPage({Key? key, this.shipment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock data for demonstration if shipment is not provided
    final Map<String, dynamic> data = shipment ?? {
      'serviceType': 'courier',
      'status': 'Pending Payment',
      'sender': 'Asha Mussa',
      'senderPhone': '+255 700 123 456',
      'senderEmail': 'asha@email.com',
      'receiver': 'John Doe',
      'receiverPhone': '+255 700 654 321',
      'receiverEmail': 'john@email.com',
      'pickupAddress': '123 Main St, Dar es Salaam',
      'deliveryAddress': '456 Arusha Ave, Arusha',
      'businessName': 'Asha Electronics',
      'businessType': 'Retail',
      'businessAddress': 'Market St, Dar',
      'businessContact': '+255 700 123 456',
      'paymentType': 'Mobile Money',
      'paymentProvider': 'M-Pesa',
      'accountNumber': '123456789',
      'accountName': 'Asha Mussa',
      'instructions': 'Handle with care. Call before delivery.',
      'items': [
        {
          'name': 'Laptop',
          'category': 'Electronics',
          'description': 'Dell XPS 13',
          'quantity': '1',
          'value': 'TZS 2,000,000',
          'image': null,
        },
        {
          'name': 'Phone',
          'category': 'Electronics',
          'description': 'iPhone 13 Pro',
          'quantity': '2',
          'value': 'TZS 1,200,000',
          'image': null,
        },
      ],
    };
    final List<dynamic> parcels = data['items'] ?? [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipment Details'),
        backgroundColor: AppTheme.successGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionCard(
              context,
              title: 'Service Type',
              children: [
                _detailRow('Type', data['serviceType'] ?? 'Courier'),
                _detailRow('Status', data['status'] ?? '-', color: _statusColor(data['status'] ?? '')),
              ],
            ),
            _sectionCard(
              context,
              title: 'Sender Information',
              children: [
                _detailRow('Name', data['sender'] ?? '-'),
                _detailRow('Phone', data['senderPhone'] ?? '-'),
                _detailRow('Email', data['senderEmail'] ?? '-'),
              ],
            ),
            _sectionCard(
              context,
              title: 'Receiver Information',
              children: [
                _detailRow('Name', data['receiver'] ?? '-'),
                _detailRow('Phone', data['receiverPhone'] ?? '-'),
                _detailRow('Email', data['receiverEmail'] ?? '-'),
              ],
            ),
            _sectionCard(
              context,
              title: 'Pickup Details',
              children: [
                _detailRow('Pickup Address', data['pickupAddress'] ?? '-'),
              ],
            ),
            _sectionCard(
              context,
              title: 'Delivery Details',
              children: [
                _detailRow('Delivery Address', data['deliveryAddress'] ?? '-'),
              ],
            ),
            if ((data['businessName'] ?? '').isNotEmpty || (data['businessType'] ?? '').isNotEmpty)
              _sectionCard(
                context,
                title: 'Business Info',
                children: [
                  _detailRow('Business Name', data['businessName'] ?? '-'),
                  _detailRow('Business Type', data['businessType'] ?? '-'),
                  _detailRow('Business Address', data['businessAddress'] ?? '-'),
                  _detailRow('Contact', data['businessContact'] ?? '-'),
                ],
              ),
            if ((data['paymentType'] ?? '').isNotEmpty || (data['paymentProvider'] ?? '').isNotEmpty)
              _sectionCard(
                context,
                title: 'Payment Info',
                children: [
                  _detailRow('Payment Type', data['paymentType'] ?? '-'),
                  _detailRow('Provider', data['paymentProvider'] ?? '-'),
                  _detailRow('Account Number', data['accountNumber'] ?? '-'),
                  _detailRow('Account Name', data['accountName'] ?? '-'),
                ],
              ),
            if ((data['instructions'] ?? '').isNotEmpty)
              _sectionCard(
                context,
                title: 'Additional Instructions',
                children: [
                  _detailRow('Instructions', data['instructions'] ?? '-'),
                ],
              ),
            const SizedBox(height: 18),
            Text('Parcels in Package', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.successGreen)),
            const SizedBox(height: 8),
            if (parcels.isNotEmpty)
              ...parcels.map((parcel) => _ParcelCard(parcel: parcel)).toList()
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('No parcels in package', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.slate400)),
              ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  textStyle: Theme.of(context).textTheme.titleMedium,
                ),
                onPressed: () {},
                child: const Text('Click to Pay'),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _sectionCard(BuildContext context, {required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.successGreen)),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: AppTheme.slate500)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: color ?? AppTheme.slate900)),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Delivered':
        return AppTheme.successGreen;
      case 'In Transit':
        return AppTheme.primaryOrange;
      case 'Pending Pickup':
        return AppTheme.successGreen;
      default:
        return AppTheme.slate900;
    }
  }
}

class _ParcelCard extends StatelessWidget {
  final Map<String, dynamic> parcel;
  const _ParcelCard({required this.parcel});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      color: AppTheme.slate100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (parcel['image'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  parcel['image'],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.slate200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.inventory, color: AppTheme.successGreen, size: 32),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(parcel['name'] ?? '', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  Text('Category: ${parcel['category'] ?? ''}', style: Theme.of(context).textTheme.bodyMedium),
                  if (parcel['description'] != null && parcel['description'].toString().isNotEmpty)
                    Text('Description: ${parcel['description']}', style: Theme.of(context).textTheme.bodyMedium),
                  Text('Quantity: ${parcel['quantity'] ?? ''}', style: Theme.of(context).textTheme.bodyMedium),
                  Text('Value: ${parcel['value'] ?? ''}', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 