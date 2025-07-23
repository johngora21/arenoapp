import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:latlong2/latlong.dart' as latlng2;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DriverCreateShipmentPage extends StatefulWidget {
  const DriverCreateShipmentPage({Key? key}) : super(key: key);

  @override
  State<DriverCreateShipmentPage> createState() => _DriverCreateShipmentPageState();
}

class _DriverCreateShipmentPageState extends State<DriverCreateShipmentPage> {
  String _courierType = '';
  final _formKey = GlobalKey<FormState>();
  final _pickupController = TextEditingController();
  final _deliveryController = TextEditingController();
  final _senderNameController = TextEditingController();
  final _senderPhoneController = TextEditingController();
  final _senderEmailController = TextEditingController();
  final _receiverNameController = TextEditingController();
  final _receiverPhoneController = TextEditingController();
  final _receiverEmailController = TextEditingController();
  final _packageDescriptionController = TextEditingController();
  final _courierContactPersonController = TextEditingController();
  final _courierContactPhoneController = TextEditingController();
  final _courierContactEmailController = TextEditingController();
  latlng2.LatLng? _pickupLatLng;
  latlng2.LatLng? _deliveryLatLng;
  final _packageNameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final CollectionReference quotesRef = FirebaseFirestore.instance.collection('quotes');
  List<Map<String, dynamic>> myQuotes = [];
  Stream<QuerySnapshot>? quotesStream;
  List<_PackageItem> _packageItems = [ _PackageItem() ];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      quotesStream = quotesRef.where('userId', isEqualTo: user.uid).snapshots();
      quotesStream!.listen((snapshot) {
        setState(() {
          myQuotes = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        });
      });
    }
  }

  Future<void> _submitBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to submit a booking.')),
      );
      return;
    }
    final data = {
      'userId': user.uid,
      'serviceType': 'courier',
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    };
    await quotesRef.add(data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking/Quote submitted!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Shipment'),
        backgroundColor: AppTheme.successGreen,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.slateGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._buildCourierSection(context),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                      onPressed: _submitBooking,
                      child: const Text('Submit Request'),
                    ),
                  ),
                  if (myQuotes.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Text('My Recent Quotes/Bookings:', style: Theme.of(context).textTheme.titleMedium),
                    ...myQuotes.map((q) => Card(
                      child: ListTile(
                        title: Text('Type:  ${q['serviceType']}'),
                        subtitle: Text('Status:  ${q['status']}'),
                      ),
                    )),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCourierSection(BuildContext context) {
    return [
      _sectionHeader('Service Type'),
      Row(
        children: [
          Expanded(
            child: _dropdownField(
              value: _courierType,
              items: const [
                'Personal Items',
                'Business Items',
              ],
              hint: 'Select service type',
              onChanged: (v) => setState(() => _courierType = v ?? ''),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: AppTheme.successGreen, size: 28),
            tooltip: 'Scan Shipment',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Scan Shipment'),
                  content: const Text('Simulate scanning a shipment barcode/QR to verify.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      if (_courierType == 'Business Items')
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _styledTextField(_businessNameController, 'Business Name', Icons.business, hint: 'Enter your business name'),
        ),
      _sectionHeader('Sender Information'),
      _styledTextField(_senderNameController, 'Sender Name *', Icons.person),
      _styledTextField(_senderPhoneController, 'Phone Number *', Icons.phone, hint: '+255 XXX XXX XXX'),
      _styledTextField(_senderEmailController, 'Email Address', Icons.email, hint: 'sender@email.com'),
      _sectionHeader('Receiver Information'),
      _styledTextField(_receiverNameController, 'Receiver Name *', Icons.person),
      _styledTextField(_receiverPhoneController, 'Phone Number *', Icons.phone, hint: '+255 XXX XXX XXX'),
      _styledTextField(_receiverEmailController, 'Email Address', Icons.email, hint: 'receiver@email.com'),
      _sectionHeader('Pickup Details'),
      _styledTextField(_pickupController, 'Pickup Address *', Icons.location_on, hint: 'Enter pickup address or select on map'),
      _mapPickerButton(_pickupLatLng, (latlng) => setState(() => _pickupLatLng = latlng), label: 'Pickup'),
      _sectionHeader('Delivery Details'),
      _styledTextField(_deliveryController, 'Delivery Address *', Icons.location_on, hint: 'Enter delivery address or select on map'),
      _mapPickerButton(_deliveryLatLng, (latlng) => setState(() => _deliveryLatLng = latlng), label: 'Delivery'),
      _sectionHeader('Package Name'),
      _styledTextField(_packageNameController, 'Package Name', Icons.inventory, hint: 'e.g. Electronics Shipment'),
      _sectionHeader('Items in Package'),
      ..._packageItems.asMap().entries.map((entry) {
        final idx = entry.key;
        final item = entry.value;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_packageItems.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => setState(() => _packageItems.removeAt(idx)),
                      ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _dropdownField(
                        value: item.category,
                        items: const [
                          'Electronics', 'Fashion', 'Documents', 'Food', 'Medical', 'Other'
                        ],
                        hint: 'Category',
                        onChanged: (v) => setState(() => item.category = v ?? ''),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _styledTextField(item.nameController, 'Item Name', Icons.label),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _styledTextField(item.quantityController, 'Quantity', Icons.confirmation_number),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _styledTextField(item.valueController, 'Value', Icons.attach_money),
                    ),
                  ],
                ),
                _itemImageUploadWidget(item, (file) => setState(() => item.image = file)),
              ],
            ),
          ),
        );
      }),
      Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.add, color: AppTheme.successGreen),
          label: const Text('Add Item'),
          onPressed: () => setState(() => _packageItems.add(_PackageItem())),
        ),
      ),
      _sectionHeader('Additional Description'),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: TextField(
          controller: _packageDescriptionController,
          maxLines: 4,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            labelText: 'Additional Instructions or Notes',
            labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: AppTheme.slate700),
            floatingLabelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.slate900),
            hintText: 'Provide any extra details, instructions, or special requirements for your shipment.',
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w300, color: AppTheme.slate300),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ),
      const SizedBox(height: 12),
      _sectionHeader('Summary'),
      _buildPackageSummary(),
    ];
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.slate900)),
    );
  }

  Widget _styledTextField(TextEditingController controller, String label, IconData icon, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: AppTheme.slate700),
          floatingLabelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.slate900),
          hintText: hint,
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w300, color: AppTheme.slate300),
          prefixIcon: Icon(icon, color: AppTheme.successGreen),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _dropdownField({required String value, required List<String> items, required String hint, required ValueChanged<String?> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        value: value.isEmpty ? null : value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: AppTheme.slate900),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: AppTheme.slate900)))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: hint,
          labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: AppTheme.slate700),
          floatingLabelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.slate900),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _mapPickerButton(latlng2.LatLng? value, ValueChanged<latlng2.LatLng> onPicked, {required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.location_on, color: AppTheme.successGreen),
        label: Text(value == null
            ? 'Set $label Location'
            : '$label: ${value.latitude.toStringAsFixed(5)}, ${value.longitude.toStringAsFixed(5)}'),
        onPressed: () async {
          final picked = await showModalBottomSheet<latlng2.LatLng>(
            context: context,
            isScrollControlled: true,
            builder: (ctx) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: _OpenStreetMapPicker(
                initial: value ?? latlng2.LatLng(-6.7924, 39.2083),
                label: label,
              ),
            ),
          );
          if (picked != null) onPicked(picked);
        },
      ),
    );
  }

  Widget _itemImageUploadWidget(_PackageItem item, ValueChanged<PlatformFile?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (item.image != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Image.memory(
                item.image!.bytes!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
          OutlinedButton.icon(
            icon: const Icon(Icons.image, color: AppTheme.successGreen),
            label: Text(item.image == null ? 'Upload Image' : 'Change Image'),
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.image,
                allowMultiple: false,
              );
              if (result != null && result.files.isNotEmpty) {
                onChanged(result.files.first);
              }
            },
          ),
          if (item.image != null)
            IconButton(
              icon: const Icon(Icons.close, color: AppTheme.successGreen),
              onPressed: () => onChanged(null),
            ),
        ],
      ),
    );
  }

  double _getTotalValue() {
    double total = 0;
    for (final item in _packageItems) {
      final value = double.tryParse(item.valueController.text.trim()) ?? 0;
      total += value;
    }
    return total;
  }

  Widget _buildPackageSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Total Value: TZS ${_getTotalValue().toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 6),
        Text('Items:', style: Theme.of(context).textTheme.bodyMedium),
        ..._packageItems.where((item) => item.nameController.text.isNotEmpty).map((item) =>
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 2),
            child: Text('- ${item.nameController.text} (${item.category}) x${item.quantityController.text}', style: Theme.of(context).textTheme.bodySmall),
          ),
        ),
      ],
    );
  }
}

