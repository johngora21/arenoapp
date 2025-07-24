import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AgentShipmentDetailsPage extends StatefulWidget {
  final Map<String, dynamic> shipment;
  const AgentShipmentDetailsPage({Key? key, required this.shipment}) : super(key: key);

  @override
  State<AgentShipmentDetailsPage> createState() => _AgentShipmentDetailsPageState();
}

class _AgentShipmentDetailsPageState extends State<AgentShipmentDetailsPage> {
  late List<Map<String, dynamic>> parcels;
  late List<String> allImages;
  late List<String> videos;
  final TextEditingController commentController = TextEditingController();
  bool isApproved = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    parcels = (widget.shipment['parcels'] as List<dynamic>? ?? []).map((e) => Map<String, dynamic>.from(e)).toList();
    allImages = [
      ...List<String>.from(widget.shipment['images'] ?? []),
      ...parcels.map((p) => p['image']).whereType<String>()
    ];
    videos = List<String>.from(widget.shipment['videos'] ?? []);
    isApproved = widget.shipment['status'] == 'Approved';
  }

  void _scanParcel(int idx) {
    setState(() {
      parcels[idx]['scanned'] = true;
    });
  }

  void _approveParcel(int idx) {
    setState(() {
      parcels[idx]['approved'] = true;
    });
  }

  void _approveAll() {
    setState(() {
      isApproved = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Package marked as Arrived/Received!')),
    );
  }

  Future<void> _updateShipmentStatus(String newStatus) async {
    setState(() { isLoading = true; });
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    // Here you would call your backend API, e.g.:
    // await BackendService.updateShipmentStatus(widget.shipment['id'], newStatus);
    // For now, we just simulate success and update local state
    setState(() {
      isApproved = true;
      isLoading = false;
      widget.shipment['status'] = 'Received by Agent';
    });
    // Simulate SMS notification (in real app, backend handles this)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Package marked as Received by Agent! SMS sent to sender and receiver.')),
    );
  }

  void _scanParcelByBarcode(String barcode) {
    final idx = parcels.indexWhere((p) => p['barcode'] == barcode);
    if (idx != -1) {
      if (parcels[idx]['scanned'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Parcel $barcode already scanned.')),
        );
      } else {
        setState(() {
          parcels[idx]['scanned'] = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Parcel $barcode scanned!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Parcel $barcode not found in this shipment.')),
      );
    }
  }

  void _showScanDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Scan Parcel'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter or scan barcode'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _scanParcelByBarcode(controller.text.trim());
            },
            child: const Text('Scan'),
          ),
        ],
      ),
    );
  }

  bool isParcelApproved(dynamic approved) {
    return approved == true || approved == 'true';
  }

  @override
  Widget build(BuildContext context) {
    final String status = (widget.shipment['status'] ?? '').toString();
    final bool isPendingOrArrived = status == 'Pending' || status == 'Arrived';
    final bool isApprovedStatus = status == 'Approved';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipment Details'),
        backgroundColor: AppTheme.primaryDarkBlue,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.slateGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. General Details
                Row(
                  children: [
                    Text('ID: ', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                    Text(widget.shipment['packageNumber'], style: Theme.of(context).textTheme.bodyLarge),
                    const Spacer(),
                    _typeChip(context, widget.shipment['type']),
                  ],
                ),
                const SizedBox(height: 8),
                _detailRow(context, 'Tracking Number', widget.shipment['id']),
                _detailRow(context, 'Sender', widget.shipment['sender']),
                _detailRow(context, 'Receiver', widget.shipment['receiver']),
                _detailRow(context, 'Sender Location', widget.shipment['senderLocation']),
                _detailRow(context, 'Receiver Location', widget.shipment['receiverLocation']),
                _detailRow(context, 'Category', widget.shipment['category']),
                _detailRow(context, 'Status', status),
                _detailRow(context, 'Amount', widget.shipment['amount']),
                if (widget.shipment['escrow']) _detailRow(context, 'Business Escrow', 'Yes'),
                const SizedBox(height: 16),
                Text('Other Details:', style: Theme.of(context).textTheme.bodyMedium),
                Text(widget.shipment['details'] ?? '-', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 24),
                // 2. Scan Parcel Button (only if pending/arrived)
                if (parcels.isNotEmpty && isPendingOrArrived) ...[
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan Parcel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        textStyle: Theme.of(context).textTheme.titleMedium,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _showScanDialog,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                // 3. Parcels section
                if (parcels.isNotEmpty) ...[
                  Text('Parcels in this Package', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...parcels.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final parcel = entry.value;
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.qr_code, color: AppTheme.primaryBlue),
                                const SizedBox(width: 8),
                                Text('Barcode: ${parcel['barcode']}', style: Theme.of(context).textTheme.bodyMedium),
                                const Spacer(),
                                // Switch for seen/verified
                                if (!isApprovedStatus && !isParcelApproved(parcel['approved']))
                                  Row(
                                    children: [
                                      Text('Verified', style: Theme.of(context).textTheme.bodySmall),
                                      Switch(
                                        value: parcel['verified'] == true,
                                        onChanged: (val) {
                                          setState(() {
                                            parcel['verified'] = val;
                                          });
                                        },
                                        activeColor: AppTheme.successGreen,
                                      ),
                                    ],
                                  ),
                                if (parcel['approved'] == true)
                                  const Icon(Icons.verified, color: AppTheme.successGreen)
                                // Removed per-item Approve button
                              ],
                            ),
                            const SizedBox(height: 6),
                            if (parcel['image'] != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  parcel['image'],
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => Container(
                                    width: 90,
                                    height: 90,
                                    color: AppTheme.slate200,
                                    child: const Icon(Icons.broken_image, color: AppTheme.slate400),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 6),
                            Text('Name: ${parcel['name'] ?? '-'}', style: Theme.of(context).textTheme.bodySmall),
                            Text('Category: ${parcel['category'] ?? '-'}', style: Theme.of(context).textTheme.bodySmall),
                            Text('Quantity: ${parcel['quantity'] ?? '-'}', style: Theme.of(context).textTheme.bodySmall),
                            Text('Value: ${parcel['value'] ?? '-'}', style: Theme.of(context).textTheme.bodySmall),
                            if (parcel['description'] != null)
                              Text('Description: ${parcel['description']}', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
                // 4. Approve button (for Pending/Arrived, routes to next stage)
                if (!isApproved && isPendingOrArrived)
                  Center(
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                      icon: const Icon(Icons.verified),
                            label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        textStyle: Theme.of(context).textTheme.titleMedium,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                            onPressed: () async {
                              setState(() { isLoading = true; });
                              await Future.delayed(const Duration(seconds: 1));
                              String newStatus = status == 'Pending' ? 'Arrived' : 'Approved';
                              setState(() {
                                widget.shipment['status'] = newStatus;
                                isApproved = newStatus == 'Approved';
                                isLoading = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Shipment status updated to $newStatus.')),
                              );
                            },
                    ),
                  ),
                const SizedBox(height: 24),
                // 5. Comment box
                Text('Agent Comment', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: 'Write a comment...',
                          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.slate300),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        minLines: 1,
                        maxLines: 3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        commentController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Comment submitted!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      ),
                      child: const Icon(Icons.send),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }

  Widget _typeChip(BuildContext context, String type) {
    final isBusiness = type.toLowerCase() == 'business';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isBusiness ? AppTheme.successGreen.withOpacity(0.15) : AppTheme.primaryBlue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: isBusiness ? AppTheme.successGreen : AppTheme.primaryBlue,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
} 