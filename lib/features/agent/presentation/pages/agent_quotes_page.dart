import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'agent_main_shell.dart';
import 'agent_quote_details_page.dart';

class AgentQuotesPage extends StatefulWidget {
  const AgentQuotesPage({Key? key}) : super(key: key);

  @override
  State<AgentQuotesPage> createState() => _AgentQuotesPageState();
}

class _AgentQuotesPageState extends State<AgentQuotesPage> {
  // Mock pending quotes data
  List<Map<String, dynamic>> pendingQuotes = [
    {
      'id': 'Q001',
      'customer': 'John Doe',
      'item': 'Electronics Package',
      'amount': 120000,
      'status': 'pending',
      'details': '2x Laptop, 1x Phone',
      'items': [
        {
          'name': 'Laptop',
          'category': 'Electronics',
          'quantity': '2',
          'value': '100000',
          'description': 'Dell XPS 13',
          'image': 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308',
        },
        {
          'name': 'Phone',
          'category': 'Electronics',
          'quantity': '1',
          'value': '20000',
          'description': 'iPhone 12',
          'image': 'https://images.unsplash.com/photo-1516979187457-637abb4f9353',
        },
      ],
    },
    {
      'id': 'Q002',
      'customer': 'Alice',
      'item': 'Clothing Box',
      'amount': 30000,
      'status': 'pending',
      'details': '5x Shirt, 2x Jeans',
      'items': [
        {
          'name': 'Shirt',
          'category': 'Clothing',
          'quantity': '5',
          'value': '20000',
          'description': 'Cotton shirts',
          'image': 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308',
        },
        {
          'name': 'Jeans',
          'category': 'Clothing',
          'quantity': '2',
          'value': '10000',
          'description': 'Blue jeans',
          'image': 'https://images.unsplash.com/photo-1516979187457-637abb4f9353',
        },
      ],
    },
  ];

  void _markAsPaid(int idx) {
    final quote = pendingQuotes[idx];
    setState(() {
      pendingQuotes.removeAt(idx);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment received for ${quote['item']}. Item moved to pending shipments.')),
    );
    // TODO: Actually move to pending shipments in backend
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => AgentMainShell()),
            );
          },
        ),
        title: const Text('Quotes'),
        backgroundColor: AppTheme.primaryDarkBlue,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.slateGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: pendingQuotes.isEmpty
              ? Center(
                  child: Text('No pending quotes.', style: Theme.of(context).textTheme.bodyLarge),
                )
              : ListView.separated(
                  itemCount: pendingQuotes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, idx) {
                    final q = pendingQuotes[idx];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => AgentQuoteDetailsPage(
                                quote: q,
                                onMarkAsPaid: () => _markAsPaid(idx),
                                onDelete: () {
                                  setState(() {
                                    pendingQuotes.removeAt(idx);
                                  });
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Quote deleted.')),
                                  );
                                },
                              ),
                            ),
                          );
                          if (result == 'paid') _markAsPaid(idx);
                          if (result == 'deleted') {
                            setState(() {
                              pendingQuotes.removeAt(idx);
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.pending_actions, color: AppTheme.primaryOrange),
                                  const SizedBox(width: 8),
                                  Text('Quote ID: ${q['id']}', style: Theme.of(context).textTheme.bodyLarge),
                                  const Spacer(),
                                  Text('TZS ${q['amount']}', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.primaryDarkBlue)),
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
                                      backgroundColor: AppTheme.primaryOrange,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () => _markAsPaid(idx),
                                    child: const Text('Mark as Paid'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
} 