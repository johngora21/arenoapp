import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Dummy user and partner status
  bool hasBusiness = false;
  bool isBusinessRegistered = false;
  final _personalFormKey = GlobalKey<FormState>();
  String name = 'John Doe';
  String email = 'johndoe@email.com';
  String phone = '+255 123 456 789';
  String location = 'Dar es Salaam';
  void _showBusinessRegistrationForm(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String businessName = '';
    String businessType = '';
    String businessAddress = '';
    String businessContact = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Business Registration', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Business Name',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Enter business name' : null,
                  onChanged: (v) => businessName = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Business Type',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Enter business type' : null,
                  onChanged: (v) => businessType = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Business Address',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Enter address' : null,
                  onChanged: (v) => businessAddress = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Contact Person / Phone',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Enter contact' : null,
                  onChanged: (v) => businessContact = v,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      setState(() => isBusinessRegistered = true);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.primaryOrange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Picture Only
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppTheme.slate200,
                    backgroundImage: null, // TODO: Add image provider
                    child: Icon(Icons.person, size: 48, color: AppTheme.slate400),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.edit, size: 18, color: AppTheme.primaryOrange),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Personal Info Form
            Text('Personal Information', style: AppTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.slate900)),
            const SizedBox(height: 12),
            Form(
              key: _personalFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _personalInfoRow('Full Name', name, readOnly: true),
                  _personalInfoRow('Email', email, readOnly: true),
                  _personalInfoRow('Phone', phone, readOnly: true),
                  _personalInfoRow('Location', location, readOnly: true),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      if (_personalFormKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Personal info saved!')),
                        );
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Business Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Do you have a business you want Areno Express to handle deliveries for?',
                    style: AppTheme.bodyMedium,
                  ),
                ),
                Switch(
                  value: hasBusiness,
                  activeColor: AppTheme.primaryOrange,
                  onChanged: (val) => setState(() => hasBusiness = val),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (hasBusiness) ...[
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: BusinessRegistrationForm(),
                ),
              ),
              const SizedBox(height: 28),
            ],
            // 3. Payment Methods
            Text('Payment Methods', style: AppTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.slate900)),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: PaymentMethodForm(),
              ),
            ),
            if (hasBusiness) ...[
              const SizedBox(height: 28),
              // 4. Logistics Dashboard (for partners)
              Text('Logistics Dashboard', style: AppTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.slate900)),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Shipments Managed: 12'),
                      Text('Earnings: TZS 1,200,000'),
                      Text('Performance: Excellent'),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {},
                            child: const Text('View Shipments'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryOrange,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {},
                            child: const Text('Request Pickup'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 28),
            // 5. General Actions
            Text('Account Actions', style: AppTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.slate900)),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: Icon(Icons.lock, color: AppTheme.primaryOrange),
                title: Text('Change Password'),
                onTap: () {}, // TODO: Change password
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400, color: AppTheme.slate500),
      floatingLabelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.slate900),
      hintText: hint,
      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w300, color: AppTheme.slate300),
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _personalInfoRow(String label, String value, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: AppTheme.bodySmall?.copyWith(color: AppTheme.slate500)),
          ),
          Expanded(
            child: Text(
              value,
              style: readOnly
                  ? AppTheme.bodyMedium?.copyWith(color: AppTheme.slate400, fontStyle: FontStyle.italic)
                  : AppTheme.bodyMedium?.copyWith(color: AppTheme.slate900),
            ),
          ),
        ],
      ),
    );
  }
}

class BusinessRegistrationForm extends StatefulWidget {
  @override
  State<BusinessRegistrationForm> createState() => _BusinessRegistrationFormState();
}

