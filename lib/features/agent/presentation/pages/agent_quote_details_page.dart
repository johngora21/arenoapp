import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'agent_register_shipment_page.dart';
import 'agent_main_shell.dart';

class AgentQuoteDetailsPage extends StatelessWidget {
  final Map<String, dynamic> quote;
  final VoidCallback onMarkAsPaid;
  final VoidCallback onDelete;
  const AgentQuoteDetailsPage({Key? key, required this.quote, required this.onMarkAsPaid, required this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = quote['items'] as List<Map<String, dynamic>>? ?? [];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => AgentMainShell()),
              );
            }
          },
        ),
        title: const Text('Quote Details'),
        backgroundColor: AppTheme.primaryDarkBlue,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.slateGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.pending_actions, color: AppTheme.primaryOrange),
                            const SizedBox(width: 8),
                            Text('Quote ID: ${quote['id']}', style: Theme.of(context).textTheme.titleMedium),
                            const Spacer(),
                            Text('TZS ${quote['amount']}', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.primaryDarkBlue)),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete',
                              onPressed: () {
                                onDelete();
                                Navigator.of(context).pop('deleted');
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _detailRow(context, 'Customer', quote['customer']),
                        _detailRow(context, 'Item', quote['item']),
                        _detailRow(context, 'Status', quote['status']),
                        _detailRow(context, 'Amount', 'TZS ${quote['amount']}'),
                        if (quote['details'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Other Details:', style: Theme.of(context).textTheme.bodyMedium),
                                Text(quote['details'], style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (items.isNotEmpty) ...[
                  Text('Items in this Quote', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...items.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item['image'] != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item['image'],
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
                            Text('Name: ${item['name'] ?? '-'}', style: Theme.of(context).textTheme.bodySmall),
                            Text('Category: ${item['category'] ?? '-'}', style: Theme.of(context).textTheme.bodySmall),
                            Text('Quantity: ${item['quantity'] ?? '-'}', style: Theme.of(context).textTheme.bodySmall),
                            Text('Value: ${item['value'] ?? '-'}', style: Theme.of(context).textTheme.bodySmall),
                            if (item['description'] != null)
                              Text('Description: ${item['description']}', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        // TODO: Implement edit functionality
                      },
                      label: const Text('Edit'),
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
          SizedBox(width: 110, child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
} 