import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../widgets/customer_bottom_nav.dart';
import '../widgets/quote_request_card.dart';
import '../widgets/shipment_tracking_card.dart';
import '../widgets/app_drawer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'home_page.dart';
import 'booking_page.dart';
import 'offices_page.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    OfficesPage(),        // index 0: Offices (left)
    HomePage(),           // index 1: Home (center)
    BookingPage(),        // index 2: Booking (right)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('Areno Express'),
        backgroundColor: AppTheme.successGreen,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomerBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _DashboardStatCard({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color)),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickActionCard({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;
  final Color color;
  const _ActivityItem({required this.title, required this.time, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(time),
    );
  }
}

class _BookingTab extends StatefulWidget {
  @override
  State<_BookingTab> createState() => _BookingTabState();
}

class _BookingTabState extends State<_BookingTab> {
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
  Map<int, LatLng?> _parcelPickupLocations = {};
  Map<int, LatLng?> _parcelDeliveryLocations = {};
  int? _selectedParcelForPickup;
  int? _selectedParcelForDelivery;

  LatLng? _pickupLatLng;
  LatLng? _deliveryLatLng;
  List<PlatformFile> _packageFiles = [];
  // Restore moving/freight state for other tabs
  LatLng? _movingPickupLatLng;
  LatLng? _movingDeliveryLatLng;
  LatLng? _freightPickupLatLng;
  LatLng? _freightDeliveryLatLng;
  List<PlatformFile> _movingFiles = [];
  List<PlatformFile> _freightFiles = [];

  List<_PackageItem> _packageItems = [ _PackageItem() ];
  final _packageNameController = TextEditingController();
  final _businessNameController = TextEditingController();

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
                    onPressed: () {},
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
        backgroundColor: isSelected ? AppTheme.primaryOrange : AppTheme.slate200,
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
          _styledTextField(_movingDateController, 'Preferred Moving Date', Icons.calendar_today),
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
          _styledTextField(_freightPickupDateController, 'Expected Pickup Date', Icons.calendar_today),
          _styledTextField(_freightDeliveryDateController, 'Expected Delivery Date', Icons.calendar_today),
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

class _OfficesTab extends StatefulWidget {
  @override
  State<_OfficesTab> createState() => _OfficesTabState();
}

class _OfficesTabState extends State<_OfficesTab> {
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

    // Prepare markers for Google Map (only for filtered offices)
    final List<Marker> markers = filtered.map((office) {
      double lat = 0, lng = 0;
      if (office['city'] == 'Dar es Salaam') { lat = -6.7924; lng = 39.2083; }
      if (office['city'] == 'Arusha') { lat = -3.3869; lng = 36.68299; }
      if (office['city'] == 'Mwanza') { lat = -2.5164; lng = 32.9175; }
      if (office['city'] == 'Dodoma') { lat = -6.1630; lng = 35.7516; }
      return Marker(
        markerId: MarkerId(office['name']!),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: office['name'], snippet: office['address']),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          office['type'] == 'Branch' ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueOrange,
        ),
      );
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
            // Google Map below search/filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SizedBox(
                height: 240,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Builder(
                    builder: (context) {
                      try {
                        return GoogleMap(
                          initialCameraPosition: const CameraPosition(target: LatLng(-6.7924, 39.2083), zoom: 5.5),
                          markers: Set<Marker>.of(markers),
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                        );
                      } catch (e) {
                        return Container(
                          color: Colors.grey[200],
                          child: Center(child: Text('Map could not be loaded.')), 
                        );
                      }
                    },
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
          child: Text('Select ${widget.label} Location', style: Theme.of(context).textTheme.titleMedium),
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