class _CourierParcel {
  TextEditingController nameController = TextEditingController();
  String category = '';
  TextEditingController descriptionController = TextEditingController();
  List<PlatformFile> files = [];
}

class _PackageItem {
  String category = '';
  TextEditingController nameController = TextEditingController();
  TextEditingController valueController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  PlatformFile? image;
}

class _OpenStreetMapPicker extends StatefulWidget {
  final latlng2.LatLng initial;
  final String label;
  const _OpenStreetMapPicker({required this.initial, required this.label});
  @override
  State<_OpenStreetMapPicker> createState() => _OpenStreetMapPickerState();
}

class _OpenStreetMapPickerState extends State<_OpenStreetMapPicker> {
  late latlng2.LatLng _selected;
  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Select ${widget.label} Location', style: Theme.of(context).textTheme.titleMedium),
        ),
        Expanded(
          child: flutter_map.FlutterMap(
            options: flutter_map.MapOptions(
              initialCenter: _selected,
              initialZoom: 15,
              onTap: (tapPos, latlng) => setState(() => _selected = latlng),
            ),
            children: [
              flutter_map.TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.arenoapp',
              ),
              flutter_map.MarkerLayer(
                markers: [
                  flutter_map.Marker(
                    width: 40,
                    height: 40,
                    point: _selected,
                    child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(_selected),
            child: const Text('Select Location'),
          ),
        ),
      ],
    );
  }
} 