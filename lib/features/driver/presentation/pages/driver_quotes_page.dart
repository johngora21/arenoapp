import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/beem_sms_service.dart';

class DriverQuotesPage extends StatelessWidget {
  const DriverQuotesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Not logged in'));
    }
    final quotesStream = FirebaseFirestore.instance
        .collection('quotes')
        .where('driverId', isEqualTo: user.uid)
        .snapshots();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Quotes'),
        backgroundColor: AppTheme.successGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.slateGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: StreamBuilder<QuerySnapshot>(
            stream: quotesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No pending quotes.', style: Theme.of(context).textTheme.bodyLarge));
              }
              final pendingQuotes = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
              return ListView.separated(
                itemCount: pendingQuotes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, idx) {
                  final q = pendingQuotes[idx];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => DriverQuoteDetailsPage(quote: q),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.pending_actions, color: AppTheme.successGreen),
                                const SizedBox(width: 8),
                                Text('Quote ID: ${q['quoteId']}', style: Theme.of(context).textTheme.bodyLarge),
                                const Spacer(),
                                Text(q['amount'], style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.successGreen)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Customer: ${q['customer']}', style: Theme.of(context).textTheme.bodyMedium),
                            Text('Item: ${q['item']}', style: Theme.of(context).textTheme.bodyMedium),
                            Text('Details: ${q['details']}', style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.successGreen,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () async {
                                    final phone = q['receiverPhone'] ?? '';
                                    final message = 'Your quote ${q['quoteId'] ?? ''} has been approved and is ready for payment.';
                                    await BeemSmsService.sendSms(phone: phone, message: message);
                                  },
                                  child: const Text('Click to Pay'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class DriverQuoteDetailsPage extends StatelessWidget {
  final Map<String, dynamic> quote;
  const DriverQuoteDetailsPage({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> parcels = quote['items'] ?? [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quote Details'),
        backgroundColor: AppTheme.successGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            tooltip: 'Delete Quote',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Quote'),
                  content: const Text('Are you sure you want to delete this quote?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                // TODO: Add Firestore delete logic here if needed
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Quote deleted.')),
                );
              }
            },
          ),
        ],
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
                _detailRow('Type', quote['serviceType'] ?? 'Courier'),
                _detailRow('Status', quote['status'] ?? '-', color: _statusColor(quote['status'] ?? '')),
              ],
            ),
            _sectionCard(
              context,
              title: 'Sender Information',
              children: [
                _detailRow('Name', quote['sender'] ?? quote['senderName'] ?? '-'),
                _detailRow('Phone', quote['senderPhone'] ?? '-'),
                _detailRow('Email', quote['senderEmail'] ?? '-'),
              ],
            ),
            _sectionCard(
              context,
              title: 'Receiver Information',
              children: [
                _detailRow('Name', quote['receiver'] ?? quote['receiverName'] ?? '-'),
                _detailRow('Phone', quote['receiverPhone'] ?? '-'),
                _detailRow('Email', quote['receiverEmail'] ?? '-'),
              ],
            ),
            _sectionCard(
              context,
              title: 'Pickup Details',
              children: [
                _detailRow('Pickup Address', quote['pickupAddress'] ?? '-'),
              ],
            ),
            _sectionCard(
              context,
              title: 'Delivery Details',
              children: [
                _detailRow('Delivery Address', quote['destination'] ?? quote['deliveryAddress'] ?? '-'),
              ],
            ),
            if ((quote['businessName'] ?? '').isNotEmpty || (quote['businessType'] ?? '').isNotEmpty)
              _sectionCard(
                context,
                title: 'Business Info',
                children: [
                  _detailRow('Business Name', quote['businessName'] ?? '-'),
                  _detailRow('Business Type', quote['businessType'] ?? '-'),
                  _detailRow('Business Address', quote['businessAddress'] ?? '-'),
                  _detailRow('Contact', quote['businessContact'] ?? '-'),
                ],
              ),
            if ((quote['paymentType'] ?? '').isNotEmpty || (quote['paymentProvider'] ?? '').isNotEmpty)
              _sectionCard(
                context,
                title: 'Payment Info',
                children: [
                  _detailRow('Payment Type', quote['paymentType'] ?? '-'),
                  _detailRow('Provider', quote['paymentProvider'] ?? '-'),
                  _detailRow('Account Number', quote['accountNumber'] ?? '-'),
                  _detailRow('Account Name', quote['accountName'] ?? '-'),
                ],
              ),
            if ((quote['instructions'] ?? quote['notes'] ?? '').isNotEmpty)
              _sectionCard(
                context,
                title: 'Additional Instructions',
                children: [
                  _detailRow('Instructions', quote['instructions'] ?? quote['notes'] ?? '-'),
                ],
              ),
            const SizedBox(height: 18),
            Text('Parcels in Package', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
            const SizedBox(height: 8),
            if (parcels.isNotEmpty)
              ...parcels.map((parcel) => _ParcelCard(parcel: parcel)).toList()
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('No parcels in package', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.slate400)),
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
            Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
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
        return AppTheme.primaryBlue;
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
                child: const Icon(Icons.inventory, color: AppTheme.primaryBlue, size: 32),
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