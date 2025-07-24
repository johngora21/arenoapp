import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:latlong2/latlong.dart' as latlng2;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'change_password_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CustomerProfilePage extends StatefulWidget {
  const CustomerProfilePage({Key? key}) : super(key: key);

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  // Dummy user and partner status
  bool hasBusiness = false;
  bool isBusinessRegistered = false;
  final _personalFormKey = GlobalKey<FormState>();
  bool isEditingPersonal = false;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? error;
  String name = '';
  String email = '';
  String phone = '';
  String location = '';
  String businessAddress = '-';
  bool isFetchingBusinessAddress = false;
  String? photoUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchBusinessAddressFromCoords() async {
    if (userData == null || userData?['businessLocation'] == null) return;
    final loc = userData?['businessLocation'] as String;
    if (!loc.contains('Lat:')) return;
    try {
      final parts = loc.split(',');
      final lat = double.parse(parts[0].split(':')[1].trim());
      final lng = double.parse(parts[1].split(':')[1].trim());
      setState(() { isFetchingBusinessAddress = true; });
      final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng');
      final response = await http.get(url, headers: {'User-Agent': 'arenoapp/1.0'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          businessAddress = data['display_name'] ?? '-';
          isFetchingBusinessAddress = false;
        });
      } else {
        setState(() { businessAddress = '-'; isFetchingBusinessAddress = false; });
      }
    } catch (e) {
      setState(() { businessAddress = '-'; isFetchingBusinessAddress = false; });
    }
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        error = 'Not logged in.';
        isLoading = false;
      });
      return;
    }
    final doc = await FirebaseFirestore.instance.collection('customers').doc(user.uid).get();
    if (!doc.exists) {
      setState(() {
        error = 'User not found.';
        isLoading = false;
      });
      return;
    }
    setState(() {
      userData = doc.data();
      print('Fetched userData: ' + userData.toString());
      var n = (userData?['name'] ?? '').toString();
      name = n.isNotEmpty ? n : '-';
      var e = (userData?['email'] ?? '').toString();
      email = e.isNotEmpty ? e : '-';
      var p = (userData?['phone'] ?? '').toString();
      phone = p.isNotEmpty ? p : '-';
      var l = (userData?['location'] ?? '').toString();
      location = l.isNotEmpty ? l : '-';
      photoUrl = userData?['photoUrl'] as String?;
      isLoading = false;
    });
    await _fetchBusinessAddressFromCoords();
  }

  Future<void> _pickAndUploadProfilePhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final ref = FirebaseStorage.instance.ref().child('profile_photos/${user.uid}.jpg');
    await ref.putData(await picked.readAsBytes());
    final url = await ref.getDownloadURL();
    await FirebaseFirestore.instance.collection('customers').doc(user.uid).update({'photoUrl': url});
    setState(() {
      photoUrl = url;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile photo updated!')));
  }

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
                    backgroundColor: AppTheme.successGreen,
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
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile'), backgroundColor: AppTheme.successGreen),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile'), backgroundColor: AppTheme.successGreen),
        body: Center(child: Text(error!, style: const TextStyle(color: Colors.red))),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.successGreen,
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
                    backgroundImage: (photoUrl != null && photoUrl!.isNotEmpty)
                        ? NetworkImage(photoUrl!)
                        : null,
                    child: (photoUrl == null || photoUrl!.isEmpty)
                        ? Icon(Icons.person, size: 48, color: AppTheme.slate400)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickAndUploadProfilePhoto,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                        child: Icon(Icons.edit, size: 18, color: AppTheme.successGreen),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: isEditingPersonal ? AppTheme.successGreen : AppTheme.slate200),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => setState(() => isEditingPersonal = true),
                  child: const Text('Edit Profile'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !isEditingPersonal ? AppTheme.successGreen : AppTheme.slate200,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => setState(() => isEditingPersonal = false),
                  child: Text(
                    'View Profile',
                    style: TextStyle(
                      color: isEditingPersonal ? AppTheme.successGreen : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (!isEditingPersonal) ...[
              if (name == '-' && email == '-' && phone == '-' && location == '-')
                const Text('No profile data found.')
              else
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Personal Information', style: AppTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.slate900)),
                      const SizedBox(height: 16),
                      _profileField('Full Name', name),
                      _profileField('Email', email),
                      _profileField('Phone', phone),
                      _profileField('Location', location),
                    ],
                  ),
                ),
              ),
              if ((userData?['businessName'] ?? '').toString().isNotEmpty || (userData?['businessType'] ?? '').toString().isNotEmpty) ...[
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Business Details', style: AppTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.slate900)),
                        const SizedBox(height: 16),
                        _profileField('Business Name', userData?['businessName']?.toString() ?? '-'),
                        _profileField('Business Type', userData?['businessType']?.toString() ?? '-'),
                        _profileField('Business Address', isFetchingBusinessAddress ? 'Loading address...' : businessAddress),
                        _profileField('Contact', userData?['businessContact']?.toString() ?? '-'),
                        _profileField('TIN Number', userData?['tinNumber']?.toString() ?? '-'),
                      ],
                    ),
                  ),
                ),
              ],
              if ((userData?['paymentType'] ?? '').toString().isNotEmpty || (userData?['paymentProvider'] ?? '').toString().isNotEmpty) ...[
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Payment Methods', style: AppTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.slate900)),
                      const SizedBox(height: 16),
                        _profileField('Payment Type', userData?['paymentType']?.toString() ?? '-'),
                        _profileField('Provider', userData?['paymentProvider']?.toString() ?? '-'),
                        _profileField('Account Number', userData?['accountNumber']?.toString() ?? '-'),
                        _profileField('Account Name', userData?['accountName']?.toString() ?? '-'),
                    ],
                    ),
                  ),
                ),
              ],
            ] else ...[
              // EDIT MODE: All details as input fields
              Text('Personal Information', style: AppTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.slate900)),
              const SizedBox(height: 12),
              Form(
                key: _personalFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      initialValue: name,
                      decoration: _inputDecoration('Full Name', 'Enter your name'),
                      validator: (v) => v == null || v.isEmpty ? 'Enter your name' : null,
                      onChanged: (v) => setState(() => name = v),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: email,
                      decoration: _inputDecoration('Email', 'Enter your email'),
                      validator: (v) => v == null || v.isEmpty ? 'Enter your email' : null,
                      onChanged: (v) => setState(() => email = v),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: phone,
                      decoration: _inputDecoration('Phone', 'Enter your phone'),
                      validator: (v) => v == null || v.isEmpty ? 'Enter your phone' : null,
                      onChanged: (v) => setState(() => phone = v),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: location,
                      decoration: _inputDecoration('Location', 'Enter your location'),
                      validator: (v) => v == null || v.isEmpty ? 'Enter your location' : null,
                      onChanged: (v) => setState(() => location = v),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.successGreen,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () async {
                              if (_personalFormKey.currentState!.validate()) {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  await FirebaseFirestore.instance.collection('customers').doc(user.uid).update({
                                    'name': name,
                                    'email': email,
                                    'phone': phone,
                                    'location': location,
                                  });
                                  await _fetchUserData();
                                setState(() => isEditingPersonal = false);
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Personal info saved!')),
                                );
                              }
                            },
                            child: const Text('Save'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppTheme.primaryOrange),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
                            );
                          },
                          child: const Text('Update Password'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
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
                    activeColor: AppTheme.successGreen,
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
                    child: BusinessRegistrationForm(
                      onSaved: _fetchUserData,
                      initialBusinessName: userData?['businessName'] ?? '',
                      initialBusinessType: userData?['businessType'] ?? '',
                      initialBusinessAddress: userData?['businessAddress'] ?? '',
                      initialBusinessContact: userData?['businessContact'] ?? '',
                      initialTinNumber: userData?['tinNumber'] ?? '',
                      initialBusinessLocation: userData?['businessLocation'] ?? '',
                    ),
                  ),
                ),
                const SizedBox(height: 28),
              ],
              Text('Payment Methods', style: AppTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.slate900)),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: PaymentMethodForm(onSaved: _fetchUserData),
                ),
              ),
            ],
            const SizedBox(height: 28),
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
  final VoidCallback? onSaved;
  final String initialBusinessName;
  final String initialBusinessType;
  final String initialBusinessAddress;
  final String initialBusinessContact;
  final String initialTinNumber;
  final String initialBusinessLocation;
  const BusinessRegistrationForm({
    this.onSaved,
    this.initialBusinessName = '',
    this.initialBusinessType = '',
    this.initialBusinessAddress = '',
    this.initialBusinessContact = '',
    this.initialTinNumber = '',
    this.initialBusinessLocation = '',
    Key? key,
  }) : super(key: key);
  @override
  State<BusinessRegistrationForm> createState() => _BusinessRegistrationFormState();
}

