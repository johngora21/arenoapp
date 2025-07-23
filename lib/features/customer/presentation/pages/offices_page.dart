import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:latlong2/latlong.dart' as latlng2;
import '../../../../core/theme/app_theme.dart';

class OfficesPage extends StatefulWidget {
  const OfficesPage({Key? key}) : super(key: key);

  @override
  State<OfficesPage> createState() => _OfficesPageState();
}

class _OfficesPageState extends State<OfficesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedLocation = 'All';

  // Dummy data for agents/branches
  final List<Map<String, String>> _offices = [
    {
      'name': 'Main Branch - Dar es Salaam',
      'address': '123 Main St, Dar es Salaam',
      'type': 'Branch',
      'city': 'Dar es Salaam',
    },
    {
      'name': 'Agent - Arusha',
      'address': '456 Arusha Ave, Arusha',
      'type': 'Agent',
      'city': 'Arusha',
    },
    {
      'name': 'Agent - Mwanza',
      'address': '789 Mwanza Rd, Mwanza',
      'type': 'Agent',
      'city': 'Mwanza',
    },
    {
      'name': 'Branch - Dodoma',
      'address': '101 Dodoma St, Dodoma',
      'type': 'Branch',
      'city': 'Dodoma',
    },
  ];

  List<String> get _locations {
    final locs = _offices.map((o) => o['city']!).toSet().toList();
    locs.sort();
    return ['All', ...locs];
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _offices.where((office) {
      final matchesLocation = _selectedLocation == 'All' || office['city'] == _selectedLocation;
      final matchesQuery = office['name']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        office['address']!.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesLocation && matchesQuery;
    }).toList();

    // Prepare markers for OpenStreetMap (flutter_map)
    final List<latlng2.LatLng> markerPoints = filtered.map((office) {
      double lat = 0, lng = 0;
      if (office['city'] == 'Dar es Salaam') { lat = -6.7924; lng = 39.2083; }
      if (office['city'] == 'Arusha') { lat = -3.3869; lng = 36.68299; }
      if (office['city'] == 'Mwanza') { lat = -2.5164; lng = 32.9175; }
      if (office['city'] == 'Dodoma') { lat = -6.1630; lng = 35.7516; }
      return latlng2.LatLng(lat, lng);
    }).toList();

    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.slateGradient,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 12, right: 12, bottom: 0),
              child: Row(
                children: [
                  SizedBox(
                    width: 180,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        labelText: 'Search',
                        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w300, color: AppTheme.slate300),
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Colors.white,
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedLocation,
                      items: _locations.map((loc) => DropdownMenuItem(value: loc, child: Text(loc, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (v) => setState(() => _selectedLocation = v ?? 'All'),
                      decoration: InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Colors.white,
                        isDense: true,
                      ),
                    ),
            ),
          ],
        ),
            ),
            // OpenStreetMap below search/filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SizedBox(
                height: 240,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: flutter_map.FlutterMap(
                    options: flutter_map.MapOptions(
                      initialCenter: markerPoints.isNotEmpty ? markerPoints[0] : latlng2.LatLng(-6.7924, 39.2083),
                      initialZoom: 5.5,
                    ),
                    children: [
                      flutter_map.TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.arenoapp',
                      ),
                      flutter_map.MarkerLayer(
                        markers: markerPoints.map((point) => flutter_map.Marker(
                          width: 40,
                          height: 40,
                          point: point,
                          child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // List of offices below map
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final office = filtered[i];
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        office['type'] == 'Branch' ? Icons.location_city : Icons.person_pin_circle,
                        color: AppTheme.primaryOrange,
                      ),
                      title: Text(office['name']!),
                      subtitle: Text(office['address']!),
                      onTap: () => _showOfficeDetails(context, office),
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

  void _showOfficeDetails(BuildContext context, Map<String, String> office) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
            child: Column(
            mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(
                children: [
                  Icon(
                    office['type'] == 'Branch' ? Icons.location_city : Icons.person_pin_circle,
                    color: AppTheme.primaryOrange,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      office['name']!,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Address:', style: Theme.of(context).textTheme.bodyMedium),
              Text(office['address']!, style: Theme.of(context).textTheme.bodyLarge),
              if (office['city'] != null) ...[
                const SizedBox(height: 8),
                Text('City/Region:', style: Theme.of(context).textTheme.bodyMedium),
                Text(office['city']!, style: Theme.of(context).textTheme.bodyLarge),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      // TODO: Integrate call functionality
                    },
                    icon: const Icon(Icons.call),
                    label: const Text('Call'),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      // TODO: Integrate directions functionality
                    },
                    icon: const Icon(Icons.directions),
                    label: const Text('Directions'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy Address',
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Address copied to clipboard')),
                      );
                      // TODO: Actually copy to clipboard
                    },
                  ),
                ],
          ),
        ],
      ),
        );
      },
    );
  }
} 