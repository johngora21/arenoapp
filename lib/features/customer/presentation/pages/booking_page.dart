import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:latlong2/latlong.dart' as latlng2;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({Key? key}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String _serviceType = 'courier';
  String _courierType = '';
  String _movingType = '';
  String _freightType = '';
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

  // Moving controllers
  final _movingFullNameController = TextEditingController();
  final _movingPhoneController = TextEditingController();
  final _movingEmailController = TextEditingController();
  final _movingDateController = TextEditingController();
  final _itemsListController = TextEditingController();
  final _movingSpecialRequestsController = TextEditingController();
  final _movingBusinessNameController = TextEditingController();

  // Freight controllers
  final _freightBusinessNameController = TextEditingController();
  final _freightContactPersonController = TextEditingController();
  final _freightPhoneController = TextEditingController();
  final _freightEmailController = TextEditingController();
  final _freightPickupDateController = TextEditingController();
  final _freightDeliveryDateController = TextEditingController();
  final _freightCargoDescriptionController = TextEditingController();
  final _freightQuantityController = TextEditingController();
  final _freightWeightController = TextEditingController();
  final _freightVolumeController = TextEditingController();
  final _freightSpecialHandlingController = TextEditingController();
  final _freightOtherRequestsController = TextEditingController();

  // Additional services
  final Set<String> _courierAdditional = {};
  final Set<String> _movingAdditional = {};
  final Set<String> _freightAdditional = {};
  final Set<String> _freightSpecialHandling = {};

  // For courier: list of parcels, each with name, description, files
  List<_CourierParcel> _parcels = [
    _CourierParcel(),
  ];
  // For locations, map from parcel index to LatLng
  Map<int, latlng2.LatLng?> _parcelPickupLocations = {};
  Map<int, latlng2.LatLng?> _parcelDeliveryLocations = {};
  int? _selectedParcelForPickup;
  int? _selectedParcelForDelivery;

  latlng2.LatLng? _pickupLatLng;
  latlng2.LatLng? _deliveryLatLng;
  List<PlatformFile> _packageFiles = [];
  // Restore moving/freight state for other tabs
  latlng2.LatLng? _movingPickupLatLng;
  latlng2.LatLng? _movingDeliveryLatLng;
  latlng2.LatLng? _freightPickupLatLng;
  latlng2.LatLng? _freightDeliveryLatLng;
  List<PlatformFile> _movingFiles = [];
  List<PlatformFile> _freightFiles = [];

  List<_PackageItem> _packageItems = [ _PackageItem() ];
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
    Map<String, dynamic> contactInfo;
    if (_serviceType == 'courier') {
      contactInfo = {
        'contactPerson': _senderNameController.text.trim(),
        'email': _senderEmailController.text.trim(),
        'phone': _senderPhoneController.text.trim(),
      };
    } else if (_serviceType == 'moving') {
      contactInfo = {
        'contactPerson': _movingFullNameController.text.trim(),
        'email': _movingEmailController.text.trim(),
        'phone': _movingPhoneController.text.trim(),
      };
    } else if (_serviceType == 'freight') {
      contactInfo = {
        'contactPerson': _freightContactPersonController.text.trim(),
        'email': _freightEmailController.text.trim(),
        'phone': _freightPhoneController.text.trim(),
      };
    } else {
      contactInfo = {
        'contactPerson': '',
        'email': '',
        'phone': '',
      };
    }
    // Collect all package items
    final packageItems = _packageItems.map((item) => {
      'category': item.category,
      'name': item.nameController.text.trim(),
      'quantity': item.quantityController.text.trim(),
      'value': item.valueController.text.trim(),
    }).toList();
    final data = {
      'userId': user.uid,
      'serviceType': _serviceType,
      'courierType': _courierType,
      'movingType': _movingType,
      'freightType': _freightType,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'contactInfo': contactInfo,
      'sender': {
        'name': _senderNameController.text.trim(),
        'phone': _senderPhoneController.text.trim(),
        'email': _senderEmailController.text.trim(),
      },
      'receiver': {
        'name': _receiverNameController.text.trim(),
        'phone': _receiverPhoneController.text.trim(),
        'email': _receiverEmailController.text.trim(),
      },
      'pickupAddress': _pickupController.text.trim(),
      'pickupLatLng': _pickupLatLng != null ? {
        'lat': _pickupLatLng!.latitude,
        'lng': _pickupLatLng!.longitude,
      } : null,
      'deliveryAddress': _deliveryController.text.trim(),
      'deliveryLatLng': _deliveryLatLng != null ? {
        'lat': _deliveryLatLng!.latitude,
        'lng': _deliveryLatLng!.longitude,
      } : null,
      'packageName': _packageNameController.text.trim(),
      'packageItems': packageItems,
      'packageDescription': _packageDescriptionController.text.trim(),
      'businessName': _businessNameController.text.trim(),
      'isExpress': _isExpress,
      'isDoorToDoor': _isDoorToDoor,
      // Moving
      'movingBusinessName': _movingBusinessNameController.text.trim(),
      'movingDate': _movingDateController.text.trim(),
      'movingPickupLatLng': _movingPickupLatLng != null ? {
        'lat': _movingPickupLatLng!.latitude,
        'lng': _movingPickupLatLng!.longitude,
      } : null,
      'movingDeliveryLatLng': _movingDeliveryLatLng != null ? {
        'lat': _movingDeliveryLatLng!.latitude,
        'lng': _movingDeliveryLatLng!.longitude,
      } : null,
      'itemsList': _itemsListController.text.trim(),
      'movingSpecialRequests': _movingSpecialRequestsController.text.trim(),
      'movingAdditional': _movingAdditional.toList(),
      // Freight
      'freightBusinessName': _freightBusinessNameController.text.trim(),
      'freightContactPerson': _freightContactPersonController.text.trim(),
      'freightPhone': _freightPhoneController.text.trim(),
      'freightEmail': _freightEmailController.text.trim(),
      'freightPickupDate': _freightPickupDateController.text.trim(),
      'freightDeliveryDate': _freightDeliveryDateController.text.trim(),
      'freightPickupLatLng': _freightPickupLatLng != null ? {
        'lat': _freightPickupLatLng!.latitude,
        'lng': _freightPickupLatLng!.longitude,
      } : null,
      'freightDeliveryLatLng': _freightDeliveryLatLng != null ? {
        'lat': _freightDeliveryLatLng!.latitude,
        'lng': _freightDeliveryLatLng!.longitude,
      } : null,
      'freightCargoDescription': _freightCargoDescriptionController.text.trim(),
      'freightQuantity': _freightQuantityController.text.trim(),
      'freightWeight': _freightWeightController.text.trim(),
      'freightVolume': _freightVolumeController.text.trim(),
      'freightSpecialHandling': _freightSpecialHandling.toList(),
      'freightSpecialHandlingDesc': _freightSpecialHandlingController.text.trim(),
      'freightOtherRequests': _freightOtherRequestsController.text.trim(),
      'freightType': _freightType,
    };
    await quotesRef.add(data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking/Quote submitted!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Text('Book a Shipment / Request a Quote', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _serviceTypeButton('courier', 'Courier'),
                    const SizedBox(width: 8),
                    _serviceTypeButton('moving', 'Movers'),
                    const SizedBox(width: 8),
                    _serviceTypeButton('freight', 'Freight'),
                  ],
                ),
                const SizedBox(height: 24),
                ..._buildSectionedForm(context),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _serviceTypeButton(String type, String label) {
    final isSelected = _serviceType == type;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppTheme.successGreen : AppTheme.slate200,
        foregroundColor: isSelected ? Colors.white : AppTheme.slate900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () => setState(() => _serviceType = type),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: isSelected ? Colors.white : AppTheme.slate900,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _fileUploadWidget(List<PlatformFile> files, void Function(List<PlatformFile>) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton.icon(
            icon: const Icon(Icons.attach_file),
            label: const Text('Upload files (images, pdf, doc)'),
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                allowMultiple: true,
                type: FileType.custom,
                allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf', 'doc', 'docx'],
              );
              if (result != null) {
                onChanged([...files, ...result.files]);
              }
            },
          ),
          if (files.isNotEmpty)
            ...files.map((file) => ListTile(
                  leading: Icon(
                    file.extension == 'pdf' || file.extension == 'doc' || file.extension == 'docx'
                        ? Icons.insert_drive_file
                        : Icons.image,
                    color: AppTheme.primaryOrange,
                  ),
                  title: Text(file.name, overflow: TextOverflow.ellipsis),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      final updated = List<PlatformFile>.from(files)..remove(file);
                      onChanged(updated);
                    },
                  ),
                )),
        ],
      ),
    );
  }

  List<Widget> _buildSectionedForm(BuildContext context) {
    switch (_serviceType) {
      case 'courier':
        return [
          _sectionHeader('Service Type'),
          _dropdownField(
            value: _courierType,
            items: const [
              'Personal Items',
              'Business Items',
              'Medical Courier',
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
          // Move Pickup/Delivery sections above items
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
              icon: const Icon(Icons.add),
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
          // Total value and summary
          const SizedBox(height: 12),
          _sectionHeader('Summary'),
          _buildPackageSummary(),
          const SizedBox(height: 8),
          _buildOptions(),
        ];
      case 'moving':
        return [
          _sectionHeader('Type of Service Required'),
          _dropdownField(
            value: _movingType,
            items: const ['Home Relocation', 'Office Relocation'],
            hint: 'Select service type',
            onChanged: (v) => setState(() => _movingType = v ?? ''),
          ),
          if (_movingType == 'Office Relocation')
            _styledTextField(_movingBusinessNameController, 'Business Name', Icons.business),
          _sectionHeader('Contact Information'),
          _styledTextField(_movingFullNameController, 'Full Name', Icons.person),
          _styledTextField(_movingPhoneController, 'Phone Number', Icons.phone),
          _styledTextField(_movingEmailController, 'Email Address', Icons.email),
          _sectionHeader('Moving Details'),
          _styledTextField(_pickupController, 'Pickup Location', Icons.location_on),
          _mapPickerButton(
            _movingPickupLatLng,
            (latlng) => setState(() => _movingPickupLatLng = latlng),
            label: 'Pickup',
          ),
          _styledTextField(_deliveryController, 'Drop-off Location', Icons.location_on),
          _mapPickerButton(
            _movingDeliveryLatLng,
            (latlng) => setState(() => _movingDeliveryLatLng = latlng),
            label: 'Drop-off',
          ),
          _styledTextField(_movingDateController, 'Preferred Moving Date', Icons.calendar_today, readOnly: true, onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 365)),
            );
            if (picked != null) {
              _movingDateController.text = picked.toIso8601String().split('T').first;
            }
          }),
          _sectionHeader('Items to Be Moved'),
          _styledTextField(_itemsListController, 'List Items Manually', Icons.list),
          _fileUploadWidget(_movingFiles, (files) => setState(() => _movingFiles = files)),
          _sectionHeader('Additional Services Required'),
          _checkboxList(
            _movingAdditional,
            [
              {'id': 'storage', 'label': 'Storage Services', 'desc': 'Secure storage facilities for your belongings'},
              {'id': 'insurance', 'label': 'Insurance Coverage', 'desc': 'Protect your items during the move'},
              {'id': 'cleaning', 'label': 'House Cleaning', 'desc': 'Professional cleaning of old and new locations'},
            ],
          ),
          _styledTextField(_movingSpecialRequestsController, 'Other Special Requests', Icons.info_outline),
        ];
      case 'freight':
        return [
          _sectionHeader('Contact Information'),
          _styledTextField(_freightBusinessNameController, 'Business Name', Icons.business),
          _styledTextField(_freightContactPersonController, 'Contact Person', Icons.person),
          _styledTextField(_freightPhoneController, 'Phone Number', Icons.phone),
          _styledTextField(_freightEmailController, 'Email Address', Icons.email),
          _sectionHeader('Shipment Details'),
          _dropdownField(
            value: _freightType,
            items: const ['Local Freight', 'International Freight'],
            hint: 'Select shipment type',
            onChanged: (v) => setState(() => _freightType = v ?? ''),
          ),
          _styledTextField(_pickupController, 'Pickup Location', Icons.location_on),
          _mapPickerButton(
            _freightPickupLatLng,
            (latlng) => setState(() => _freightPickupLatLng = latlng),
            label: 'Pickup',
          ),
          _styledTextField(_deliveryController, 'Destination Location', Icons.location_on),
          _mapPickerButton(
            _freightDeliveryLatLng,
            (latlng) => setState(() => _freightDeliveryLatLng = latlng),
            label: 'Destination',
          ),
          _styledTextField(_freightPickupDateController, 'Expected Pickup Date', Icons.calendar_today, readOnly: true, onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 365)),
            );
            if (picked != null) {
              _freightPickupDateController.text = picked.toIso8601String().split('T').first;
            }
          }),
          _styledTextField(_freightDeliveryDateController, 'Expected Delivery Date', Icons.calendar_today, readOnly: true, onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 365)),
            );
            if (picked != null) {
              _freightDeliveryDateController.text = picked.toIso8601String().split('T').first;
            }
          }),
          _sectionHeader('Cargo Details'),
          _styledTextField(_freightCargoDescriptionController, 'Cargo Description', Icons.description),
          _styledTextField(_freightQuantityController, 'Quantity', Icons.confirmation_number),
          _styledTextField(_freightWeightController, 'Weight (kg)', Icons.scale),
          _styledTextField(_freightVolumeController, 'Volume (m³)', Icons.straighten),
          _fileUploadWidget(_freightFiles, (files) => setState(() => _freightFiles = files)),
          _sectionHeader('Special Handling Instructions'),
          _checkboxList(
            _freightSpecialHandling,
            [
              {'id': 'Fragile', 'label': 'Fragile'},
              {'id': 'Hazardous', 'label': 'Hazardous'},
              {'id': 'Perishable', 'label': 'Perishable'},
            ],
            isSpecial: true,
          ),
          _styledTextField(_freightSpecialHandlingController, 'Additional handling instructions', Icons.warning),
          _sectionHeader('Included Services'),
          _includedServices([
            {'label': 'Cargo Tracking', 'icon': Icons.track_changes},
            {'label': 'Customs Clearance', 'icon': Icons.assignment_turned_in},
            {'label': 'Warehousing', 'icon': Icons.warehouse},
            {'label': 'Insurance Coverage', 'icon': Icons.verified_user},
          ]),
          _styledTextField(_freightOtherRequestsController, 'Other Requests', Icons.info_outline),
        ];
      default:
        return [];
    }
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.slate900)),
    );
  }

  Widget _styledTextField(TextEditingController controller, String label, IconData icon, {String? hint, bool readOnly = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
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

  Widget _checkboxList(Set<String> selected, List<Map<String, String>> options, {bool isSpecial = false}) {
    return Column(
      children: options.map((opt) => CheckboxListTile(
        value: selected.contains(opt['id']!),
        onChanged: (v) => setState(() {
          if (v == true) {
            selected.add(opt['id']!);
          } else {
            selected.remove(opt['id']!);
          }
        }),
        title: Text(opt['label']!, style: Theme.of(context).textTheme.bodyLarge),
        subtitle: opt['desc'] != null ? Text(opt['desc']!) : null,
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: AppTheme.primaryOrange,
      )).toList(),
    );
  }

  Widget _includedServices(List<Map<String, dynamic>> services) {
    return Column(
      children: services.map((service) => Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(service['icon'], color: AppTheme.primaryOrange, size: 18),
              ),
              const SizedBox(width: 12),
              Text(service['label'], style: Theme.of(context).textTheme.bodyLarge),
            ],
          )).toList(),
    );
  }

  Widget _mapPickerButton(latlng2.LatLng? value, ValueChanged<latlng2.LatLng> onPicked, {required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.location_on),
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
            icon: const Icon(Icons.image),
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
              icon: const Icon(Icons.close),
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

  bool _isExpress = false;
  bool _isDoorToDoor = false;

  Widget _buildOptions() {
    return Column(
      children: [
        CheckboxListTile(
          value: _isExpress,
          onChanged: (v) => setState(() => _isExpress = v ?? false),
          title: const Text('Express Delivery'),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppTheme.primaryOrange,
        ),
        CheckboxListTile(
          value: _isDoorToDoor,
          onChanged: (v) => setState(() => _isDoorToDoor = v ?? false),
          title: const Text('Door to Door Delivery'),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppTheme.primaryOrange,
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