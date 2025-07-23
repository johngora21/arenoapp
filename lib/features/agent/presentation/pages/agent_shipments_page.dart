import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/agent_drawer.dart';
import 'agent_shipment_details_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AgentShipmentsPage extends StatefulWidget {
  const AgentShipmentsPage({Key? key}) : super(key: key);

  @override
  State<AgentShipmentsPage> createState() => _AgentShipmentsPageState();
}

class _AgentShipmentsPageState extends State<AgentShipmentsPage> {
  final CollectionReference shipmentsRef = FirebaseFirestore.instance.collection('shipments');
  List<Map<String, dynamic>> shipments = [];
  Stream<QuerySnapshot>? shipmentsStream;

  bool isLoading = false;
  String filter = 'Pending';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      shipmentsStream = shipmentsRef.where('agentId', isEqualTo: user.uid).snapshots();
      shipmentsStream!.listen((snapshot) {
        setState(() {
          shipments = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        });
      });
    }
  }

  void _simulateScan(int index) async {
    setState(() { isLoading = true; });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      shipments[index]['status'] = 'Arrived';
      isLoading = false;
    });
  }

  List<Map<String, dynamic>> get filteredShipments {
    List<Map<String, dynamic>> filtered = shipments;
    if (filter != 'All') {
      filtered = filtered.where((s) => s['status'] == filter).toList();
    }
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((s) =>
        s['id'].toString().toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipments'),
        backgroundColor: AppTheme.successGreen,
        elevation: 0,
      ),
      drawer: AgentDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.slateGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('All Shipments', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                // Search bar on top
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Search by Tracking/Parcel Number',
                    labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.slate400, fontWeight: FontWeight.w400),
                    prefixIcon: const Icon(Icons.search, color: AppTheme.slate400),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'e.g. QR123456',
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.slate300, fontWeight: FontWeight.w300),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.slate700, fontWeight: FontWeight.w500),
                  onChanged: (v) => setState(() => searchQuery = v),
                ),
                const SizedBox(height: 12),
                // Filter buttons with horizontal scroll
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterButton('Pending', AppTheme.primaryOrange),
                      const SizedBox(width: 8),
                      _buildFilterButton('Arrived', AppTheme.primaryBlue),
                      const SizedBox(width: 8),
                      _buildFilterButton('Approved', AppTheme.successGreen),
                      const SizedBox(width: 8),
                      _buildFilterButton('All', AppTheme.successGreen),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (isLoading) const Center(child: CircularProgressIndicator()),
                Expanded(
                  child: ListView.separated(
                    itemCount: filteredShipments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final s = filteredShipments[idx];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    s['escrow'] ? Icons.business_center : Icons.inbox,
                                    color: s['escrow'] ? AppTheme.successGreen : AppTheme.primaryBlue,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text('ID: ${s['packageNumber']}', style: Theme.of(context).textTheme.bodyLarge),
                                  ),
                                  _typeChip(s['type']),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 32, top: 2, bottom: 2),
                                child: Text('Tracking Number: ${s['id']}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.slate700)),
                              ),
                              const SizedBox(height: 4),
                              Text('Receiver: ${s['receiver']}', style: Theme.of(context).textTheme.bodyMedium),
                              Text('From: ${s['senderLocation']}  →  To: ${s['receiverLocation']}', style: Theme.of(context).textTheme.bodySmall),
                              Text('Category: ${s['category']}', style: Theme.of(context).textTheme.bodySmall),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (ctx) => AgentShipmentDetailsPage(shipment: s),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.successGreen,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                    ),
                                    child: const Text('View More'),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label, Color color) {
    final bool selected = filter == label;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? color : color.withOpacity(0.18),
        foregroundColor: selected ? Colors.white : color,
        elevation: selected ? 3 : 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      onPressed: () {
        setState(() {
          filter = label;
        });
      },
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : color,
            ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
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

  Widget _typeChip(String type) {
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