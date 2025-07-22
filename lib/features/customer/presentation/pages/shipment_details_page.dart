import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ShipmentDetailsPage extends StatelessWidget {
  final Map<String, String> shipment;
  const ShipmentDetailsPage({Key? key, required this.shipment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipment Details'),
        backgroundColor: AppTheme.primaryOrange,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 8,
          color: Colors.white,
          shadowColor: AppTheme.primaryBlue.withOpacity(0.08),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Icon(
                      Icons.local_shipping_rounded,
                      color: AppTheme.primaryBlue,
                      size: 38,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _sectionHeader(context, 'Service Type'),
                _detailRow('Type', shipment['serviceType'] ?? 'Courier'),
                const SizedBox(height: 16),
                _sectionHeader(context, 'Sender Information'),
                _detailRow('Name', shipment['senderName'] ?? '-'),
                _detailRow('Phone', shipment['senderPhone'] ?? '-'),
                _detailRow('Email', shipment['senderEmail'] ?? '-'),
                const SizedBox(height: 16),
                _sectionHeader(context, 'Receiver Information'),
                _detailRow('Name', shipment['receiver'] ?? shipment['receiverName'] ?? '-'),
                _detailRow('Phone', shipment['receiverPhone'] ?? '-'),
                _detailRow('Email', shipment['receiverEmail'] ?? '-'),
                const SizedBox(height: 16),
                _sectionHeader(context, 'Pickup Details'),
                _detailRow('Pickup Address', shipment['pickupAddress'] ?? '-'),
                const SizedBox(height: 16),
                _sectionHeader(context, 'Delivery Details'),
                _detailRow('Delivery Address', shipment['destination'] ?? shipment['deliveryAddress'] ?? '-'),
                const SizedBox(height: 16),
                _sectionHeader(context, 'Package Details'),
                _detailRow('Tracking Number', shipment['trackingNumber'] ?? '-'),
                _detailRow('Parcel Number', shipment['parcelNumber'] ?? '-'),
                _detailRow('Package Name', shipment['packageName'] ?? '-'),
                _detailRow('Description', shipment['packageDescription'] ?? '-'),
                _detailRow('Category', shipment['category'] ?? '-'),
                _detailRow('Quantity', shipment['quantity'] ?? '-'),
                _detailRow('Value', shipment['value'] ?? '-'),
                _detailRow('Status', shipment['status'] ?? '-', color: _statusColor(shipment['status'] ?? '')),
                _detailRow('Date', shipment['date'] ?? '-'),
                const SizedBox(height: 16),
                _sectionHeader(context, 'Additional Instructions'),
                _detailRow('Instructions', shipment['instructions'] ?? shipment['notes'] ?? '-'),
                const SizedBox(height: 16),
                _sectionHeader(context, 'Business Info'),
                _detailRow('Business Name', shipment['businessName'] ?? '-'),
                _detailRow('Business Type', shipment['businessType'] ?? '-'),
                _detailRow('Business Address', shipment['businessAddress'] ?? '-'),
                _detailRow('Contact', shipment['businessContact'] ?? '-'),
                const SizedBox(height: 16),
                _sectionHeader(context, 'Payment Info'),
                _detailRow('Payment Type', shipment['paymentType'] ?? '-'),
                _detailRow('Provider', shipment['paymentProvider'] ?? '-'),
                _detailRow('Account Number', shipment['accountNumber'] ?? '-'),
                _detailRow('Account Name', shipment['accountName'] ?? '-'),
                const SizedBox(height: 24),
                _sectionHeader(context, 'Images'),
                const SizedBox(height: 12),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.slate100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text('No images uploaded', style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Poppins', color: AppTheme.slate400)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: AppTheme.slate900)),
    );
  }

  Widget _detailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.w500, color: AppTheme.slate500)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: color ?? AppTheme.slate900)),
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
        return AppTheme.primaryBlue;
      default:
        return AppTheme.slate900;
    }
  }
} 