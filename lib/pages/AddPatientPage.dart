import 'package:flutter/material.dart';

class AddPatientPage extends StatefulWidget {
  final String patientId;
  final Map<String, dynamic>? initialData;
  const AddPatientPage({Key? key, required this.patientId, this.initialData})
    : super(key: key);

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers for form fields
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _gender = '--';
  String _ethnicity = '--';
  final _formKey = GlobalKey<FormState>();
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    if (widget.initialData != null) {
      final d = widget.initialData!;
      _lastNameController.text = d['lastName'] ?? '';
      _firstNameController.text = d['firstName'] ?? '';
      _ageController.text = d['age'] ?? '';
      _birthDateController.text = d['birthDate'] ?? '';
      _heightController.text = d['height'] ?? '';
      _weightController.text = d['weight'] ?? '';
      _addressController.text = d['address'] ?? '';
      _phoneController.text = d['phone'] ?? '';
      _emailController.text = d['email'] ?? '';
      _gender = d['gender'] ?? '--';
      _ethnicity = d['ethnicity'] ?? '--';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _ageController.dispose();
    _birthDateController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onOkPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      final patientData = {
        'id': widget.patientId,
        'lastName': _lastNameController.text,
        'firstName': _firstNameController.text,
        'age': _ageController.text,
        'birthDate': _birthDateController.text,
        'height': _heightController.text,
        'weight': _weightController.text,
        'address': _addressController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'gender': _gender,
        'ethnicity': _ethnicity,
      };
      Navigator.of(context).pop(patientData);
    } else {
      setState(() {
        _showError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color blue = const Color(0xFF1565C0);
    final Color bg = const Color(0xFFE3E0F3);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 800;

    return Scaffold(
      backgroundColor: bg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Container(
              width: isSmallScreen ? size.width - 32 : 800,
              margin: EdgeInsets.symmetric(
                vertical: isSmallScreen ? 16 : 40,
                horizontal: isSmallScreen ? 16 : 0,
              ),
              padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  // Watermark logo on the left
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Opacity(
                      opacity: 0.08,
                      child: Image.asset(
                        'assets/respirit.png',
                        height: 400,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                  // Main content
                  Padding(
                    padding: const EdgeInsets.only(left: 80),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const RespiritLogo(),
                          TabBar(
                            controller: _tabController,
                            labelColor: blue,
                            unselectedLabelColor: Colors.black87,
                            indicatorColor: blue,
                            indicatorWeight: 3,
                            labelStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            tabs: const [
                              Tab(text: 'General'),
                              Tab(text: 'Smoking History'),
                              Tab(text: 'History'),
                              Tab(text: 'Environment'),
                              Tab(text: 'Comment'),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _GeneralTab(
                                  blue: blue,
                                  patientId: widget.patientId,
                                  lastNameController: _lastNameController,
                                  firstNameController: _firstNameController,
                                  ageController: _ageController,
                                  birthDateController: _birthDateController,
                                  heightController: _heightController,
                                  weightController: _weightController,
                                  addressController: _addressController,
                                  phoneController: _phoneController,
                                  emailController: _emailController,
                                  gender: _gender,
                                  ethnicity: _ethnicity,
                                  onGenderChanged:
                                      (val) =>
                                          setState(() => _gender = val ?? '--'),
                                  onEthnicityChanged:
                                      (val) => setState(
                                        () => _ethnicity = val ?? '--',
                                      ),
                                ),
                                _SmokingHistoryTab(blue: blue),
                                Center(
                                  child: Text(
                                    'History',
                                    style: TextStyle(color: blue, fontSize: 16),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    'Environment',
                                    style: TextStyle(color: blue, fontSize: 16),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    'Comment',
                                    style: TextStyle(color: blue, fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: isSmallScreen ? 100 : 120,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    textStyle: const TextStyle(fontSize: 14),
                                  ),
                                  onPressed: _onOkPressed,
                                  child: const Text('Ok'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: isSmallScreen ? 100 : 120,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: blue,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    textStyle: const TextStyle(fontSize: 14),
                                    side: BorderSide(color: blue, width: 1.5),
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text(
                                '*',
                                style: TextStyle(color: Colors.red),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'required',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          if (_showError)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Please fill all required fields.',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 8,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1565C0)),
                label: const Text(
                  'Return',
                  style: TextStyle(
                    color: Color(0xFF1565C0),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1565C0),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GeneralTab extends StatelessWidget {
  final Color blue;
  final String patientId;
  final TextEditingController lastNameController;
  final TextEditingController firstNameController;
  final TextEditingController ageController;
  final TextEditingController birthDateController;
  final TextEditingController heightController;
  final TextEditingController weightController;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final String gender;
  final String ethnicity;
  final ValueChanged<String?> onGenderChanged;
  final ValueChanged<String?> onEthnicityChanged;
  const _GeneralTab({
    required this.blue,
    required this.patientId,
    required this.lastNameController,
    required this.firstNameController,
    required this.ageController,
    required this.birthDateController,
    required this.heightController,
    required this.weightController,
    required this.addressController,
    required this.phoneController,
    required this.emailController,
    required this.gender,
    required this.ethnicity,
    required this.onGenderChanged,
    required this.onEthnicityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 800;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FormRow(
              label: 'Patient ID',
              required: true,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: TextEditingController(text: patientId),
                      readOnly: true,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            _FormRow(
              label: 'Last Name',
              child: _FormInput(
                controller: lastNameController,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
            ),
            _FormRow(
              label: 'First Name',
              child: _FormInput(
                controller: firstNameController,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
            ),
            _FormRow(
              label: 'Gender',
              required: true,
              child: _FormDropdown(
                items: const ['--', 'Male', 'Female', 'Other'],
                value: gender,
                onChanged: onGenderChanged,
                validator: (v) => (v == null || v == '--') ? 'Required' : null,
              ),
            ),
            _FormRow(
              label: 'Ethnicity',
              required: true,
              child: _FormDropdown(
                items: const ['--', 'Asian', 'Black', 'White', 'Other'],
                value: ethnicity,
                onChanged: onEthnicityChanged,
                validator: (v) => (v == null || v == '--') ? 'Required' : null,
              ),
            ),
            _FormRow(
              label: 'Age',
              required: true,
              child: _FormInput(
                width: 80,
                controller: ageController,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
            ),
            _FormRow(
              label: 'Height',
              required: true,
              child: Row(
                children: [
                  _FormInput(width: 80, controller: heightController),
                  const SizedBox(width: 8),
                  const Text('cm', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            _FormRow(
              label: 'Weight',
              child: Row(
                children: [
                  _FormInput(width: 80, controller: weightController),
                  const SizedBox(width: 8),
                  const Text('kg', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            _FormRow(
              label: 'Address',
              child: _FormInput(controller: addressController),
            ),
            _FormRow(
              label: 'Phone',
              child: _FormInput(controller: phoneController),
            ),
            _FormRow(
              label: 'Email',
              child: _FormInput(controller: emailController),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmokingHistoryTab extends StatelessWidget {
  final Color blue;
  const _SmokingHistoryTab({required this.blue});
  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 800;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FormRow(
              label: 'Smoker',
              child: _FormDropdown(items: const ['--', 'Yes', 'No']),
            ),
            _FormRow(
              label: 'Intensity',
              child: Row(
                children: [
                  _FormInput(width: 100),
                  const SizedBox(width: 8),
                  const Text(
                    'Cigarette(s) per Day',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            _FormRow(
              label: 'Years Smoking',
              child: Row(
                children: [
                  _FormInput(width: 80),
                  const SizedBox(width: 8),
                  const Text('Years', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormRow extends StatelessWidget {
  final String label;
  final Widget child;
  final bool required;

  const _FormRow({
    required this.label,
    required this.child,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 800;

    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isSmallScreen ? 100 : 120,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (required)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text('*', style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _FormInput extends StatelessWidget {
  final double? width;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  const _FormInput({this.width, this.controller, this.validator});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        style: const TextStyle(fontSize: 14),
        validator: validator,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }
}

class _FormDropdown extends StatelessWidget {
  final List<String> items;
  final String? value;
  final ValueChanged<String?>? onChanged;
  final String? Function(String?)? validator;
  const _FormDropdown({
    required this.items,
    this.value,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value ?? items.first,
      items:
          items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}

class RespiritLogo extends StatelessWidget {
  final double height;
  const RespiritLogo({this.height = 56, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Image.asset(
        'assets/respirit.png',
        height: height,
        fit: BoxFit.contain,
      ),
    );
  }
}