class _BusinessRegistrationFormState extends State<BusinessRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  String businessName = '';
  String businessType = '';
  String businessAddress = '';
  String? licenseFileName;
  String? tinFileName;
  LatLng? businessLocation;
  String businessContact = '';
  bool isRegistered = false;

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400, color: AppTheme.slate500),
      floatingLabelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.slate900),
      hintText: hint,
      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w300, color: AppTheme.slate300),
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Business Registration', style: AppTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.slate900)),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: businessName,
            decoration: _inputDecoration('Business Name', 'Enter business name'),
            validator: (v) => v == null || v.isEmpty ? 'Enter business name' : null,
            onChanged: (v) => setState(() => businessName = v),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: businessType,
            decoration: _inputDecoration('Business Type', 'Enter business type'),
            validator: (v) => v == null || v.isEmpty ? 'Enter business type' : null,
            onChanged: (v) => setState(() => businessType = v),
          ),
          const SizedBox(height: 12),
          TextFormField(
            readOnly: true,
            decoration: _inputDecoration('Business Location', 'Tap to pick location').copyWith(
              suffixIcon: Icon(Icons.location_on, color: AppTheme.primaryOrange),
            ),
            controller: TextEditingController(text: businessLocation != null ? 'Lat: ${businessLocation!.latitude}, Lng: ${businessLocation!.longitude}' : ''),
            validator: (v) => businessLocation == null ? 'Pick location' : null,
            onTap: () async {
              LatLng? picked = await showDialog(
                context: context,
                builder: (context) => _MapPickerDialog(initial: businessLocation),
              );
              if (picked != null) {
                setState(() => businessLocation = picked);
              }
            },
          ),
          const SizedBox(height: 12),
          // TIN number field
          TextFormField(
            decoration: _inputDecoration('TIN Number', 'Enter TIN number'),
            validator: (v) => v == null || v.isEmpty ? 'Enter TIN number' : null,
            onChanged: (v) => setState(() => businessContact = v),
          ),
          const SizedBox(height: 12),
          // TIN certificate upload
          Text('TIN Certificate', style: AppTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: AppTheme.slate900)),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: Text(tinFileName == null ? 'Upload TIN certificate' : 'Change TIN certificate'),
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'png']);
              if (result != null && result.files.isNotEmpty) {
                setState(() => tinFileName = result.files.single.name);
              }
            },
          ),
          if (tinFileName != null)
            ListTile(
              leading: const Icon(Icons.insert_drive_file, color: AppTheme.primaryOrange),
              title: Text(tinFileName!, overflow: TextOverflow.ellipsis),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => tinFileName = null),
              ),
            ),
          const SizedBox(height: 12),
          // Business license upload
          Text('Business License', style: AppTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: AppTheme.slate900)),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: Text(licenseFileName == null ? 'Upload business license' : 'Change business license'),
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'png']);
              if (result != null && result.files.isNotEmpty) {
                setState(() => licenseFileName = result.files.single.name);
              }
            },
          ),
          if (licenseFileName != null)
            ListTile(
              leading: const Icon(Icons.insert_drive_file, color: AppTheme.primaryOrange),
              title: Text(licenseFileName!, overflow: TextOverflow.ellipsis),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => licenseFileName = null),
              ),
            ),
          const SizedBox(height: 12),
          // Removed contact person field
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                setState(() => isRegistered = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Business registered!')),
                );
              }
            },
            child: Text(isRegistered ? 'Update Business' : 'Register Business'),
          ),
        ],
      ),
    );
  }
}

class PaymentMethodForm extends StatefulWidget {
  @override
  State<PaymentMethodForm> createState() => _PaymentMethodFormState();
}

class _PaymentMethodFormState extends State<PaymentMethodForm> {
  final _formKey = GlobalKey<FormState>();
  String paymentType = 'Mobile Payment';
  String provider = '';
  String accountNumber = '';
  String accountName = '';

  final List<String> paymentTypes = ['Mobile Payment', 'Bank'];
  final Map<String, List<String>> providers = {
    'Mobile Payment': ['M-Pesa', 'Tigo Pesa', 'Airtel Money', 'Halopesa'],
    'Bank': ['CRDB', 'NMB', 'Stanbic', 'NBC', 'DTB'],
  };

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400, color: AppTheme.slate500),
      floatingLabelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.slate900),
      hintText: hint,
      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w300, color: AppTheme.slate300),
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            value: paymentType,
            items: paymentTypes.map((type) => DropdownMenuItem(
              value: type,
              child: Text(type, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.slate900)),
            )).toList(),
            onChanged: (val) {
              setState(() {
                paymentType = val!;
                provider = '';
              });
            },
            decoration: _inputDecoration('Payment Type', 'Select type'),
            isDense: true,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: provider.isNotEmpty ? provider : null,
            items: providers[paymentType]!.map((prov) => DropdownMenuItem(
              value: prov,
              child: Text(prov, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.slate900)),
            )).toList(),
            onChanged: (val) => setState(() => provider = val ?? ''),
            decoration: _inputDecoration(paymentType == 'Mobile Payment' ? 'MNO' : 'Bank', 'Select'),
            isDense: true,
            validator: (v) => v == null || v.isEmpty ? 'Select provider' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: _inputDecoration(
              paymentType == 'Mobile Payment' ? 'Phone Number' : 'Account Number',
              paymentType == 'Mobile Payment' ? 'Enter phone number' : 'Enter account number',
            ),
            keyboardType: TextInputType.number,
            validator: (v) => v == null || v.isEmpty ? 'Enter number' : null,
            onChanged: (v) => setState(() => accountNumber = v),
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: _inputDecoration('Account Name', 'Enter account holder name'),
            validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
            onChanged: (v) => setState(() => accountName = v),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment method saved!')),
                );
              }
            },
            child: const Text('Save Payment Method'),
          ),
        ],
      ),
    );
  }
}

// Google Map Picker Dialog
class _MapPickerDialog extends StatefulWidget {
  final LatLng? initial;
  const _MapPickerDialog({this.initial});
  @override
  State<_MapPickerDialog> createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<_MapPickerDialog> {
  late LatLng _selected;
  @override
  void initState() {
    super.initState();
    _selected = widget.initial ?? const LatLng(-6.7924, 39.2083); // Default Dar es Salaam
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('Select Business Location', style: Theme.of(context).textTheme.titleMedium),
            ),
            SizedBox(
              width: 320,
              height: 320,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: _selected, zoom: 15),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(_selected),
                    child: const Text('Select Location'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 