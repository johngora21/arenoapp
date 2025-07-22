import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'agent_main_shell.dart';

class AgentProfilePage extends StatefulWidget {
  const AgentProfilePage({Key? key}) : super(key: key);

  @override
  State<AgentProfilePage> createState() => _AgentProfilePageState();
}

class _AgentProfilePageState extends State<AgentProfilePage> {
  final _personalFormKey = GlobalKey<FormState>();
  String name = 'John Agent';
  String email = 'agent@email.com';
  String phone = '+255 700 000 000';
  String location = 'Arusha';
  bool isEditingPersonal = false;

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
        title: const Text('Profile'),
        backgroundColor: AppTheme.primaryDarkBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: isEditingPersonal ? AppTheme.primaryDarkBlue : AppTheme.slate200),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => setState(() => isEditingPersonal = true),
                  child: const Text('Edit Profile'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !isEditingPersonal ? AppTheme.primaryDarkBlue : AppTheme.slate200,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => setState(() => isEditingPersonal = false),
                  child: Text(
                    'View Profile',
                    style: TextStyle(
                      color: isEditingPersonal ? AppTheme.primaryDarkBlue : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (!isEditingPersonal) ...[
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
                      Text('No payment method on file', style: AppTheme.bodyMedium?.copyWith(color: AppTheme.slate900)),
                    ],
                  ),
                ),
              ),
            ] else ...[
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
                              backgroundColor: AppTheme.primaryDarkBlue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              if (_personalFormKey.currentState!.validate()) {
                                setState(() => isEditingPersonal = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Personal info saved!')),
                                );
                              }
                            },
                            child: const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Payment Details Section (edit mode)
              Text('Payment Details', style: AppTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.slate900)),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AgentPaymentMethodForm(),
                ),
              ),
              const SizedBox(height: 28),
              // Change Password (edit mode only)
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
          ],
        ),
      ),
      // No drawer here, just a back arrow
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
}

// Add the AgentPaymentMethodForm widget below (copied from customer profile)
class AgentPaymentMethodForm extends StatefulWidget {
  @override
  State<AgentPaymentMethodForm> createState() => _AgentPaymentMethodFormState();
}

class _AgentPaymentMethodFormState extends State<AgentPaymentMethodForm> {
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