class _BusinessRegistrationFormState extends State<BusinessRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  late String businessName;
  late String businessType;
  late String businessAddress;
  String? licenseFileName;
  String? tinFileName;
  latlng2.LatLng? businessLocation;
  late String businessContact;
  late String tinNumber;
  bool isRegistered = false;

  @override
  void initState() {
    super.initState();
    businessName = widget.initialBusinessName;
    businessType = widget.initialBusinessType;
    businessAddress = widget.initialBusinessAddress;
    businessContact = widget.initialBusinessContact;
    tinNumber = widget.initialTinNumber;
    // Parse businessLocation from string if available
    if (widget.initialBusinessLocation.isNotEmpty && widget.initialBusinessLocation.contains('Lat:')) {
      final parts = widget.initialBusinessLocation.split(',');
      try {
        final lat = double.parse(parts[0].split(':')[1].trim());
        final lng = double.parse(parts[1].split(':')[1].trim());
        businessLocation = latlng2.LatLng(lat, lng);
      } catch (_) {
        businessLocation = null;
      }
    }
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
              suffixIcon: Icon(Icons.location_on, color: AppTheme.successGreen),
            ),
            controller: TextEditingController(text: businessLocation != null ? 'Lat:  ${businessLocation!.latitude}, Lng:  ${businessLocation!.longitude}' : ''),
            validator: (v) => businessLocation == null ? 'Pick location' : null,
            onTap: () async {
              latlng2.LatLng? picked = await showDialog(
                context: context,
                builder: (context) => _MapPickerDialog(initial: businessLocation),
              );
              if (picked != null) {
                setState(() => businessLocation = picked);
              }
            },
          ),
          const SizedBox(height: 12),
          // TIN number field (actual number)
          TextFormField(
            initialValue: tinNumber,
            decoration: _inputDecoration('TIN Number', 'Enter TIN number'),
            validator: (v) => v == null || v.isEmpty ? 'Enter TIN number' : null,
            onChanged: (v) => setState(() => tinNumber = v),
          ),
          const SizedBox(height: 12),
          // TIN certificate upload (file name only, not shown in view)
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
              leading: const Icon(Icons.insert_drive_file, color: AppTheme.successGreen),
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
              leading: const Icon(Icons.insert_drive_file, color: AppTheme.successGreen),
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
              backgroundColor: AppTheme.successGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await FirebaseFirestore.instance.collection('customers').doc(user.uid).update({
                    'businessName': businessName,
                    'businessType': businessType,
                    'businessAddress': businessAddress,
                    'businessContact': businessContact,
                    'tinNumber': tinNumber, // Save the actual number
                    'tinCertificateFile': tinFileName ?? '', // Save the file name separately
                    'license': licenseFileName ?? '',
                    'businessLocation': businessLocation != null ? 'Lat: ${businessLocation!.latitude}, Lng: ${businessLocation!.longitude}' : '',
                  });
                }
                setState(() => isRegistered = true);
                if (widget.onSaved != null) widget.onSaved!();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Business registered!')),
                );
                Navigator.of(context).pop();
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
  final VoidCallback? onSaved;
  const PaymentMethodForm({this.onSaved, Key? key}) : super(key: key);
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
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await FirebaseFirestore.instance.collection('customers').doc(user.uid).update({
                    'paymentType': paymentType,
                    'paymentProvider': provider,
                    'accountNumber': accountNumber,
                    'accountName': accountName,
                  });
                }
                if (widget.onSaved != null) widget.onSaved!();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment method saved!')),
                );
                Navigator.of(context).pop();
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
  final latlng2.LatLng? initial;
  const _MapPickerDialog({this.initial});
  @override
  State<_MapPickerDialog> createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<_MapPickerDialog> {
  late latlng2.LatLng _selected;
  @override
  void initState() {
    super.initState();
    _selected = widget.initial ?? latlng2.LatLng(-6.7924, 39.2083); // Default Dar es Salaam
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

Widget _profileField(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.bodySmall?.copyWith(color: AppTheme.slate500, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value, style: AppTheme.bodyMedium?.copyWith(color: AppTheme.slate900, fontWeight: FontWeight.w600)),
      ],
    ),
  );
} 