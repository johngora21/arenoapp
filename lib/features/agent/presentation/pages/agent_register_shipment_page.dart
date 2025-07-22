import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/agent_drawer.dart';

class AgentRegisterShipmentPage extends StatefulWidget {
  const AgentRegisterShipmentPage({Key? key}) : super(key: key);

  @override
  State<AgentRegisterShipmentPage> createState() => _AgentRegisterShipmentPageState();
}

class _AgentRegisterShipmentPageState extends State<AgentRegisterShipmentPage> {
  // Only keep courier section
  String _courierType = '';
  final _formKey = GlobalKey<FormState>();

  // Common controllers
  final _pickupController = TextEditingController();
  final _deliveryController = TextEditingController();

  // Courier controllers
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

  // For courier: list of parcels, each with name, description, files
  List<_CourierParcel> _parcels = [
    _CourierParcel(),
  ];
  // For locations, map from parcel index to LatLng
  Map<int, LatLng?> _parcelPickupLocations = {};
  Map<int, LatLng?> _parcelDeliveryLocations = {};
  int? _selectedParcelForPickup;
  int? _selectedParcelForDelivery;

  LatLng? _pickupLatLng;
  LatLng? _deliveryLatLng;
  List<PlatformFile> _packageFiles = [];
  final _packageNameController = TextEditingController();
  final _businessNameController = TextEditingController();

  final CollectionReference quotesRef = FirebaseFirestore.instance.collection('quotes');
  List<Map<String, dynamic>> myQuotes = [];
  Stream<QuerySnapshot>? quotesStream;

  @override
  void initState() {
    super.initState();
    // Listen to real-time updates for the current user's quotes
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
    // Example: Only basic fields, expand as needed
    final data = {
      'userId': user.uid,
      'serviceType': 'courier',
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      // Add more fields from the form as needed
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
        backgroundColor: AppTheme.primaryDarkBlue,
        elevation: 0,
      ),
      drawer: AgentDrawer(),
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
                  // Removed the 'Register a Shipment (Courier Only)' title
                  ..._buildCourierSection(context),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
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
      _dropdownField(
        value: _courierType,
        items: const [
          'Personal Items',
          'Business Items',
         
        ],
        hint: 'Select service type',
        onChanged: (v) => setState(() => _courierType = v ?? ''),
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
          prefixIcon: Icon(icon, color: AppTheme.primaryOrange),
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

  Widget _mapPickerButton(LatLng? value, ValueChanged<LatLng> onPicked, {required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.location_on),
        label: Text(value == null
            ? 'Set $label Location'
            : '$label: ${value.latitude.toStringAsFixed(5)}, ${value.longitude.toStringAsFixed(5)}'),
        onPressed: () async {
          final picked = await showModalBottomSheet<LatLng>(
            context: context,
            isScrollControlled: true,
            builder: (ctx) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: _GoogleMapPicker(
                initial: value ?? const LatLng(-6.7924, 39.2083),
                label: label,
              ),
            ),
          );
          if (picked != null) onPicked(picked);
        },
      ),
    );
  }
}

class _CourierParcel {
  TextEditingController nameController = TextEditingController();
  String category = '';
  TextEditingController descriptionController = TextEditingController();
  List<PlatformFile> files = [];
}

class _GoogleMapPicker extends StatefulWidget {
  final LatLng initial;
  final String label;
  const _GoogleMapPicker({required this.initial, required this.label});
  @override
  State<_GoogleMapPicker> createState() => _GoogleMapPickerState();
}

class _GoogleMapPickerState extends State<_GoogleMapPicker> {
  late LatLng _selected;
  GoogleMapController? _controller;
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
          child: Text('Select  {widget.label} Location', style: Theme.of(context).textTheme.titleMedium),
        ),
        Expanded(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(target: _selected, zoom: 15),
            onMapCreated: (controller) => _controller = controller,
            markers: {
              Marker(
                markerId: const MarkerId('selected'),
                position: _selected,
                draggable: true,
                onDragEnd: (pos) => setState(() => _selected = pos),
              ),
            },
            onTap: (latlng) => setState(() => _selected = latlng),
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
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